#ifndef K3CLIENT_H
#define K3CLIENT_H

#include <deque>

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QVector>
#include <QtQml/qqml.h>

class MosNetTcpManager;

class K3Client : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(K3Client)

    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged FINAL)
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged FINAL)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged FINAL)
    Q_PROPERTY(QString secondaryHost READ secondaryHost WRITE setSecondaryHost NOTIFY secondaryHostChanged FINAL)
    Q_PROPERTY(int secondaryPort READ secondaryPort WRITE setSecondaryPort NOTIFY secondaryPortChanged FINAL)

public:
    ~K3Client() override;

    static K3Client *instance();
    static K3Client *create(QQmlEngine *, QJSEngine *);

    bool isConnected() const;
    QString host() const;
    int port() const;
    QString secondaryHost() const;
    int secondaryPort() const;

    void setHost(const QString &h);
    void setPort(int p);
    void setSecondaryHost(const QString &h);
    void setSecondaryPort(int p);

    Q_INVOKABLE void connectToHost();
    Q_INVOKABLE void safeConnectToHost();  
    Q_INVOKABLE void disconnectFromHost();

    // ── 读取 ──
    Q_INVOKABLE void dbReadReal(int dbNumber, int start, int size);
    Q_INVOKABLE void dbReadBit(int dbNumber, int start, int size);

    // ── 写入 ──
    Q_INVOKABLE void dbWriteReal(float value, int dbNumber, int start);
    Q_INVOKABLE void dbWriteBit(bool value, int dbNumber, int start, int bit);

Q_SIGNALS:
    void isConnectedChanged();
    void hostChanged();
    void portChanged();
    void secondaryHostChanged();
    void secondaryPortChanged();

    // ★ 优化: QVector<float> / QByteArray 替代 QVariantList，
    //   消除每元素一次 QVariant 堆分配，QML 可直接作为 JS 数组使用
    void realDataReceived(int dbNumber, int start, QVector<float> values);
    void bitDataReceived(int dbNumber, int start, QVector<quint8> rawBytes);
    void writeCompleted(int dbNumber, int start, int cmdId);
    void errorOccurred(const QString &message);

private:
    explicit K3Client(QObject *parent = nullptr);

    // ── 协议帧 (内联优化) ──
    QByteArray buildFrame(const QByteArray &command) const;
    bool extractFrame(QByteArray &buffer, QByteArray &frameData);

    // ── 命令队列 ──
    struct PendingCommand {
        QByteArray rawCommand;
        quint8 cmdId    = 0;
        int dbNumber    = 0;
        int start       = 0;
        bool isWrite    = false;
    };

    // ★ 统一入队入口，消除 4 个 API 方法的重复代码
    void enqueueCommand(quint8 cmdId, QByteArray &&cmd,
                        int dbNumber, int start, bool isWrite);
    void sendNextCommand();
    void handleResponse(QByteArray &&response);

    // ── TCP 回调 ──
    void onTcpConnected();
    void onTcpDisconnected();
    void onTcpDataReceived(const QByteArray &data, const QString &text, const QString &hex);
    void onTcpError(const QString &msg);

    void tryConnectPrimary();
    void tryConnectSecondary();
    QString m_host          = QStringLiteral("192.168.0.108");
    int     m_port          = 50002;
    QString m_secondaryHost = QStringLiteral("192.168.0.108");
    int     m_secondaryPort = 50000;
    bool    m_connected        = false;
    bool    m_reconnecting     = false;  // 防重入：防止主备切换时的无限递归

    QByteArray m_readBuffer;
    std::deque<PendingCommand> m_queue;  // ★ std::deque 对头删更友好
    bool m_commandInFlight = false;
};

#endif // K3CLIENT_H
