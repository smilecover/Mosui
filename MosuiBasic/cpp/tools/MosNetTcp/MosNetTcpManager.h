#ifndef MOSNETTCPMANAGER_H
#define MOSNETTCPMANAGER_H

#include <QObject>
#include <QByteArray>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosNetTcpManagerPrivate)

class MOSUIBASIC_EXPORT MosNetTcpManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosNetTcpManager)

    // 连接设置
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged FINAL)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged FINAL)
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged FINAL)

    // 连接状态
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged FINAL)
    Q_PROPERTY(State state READ state NOTIFY stateChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)

    // 多连接信息
    Q_PROPERTY(QStringList peerNames READ peerNames NOTIFY connectionsChanged FINAL)
    Q_PROPERTY(QVariantList peerList READ peerList NOTIFY connectionsChanged FINAL)
    Q_PROPERTY(bool hasConnections READ hasConnections NOTIFY connectionsChanged FINAL)
    Q_PROPERTY(int connectionCount READ connectionCount NOTIFY connectionsChanged FINAL)

    // 自动重连（客户端模式）
    Q_PROPERTY(bool autoReconnect READ autoReconnect WRITE setAutoReconnect NOTIFY autoReconnectChanged FINAL)
    Q_PROPERTY(int reconnectInterval READ reconnectInterval WRITE setReconnectInterval NOTIFY reconnectIntervalChanged FINAL)

    // SSL/TLS
    Q_PROPERTY(bool sslEnabled READ sslEnabled WRITE setSslEnabled NOTIFY sslEnabledChanged FINAL)
    Q_PROPERTY(QString sslCaCertPath READ sslCaCertPath WRITE setSslCaCertPath NOTIFY sslCaCertPathChanged FINAL)
    Q_PROPERTY(QString sslLocalCertPath READ sslLocalCertPath WRITE setSslLocalCertPath NOTIFY sslLocalCertPathChanged FINAL)
    Q_PROPERTY(QString sslPrivateKeyPath READ sslPrivateKeyPath WRITE setSslPrivateKeyPath NOTIFY sslPrivateKeyPathChanged FINAL)
    Q_PROPERTY(bool sslPeerVerify READ sslPeerVerify WRITE setSslPeerVerify NOTIFY sslPeerVerifyChanged FINAL)

    // 性能调优
    Q_PROPERTY(bool tcpNoDelay READ tcpNoDelay WRITE setTcpNoDelay NOTIFY tcpNoDelayChanged FINAL)
    Q_PROPERTY(int readBufferSize READ readBufferSize WRITE setReadBufferSize NOTIFY readBufferSizeChanged FINAL)
    Q_PROPERTY(int maxConnections READ maxConnections WRITE setMaxConnections NOTIFY maxConnectionsChanged FINAL)

    // 解码控制 (P1)
    Q_PROPERTY(bool lazyDecode READ lazyDecode WRITE setLazyDecode NOTIFY lazyDecodeChanged FINAL)

public:
    enum State {
        Disconnected = 0,
        Connecting  = 1,
        Connected   = 2,
        Listening   = 3
    };
    Q_ENUM(State)

    enum Mode {
        Client = 0,
        Server = 1
    };
    Q_ENUM(Mode)

    ~MosNetTcpManager() override;

    static MosNetTcpManager *instance();
    static MosNetTcpManager *create(QQmlEngine *, QJSEngine *);

    QString host() const;
    int port() const;
    Mode mode() const;
    bool isConnected() const;
    State state() const;
    QString errorString() const;
    QStringList peerNames() const;
    QVariantList peerList() const;
    bool hasConnections() const;
    int connectionCount() const;
    bool autoReconnect() const;
    int reconnectInterval() const;
    bool sslEnabled() const;
    QString sslCaCertPath() const;
    QString sslLocalCertPath() const;
    QString sslPrivateKeyPath() const;
    bool sslPeerVerify() const;
    bool tcpNoDelay() const;
    int readBufferSize() const;
    int maxConnections() const;
    bool lazyDecode() const;

    void setHost(const QString &host);
    void setPort(int port);
    void setMode(Mode mode);
    void setAutoReconnect(bool enabled);
    void setReconnectInterval(int ms);
    void setSslEnabled(bool enabled);
    void setSslCaCertPath(const QString &path);
    void setSslLocalCertPath(const QString &path);
    void setSslPrivateKeyPath(const QString &path);
    void setSslPeerVerify(bool enabled);
    void setTcpNoDelay(bool enabled);
    void setReadBufferSize(int size);
    void setMaxConnections(int max);
    void setLazyDecode(bool enabled);

    // 客户端操作
    Q_INVOKABLE void connectToHost();
    Q_INVOKABLE void connectToHost(const QString &host, int port);
    Q_INVOKABLE void disconnectFromHost();

    // 服务器操作
    Q_INVOKABLE void startServer();
    Q_INVOKABLE void startServer(int port);
    Q_INVOKABLE void stopServer();

    // 数据发送
    Q_INVOKABLE bool sendText(const QString &text);
    Q_INVOKABLE bool sendTextToPeer(const QString &peerKey, const QString &text);
    Q_INVOKABLE bool sendBytes(const QByteArray &data);
    Q_INVOKABLE bool sendBytesToPeer(const QString &peerKey, const QByteArray &data);
    Q_INVOKABLE bool sendHex(const QString &hexText);
    Q_INVOKABLE bool sendHexToPeer(const QString &peerKey, const QString &hexText);

    // 连接管理
    Q_INVOKABLE void disconnectPeer(const QString &peerKey);

    // 工具方法
    Q_INVOKABLE void clearError();
    Q_INVOKABLE QString bytesToHex(const QByteArray &data) const;
    Q_INVOKABLE QString bytesToText(const QByteArray &data) const;

Q_SIGNALS:
    void hostChanged();
    void portChanged();
    void modeChanged();
    void isConnectedChanged();
    void stateChanged();
    void errorStringChanged();
    void connectionsChanged();
    void autoReconnectChanged();
    void reconnectIntervalChanged();
    void sslEnabledChanged();
    void sslCaCertPathChanged();
    void sslLocalCertPathChanged();
    void sslPrivateKeyPathChanged();
    void sslPeerVerifyChanged();
    void tcpNoDelayChanged();
    void readBufferSizeChanged();
    void maxConnectionsChanged();
    void lazyDecodeChanged();

    // 事件信号
    void connected();
    void disconnected();
    void dataReceived(const QByteArray &data, const QString &text, const QString &hex);
    void dataReceivedFromPeer(const QString &peerKey, const QByteArray &data, const QString &text, const QString &hex);
    void bytesSent(const QString &peerKey, qint64 bytes);
    void errorOccurred(const QString &message);
    void errorOccurredFromPeer(const QString &peerKey, const QString &message);
    void peerConnected(const QString &peerKey);
    void peerDisconnected(const QString &peerKey);

private:
    explicit MosNetTcpManager(QObject *parent = nullptr);

    Q_DECLARE_PRIVATE(MosNetTcpManager)
    QScopedPointer<MosNetTcpManagerPrivate> d_ptr;
};

#endif // MOSNETTCPMANAGER_H
