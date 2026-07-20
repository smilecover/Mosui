#include "MosNetTcpManager.h"
#include "MosNetTcpManager_p.h"

#include <QAtomicInt>
#include <QEventLoop>
#include <QFile>
#include <QFileSystemWatcher>
#include <QHash>
#include <QMetaObject>
#include <QNetworkProxy>
#include <QPointer>
#include <QQmlEngine>
#include <QQueue>
#include <QRandomGenerator>
#include <QSet>
#include <QSslCertificate>
#include <QSslConfiguration>
#include <QSslKey>
#include <QSslSocket>
#include <QTcpServer>
#include <QTcpSocket>
#include <QThread>
#include <QTimer>
#include <QVariantMap>

#include <algorithm>
#include <functional>
#include <memory>
#include <optional>

namespace {

constexpr int TcpOperationTimeoutMs = 5000;
constexpr int TcpShutdownTimeoutMs = 10000; // P1: 延长到 10s，减少 terminate() 概率
constexpr int MaxReconnectDelayMs = 60000;
constexpr int MaxSendQueueSize = 256;

// P0: socket 指针转哈希 key（避免裸指针复用风险）
inline quintptr socketKey(const QTcpSocket *socket)
{
    return reinterpret_cast<quintptr>(socket);
}

// ---- 辅助函数 ----

QString toHexString(const QByteArray &data)
{
    return QString::fromLatin1(data.toHex(' ').toUpper());
}

void setError(MosNetTcpManager *q, MosNetTcpManagerPrivate *d, const QString &message)
{
    if (d->errorString == message) {
        emit q->errorOccurred(message);
        return;
    }

    d->errorString = message;
    emit q->errorStringChanged();
    emit q->errorOccurred(message);
}

void setConnected(MosNetTcpManager *q, MosNetTcpManagerPrivate *d, bool connected)
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

void setState(MosNetTcpManager *q, MosNetTcpManagerPrivate *d, MosNetTcpManager::State state)
{
    if (d->state == state)
        return;

    d->state = state;
    emit q->stateChanged();
}

bool setPeerList(MosNetTcpManagerPrivate *d, const QVariantList &peers)
{
    QStringList names;
    names.reserve(peers.size());
    for (const QVariant &v : peers) {
        const QVariantMap peer = v.toMap();
        const QString key = peer.value(QStringLiteral("peerKey")).toString();
        if (!key.isEmpty())
            names.push_back(key);
    }
    names.sort();

    if (d->peerNameList == names && d->peerInfoList == peers)
        return false;

    d->peerNameList = names;
    d->peerInfoList = peers;
    return true;
}

void emitConnectionsChanged(MosNetTcpManager *q)
{
    emit q->connectionsChanged();
}

QByteArray parseHexText(QString text, bool *ok)
{
    text = text.trimmed();
    text.replace(QStringLiteral("0x"), QString(), Qt::CaseInsensitive);
    text.replace(QLatin1Char(','), QLatin1Char(' '));
    text.replace(QLatin1Char(';'), QLatin1Char(' '));
    text.replace(QLatin1Char('\r'), QLatin1Char(' '));
    text.replace(QLatin1Char('\n'), QLatin1Char(' '));
    text.remove(QChar::Space);
    text.remove(QChar::Tabulation);

    if (text.isEmpty() || text.size() % 2 != 0) {
        *ok = false;
        return {};
    }

    const QByteArray hex = text.toLatin1();
    for (char c : hex) {
        const bool digit = c >= '0' && c <= '9';
        const bool lower = c >= 'a' && c <= 'f';
        const bool upper = c >= 'A' && c <= 'F';
        if (!digit && !lower && !upper) {
            *ok = false;
            return {};
        }
    }

    *ok = true;
    return QByteArray::fromHex(hex);
}

QString makePeerKey(const QString &address, int port)
{
    return QStringLiteral("%1:%2").arg(address).arg(port);
}

QString socketPeerKey(const QTcpSocket *socket)
{
    if (!socket)
        return {};
    return makePeerKey(socket->peerAddress().toString(), socket->peerPort());
}

QVariantMap socketPeerInfo(const QTcpSocket *socket, const QString &peerKey)
{
    QVariantMap info;
    info.insert(QStringLiteral("peerKey"), peerKey);
    info.insert(QStringLiteral("peerAddress"), socket->peerAddress().toString());
    info.insert(QStringLiteral("peerPort"), socket->peerPort());
    info.insert(QStringLiteral("localAddress"), socket->localAddress().toString());
    info.insert(QStringLiteral("localPort"), socket->localPort());
    info.insert(QStringLiteral("isConnected"),
                socket->state() == QAbstractSocket::ConnectedState);
    return info;
}

} // namespace

// =====================================================================
// MosNetTcpWorker — 运行在专用线程上的 TCP 工作器
// =====================================================================

class MosNetTcpWorker : public QObject
{
    Q_OBJECT

public:
    struct OperationResult {
        bool ok { false };
        QString error;
        bool connectionsChanged { false };
        QVariantList peerList;
    };

    // P0: per-worker 操作防重入锁
    QAtomicInt operationInFlight { 0 };

    // ---- 发送队列 (P0 partial write) ----

    struct PendingWrite {
        QByteArray data;
        qint64 offset { 0 };
    };

    // ---- 回调类型 ----
    // P1: text/hex 改为 optional，lazyDecode 时传 nullopt 避免空字符串拷贝

    using DataCallback = std::function<void(QString, QByteArray,
                                            std::optional<QString>,
                                            std::optional<QString>)>;
    using BytesCallback = std::function<void(const QString &, qint64)>;
    using StateCallback = std::function<void(QVariantList)>;
    using ErrorCallback = std::function<void(QString, QString, bool, QVariantList)>;

    MosNetTcpWorker(DataCallback dataCallback,
                    BytesCallback bytesCallback,
                    StateCallback stateCallback,
                    ErrorCallback errorCallback)
        : dataCallback_(std::move(dataCallback)),
          bytesCallback_(std::move(bytesCallback)),
          stateCallback_(std::move(stateCallback)),
          errorCallback_(std::move(errorCallback))
    {
        reconnectTimer_ = new QTimer(this);
        reconnectTimer_->setSingleShot(true);
        QObject::connect(reconnectTimer_, &QTimer::timeout,
                         this, &MosNetTcpWorker::attemptReconnect);
    }

    ~MosNetTcpWorker() override
    {
        stopAll();
    }

    // ---- 客户端模式 ----

