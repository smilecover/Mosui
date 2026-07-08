#include "MosMqttManager.h"
#include "MosMqttManager_p.h"

#include <QAtomicInt>
#include <QEventLoop>
#include <QMetaObject>
#include <QMqttClient>
#include <QMqttSubscription>
#include <QMqttTopicFilter>
#include <QMqttTopicName>
#include <QPointer>
#include <QQmlEngine>
#include <QSslCertificate>
#include <QSslConfiguration>
#include <QSslSocket>
#include <QThread>
#include <QTimer>

#include <algorithm>
#include <functional>
#include <memory>
#include <optional>

namespace {

constexpr int MqttOperationTimeoutMs = 5000;
constexpr int MqttShutdownTimeoutMs = 5000;
constexpr int MaxReconnectDelayMs = 60000;

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

void setState(MosMqttManager *q, MosMqttManagerPrivate *d, MosMqttManager::State state)
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
    Q_OBJECT

public:
    struct OperationResult {
        bool ok { false };
        QString error;
        int messageId { -1 };
    };

    using StateCallback = std::function<void(bool, MosMqttManager::State)>;
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
        reconnectTimer_ = new QTimer(this);
        reconnectTimer_->setSingleShot(true);
        QObject::connect(reconnectTimer_, &QTimer::timeout, this, &MosMqttWorker::attemptReconnect);
    }

    ~MosMqttWorker() override
    {
        intentionalDisconnect_ = true;
        disconnectFromHost();
    }

    OperationResult connectToHost(const QString &host,
                                  int port,
                                  const QString &clientId,
                                  const QString &username,
                                  const QString &password,
                                  int keepAlive,
                                  bool autoReconnect,
                                  int reconnectIntervalMs,
                                  bool sslEnabled,
                                  const QString &sslCaCertPath,
                                  bool sslPeerVerify,
                                  const QString &willTopic,
                                  const QString &willMessage,
                                  int willQos,
                                  bool willRetain)
    {
        OperationResult result;

        if (!client_) {
            client_ = new QMqttClient(this);
            setupClientConnections();
        }

        // 检查当前状态：已连接则直接返回，连接中则拒绝
        if (client_->state() == QMqttClient::Connected) {
            result.ok = true;
            return result;
        }
        if (client_->state() == QMqttClient::Connecting) {
            result.error = tr("Already connecting, please wait or disconnect first.");
            return result;
        }

        // 存储连接参数，用于重连
        autoReconnect_ = autoReconnect;
        reconnectIntervalMs_ = std::max(1000, reconnectIntervalMs);
        savedHost_ = host;
        savedPort_ = port;
        savedClientId_ = clientId;
        savedUsername_ = username;
        savedPassword_ = password;
        savedKeepAlive_ = keepAlive;
        sslEnabled_ = sslEnabled;
        sslCaCertPath_ = sslCaCertPath;
        sslPeerVerify_ = sslPeerVerify;
        savedWillTopic_ = willTopic;
        savedWillMessage_ = willMessage;
        savedWillQos_ = willQos;
        savedWillRetain_ = willRetain;
        intentionalDisconnect_ = false;
        reconnectAttempt_ = 0;

        client_->setHostname(host);
        client_->setPort(static_cast<quint16>(port));
        client_->setClientId(clientId);
        client_->setUsername(username);
        client_->setPassword(password);
        client_->setKeepAlive(static_cast<quint16>(keepAlive));
        client_->setAutoKeepAlive(true);

        // 设置遗愿消息 (Will Message)
        if (!willTopic.isEmpty()) {
            client_->setWillTopic(willTopic);
            client_->setWillMessage(willMessage.toUtf8());
            client_->setWillQoS(static_cast<quint8>(willQos));
            client_->setWillRetain(willRetain);
        }

        if (sslEnabled_) {
            QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
            if (!sslCaCertPath_.isEmpty()) {
                QList<QSslCertificate> certs = QSslCertificate::fromPath(sslCaCertPath_);
                if (certs.isEmpty()) {
                    // 证书加载失败，通过 error 信号报告
                    const QString errMsg = tr("Failed to load CA certificate from: %1").arg(sslCaCertPath_);
                    result.error = errMsg;
                    errorCallback_(errMsg);
                    return result;
                }
                sslConfig.setCaCertificates(certs);
            }
            if (!sslPeerVerify_) {
                sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
            }
            client_->connectToHostEncrypted(sslConfig);
        } else {
            client_->connectToHost();
        }

        result.ok = true;
        return result;
    }

    OperationResult disconnectFromHost()
    {
        OperationResult result;
        intentionalDisconnect_ = true;
        reconnectTimer_->stop();
        reconnectAttempt_ = 0;
        if (client_ && client_->state() != QMqttClient::Disconnected) {
            client_->disconnectFromHost();
        }
        subscriptions_.clear();
        result.ok = true;
        return result;
    }

    // 超时时取消挂起的连接操作，防止底层 QMqttClient 继续尝试连接
    void cancelPendingConnection()
    {
        if (client_ && client_->state() != QMqttClient::Disconnected) {
            client_->disconnectFromHost();
        }
    }

    // 允许发送空消息。
    // 空消息在 MQTT 协议中是合法的，常用于清除 retained 消息
    // (发送空 payload 到同一主题即可清除)。
    OperationResult publish(const QString &topic, const QByteArray &data, int qos, bool retain)
    {
        OperationResult result;
        if (!client_ || client_->state() != QMqttClient::Connected) {
            result.error = tr("MQTT client is not connected.");
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

        // 存储主题及其 QOS，用于断线重连后恢复
        subscriptions_.insert(topic, qos);
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
        subscriptions_.remove(topic);
        result.ok = true;
        return result;
    }

    QStringList currentSubscriptions() const
    {
        QStringList subs = subscriptions_.keys();
        subs.sort();
        return subs;
    }

private:
    void setupClientConnections()
    {
        QObject::connect(client_, &QMqttClient::connected, this, [this]() {
            reconnectAttempt_ = 0;
            // 重连后使用存储的 QOS 值重新订阅所有主题
            // 注意：subscriptions_ 可能在断线期间通过 unsubscribe 被移除，
            // 被移除的主题不会被重新订阅。Broker 端的变化客户端无法感知，
            // 这里选择恢复客户端记录的订阅状态。
            QHashIterator<QString, int> it(subscriptions_);
            while (it.hasNext()) {
                it.next();
                client_->subscribe(QMqttTopicFilter(it.key()), static_cast<quint8>(it.value()));
            }
            stateCallback_(true, MosMqttManager::Connected);
        });

        QObject::connect(client_, &QMqttClient::disconnected, this, [this]() {
            const bool wasIntentional = intentionalDisconnect_;
            intentionalDisconnect_ = false;

            if (!wasIntentional && autoReconnect_) {
                // 意外断连 + 启用自动重连: 保留 QHash 订阅列表，启动指数退避重连
                scheduleReconnect();
            } else {
                // 主动断连或未启用重连: 清除订阅
                subscriptions_.clear();
            }

            stateCallback_(false, MosMqttManager::Disconnected);
        });

        QObject::connect(client_, &QMqttClient::stateChanged, this, [this](QMqttClient::ClientState clientState) {
            MosMqttManager::State s;
            switch (clientState) {
            case QMqttClient::Connected:
                s = MosMqttManager::Connected;
                break;
            case QMqttClient::Connecting:
                s = MosMqttManager::Connecting;
                break;
            default:
                s = MosMqttManager::Disconnected;
                break;
            }
            stateCallback_(clientState == QMqttClient::Connected, s);
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

    // 指数退避重连调度: delay = min(baseInterval * 2^attempt, MaxReconnectDelayMs)
    void scheduleReconnect()
    {
        if (!autoReconnect_)
            return;

        const int delay = std::min(reconnectIntervalMs_ * (1 << reconnectAttempt_), MaxReconnectDelayMs);
        reconnectAttempt_++;
        reconnectTimer_->start(delay);
    }

    void attemptReconnect()
    {
        if (!client_ || !autoReconnect_)
            return;

        client_->setHostname(savedHost_);
        client_->setPort(static_cast<quint16>(savedPort_));
        client_->setClientId(savedClientId_);
        client_->setUsername(savedUsername_);
        client_->setPassword(savedPassword_);
        client_->setKeepAlive(static_cast<quint16>(savedKeepAlive_));
        client_->setAutoKeepAlive(true);

        // 恢复遗愿消息
        if (!savedWillTopic_.isEmpty()) {
            client_->setWillTopic(savedWillTopic_);
            client_->setWillMessage(savedWillMessage_.toUtf8());
            client_->setWillQoS(static_cast<quint8>(savedWillQos_));
            client_->setWillRetain(savedWillRetain_);
        }

        if (sslEnabled_) {
            QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
            if (!sslCaCertPath_.isEmpty()) {
                QList<QSslCertificate> certs = QSslCertificate::fromPath(sslCaCertPath_);
                if (certs.isEmpty()) {
                    const QString errMsg = tr("Reconnect: failed to load CA certificate from: %1").arg(sslCaCertPath_);
                    errorCallback_(errMsg);
                    // 证书加载失败，安排下一次重连尝试
                    scheduleReconnect();
                    return;
                }
                sslConfig.setCaCertificates(certs);
            }
            if (!sslPeerVerify_) {
                sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
            }
            client_->connectToHostEncrypted(sslConfig);
        } else {
            client_->connectToHost();
        }
    }

    QMqttClient *client_ { nullptr };
    // 订阅主题 → QOS 映射
    QHash<QString, int> subscriptions_;
    QTimer *reconnectTimer_ { nullptr };
    StateCallback stateCallback_;
    MessageCallback messageCallback_;
    PublishedCallback publishedCallback_;
    ErrorCallback errorCallback_;

    // 自动重连
    bool autoReconnect_ { false };
    int reconnectIntervalMs_ { 5000 };
    int reconnectAttempt_ { 0 };
    bool intentionalDisconnect_ { false };
    QString savedHost_;
    int savedPort_ { 1883 };
    QString savedClientId_;
    QString savedUsername_;
    QString savedPassword_;
    int savedKeepAlive_ { 60 };

    // SSL
    bool sslEnabled_ { false };
    QString sslCaCertPath_;
    bool sslPeerVerify_ { true };

    // 遗愿消息
    QString savedWillTopic_;
    QString savedWillMessage_;
    int savedWillQos_ { 0 };
    bool savedWillRetain_ { false };
};

// 全局防重入锁，确保同一时间只有一个跨线程 invokeOperation 在执行。
// 注意：此锁依赖于 MosMqttManager 为单例（Singleton），
// 若未来移除单例模式，需改为实例成员变量以避免多实例间的竞争。
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
    QPointer<QEventLoop> loopGuard(&loop);

    QTimer timer;
    timer.setSingleShot(true);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    const bool posted = QMetaObject::invokeMethod(worker,
                                                  [state, loopGuard, function = std::forward<Function>(function)]() mutable {
        state->result = function();
        state->done = true;
        if (loopGuard) {
            QMetaObject::invokeMethod(loopGuard.data(), &QEventLoop::quit, Qt::QueuedConnection);
        }
    }, Qt::QueuedConnection);

    if (!posted) {
        g_operationInFlight.storeRelease(0);
        return std::nullopt;
    }

    timer.start(timeoutMs);
    loop.exec();

    g_operationInFlight.storeRelease(0);

    if (!state->done) {
        // 超时：尝试取消挂起的连接操作，避免底层 QMqttClient 继续尝试连接
        QMetaObject::invokeMethod(worker, [worker]() {
            if (worker)
                worker->cancelPendingConnection();
        }, Qt::QueuedConnection);
        return std::nullopt;
    }

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
        [this](bool connected, State state) {
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
    shutdown();
}

void MosMqttManager::shutdown()
{
    Q_D(MosMqttManager);

    if (d->m_shutdownStarted)
        return;
    d->m_shutdownStarted = true;

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

MosMqttManager::State MosMqttManager::state() const
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

int MosMqttManager::reconnectInterval() const
{
    Q_D(const MosMqttManager);
    return d->reconnectInterval;
}

bool MosMqttManager::sslEnabled() const
{
    Q_D(const MosMqttManager);
    return d->sslEnabled;
}

QString MosMqttManager::sslCaCertPath() const
{
    Q_D(const MosMqttManager);
    return d->sslCaCertPath;
}

bool MosMqttManager::sslPeerVerify() const
{
    Q_D(const MosMqttManager);
    return d->sslPeerVerify;
}

QString MosMqttManager::willTopic() const
{
    Q_D(const MosMqttManager);
    return d->willTopic;
}

QString MosMqttManager::willMessage() const
{
    Q_D(const MosMqttManager);
    return d->willMessage;
}

int MosMqttManager::willQos() const
{
    Q_D(const MosMqttManager);
    return d->willQos;
}

bool MosMqttManager::willRetain() const
{
    Q_D(const MosMqttManager);
    return d->willRetain;
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

void MosMqttManager::setReconnectInterval(int ms)
{
    Q_D(MosMqttManager);
    const int clamped = std::max(1000, ms);
    if (d->reconnectInterval == clamped)
        return;

    d->reconnectInterval = clamped;
    emit reconnectIntervalChanged();
}

void MosMqttManager::setSslEnabled(bool enabled)
{
    Q_D(MosMqttManager);
    if (d->sslEnabled == enabled)
        return;

    d->sslEnabled = enabled;
    emit sslEnabledChanged();
}

void MosMqttManager::setSslCaCertPath(const QString &path)
{
    Q_D(MosMqttManager);
    if (d->sslCaCertPath == path)
        return;

    d->sslCaCertPath = path;
    emit sslCaCertPathChanged();
}

void MosMqttManager::setSslPeerVerify(bool enabled)
{
    Q_D(MosMqttManager);
    if (d->sslPeerVerify == enabled)
        return;

    d->sslPeerVerify = enabled;
    emit sslPeerVerifyChanged();
}

void MosMqttManager::setWillTopic(const QString &topic)
{
    Q_D(MosMqttManager);
    if (d->willTopic == topic)
        return;

    d->willTopic = topic;
    emit willTopicChanged();
}

void MosMqttManager::setWillMessage(const QString &message)
{
    Q_D(MosMqttManager);
    if (d->willMessage == message)
        return;

    d->willMessage = message;
    emit willMessageChanged();
}

void MosMqttManager::setWillQos(int qos)
{
    Q_D(MosMqttManager);
    if (d->willQos == qos)
        return;

    d->willQos = qos;
    emit willQosChanged();
}

void MosMqttManager::setWillRetain(bool retain)
{
    Q_D(MosMqttManager);
    if (d->willRetain == retain)
        return;

    d->willRetain = retain;
    emit willRetainChanged();
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
                                         autoReconnect = d->autoReconnect,
                                         reconnectInterval = d->reconnectInterval,
                                         sslEnabled = d->sslEnabled,
                                         sslCaCertPath = d->sslCaCertPath,
                                         sslPeerVerify = d->sslPeerVerify,
                                         willTopic = d->willTopic,
                                         willMessage = d->willMessage,
                                         willQos = d->willQos,
                                         willRetain = d->willRetain]() {
        return worker->connectToHost(cleanHost, port, clientId, username, password,
                                     keepAlive, autoReconnect, reconnectInterval,
                                     sslEnabled, sslCaCertPath, sslPeerVerify,
                                     willTopic, willMessage, willQos, willRetain);
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
    setState(this, d, Disconnected);
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

    // 允许空消息: 在 MQTT 协议中，向某主题发布空 payload 是清除 retained 消息的标准方式
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

#include "MosMqttManager.moc"
