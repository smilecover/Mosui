#ifndef MOSNETTCPMANAGER_P_H
#define MOSNETTCPMANAGER_P_H

#include "MosNetTcpManager.h"

#include <QString>
#include <QStringList>
#include <QThread>
#include <QVariantList>

class MosNetTcpWorker;

class MosNetTcpManagerPrivate
{
public:
    Q_DECLARE_PUBLIC(MosNetTcpManager)

    explicit MosNetTcpManagerPrivate(MosNetTcpManager *q) : q_ptr(q) { }

    MosNetTcpManager *q_ptr { nullptr };
    QThread *tcpThread { nullptr };
    MosNetTcpWorker *worker { nullptr };

    // 连接设置
    QString host;
    int port { 502 };

    // 连接状态
    bool isConnected { false };
    MosNetTcpManager::State state { MosNetTcpManager::Disconnected };
    QString errorString;

    // 多连接信息
    QStringList peerNameList;
    QVariantList peerInfoList;

    // 工作模式
    MosNetTcpManager::Mode mode { MosNetTcpManager::Client };

    // 自动重连
    bool autoReconnect { false };
    int reconnectInterval { 5000 };

    // SSL/TLS
    bool sslEnabled { false };
    QString sslCaCertPath;
    QString sslLocalCertPath;
    QString sslPrivateKeyPath;
    bool sslPeerVerify { true };

    // 性能调优
    bool tcpNoDelay { true };
    int readBufferSize { 65536 };
    int maxConnections { 100 };

    // 解码控制 (P1)
    bool lazyDecode { false };
    bool m_shutdownStarted { false };
};

#endif // MOSNETTCPMANAGER_P_H