    OperationResult connectToHost(const QString &host,
                                  int port,
                                  bool autoReconnect,
                                  int reconnectIntervalMs,
                                  bool sslEnabled,
                                  const QString &sslCaCertPath,
                                  const QString &sslLocalCertPath,
                                  const QString &sslPrivateKeyPath,
                                  bool sslPeerVerify,
                                  bool tcpNoDelay,
                                  int readBufferSize)
    {
        OperationResult result;

        if (server_ && server_->isListening()) {
            result.error = tr("Cannot connect in server mode. Stop the server first.");
            return result;
        }

        if (clientSocket_) {
            // ★ 修复：abort 所有非干净状态的 socket，避免复用脏 socket 导致
            //    Windows 底层报 "对于这个操作代理类型时无效的" 错误。
            const auto state = clientSocket_->state();
            if (state != QAbstractSocket::UnconnectedState) {
                intentionalDisconnect_ = true;
                clientSocket_->abort();
                intentionalDisconnect_ = false;
            }
        }

        autoReconnect_ = autoReconnect;
        reconnectIntervalMs_ = std::max(1000, reconnectIntervalMs);
        savedHost_ = host;
        savedPort_ = port;
        sslEnabled_ = sslEnabled;
        tcpNoDelay_ = tcpNoDelay;
        readBufferSize_ = std::max(1024, readBufferSize);
        reconnectAttempt_ = 0;
        mode_ = MosNetTcpManager::Client;

        if (sslCaCertPath_ != sslCaCertPath
            || sslLocalCertPath_ != sslLocalCertPath
            || sslPrivateKeyPath_ != sslPrivateKeyPath
            || sslPeerVerify_ != sslPeerVerify)
            sslConfigDirty_ = true;

        sslCaCertPath_ = sslCaCertPath;
        sslLocalCertPath_ = sslLocalCertPath;
        sslPrivateKeyPath_ = sslPrivateKeyPath;
        sslPeerVerify_ = sslPeerVerify;

        ensureClientSocket();
        applySocketOptions(clientSocket_.data());
        clientSocket_->setProxy(QNetworkProxy::NoProxy);  // ★ 防御系统代理干扰

        if (sslEnabled_) {
            QSslConfiguration sslConfig = buildSslConfiguration();
            if (sslConfig.isNull()) {
                result.error = tr("SSL configuration failed.");
                return result;
            }
            QSslSocket *sslSocket = qobject_cast<QSslSocket *>(clientSocket_.data());
            if (sslSocket) {
                sslSocket->setSslConfiguration(sslConfig);
                sslSocket->connectToHostEncrypted(savedHost_, static_cast<quint16>(savedPort_));
            }
        } else {
            clientSocket_->connectToHost(savedHost_, static_cast<quint16>(savedPort_));
        }

        result.ok = true;
        result.connectionsChanged = false;
        return result;
    }

    OperationResult disconnectFromHost()
    {
        OperationResult result;
        intentionalDisconnect_ = true;
        reconnectTimer_->stop();
        reconnectAttempt_ = 0;

        if (clientSocket_)
            pendingWrites_.remove(socketKey(clientSocket_.data()));

        if (clientSocket_
            && clientSocket_->state() != QAbstractSocket::UnconnectedState) {
            clientSocket_->disconnectFromHost();
        }

        result.ok = true;
        result.connectionsChanged = true;
        result.peerList = peerList();
        return result;
    }

    void cancelPendingConnection()
    {
        if (clientSocket_
            && clientSocket_->state() != QAbstractSocket::UnconnectedState
            && clientSocket_->state() != QAbstractSocket::ConnectedState) {
            clientSocket_->abort();
        }
    }

    // ---- 服务器模式 ----

    OperationResult startServer(int port,
                                int maxConnections,
                                bool sslEnabled,
                                const QString &sslCaCertPath,
                                const QString &sslLocalCertPath,
                                const QString &sslPrivateKeyPath,
                                bool sslPeerVerify,
                                bool tcpNoDelay,
                                int readBufferSize)
    {
        OperationResult result;

        if (clientSocket_
            && clientSocket_->state() != QAbstractSocket::UnconnectedState) {
            result.error = tr("Cannot start server while client is connected. Disconnect first.");
            return result;
        }
        if (reconnectTimer_->isActive()) {
            result.error = tr("Cannot start server during client auto-reconnect. Disable auto-reconnect first.");
            return result;
        }

        savedPort_ = port;
        sslEnabled_ = sslEnabled;
        tcpNoDelay_ = tcpNoDelay;
        readBufferSize_ = std::max(1024, readBufferSize);
        maxConnections_ = std::max(1, maxConnections);
        mode_ = MosNetTcpManager::Server;

        if (sslCaCertPath_ != sslCaCertPath
            || sslLocalCertPath_ != sslLocalCertPath
            || sslPrivateKeyPath_ != sslPrivateKeyPath
            || sslPeerVerify_ != sslPeerVerify)
            sslConfigDirty_ = true;

        sslCaCertPath_ = sslCaCertPath;
        sslLocalCertPath_ = sslLocalCertPath;
        sslPrivateKeyPath_ = sslPrivateKeyPath;
        sslPeerVerify_ = sslPeerVerify;

        if (!server_) {
            server_ = new QTcpServer(this);
            QObject::connect(server_, &QTcpServer::newConnection,
                             this, &MosNetTcpWorker::onNewConnection);
            QObject::connect(server_, &QTcpServer::acceptError,
                             this, &MosNetTcpWorker::onAcceptError);
        }

        if (sslEnabled_ && !sslLocalCertPath_.isEmpty()) {
            QSslConfiguration sslConfig = buildSslConfiguration();
            if (sslConfig.isNull()) {
                result.error = tr("SSL configuration failed.");
                return result;
            }
        }

        // P1: 启动 SSL 证书文件监控
        setupSslWatcher();

        const bool listening = server_->listen(QHostAddress::AnyIPv4, static_cast<quint16>(port));
        if (!listening) {
            result.error = server_->errorString();
            return result;
        }

        server_->setMaxPendingConnections(maxConnections_);
        result.ok = true;
        result.peerList = peerList();
        return result;
    }

    OperationResult stopServer()
    {
        OperationResult result;

        if (server_) {
            server_->close();
        }

        closeAllPeers();

        result.ok = true;
        result.connectionsChanged = true;
        result.peerList = peerList();
        return result;
    }

    // ---- 数据发送 (P0: 支持 partial write 和背压) ----

    OperationResult sendBytesToPeer(const QString &peerKey, const QByteArray &data)
    {
        OperationResult result;

        QTcpSocket *socket = findSocket(peerKey);
        if (!socket || socket->state() != QAbstractSocket::ConnectedState) {
            result.error = tr("Peer is not connected: %1").arg(peerKey);
            result.connectionsChanged = true;
            result.peerList = peerList();
            return result;
        }

        if (data.isEmpty()) {
            result.ok = true;
            return result;
        }

        const quintptr sk = socketKey(socket);
        QQueue<PendingWrite> &queue = pendingWrites_[sk];
        if (queue.size() >= MaxSendQueueSize) {
            result.error = tr("Send queue full for peer %1 (%2 pending)")
                               .arg(peerKey).arg(queue.size());
            return result;
        }

        PendingWrite pw;
        pw.data = data;
        pw.offset = 0;

        const bool wasIdle = queue.isEmpty();
        queue.enqueue(std::move(pw));

        if (wasIdle) {
            flushWriteQueue(socket, peerKey);
        }

        result.ok = true;
        return result;
    }

    OperationResult disconnectPeer(const QString &peerKey)
    {
        OperationResult result;

        QTcpSocket *socket = peerSockets_.take(peerKey);
        if (!socket) {
            result.error = tr("Peer not found: %1").arg(peerKey);
            return result;
        }

        pendingWrites_.remove(socketKey(socket));

        if (socket->state() != QAbstractSocket::UnconnectedState)
            socket->disconnectFromHost();
        socket->deleteLater();

        result.ok = true;
        result.connectionsChanged = true;
        result.peerList = peerList();
        return result;
    }

    // P1: 运行中参数同步到已有 socket
    Q_INVOKABLE void applySettings(bool tcpNoDelay, int readBufferSize,
                                   bool lazyDecode)
    {
        tcpNoDelay_ = tcpNoDelay;
        readBufferSize_ = std::max(1024, readBufferSize);
        lazyDecode_ = lazyDecode;

        if (clientSocket_)
            applySocketOptions(clientSocket_.data());

        for (auto it = peerSockets_.cbegin(); it != peerSockets_.cend(); ++it) {
            QTcpSocket *socket = it.value();
            if (socket)
                applySocketOptions(socket);
        }
    }

