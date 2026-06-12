#include "MosMqttManager.h"
#include "MosMqttManager_p.h"

#include <QAtomicInt>
#include <QEventLoop>
#include <QMetaObject>
#include <QMqttClient>
#include <QMqttSubscription>
#include <QMqttTopicFilter>
#include <QMqttTopicName>
#include <QQmlEngine>
#include <QThread>
#include <QTimer>

#include <functional>
#include <memory>
#include <optional>

namespace {

constexpr int MqttOperationTimeoutMs = 5000;
constexpr int MqttShutdownTimeoutMs = 5000;

QString mqttErrorToString(QMqttClient::ClientError error)
{
    switch (error) {
    case QMqttClient::NoError:
        return QString();
    case QMqttClient::InvalidProtocolVersion:
        return QStringLiteral("Invalid protocol version");
    case QMqttClient::IdRejected:
        return QStringLiteral("Client ID rejected");
    case QMqttClient::ServerUnavailable:
        return QStringLiteral("Server unavailable");
    case QMqttClient::BadUsernameOrPassword:
        return QStringLiteral("Bad username or password");
    case QMqttClient::NotAuthorized:
        return QStringLiteral("Not authorized");
    case QMqttClient::TransportInvalid:
        return QStringLiteral("Transport invalid");
    case QMqttClient::ProtocolViolation:
        return QStringLiteral("Protocol violation");
    case QMqttClient::UnknownError:
        return QStringLiteral("Unknown error");
    case QMqttClient::Mqtt5SpecificError:
        return QStringLiteral("MQTT 5.0 specific error");
    default:
        return QStringLiteral("Unknown MQTT error");
    }
}

void setError(MosMqttManager *q, MosMqttManagerPrivate *d, const QString &message)
{
    if (d->errorString == message) {
        emit q->errorOccurred(message);
        return;
    }

    d->errorString = message;
    emit q->errorStringChanged();
    emit q->errorOccurred(message);
}

void setConnected(MosMqttManager *q, MosMqttManagerPrivate *d, bool connected)
{
    if (d->isConnected == connected)
        return;

    d->isConnected = connected;
    emit q->isConnectedChanged();
    if (connected)
        emit q->connected();
    else
        emit q->disconnected();
}

void setState(MosMqttManager *q, MosMqttManagerPrivate *d, int state)
{
    if (d->state == state)
        return;

    d->state = state;
    emit q->stateChanged();
}

void setSubscriptions(MosMqttManager *q, MosMqttManagerPrivate *d, const QStringList &subs)
{
    if (d->subscriptions == subs)
        return;

    d->subscriptions = subs;
    d->subscriptions.sort();
    emit q->subscriptionsChanged();
}

} // namespace

class MosMqttWorker : public QObject
{
public:
    struct OperationResult {
        bool ok { false };
        QString error;
        int messageId { -1 };
    };

    using StateCallback = std::function<void(bool, int)>;
    using MessageCallback = std::function<void(QString, QByteArray)>;
    using PublishedCallback = std::function<void(int)>;
    using ErrorCallback = std::function<void(QString)>;

    MosMqttWorker(StateCallback stateCallback,
                  MessageCallback messageCallback,
                  PublishedCallback publishedCallback,
                  ErrorCallback errorCallback)
        : stateCallback_(std::move(stateCallback)),
          messageCallback_(std::move(messageCallback)),
          publishedCallback_(std::move(publishedCallback)),
          errorCallback_(std::move(errorCallback))
    {
    }

    ~MosMqttWorker() override
    {
        disconnectFromHost();
    }

    OperationResult connectToHost(const QString &host,
                                  int port,
                                  const QString &clientId,
                                  const QString &username,
                                  const QString &password,
                                  int keepAlive,
                                  bool autoReconnect)
    {
        OperationResult result;

        if (!client_) {
            client_ = new QMqttClient(this);
            setupClientConnections();
        }

        if (client_->state() == QMqttClient::Connected)
            client_->disconnectFromHost();

        client_->setHostname(host);
        client_->setPort(static_cast<quint16>(port));
        client_->setClientId(clientId);
        client_->setUsername(username);
        client_->setPassword(password);
        client_->setKeepAlive(static_cast<quint16>(keepAlive));
        client_->setAutoKeepAlive(true);

        client_->connectToHost();
        result.ok = true;
        return result;
    }

    OperationResult disconnectFromHost()
    {
        OperationResult result;
        if (client_ && client_->state() != QMqttClient::Disconnected) {
            client_->disconnectFromHost();
        }
        subscriptions_.clear();
        result.ok = true;
        return result;
    }