    // P1: SSL 缓存失效
    Q_INVOKABLE void invalidateSslCache()
    {
        sslConfigDirty_ = true;
        cachedSslConfig_ = QSslConfiguration();
    }

    // P1: 运行时 maxConnections 同步
    Q_INVOKABLE void applyMaxConnections(int max)
    {
        maxConnections_ = std::max(1, max);
    }

    // P1: 手动刷新 SSL 配置（用户主动调用）
    Q_INVOKABLE void refreshSslConfig()
    {
        invalidateSslCache();
        buildSslConfiguration(); // 触发重新加载
    }

    // P0: 优雅停止
    Q_INVOKABLE void requestStop()
    {
        stopAll();

        if (thread())
            thread()->quit();
    }

    QVariantList peerList() const
    {
        QVariantList peers;

        if (mode_ == MosNetTcpManager::Client
            && clientSocket_
            && clientSocket_->state() == QAbstractSocket::ConnectedState) {
            const QString key = makePeerKey(savedHost_, savedPort_);
            QVariantMap peer = socketPeerInfo(clientSocket_.data(), key);
            if (sslEnabled_) {
                QSslSocket *sslSocket = qobject_cast<QSslSocket *>(clientSocket_.data());
                peer.insert(QStringLiteral("sslEncrypted"),
                            sslSocket ? sslSocket->isEncrypted() : false);
            }
            peers.push_back(peer);
        }

        if (mode_ == MosNetTcpManager::Server) {
            const QStringList keys = peerSockets_.keys();
            peers.reserve(keys.size());
            for (const QString &key : keys) {
                QTcpSocket *socket = peerSockets_.value(key, nullptr);
                if (!socket)
                    continue;
                if (socket->state() == QAbstractSocket::ConnectedState) {
                    QVariantMap peer = socketPeerInfo(socket, key);
                    QSslSocket *sslSocket = qobject_cast<QSslSocket *>(socket);
                    peer.insert(QStringLiteral("sslEncrypted"),
                                sslSocket ? sslSocket->isEncrypted() : false);
                    peers.push_back(peer);
                }
            }
        }

        return peers;
    }

    MosNetTcpManager::State currentState() const
    {
        if (mode_ == MosNetTcpManager::Server) {
            if (server_ && server_->isListening())
                return MosNetTcpManager::Listening;
            return MosNetTcpManager::Disconnected;
        }

        if (!clientSocket_)
            return MosNetTcpManager::Disconnected;

        switch (clientSocket_->state()) {
        case QAbstractSocket::ConnectedState:
            return MosNetTcpManager::Connected;
        case QAbstractSocket::ConnectingState:
        case QAbstractSocket::HostLookupState:
            return MosNetTcpManager::Connecting;
        default:
            return MosNetTcpManager::Disconnected;
        }
    }

private:
    // ---- Socket 选项应用 ----

    void applySocketOptions(QTcpSocket *socket)
    {
        socket->setSocketOption(QAbstractSocket::LowDelayOption,
                                tcpNoDelay_ ? 1 : 0);
        socket->setSocketOption(QAbstractSocket::KeepAliveOption, 1);
        socket->setReadBufferSize(readBufferSize_);
    }

    // ---- Socket 管理 ----

    void ensureClientSocket()
    {
        if (clientSocket_)
            return;

        if (sslEnabled_) {
            clientSocket_ = new QSslSocket(this);
        } else {
            clientSocket_ = new QTcpSocket(this);
        }
        clientSocket_->setProxy(QNetworkProxy::NoProxy);  // ★ 防御系统代理干扰

        applySocketOptions(clientSocket_.data());
        setupClientSocketConnections();
    }

    void setupClientSocketConnections()
    {
        QTcpSocket *sock = clientSocket_.data();

        QObject::connect(sock, &QAbstractSocket::connected, this, [this]() {
            reconnectAttempt_ = 0;
            if (autoReconnect_)
                reconnectTimer_->stop();

            notifyStateChange();
        });

        QObject::connect(sock, &QAbstractSocket::disconnected, this, [this]() {
            const bool wasIntentional = intentionalDisconnect_;
            intentionalDisconnect_ = false;

            if (clientSocket_) {
                flushingSockets_.remove(socketKey(clientSocket_.data()));
                pendingWrites_.remove(socketKey(clientSocket_.data()));
            }

            const QVariantList peers = peerList();
            stateCallback_(peers);

            if (!wasIntentional && autoReconnect_ && mode_ == MosNetTcpManager::Client) {
                scheduleReconnect();
            }
        });

        QObject::connect(sock, &QAbstractSocket::stateChanged, this,
                         [this](QAbstractSocket::SocketState) {
            notifyStateChange();
        });

        QObject::connect(sock, &QIODevice::readyRead, this, [this, sock]() {
            QByteArray data = sock->readAll();
            if (data.isEmpty())
                return;

            const QString peerKey = mode_ == MosNetTcpManager::Client
                                        ? makePeerKey(savedHost_, savedPort_)
                                        : socketPeerKey(sock);

            // P1: lazyDecode 时传 nullopt，避免空字符串构造和跨线程拷贝
            // 注意：先计算 text/hex 再 move(data)，避免参数求值顺序依赖
            if (lazyDecode_) {
                dataCallback_(peerKey, std::move(data), std::nullopt, std::nullopt);
            } else {
                const QString text = QString::fromUtf8(data);
                const QString hex = toHexString(data);
                dataCallback_(peerKey, std::move(data), std::move(text), std::move(hex));
            }
        });

        // P0: bytesWritten 中使用延迟调度，避免递归 write → bytesWritten 栈溢出
        QObject::connect(sock, &QIODevice::bytesWritten, this, [this, sock](qint64 bytes) {
            const QString peerKey = mode_ == MosNetTcpManager::Client
                                        ? makePeerKey(savedHost_, savedPort_)
                                        : socketPeerKey(sock);

            scheduleFlush(sock, peerKey);
            bytesCallback_(peerKey, bytes);
        });

        QObject::connect(sock, &QAbstractSocket::errorOccurred, this,
                         [this, sock](QAbstractSocket::SocketError error) {
            if (error == QAbstractSocket::RemoteHostClosedError)
                return;
            if (!sock)
                return;

            const QString message = sock->errorString();
            const QString peerKey = mode_ == MosNetTcpManager::Client
                                        ? makePeerKey(savedHost_, savedPort_)
                                        : socketPeerKey(sock);

            const bool connectionLost =
                error == QAbstractSocket::ConnectionRefusedError
                || error == QAbstractSocket::HostNotFoundError
                || error == QAbstractSocket::NetworkError
                || error == QAbstractSocket::SocketTimeoutError;

            errorCallback_(peerKey, message, connectionLost,
                           connectionLost ? peerList() : QVariantList());
        });

        QSslSocket *sslSocket = qobject_cast<QSslSocket *>(sock);
        if (sslSocket) {
            QObject::connect(sslSocket, &QSslSocket::encrypted, this, [this]() {
                notifyStateChange();
            });

            QObject::connect(sslSocket,
                             QOverload<const QList<QSslError> &>::of(&QSslSocket::sslErrors),
                             this, [this](const QList<QSslError> &errors) {
                for (const QSslError &err : errors) {
                    const QString peerKey = makePeerKey(savedHost_, savedPort_);
                    errorCallback_(peerKey, err.errorString(), false, QVariantList());
                }
                if (!sslPeerVerify_ && clientSocket_) {
                    QSslSocket *ssl = qobject_cast<QSslSocket *>(clientSocket_.data());
                    if (ssl)
                        ssl->ignoreSslErrors();
                }
            });
        }
    }

    void setupPeerSocketConnections(QTcpSocket *socket, const QString &peerKey)
    {
        applySocketOptions(socket);

        QObject::connect(socket, &QIODevice::readyRead, this,
                         [this, peerKey, socket]() {
            QByteArray data = socket->readAll();
            if (data.isEmpty())
                return;

            if (lazyDecode_) {
                dataCallback_(peerKey, std::move(data), std::nullopt, std::nullopt);
            } else {
                dataCallback_(peerKey, std::move(data),
                              QString::fromUtf8(data), toHexString(data));
            }
        });

        // P0: 延迟调度，避免递归
        QObject::connect(socket, &QIODevice::bytesWritten, this,
                         [this, peerKey, socket](qint64 bytes) {
            scheduleFlush(socket, peerKey);
            bytesCallback_(peerKey, bytes);
        });

        QObject::connect(socket, &QAbstractSocket::disconnected, this,
                         [this, peerKey]() {
            QTcpSocket *sock = qobject_cast<QTcpSocket *>(sender());
            if (sock) {
                flushingSockets_.remove(socketKey(sock));
                pendingWrites_.remove(socketKey(sock));
            }
            peerSockets_.remove(peerKey);
            if (sender())
                sender()->deleteLater();

            const QVariantList peers = peerList();
            stateCallback_(peers);
        });

        QObject::connect(socket, &QAbstractSocket::errorOccurred, this,
                         [this, peerKey, socket](QAbstractSocket::SocketError error) {
            if (error == QAbstractSocket::RemoteHostClosedError)
                return;

            const QString message = socket->errorString();
            const bool connectionLost =
                error == QAbstractSocket::ConnectionRefusedError
                || error == QAbstractSocket::NetworkError
                || error == QAbstractSocket::SocketTimeoutError;

            if (connectionLost) {
                flushingSockets_.remove(socketKey(socket));
                pendingWrites_.remove(socketKey(socket));
                peerSockets_.remove(peerKey);
                socket->deleteLater();
            }

            errorCallback_(peerKey, message, connectionLost,
                           connectionLost ? peerList() : QVariantList());
        });

        QSslSocket *sslSocket = qobject_cast<QSslSocket *>(socket);
        if (sslSocket) {
            QObject::connect(sslSocket, &QSslSocket::encrypted, this, [this]() {
                notifyStateChange();
            });
        }
    }

    // ---- 服务器回调 ----

    void onNewConnection()
    {
        if (!server_)
            return;

        while (server_->hasPendingConnections()) {
            // P1: 强制遵守 maxConnections 限制
            if (peerSockets_.size() >= maxConnections_) {
                QTcpSocket *rejected = server_->nextPendingConnection();
                if (rejected) {
                    rejected->disconnectFromHost();
                    rejected->deleteLater();
                }
                continue;
            }

            QTcpSocket *baseSocket = server_->nextPendingConnection();
            if (!baseSocket)
                continue;

            QTcpSocket *socket = nullptr;

            if (sslEnabled_) {
                QSslSocket *sslSocket = new QSslSocket(this);
                const qintptr desc = baseSocket->socketDescriptor();

                if (desc < 0) {
                    delete sslSocket;
                    baseSocket->deleteLater();
                    continue;
                }

                const bool descOk = sslSocket->setSocketDescriptor(
                    desc, QAbstractSocket::ConnectedState);
                if (!descOk) {
                    const QString errMsg = tr("Server SSL: setSocketDescriptor failed: %1")
                                               .arg(sslSocket->errorString());
                    errorCallback_(QString(), errMsg, false, peerList());
                    delete sslSocket;
                    baseSocket->deleteLater();
                    continue;
                }

                // P0: 必须检查 SSL 配置是否有效
                QSslConfiguration sslConfig = buildSslConfiguration();
                if (sslConfig.isNull()) {
                    const QString errMsg = tr("Server SSL: configuration is invalid, rejecting connection");
                    errorCallback_(QString(), errMsg, false, peerList());
                    delete sslSocket;
                    baseSocket->deleteLater();
                    continue;
                }

                sslSocket->setSslConfiguration(sslConfig);
                sslSocket->startServerEncryption();
                socket = sslSocket;
                baseSocket->deleteLater();
            } else {
                socket = baseSocket;
            }

            if (!socket)
                continue;

            const QString peerKey = socketPeerKey(socket);
            QString uniqueKey = peerKey;
            int suffix = 1;
            while (peerSockets_.contains(uniqueKey)) {
                uniqueKey = QStringLiteral("%1#%2").arg(peerKey).arg(suffix++);
            }

            peerSockets_.insert(uniqueKey, socket);
            setupPeerSocketConnections(socket, uniqueKey);
        }

        notifyStateChange();
    }

    void onAcceptError(QAbstractSocket::SocketError /*error*/)
    {
        if (server_) {
            errorCallback_(QString(), server_->errorString(), false, peerList());
        }
    }

    // ---- 重连逻辑 ----

    void scheduleReconnect()
    {
        if (!autoReconnect_ || mode_ != MosNetTcpManager::Client)
            return;

        const int baseDelay = std::min(
            reconnectIntervalMs_ * (1 << reconnectAttempt_),
            MaxReconnectDelayMs);

        // P1: 添加随机抖动 (±10%)，避免多个客户端同步重连造成服务端冲击
        const int jitterRange = std::max(1, baseDelay / 5); // ±10%
        const int jitter = QRandomGenerator::global()->bounded(jitterRange + 1) - jitterRange / 2;
        const int delay = std::max(0, baseDelay + jitter);

        reconnectAttempt_++;
        reconnectTimer_->start(delay);
    }

    void attemptReconnect()
    {
        if (!autoReconnect_ || mode_ != MosNetTcpManager::Client)
            return;

        // ★ 修复：abort 所有非干净状态的 socket，与 connectToHost 保持一致
        if (clientSocket_) {
            const auto state = clientSocket_->state();
            if (state != QAbstractSocket::UnconnectedState) {
                clientSocket_->abort();
            }
        } else {
            ensureClientSocket();
        }

        applySocketOptions(clientSocket_.data());
        clientSocket_->setProxy(QNetworkProxy::NoProxy);  // ★ 防御系统代理干扰

        if (sslEnabled_) {
            QSslConfiguration sslConfig = buildSslConfiguration();
            if (sslConfig.isNull()) {
                const QString errMsg = tr("Reconnect: SSL configuration failed.");
                errorCallback_(makePeerKey(savedHost_, savedPort_), errMsg,
                               false, QVariantList());
                scheduleReconnect();
                return;
            }
            QSslSocket *sslSocket = qobject_cast<QSslSocket *>(clientSocket_.data());
            if (sslSocket) {
                sslSocket->setSslConfiguration(sslConfig);
                sslSocket->connectToHostEncrypted(savedHost_, static_cast<quint16>(savedPort_));
            }
        } else {
            clientSocket_->connectToHost(savedHost_, static_cast<quint16>(savedPort_));
        }
    }

    // ---- P0: 发送队列冲刷（带重入保护 + write==0 检查） ----