    OperationResult publish(const QString &topic, const QByteArray &data, int qos, bool retain)
    {
        OperationResult result;
        if (!client_ || client_->state() != QMqttClient::Connected) {
            result.error = tr("MQTT client is not connected.");
            return result;
        }

        if (data.isEmpty()) {
            result.ok = true;
            return result;
        }

        const int id = client_->publish(QMqttTopicName(topic), data, static_cast<quint8>(qos), retain);
        result.ok = id >= 0;
        result.messageId = id;
        if (!result.ok)
            result.error = mqttErrorToString(client_->error());
        return result;
    }

    OperationResult subscribe(const QString &topic, int qos)
    {
        OperationResult result;
        if (!client_ || client_->state() != QMqttClient::Connected) {
            result.error = tr("MQTT client is not connected.");
            return result;
        }

        auto *subscription = client_->subscribe(QMqttTopicFilter(topic), static_cast<quint8>(qos));
        if (!subscription) {
            result.error = mqttErrorToString(client_->error());
            return result;
        }

        if (!subscriptions_.contains(topic))
            subscriptions_.append(topic);
        result.ok = true;
        return result;
    }

    OperationResult unsubscribe(const QString &topic)
    {
        OperationResult result;
        if (!client_ || client_->state() != QMqttClient::Connected) {
            result.error = tr("MQTT client is not connected.");
            return result;
        }

        client_->unsubscribe(QMqttTopicFilter(topic));
        subscriptions_.removeAll(topic);
        result.ok = true;
        return result;
    }

    QStringList currentSubscriptions() const
    {
        QStringList subs = subscriptions_;
        subs.sort();
        return subs;
    }

private:
    void setupClientConnections()
    {
        QObject::connect(client_, &QMqttClient::connected, this, [this]() {
            stateCallback_(true, static_cast<int>(client_->state()));
        });

        QObject::connect(client_, &QMqttClient::disconnected, this, [this]() {
            stateCallback_(false, static_cast<int>(client_->state()));
        });

        QObject::connect(client_, &QMqttClient::stateChanged, this, [this](QMqttClient::ClientState state) {
            const bool connected = (state == QMqttClient::Connected);
            stateCallback_(connected, static_cast<int>(state));
        });

        QObject::connect(client_, &QMqttClient::messageReceived, this,
                         [this](const QByteArray &message, const QMqttTopicName &topic) {
            messageCallback_(topic.name(), message);
        });

        QObject::connect(client_, &QMqttClient::messageSent, this, [this](qint32 id) {
            publishedCallback_(static_cast<int>(id));
        });

        QObject::connect(client_, &QMqttClient::errorChanged, this, [this](QMqttClient::ClientError error) {
            if (error != QMqttClient::NoError)
                errorCallback_(mqttErrorToString(error));
        });
    }

    QMqttClient *client_ { nullptr };
    QStringList subscriptions_;
    StateCallback stateCallback_;
    MessageCallback messageCallback_;
    PublishedCallback publishedCallback_;
    ErrorCallback errorCallback_;
};

// 防重入锁
static QAtomicInt g_operationInFlight { 0 };

template <typename Function>
std::optional<MosMqttWorker::OperationResult> invokeOperation(MosMqttWorker *worker,
                                                               int timeoutMs,
                                                               Function &&function)
{
    if (!worker)
        return std::nullopt;
    if (QThread::currentThread() == worker->thread())
        return function();

    if (!g_operationInFlight.testAndSetAcquire(0, 1))
        return std::nullopt;

    struct InvocationState {
        std::optional<MosMqttWorker::OperationResult> result;
        bool done { false };
    };

    auto state = std::make_shared<InvocationState>();
    QEventLoop loop;

    QTimer timer;
    timer.setSingleShot(true);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    const bool posted = QMetaObject::invokeMethod(worker,
                                                  [state, &loop, function = std::forward<Function>(function)]() mutable {
        state->result = function();
        state->done = true;
        QMetaObject::invokeMethod(&loop, &QEventLoop::quit, Qt::QueuedConnection);
    }, Qt::QueuedConnection);

    if (!posted) {
        g_operationInFlight.storeRelease(0);
        return std::nullopt;
    }

    timer.start(timeoutMs);
    loop.exec();

    g_operationInFlight.storeRelease(0);

    if (!state->done)
        return std::nullopt;

    return std::move(state->result);
}