    void scheduleFlush(QTcpSocket *socket, const QString &peerKey)
    {
        // P0: QTimer::singleShot 延迟到下一事件循环，打断 write → bytesWritten 递归链
        const quintptr sk = socketKey(socket);

        // 避免重复调度
        if (flushingSockets_.contains(sk))
            return;

        auto it = pendingWrites_.find(sk);
        if (it == pendingWrites_.end() || it->isEmpty())
            return;

        flushingSockets_.insert(sk);
        // P0: 用 QPointer 捕获 socket，防止 QTimer 触发时 socket 已被析构
        QPointer<QTcpSocket> sockGuard(socket);
        QTimer::singleShot(0, this, [this, sockGuard, peerKey, sk]() {
            flushingSockets_.remove(sk);
            if (sockGuard) {
                flushWriteQueue(sockGuard.data(), peerKey);
            } else {
                // socket 已删除，清理残留队列
                pendingWrites_.remove(sk);
            }
        });
    }

    void flushWriteQueue(QTcpSocket *socket, const QString &peerKey)
    {
        const quintptr sk = socketKey(socket);
        auto it = pendingWrites_.find(sk);
        if (it == pendingWrites_.end() || it->isEmpty())
            return;

        QQueue<PendingWrite> &queue = *it;

        while (!queue.isEmpty()) {
            PendingWrite &pw = queue.head();
            const qint64 remaining = pw.data.size() - pw.offset;
            const qint64 written = socket->write(pw.data.constData() + pw.offset, remaining);

            if (written < 0) {
                const QString errMsg = socket->errorString();
                queue.clear();
                errorCallback_(peerKey, errMsg, false, QVariantList());
                return;
            }

            // P0: write 返回 0 表示发送缓冲区已满，退出循环等待下次 bytesWritten
            if (written == 0)
                break;

            pw.offset += written;

            if (pw.offset >= pw.data.size()) {
                queue.dequeue();
            } else {
                // 部分写入，等待下次 bytesWritten 信号继续
                break;
            }
        }
    }

    // ---- 辅助方法 ----

    void notifyStateChange()
    {
        const QVariantList peers = peerList();
        stateCallback_(peers);
    }

    QTcpSocket *findSocket(const QString &peerKey) const
    {
        if (mode_ == MosNetTcpManager::Client) {
            if (clientSocket_
                && clientSocket_->state() == QAbstractSocket::ConnectedState) {
                const QString key = makePeerKey(savedHost_, savedPort_);
                if (peerKey.isEmpty() || peerKey == key)
                    return clientSocket_.data();
            }
            return nullptr;
        }

        return peerSockets_.value(peerKey, nullptr);
    }

    void closeAllPeers()
    {
        const auto sockets = peerSockets_;
        peerSockets_.clear();
        for (QTcpSocket *socket : sockets) {
            if (!socket)
                continue;
            const quintptr sk = socketKey(socket);
            flushingSockets_.remove(sk);
            pendingWrites_.remove(sk);
            if (socket->state() != QAbstractSocket::UnconnectedState)
                socket->disconnectFromHost();
            socket->deleteLater();
        }
    }

    void stopAll()
    {
        intentionalDisconnect_ = true;
        reconnectTimer_->stop();

        if (clientSocket_) {
            const quintptr sk = socketKey(clientSocket_.data());
            flushingSockets_.remove(sk);
            pendingWrites_.remove(sk);
            if (clientSocket_->state() != QAbstractSocket::UnconnectedState) {
                clientSocket_->abort();
            }
        }

        if (server_) {
            server_->close();
        }

        closeAllPeers();
    }

    // P1: SSL 配置缓存
    QSslConfiguration buildSslConfiguration()
    {
        if (!sslConfigDirty_ && !cachedSslConfig_.isNull())
            return cachedSslConfig_;

        QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();

        if (!sslCaCertPath_.isEmpty()) {
            const QList<QSslCertificate> certs =
                QSslCertificate::fromPath(sslCaCertPath_);
            if (certs.isEmpty()) {
                const QString errMsg =
                    tr("Failed to load CA certificate from: %1").arg(sslCaCertPath_);
                errorCallback_(QString(), errMsg, false, QVariantList());
                cachedSslConfig_ = QSslConfiguration();
                sslConfigDirty_ = true;
                return QSslConfiguration();
            }
            sslConfig.setCaCertificates(certs);
        }

        if (!sslLocalCertPath_.isEmpty()) {
            const QList<QSslCertificate> localCerts =
                QSslCertificate::fromPath(sslLocalCertPath_);
            if (localCerts.isEmpty()) {
                const QString errMsg =
                    tr("Failed to load local certificate from: %1").arg(sslLocalCertPath_);
                errorCallback_(QString(), errMsg, false, QVariantList());
                cachedSslConfig_ = QSslConfiguration();
                sslConfigDirty_ = true;
                return QSslConfiguration();
            }
            sslConfig.setLocalCertificate(localCerts.first());

            if (!sslPrivateKeyPath_.isEmpty()) {
                QFile keyFile(sslPrivateKeyPath_);
                if (!keyFile.open(QIODevice::ReadOnly)) {
                    const QString errMsg =
                        tr("Failed to open private key file: %1")
                            .arg(sslPrivateKeyPath_);
                    errorCallback_(QString(), errMsg, false, QVariantList());
                    cachedSslConfig_ = QSslConfiguration();
                    sslConfigDirty_ = true;
                    return QSslConfiguration();
                }
                QSslKey key(&keyFile, QSsl::Rsa);
                keyFile.close();
                if (key.isNull()) {
                    const QString errMsg =
                        tr("Failed to load private key from: %1")
                            .arg(sslPrivateKeyPath_);
                    errorCallback_(QString(), errMsg, false, QVariantList());
                    cachedSslConfig_ = QSslConfiguration();
                    sslConfigDirty_ = true;
                    return QSslConfiguration();
                }
                sslConfig.setPrivateKey(key);
            }
        }

        if (!sslPeerVerify_) {
            sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
        }

        cachedSslConfig_ = sslConfig;
        sslConfigDirty_ = false;
        return sslConfig;
    }

    // P1: SSL 证书文件监控
    void setupSslWatcher()
    {
        if (!sslWatcher_) {
            sslWatcher_ = new QFileSystemWatcher(this);
            QObject::connect(sslWatcher_, &QFileSystemWatcher::fileChanged, this, [this](const QString &) {
                invalidateSslCache();
            });
        }

        // P1: 每次调用先清空旧监控路径，避免重复添加和残留
        if (!sslWatcher_->files().isEmpty())
            sslWatcher_->removePaths(sslWatcher_->files());

        auto addPath = [&](const QString &path) {
            if (!path.isEmpty() && QFile::exists(path))
                sslWatcher_->addPath(path);
        };

        addPath(sslCaCertPath_);
        addPath(sslLocalCertPath_);
        addPath(sslPrivateKeyPath_);
    }

    // ---- 数据成员 ----

    // 客户端模式
    QPointer<QTcpSocket> clientSocket_;
    QTimer *reconnectTimer_ { nullptr };

    // 服务器模式
    QTcpServer *server_ { nullptr };
    QHash<QString, QTcpSocket *> peerSockets_;

    // P0: 发送队列 — 用 quintptr 作 key 避免裸指针复用风险
    QHash<quintptr, QQueue<PendingWrite>> pendingWrites_;

    // P0: 冲刷防重入保护 — 防止 bytesWritten → write → bytesWritten 递归
    QSet<quintptr> flushingSockets_;

    // 回调
    DataCallback dataCallback_;
    BytesCallback bytesCallback_;
    StateCallback stateCallback_;
    ErrorCallback errorCallback_;

    // 连接参数（用于重连）
    MosNetTcpManager::Mode mode_ { MosNetTcpManager::Client };
    bool autoReconnect_ { false };
    int reconnectIntervalMs_ { 5000 };
    int reconnectAttempt_ { 0 };
    bool intentionalDisconnect_ { false };
    QString savedHost_;
    int savedPort_ { 502 };

    // SSL
    bool sslEnabled_ { false };
    QString sslCaCertPath_;
    QString sslLocalCertPath_;
    QString sslPrivateKeyPath_;
    bool sslPeerVerify_ { true };

    // P1: SSL 配置缓存
    mutable QSslConfiguration cachedSslConfig_;
    mutable bool sslConfigDirty_ { true };

    // P1: SSL 文件监控
    QFileSystemWatcher *sslWatcher_ { nullptr };

    // 性能
    bool tcpNoDelay_ { true };
    int readBufferSize_ { 65536 };
    int maxConnections_ { 100 };

    // P1: 解码控制
    bool lazyDecode_ { false };
};

// =====================================================================
// invokeOperation — 跨线程安全调用模板 (P0: 使用 per-worker 锁)
// =====================================================================

template <typename Function>
std::optional<MosNetTcpWorker::OperationResult> invokeOperation(
    MosNetTcpWorker *worker,
    int timeoutMs,
    Function &&function)
{
    if (!worker)
        return std::nullopt;
    if (QThread::currentThread() == worker->thread())
        return function();

    // P0: 使用 worker 实例级的 operationInFlight，替代全局 g_operationInFlight
    if (!worker->operationInFlight.testAndSetAcquire(0, 1))
        return std::nullopt;

    struct InvocationState {
        std::optional<MosNetTcpWorker::OperationResult> result;
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
            QMetaObject::invokeMethod(loopGuard.data(), &QEventLoop::quit,
                                       Qt::QueuedConnection);
        }
    }, Qt::QueuedConnection);

    if (!posted) {
        worker->operationInFlight.storeRelease(0);
        return std::nullopt;
    }

    timer.start(timeoutMs);
    loop.exec();

    worker->operationInFlight.storeRelease(0);

    if (!state->done) {
        QMetaObject::invokeMethod(worker, [worker]() {
            if (worker)
                worker->cancelPendingConnection();
        }, Qt::QueuedConnection);
        return std::nullopt;
    }

    return std::move(state->result);
}

// =====================================================================
// MosNetTcpManager — 公开 API
// =====================================================================

MosNetTcpManager::MosNetTcpManager(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosNetTcpManagerPrivate(this))
{
    Q_D(MosNetTcpManager);

    d->tcpThread = new QThread(this);
    d->tcpThread->setObjectName(QStringLiteral("MosNetTcpThread"));
    d->worker = new MosNetTcpWorker(
        // DataCallback — 数据接收 (P1: text/hex 改为 optional)
        [this](QString peerKey, QByteArray data,
               std::optional<QString> text, std::optional<QString> hex) {
            QMetaObject::invokeMethod(this,
                                      [this,
                                       peerKey = std::move(peerKey),
                                       data = std::move(data),
                                       text = std::move(text),
                                       hex = std::move(hex)]() {
                const QString t = text.value_or(QString());
                const QString h = hex.value_or(QString());
                emit dataReceivedFromPeer(peerKey, data, t, h);
                emit dataReceived(data, t, h);
            }, Qt::QueuedConnection);
        },
        // BytesCallback
        [this](const QString &peerKey, qint64 bytes) {
            QMetaObject::invokeMethod(this, [this, peerKey, bytes]() {
                emit bytesSent(peerKey, bytes);
            }, Qt::QueuedConnection);
        },
        // StateCallback
        [this](QVariantList peerList) {
            QMetaObject::invokeMethod(this,
                                      [this, peerList = std::move(peerList)]() {
                Q_D(MosNetTcpManager);

                const QStringList oldNames = d->peerNameList;
                const QSet<QString> oldSet(oldNames.begin(), oldNames.end());

                const bool peersChanged = setPeerList(d, peerList);

                if (peersChanged) {
                    const QSet<QString> newSet(d->peerNameList.begin(),
                                               d->peerNameList.end());
                    for (const QString &name : d->peerNameList) {
                        if (!oldSet.contains(name))
                            emit peerConnected(name);
                    }
                    for (const QString &name : oldNames) {
                        if (!newSet.contains(name))
                            emit peerDisconnected(name);
                    }
                    emitConnectionsChanged(this);
                }

                if (d->mode == Client) {
                    setConnected(this, d, !d->peerNameList.isEmpty());
                }

                if (d->worker) {
                    setState(this, d, d->worker->currentState());
                }
            }, Qt::QueuedConnection);
        },
        // ErrorCallback
        [this](QString peerKey, QString message, bool connectionChanged, QVariantList peerList) {
            QMetaObject::invokeMethod(this,
                                      [this,
                                       peerKey = std::move(peerKey),
                                       message = std::move(message),
                                       connectionChanged,
                                       peerList = std::move(peerList)]() {
                Q_D(MosNetTcpManager);

                if (connectionChanged) {
                    const bool peersChanged = setPeerList(d, peerList);
                    if (d->worker)
                        setState(this, d, d->worker->currentState());
                    if (peersChanged)
                        emitConnectionsChanged(this);

                    if (d->mode == Client) {
                        setConnected(this, d, !d->peerNameList.isEmpty());
                    }
                }

                setError(this, d, message);
                if (!peerKey.isEmpty())
                    emit errorOccurredFromPeer(peerKey, message);
            }, Qt::QueuedConnection);
        });

    d->worker->moveToThread(d->tcpThread);
    connect(d->tcpThread, &QThread::finished, d->worker, &QObject::deleteLater);
    d->tcpThread->start();
}

// P0: 析构流程改进 — 用 requestStop + BlockingQueuedConnection，避免 terminate()
MosNetTcpManager::~MosNetTcpManager()
{
    shutdown();
}

void MosNetTcpManager::shutdown()
{
    Q_D(MosNetTcpManager);

    if (d->m_shutdownStarted)
        return;
    d->m_shutdownStarted = true;

    if (d->worker && d->tcpThread && d->tcpThread->isRunning()) {
        QMetaObject::invokeMethod(d->worker, &MosNetTcpWorker::requestStop,
                                  Qt::BlockingQueuedConnection);
    }

    if (d->tcpThread) {
        d->tcpThread->quit();
        if (!d->tcpThread->wait(TcpShutdownTimeoutMs)) {
            qWarning("MosNetTcp: worker thread did not stop in time, forcing termination");
            d->tcpThread->terminate();
            d->tcpThread->wait();
        }
    }
}

MosNetTcpManager *MosNetTcpManager::instance()
{
    static MosNetTcpManager ins;
    return &ins;
}

MosNetTcpManager *MosNetTcpManager::create(QQmlEngine *, QJSEngine *)
{
    auto *manager = instance();
    QQmlEngine::setObjectOwnership(manager, QQmlEngine::CppOwnership);
    return manager;
}

// ---- 属性读取 ----