MosMqttManager::MosMqttManager(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosMqttManagerPrivate(this))
{
    Q_D(MosMqttManager);

    d->mqttThread = new QThread(this);
    d->mqttThread->setObjectName(QStringLiteral("MosMqttThread"));
    d->worker = new MosMqttWorker(
        [this](bool connected, int state) {
            QMetaObject::invokeMethod(this, [this, connected, state]() {
                Q_D(MosMqttManager);
                setConnected(this, d, connected);
                setState(this, d, state);
                if (connected) {
                    setSubscriptions(this, d, d->worker ? d->worker->currentSubscriptions() : QStringList());
                }
            }, Qt::QueuedConnection);
        },
        [this](QString topic, QByteArray data) {
            QMetaObject::invokeMethod(this, [this, topic = std::move(topic), data = std::move(data)]() {
                const QString message = QString::fromUtf8(data);
                emit bytesReceived(topic, data);
                emit messageReceived(topic, message);
            }, Qt::QueuedConnection);
        },
        [this](int id) {
            QMetaObject::invokeMethod(this, [this, id]() {
                emit published(id);
            }, Qt::QueuedConnection);
        },
        [this](QString message) {
            QMetaObject::invokeMethod(this, [this, message = std::move(message)]() {
                Q_D(MosMqttManager);
                setError(this, d, message);
            }, Qt::QueuedConnection);
        });

    d->worker->moveToThread(d->mqttThread);
    connect(d->mqttThread, &QThread::finished, d->worker, &QObject::deleteLater);
    d->mqttThread->start();
}

MosMqttManager::~MosMqttManager()
{
    Q_D(MosMqttManager);

    if (d->worker)
        invokeOperation(d->worker, MqttShutdownTimeoutMs, [worker = d->worker]() {
            return worker->disconnectFromHost();
        });

    if (d->mqttThread) {
        d->mqttThread->quit();
        if (!d->mqttThread->wait(MqttShutdownTimeoutMs)) {
            d->mqttThread->terminate();
            d->mqttThread->wait();
        }
    }
}

MosMqttManager *MosMqttManager::instance()
{
    static MosMqttManager ins;
    return &ins;
}

MosMqttManager *MosMqttManager::create(QQmlEngine *, QJSEngine *)
{
    auto *manager = instance();
    QQmlEngine::setObjectOwnership(manager, QQmlEngine::CppOwnership);
    return manager;
}

QString MosMqttManager::host() const
{
    Q_D(const MosMqttManager);
    return d->host;
}

int MosMqttManager::port() const
{
    Q_D(const MosMqttManager);
    return d->port;
}

QString MosMqttManager::clientId() const
{
    Q_D(const MosMqttManager);
    return d->clientId;
}

QString MosMqttManager::username() const
{
    Q_D(const MosMqttManager);
    return d->username;
}

QString MosMqttManager::password() const
{
    Q_D(const MosMqttManager);
    return d->password;
}

bool MosMqttManager::isConnected() const
{
    Q_D(const MosMqttManager);
    return d->isConnected;
}

int MosMqttManager::state() const
{
    Q_D(const MosMqttManager);
    return d->state;
}

QString MosMqttManager::errorString() const
{
    Q_D(const MosMqttManager);
    return d->errorString;
}

QStringList MosMqttManager::subscriptions() const
{
    Q_D(const MosMqttManager);
    return d->subscriptions;
}

int MosMqttManager::keepAlive() const
{
    Q_D(const MosMqttManager);
    return d->keepAlive;
}

bool MosMqttManager::autoReconnect() const
{
    Q_D(const MosMqttManager);
    return d->autoReconnect;
}

void MosMqttManager::setHost(const QString &host)
{
    Q_D(MosMqttManager);
    if (d->host == host)
        return;

    d->host = host;
    emit hostChanged();
}

void MosMqttManager::setPort(int port)
{
    Q_D(MosMqttManager);
    if (d->port == port)
        return;

    d->port = port;
    emit portChanged();
}

void MosMqttManager::setClientId(const QString &clientId)
{
    Q_D(MosMqttManager);
    if (d->clientId == clientId)
        return;

    d->clientId = clientId;
    emit clientIdChanged();
}

void MosMqttManager::setUsername(const QString &username)
{
    Q_D(MosMqttManager);
    if (d->username == username)
        return;

    d->username = username;
    emit usernameChanged();
}

void MosMqttManager::setPassword(const QString &password)
{
    Q_D(MosMqttManager);
    if (d->password == password)
        return;

    d->password = password;
    emit passwordChanged();
}