QString MosNetTcpManager::host() const
{ Q_D(const MosNetTcpManager); return d->host; }
int MosNetTcpManager::port() const
{ Q_D(const MosNetTcpManager); return d->port; }
MosNetTcpManager::Mode MosNetTcpManager::mode() const
{ Q_D(const MosNetTcpManager); return d->mode; }
bool MosNetTcpManager::isConnected() const
{ Q_D(const MosNetTcpManager); return d->isConnected; }
MosNetTcpManager::State MosNetTcpManager::state() const
{ Q_D(const MosNetTcpManager); return d->state; }
QString MosNetTcpManager::errorString() const
{ Q_D(const MosNetTcpManager); return d->errorString; }
QStringList MosNetTcpManager::peerNames() const
{ Q_D(const MosNetTcpManager); return d->peerNameList; }
QVariantList MosNetTcpManager::peerList() const
{ Q_D(const MosNetTcpManager); return d->peerInfoList; }
bool MosNetTcpManager::hasConnections() const
{ Q_D(const MosNetTcpManager); return !d->peerNameList.isEmpty(); }
int MosNetTcpManager::connectionCount() const
{ Q_D(const MosNetTcpManager); return d->peerNameList.size(); }
bool MosNetTcpManager::autoReconnect() const
{ Q_D(const MosNetTcpManager); return d->autoReconnect; }
int MosNetTcpManager::reconnectInterval() const
{ Q_D(const MosNetTcpManager); return d->reconnectInterval; }
bool MosNetTcpManager::sslEnabled() const
{ Q_D(const MosNetTcpManager); return d->sslEnabled; }
QString MosNetTcpManager::sslCaCertPath() const
{ Q_D(const MosNetTcpManager); return d->sslCaCertPath; }
QString MosNetTcpManager::sslLocalCertPath() const
{ Q_D(const MosNetTcpManager); return d->sslLocalCertPath; }
QString MosNetTcpManager::sslPrivateKeyPath() const
{ Q_D(const MosNetTcpManager); return d->sslPrivateKeyPath; }
bool MosNetTcpManager::sslPeerVerify() const
{ Q_D(const MosNetTcpManager); return d->sslPeerVerify; }
bool MosNetTcpManager::tcpNoDelay() const
{ Q_D(const MosNetTcpManager); return d->tcpNoDelay; }
int MosNetTcpManager::readBufferSize() const
{ Q_D(const MosNetTcpManager); return d->readBufferSize; }
int MosNetTcpManager::maxConnections() const
{ Q_D(const MosNetTcpManager); return d->maxConnections; }
bool MosNetTcpManager::lazyDecode() const
{ Q_D(const MosNetTcpManager); return d->lazyDecode; }

// ---- 属性写入 ----

void MosNetTcpManager::setHost(const QString &host)
{
    Q_D(MosNetTcpManager);
    if (d->host == host) return;
    d->host = host;
    emit hostChanged();
}

void MosNetTcpManager::setPort(int port)
{
    Q_D(MosNetTcpManager);
    if (d->port == port) return;
    d->port = port;
    emit portChanged();
}

void MosNetTcpManager::setMode(Mode mode)
{
    Q_D(MosNetTcpManager);
    if (d->mode == mode) return;
    d->mode = mode;
    emit modeChanged();
}

void MosNetTcpManager::setAutoReconnect(bool enabled)
{
    Q_D(MosNetTcpManager);
    if (d->autoReconnect == enabled) return;
    d->autoReconnect = enabled;
    emit autoReconnectChanged();
}

void MosNetTcpManager::setReconnectInterval(int ms)
{
    Q_D(MosNetTcpManager);
    const int clamped = std::max(1000, ms);
    if (d->reconnectInterval == clamped) return;
    d->reconnectInterval = clamped;
    emit reconnectIntervalChanged();
}

void MosNetTcpManager::setSslEnabled(bool enabled)
{
    Q_D(MosNetTcpManager);
    if (d->sslEnabled == enabled) return;
    d->sslEnabled = enabled;
    emit sslEnabledChanged();
}

void MosNetTcpManager::setSslCaCertPath(const QString &path)
{
    Q_D(MosNetTcpManager);
    if (d->sslCaCertPath == path) return;
    d->sslCaCertPath = path;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, &MosNetTcpWorker::invalidateSslCache,
                                  Qt::QueuedConnection);
    }
    emit sslCaCertPathChanged();
}

void MosNetTcpManager::setSslLocalCertPath(const QString &path)
{
    Q_D(MosNetTcpManager);
    if (d->sslLocalCertPath == path) return;
    d->sslLocalCertPath = path;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, &MosNetTcpWorker::invalidateSslCache,
                                  Qt::QueuedConnection);
    }
    emit sslLocalCertPathChanged();
}

void MosNetTcpManager::setSslPrivateKeyPath(const QString &path)
{
    Q_D(MosNetTcpManager);
    if (d->sslPrivateKeyPath == path) return;
    d->sslPrivateKeyPath = path;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, &MosNetTcpWorker::invalidateSslCache,
                                  Qt::QueuedConnection);
    }
    emit sslPrivateKeyPathChanged();
}

void MosNetTcpManager::setSslPeerVerify(bool enabled)
{
    Q_D(MosNetTcpManager);
    if (d->sslPeerVerify == enabled) return;
    d->sslPeerVerify = enabled;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, &MosNetTcpWorker::invalidateSslCache,
                                  Qt::QueuedConnection);
    }
    emit sslPeerVerifyChanged();
}

void MosNetTcpManager::setTcpNoDelay(bool enabled)
{
    Q_D(MosNetTcpManager);
    if (d->tcpNoDelay == enabled) return;
    d->tcpNoDelay = enabled;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, "applySettings", Qt::QueuedConnection,
                                  Q_ARG(bool, d->tcpNoDelay),
                                  Q_ARG(int, d->readBufferSize),
                                  Q_ARG(bool, d->lazyDecode));
    }
    emit tcpNoDelayChanged();
}

void MosNetTcpManager::setReadBufferSize(int size)
{
    Q_D(MosNetTcpManager);
    const int clamped = std::max(1024, std::min(size, 1024 * 1024 * 10));
    if (d->readBufferSize == clamped) return;
    d->readBufferSize = clamped;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, "applySettings", Qt::QueuedConnection,
                                  Q_ARG(bool, d->tcpNoDelay),
                                  Q_ARG(int, d->readBufferSize),
                                  Q_ARG(bool, d->lazyDecode));
    }
    emit readBufferSizeChanged();
}

void MosNetTcpManager::setMaxConnections(int max)
{
    Q_D(MosNetTcpManager);
    const int clamped = std::max(1, std::min(max, 10000));
    if (d->maxConnections == clamped) return;
    d->maxConnections = clamped;
    // P1: 运行时同步到 worker（不影响已有连接，仅对后续新连接生效）
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, "applyMaxConnections", Qt::QueuedConnection,
                                  Q_ARG(int, clamped));
    }
    emit maxConnectionsChanged();
}

void MosNetTcpManager::setLazyDecode(bool enabled)
{
    Q_D(MosNetTcpManager);
    if (d->lazyDecode == enabled) return;
    d->lazyDecode = enabled;
    if (d->worker) {
        QMetaObject::invokeMethod(d->worker, "applySettings", Qt::QueuedConnection,
                                  Q_ARG(bool, d->tcpNoDelay),
                                  Q_ARG(int, d->readBufferSize),
                                  Q_ARG(bool, d->lazyDecode));
    }
    emit lazyDecodeChanged();
}

// ---- 客户端操作 ----

void MosNetTcpManager::connectToHost()
{
    Q_D(MosNetTcpManager);
    setMode(Client);
    connectToHost(d->host, d->port);
}

void MosNetTcpManager::connectToHost(const QString &host, int port)
{
    Q_D(MosNetTcpManager);

    const QString cleanHost = host.trimmed();
    if (cleanHost.isEmpty()) {
        setError(this, d, tr("TCP host is empty."));
        return;
    }

    if (port <= 0 || port > 65535) {
        setError(this, d, tr("TCP port is invalid."));
        return;
    }

    setMode(Client);
    d->host = cleanHost;
    d->port = port;

    const auto result = invokeOperation(d->worker, TcpOperationTimeoutMs,
                                        [worker = d->worker,
                                         cleanHost, port,
                                         autoReconnect = d->autoReconnect,
                                         reconnectInterval = d->reconnectInterval,
                                         sslEnabled = d->sslEnabled,
                                         sslCaCertPath = d->sslCaCertPath,
                                         sslLocalCertPath = d->sslLocalCertPath,
                                         sslPrivateKeyPath = d->sslPrivateKeyPath,
                                         sslPeerVerify = d->sslPeerVerify,
                                         tcpNoDelay = d->tcpNoDelay,
                                         readBufferSize = d->readBufferSize]() {
        return worker->connectToHost(cleanHost, port,
                                     autoReconnect, reconnectInterval,
                                     sslEnabled, sslCaCertPath,
                                     sslLocalCertPath, sslPrivateKeyPath,
                                     sslPeerVerify, tcpNoDelay, readBufferSize);
    });
    if (!result) {
        setError(this, d, tr("TCP operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    setState(this, d, Connecting);
    clearError();
}

void MosNetTcpManager::disconnectFromHost()
{
    Q_D(MosNetTcpManager);

    const auto result = invokeOperation(d->worker, TcpOperationTimeoutMs,
                                        [worker = d->worker]() {
        return worker->disconnectFromHost();
    });
    if (!result) {
        setError(this, d, tr("TCP operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    const bool peersChanged = setPeerList(d, result->peerList);
    setConnected(this, d, false);
    setState(this, d, Disconnected);
    if (peersChanged)
        emitConnectionsChanged(this);
}

// ---- 服务器操作 ----

void MosNetTcpManager::startServer()
{
    Q_D(MosNetTcpManager);
    setMode(Server);
    startServer(d->port);
}

void MosNetTcpManager::startServer(int port)
{
    Q_D(MosNetTcpManager);

    if (port <= 0 || port > 65535) {
        setError(this, d, tr("TCP port is invalid."));
        return;
    }

    setMode(Server);
    d->port = port;

    const auto result = invokeOperation(d->worker, TcpOperationTimeoutMs,
                                        [worker = d->worker,
                                         port,
                                         maxConnections = d->maxConnections,
                                         sslEnabled = d->sslEnabled,
                                         sslCaCertPath = d->sslCaCertPath,
                                         sslLocalCertPath = d->sslLocalCertPath,
                                         sslPrivateKeyPath = d->sslPrivateKeyPath,
                                         sslPeerVerify = d->sslPeerVerify,
                                         tcpNoDelay = d->tcpNoDelay,
                                         readBufferSize = d->readBufferSize]() {
        return worker->startServer(port, maxConnections,
                                   sslEnabled, sslCaCertPath,
                                   sslLocalCertPath, sslPrivateKeyPath,
                                   sslPeerVerify, tcpNoDelay, readBufferSize);
    });
    if (!result) {
        setError(this, d, tr("TCP operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    setPeerList(d, result->peerList);
    setState(this, d, Listening);
    setConnected(this, d, false);
    clearError();
}

void MosNetTcpManager::stopServer()
{
    Q_D(MosNetTcpManager);

    const auto result = invokeOperation(d->worker, TcpOperationTimeoutMs,
                                        [worker = d->worker]() {
        return worker->stopServer();
    });
    if (!result) {
        const bool peersChanged = setPeerList(d, {});
        setState(this, d, Disconnected);
        if (peersChanged)
            emitConnectionsChanged(this);
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    const bool peersChanged = setPeerList(d, result->peerList);
    setState(this, d, Disconnected);
    if (peersChanged)
        emitConnectionsChanged(this);
}

// ---- 数据发送 ----

bool MosNetTcpManager::sendText(const QString &text)
{ return sendBytes(text.toUtf8()); }

bool MosNetTcpManager::sendTextToPeer(const QString &peerKey, const QString &text)
{ return sendBytesToPeer(peerKey, text.toUtf8()); }

bool MosNetTcpManager::sendHex(const QString &hexText)
{
    Q_D(MosNetTcpManager);
    if (d->peerNameList.isEmpty()) {
        setError(this, d, tr("No peer connected."));
        return false;
    }
    return sendHexToPeer(d->peerNameList.first(), hexText);
}

bool MosNetTcpManager::sendHexToPeer(const QString &peerKey, const QString &hexText)
{
    bool ok = false;
    const QByteArray data = parseHexText(hexText, &ok);
    if (!ok) {
        Q_D(MosNetTcpManager);
        setError(this, d, tr("Invalid HEX data."));
        return false;
    }
    return sendBytesToPeer(peerKey, data);
}

bool MosNetTcpManager::sendBytes(const QByteArray &data)
{
    Q_D(MosNetTcpManager);
    if (d->peerNameList.isEmpty()) {
        setError(this, d, tr("No peer connected."));
        return false;
    }
    return sendBytesToPeer(d->peerNameList.first(), data);
}

bool MosNetTcpManager::sendBytesToPeer(const QString &peerKey, const QByteArray &data)
{
    Q_D(MosNetTcpManager);

    const QString cleanPeerKey = peerKey.trimmed();
    if (cleanPeerKey.isEmpty()) {
        setError(this, d, tr("Peer key is empty."));
        return false;
    }

    const auto result = invokeOperation(d->worker, TcpOperationTimeoutMs,
                                        [worker = d->worker, cleanPeerKey, data]() {
        return worker->sendBytesToPeer(cleanPeerKey, data);
    });
    if (!result) {
        setError(this, d, tr("TCP operation timed out."));
        return false;
    }

    if (result->connectionsChanged) {
        const bool peersChanged = setPeerList(d, result->peerList);
        if (d->worker)
            setState(this, d, d->worker->currentState());
        if (peersChanged)
            emitConnectionsChanged(this);
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return false;
    }

    return true;
}

// ---- 连接管理 ----

void MosNetTcpManager::disconnectPeer(const QString &peerKey)
{
    Q_D(MosNetTcpManager);

    const QString cleanPeerKey = peerKey.trimmed();
    if (cleanPeerKey.isEmpty()) {
        setError(this, d, tr("Peer key is empty."));
        return;
    }

    const auto result = invokeOperation(d->worker, TcpOperationTimeoutMs,
                                        [worker = d->worker, cleanPeerKey]() {
        return worker->disconnectPeer(cleanPeerKey);
    });
    if (!result) {
        setError(this, d, tr("TCP operation timed out."));
        return;
    }

    if (!result->ok) {
        setError(this, d, result->error);
        return;
    }

    const bool peersChanged = setPeerList(d, result->peerList);
    if (d->worker)
        setState(this, d, d->worker->currentState());
    if (peersChanged)
        emitConnectionsChanged(this);
}

// ---- 工具方法 ----

void MosNetTcpManager::clearError()
{
    Q_D(MosNetTcpManager);
    if (d->errorString.isEmpty())
        return;

    d->errorString.clear();
    emit errorStringChanged();
}

QString MosNetTcpManager::bytesToHex(const QByteArray &data) const
{
    return toHexString(data);
}

QString MosNetTcpManager::bytesToText(const QByteArray &data) const
{
    return QString::fromUtf8(data);
}

#include "MosNetTcpManager.moc"