void MosMqttManager::setKeepAlive(int keepAlive)
{
    Q_D(MosMqttManager);
    if (d->keepAlive == keepAlive)
        return;

    d->keepAlive = keepAlive;
    emit keepAliveChanged();
}

void MosMqttManager::setAutoReconnect(bool enabled)
{
    Q_D(MosMqttManager);
    if (d->autoReconnect == enabled)
        return;

    d->autoReconnect = enabled;
    emit autoReconnectChanged();
}

void MosMqttManager::connectToHost()
{
    Q_D(MosMqttManager);
    connectToHost(d->host, d->port);
}

void MosMqttManager::connectToHost(const QString &host, int port)
{
    Q_D(MosMqttManager);

    const QString cleanHost = host.trimmed();
    if (cleanHost.isEmpty()) {
        setError(this, d, tr("MQTT host is empty."));
        return;
    }

    if (port <= 0 || port > 65535) {
        setError(this, d, tr("MQTT port is invalid."));
        return;
    }

    d->host = cleanHost;
    d->port = port;

    const auto result = invokeOperation(d->worker,
                                        MqttOperationTimeoutMs,
                                        [worker = d->worker,
                                         cleanHost,
                                         port,
                                         clientId = d->clientId,
                                         username = d->username,
                                         password = d->password,
                                         keepAlive = d->keepAlive,
                                         autoReconnect = d->autoReconnect]() {
        return worker->connectToHost(cleanHost, port, clientId, username, password, keepAlive, autoReconnect);
    });
    if (!result) {
        setError(this, d, tr("MQTT operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    clearError();
}

void MosMqttManager::disconnectFromHost()
{
    Q_D(MosMqttManager);

    const auto result = invokeOperation(d->worker,
                                        MqttOperationTimeoutMs,
                                        [worker = d->worker]() {
        return worker->disconnectFromHost();
    });
    if (!result) {
        setError(this, d, tr("MQTT operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    setConnected(this, d, false);
    setState(this, d, 0);
    setSubscriptions(this, d, {});
}

int MosMqttManager::publish(const QString &topic, const QString &message, int qos, bool retain)
{
    return publishBytes(topic, message.toUtf8(), qos, retain);
}

int MosMqttManager::publishBytes(const QString &topic, const QByteArray &data, int qos, bool retain)
{
    Q_D(MosMqttManager);

    const QString cleanTopic = topic.trimmed();
    if (cleanTopic.isEmpty()) {
        setError(this, d, tr("MQTT topic is empty."));
        return -1;
    }

    if (data.isEmpty()) {
        setError(this, d, tr("MQTT publish data is empty."));
        return -1;
    }

    const auto result = invokeOperation(d->worker,
                                        MqttOperationTimeoutMs,
                                        [worker = d->worker, cleanTopic, data, qos, retain]() {
        return worker->publish(cleanTopic, data, qos, retain);
    });
    if (!result) {
        setError(this, d, tr("MQTT operation timed out."));
        return -1;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return -1;
    }

    return result->messageId;
}

void MosMqttManager::subscribe(const QString &topic, int qos)
{
    Q_D(MosMqttManager);

    const QString cleanTopic = topic.trimmed();
    if (cleanTopic.isEmpty()) {
        setError(this, d, tr("MQTT topic is empty."));
        return;
    }

    const auto result = invokeOperation(d->worker,
                                        MqttOperationTimeoutMs,
                                        [worker = d->worker, cleanTopic, qos]() {
        return worker->subscribe(cleanTopic, qos);
    });
    if (!result) {
        setError(this, d, tr("MQTT operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    setSubscriptions(this, d, d->worker->currentSubscriptions());
    clearError();
}

void MosMqttManager::unsubscribe(const QString &topic)
{
    Q_D(MosMqttManager);

    const QString cleanTopic = topic.trimmed();
    if (cleanTopic.isEmpty()) {
        setError(this, d, tr("MQTT topic is empty."));
        return;
    }

    const auto result = invokeOperation(d->worker,
                                        MqttOperationTimeoutMs,
                                        [worker = d->worker, cleanTopic]() {
        return worker->unsubscribe(cleanTopic);
    });
    if (!result) {
        setError(this, d, tr("MQTT operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    setSubscriptions(this, d, d->worker->currentSubscriptions());
    clearError();
}

void MosMqttManager::clearError()
{
    Q_D(MosMqttManager);
    if (d->errorString.isEmpty())
        return;

    d->errorString.clear();
    emit errorStringChanged();
}
