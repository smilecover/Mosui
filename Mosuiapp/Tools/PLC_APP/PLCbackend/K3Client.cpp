#include "K3Client.h"

#include <QQmlEngine>
#include <QtEndian>

#include "MosNetTcpManager.h"

// ═══════════════════════════════════════════════════════════════
// 协议常量
// ═══════════════════════════════════════════════════════════════
namespace {
constexpr quint8 kDeviceId     = 1;
constexpr quint8 kCmdReadReal  = 4;
constexpr quint8 kCmdWriteReal = 5;
constexpr quint8 kCmdReadBit   = 6;
constexpr quint8 kCmdWriteBit  = 7;
constexpr char   kFrameStart   = '$';
constexpr char   kFrameEnd     = '#';
constexpr int    kMaxBuffer    = 4096;

// ── ★ 优化 1: Hex 编码查表 — 消除 buildFrame 中每字节的
//    QByteArray::number().rightJustified().toUpper() 临时分配 ──
//    256×3 = 768 字节只读数据，编译时生成，运行时零开销
constexpr char s_hex[256][3] = {
    "00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F",
    "10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F",
    "20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F",
    "30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F",
    "40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F",
    "50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F",
    "60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F",
    "70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F",
    "80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F",
    "90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F",
    "A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF",
    "B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF",
    "C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF",
    "D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF",
    "E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF",
    "F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF",
};
} // namespace

// ═══════════════════════════════════════════════════════════════
// 构造 / 析构
// ═══════════════════════════════════════════════════════════════

K3Client::K3Client(QObject *parent)
    : QObject(parent)
{
    m_tcp = MosNetTcpManager::instance();

    m_tcp->setHost(m_host);
    m_tcp->setPort(m_port);
    m_tcp->setAutoReconnect(true);           // ★ 启用自动重连
    m_tcp->setReconnectInterval(3000);       // 3 秒重试
    m_tcp->setTcpNoDelay(true);
    m_tcp->setLazyDecode(true);              // ★ 延迟解码，仅用 raw bytes

    QObject::connect(m_tcp, &MosNetTcpManager::connected,
                     this, &K3Client::onTcpConnected);
    QObject::connect(m_tcp, &MosNetTcpManager::disconnected,
                     this, &K3Client::onTcpDisconnected);
    QObject::connect(m_tcp, &MosNetTcpManager::dataReceived,
                     this, &K3Client::onTcpDataReceived);
    QObject::connect(m_tcp, &MosNetTcpManager::errorOccurred,
                     this, &K3Client::onTcpError);
}

K3Client::~K3Client() = default;

// ═══════════════════════════════════════════════════════════════
// 单例
// ═══════════════════════════════════════════════════════════════

K3Client *K3Client::instance()
{
    static K3Client ins;
    return &ins;
}

K3Client *K3Client::create(QQmlEngine *, QJSEngine *)
{
    auto *c = instance();
    QQmlEngine::setObjectOwnership(c, QQmlEngine::CppOwnership);
    return c;
}

// ═══════════════════════════════════════════════════════════════
// 属性
// ═══════════════════════════════════════════════════════════════

bool K3Client::isConnected() const      { return m_connected; }
QString K3Client::host() const          { return m_host; }
int K3Client::port() const              { return m_port; }
QString K3Client::secondaryHost() const { return m_secondaryHost; }
int K3Client::secondaryPort() const     { return m_secondaryPort; }

void K3Client::setHost(const QString &h)
{
    if (m_host == h) return;
    m_host = h;
    m_tcp->setHost(h);
    emit hostChanged();
}
void K3Client::setPort(int p)
{
    if (m_port == p) return;
    m_port = p;
    m_tcp->setPort(p);
    emit portChanged();
}
void K3Client::setSecondaryHost(const QString &h)
{
    if (m_secondaryHost == h) return;
    m_secondaryHost = h;
    emit secondaryHostChanged();
}
void K3Client::setSecondaryPort(int p)
{
    if (m_secondaryPort == p) return;
    m_secondaryPort = p;
    emit secondaryPortChanged();
}

// ═══════════════════════════════════════════════════════════════
// 连接控制
// ═══════════════════════════════════════════════════════════════

void K3Client::connectToHost()
{
    if (m_tcp->isConnected())
        m_tcp->disconnectFromHost();

    m_queue.clear();
    m_commandInFlight = false;
    m_readBuffer.clear();

    tryConnectPrimary();
}

void K3Client::tryConnectPrimary()
{
    m_tcp->setHost(m_host);
    m_tcp->setPort(m_port);
    m_tcp->connectToHost();
}

void K3Client::tryConnectSecondary()
{
    m_tcp->setHost(m_secondaryHost);
    m_tcp->setPort(m_secondaryPort);
    m_tcp->connectToHost();
}

void K3Client::disconnectFromHost()
{
    m_queue.clear();
    m_commandInFlight = false;
    m_tcp->disconnectFromHost();
}

// ═══════════════════════════════════════════════════════════════
// TCP 回调
// ═══════════════════════════════════════════════════════════════

void K3Client::onTcpConnected()
{
    if (!m_connected) {
        m_connected = true;
        emit isConnectedChanged();
    }
    m_readBuffer.clear();

    // 重连后继续处理积压命令
    if (!m_queue.empty() && !m_commandInFlight)
        sendNextCommand();
}

void K3Client::onTcpDisconnected()
{
    // ★ 断线时保留 queue，重连后自动继续
    m_commandInFlight = false;
    m_readBuffer.clear();

    if (m_connected) {
        m_connected = false;
        emit isConnectedChanged();
    }
}

void K3Client::onTcpDataReceived(const QByteArray &data,
                                  const QString & /*text*/,
                                  const QString & /*hex*/)
{
    m_readBuffer.append(data);

    QByteArray frameBody;
    while (extractFrame(m_readBuffer, frameBody)) {
        if (!frameBody.isEmpty())
            handleResponse(std::move(frameBody));
    }

    if (m_readBuffer.size() > kMaxBuffer)
        m_readBuffer = m_readBuffer.right(kMaxBuffer / 2);
}

void K3Client::onTcpError(const QString &msg)
{
    if (!m_connected && m_tcp->host() == m_host) {
        tryConnectSecondary();
        return;
    }
    emit errorOccurred(msg);
}

// ═══════════════════════════════════════════════════════════════
// ★ 优化 2: buildFrame — 查表 + 直接指针写，零临时分配
// ═══════════════════════════════════════════════════════════════

QByteArray K3Client::buildFrame(const QByteArray &command) const
{
    const int cmdSize = command.size();
    // 格式: $ + hex(cmd) + hex(cks) + #
    const int frameSize = 1 + cmdSize * 2 + 2 + 1;

    QByteArray frame;
    frame.resize(frameSize);
    char *p = frame.data();

    // 帧头
    *p++ = kFrameStart;

    // ★ 核心优化: 查表编码 + 累加校验和，一个循环完成
    quint8 cks = 0;
    for (int i = 0; i < cmdSize; ++i) {
        const quint8 b = static_cast<quint8>(command[i]);
        cks += b;
        const char *hex = s_hex[b];
        *p++ = hex[0];
        *p++ = hex[1];
    }
    // 校验和
    const char *cksHex = s_hex[cks];
    *p++ = cksHex[0];
    *p++ = cksHex[1];

    // 帧尾
    *p   = kFrameEnd;

    return frame;
}
    
// ═══════════════════════════════════════════════════════════════
// ★ 优化 3: extractFrame — fromRawData 避免 mid() 拷贝
// ═══════════════════════════════════════════════════════════════

bool K3Client::extractFrame(QByteArray &buffer, QByteArray &frameData)
{
    frameData.clear();

    const int startIdx = buffer.indexOf(kFrameStart);
    if (startIdx < 0) {
        buffer.clear();
        return false;
    }
    if (startIdx > 0)
        buffer.remove(0, startIdx);

    const int endIdx = buffer.indexOf(kFrameEnd, 1);
    if (endIdx < 0) {
        if (buffer.size() > kMaxBuffer / 2)
            buffer.clear();
        return false;
    }

    const int hexLen = endIdx - 1;
    if (hexLen < 4 || hexLen % 2 != 0) {
        buffer.remove(0, endIdx + 1);
        return false;
    }

    // ★ fromRawData 零拷贝引用，fromHex 一次分配出结果（无 mid() 中间拷贝）
    QByteArray binary = QByteArray::fromHex(
        QByteArray::fromRawData(buffer.constData() + 1, hexLen));

    buffer.remove(0, endIdx + 1);

    if (binary.size() < 2)
        return false;

    // 校验和验证
    const int dataLen = binary.size() - 1;
    quint8 cks = 0;
    for (int i = 0; i < dataLen; ++i)
        cks += static_cast<quint8>(binary[i]);

    if (cks != static_cast<quint8>(binary[dataLen]))
        return false;

    // left() 隐式共享，不拷贝
    frameData = binary.left(dataLen);
    return true;
}

// ═══════════════════════════════════════════════════════════════
// ★ 优化 4: 统一命令入队 — 消除 4 个 API 方法的代码重复
// ═══════════════════════════════════════════════════════════════

void K3Client::enqueueCommand(quint8 cmdId, QByteArray &&cmd,
                               int dbNumber, int start, bool isWrite)
{
    const bool wasIdle = m_queue.empty() && !m_commandInFlight;

    PendingCommand pc;
    pc.rawCommand = std::move(cmd);     // ★ 移动语义，零拷贝
    pc.cmdId      = cmdId;
    pc.dbNumber   = dbNumber;
    pc.start      = start;
    pc.isWrite    = isWrite;

    m_queue.push_back(std::move(pc));

    if (wasIdle && m_connected)
        sendNextCommand();
}

void K3Client::sendNextCommand()
{
    if (m_queue.empty() || !m_connected) {
        m_commandInFlight = false;
        return;
    }

    m_commandInFlight = true;
    const PendingCommand &pc = m_queue.front();
    m_tcp->sendBytes(buildFrame(pc.rawCommand));
}

// ═══════════════════════════════════════════════════════════════
// ★ 优化 5: handleResponse — QVector 替代 QVariantList
// ═══════════════════════════════════════════════════════════════

void K3Client::handleResponse(QByteArray &&response)
{
    if (!m_commandInFlight || m_queue.empty())
        return;

    PendingCommand pc = std::move(m_queue.front());  // ★ 移动，不拷贝 QByteArray
    m_queue.pop_front();
    m_commandInFlight = false;

    // ── 基本校验 ──
    if (response.size() < 2) {
        emit errorOccurred(QStringLiteral("K3 响应过短"));
        sendNextCommand();
        return;
    }

    const quint8 rspDev = static_cast<quint8>(response[0]);
    const quint8 rspCmd = static_cast<quint8>(response[1]);

    if (rspDev != kDeviceId || rspCmd != pc.cmdId) {
        emit errorOccurred(
            QStringLiteral("K3 响应不匹配: dev=%1 cmd=%2")
                .arg(rspDev).arg(rspCmd));
        sendNextCommand();
        return;
    }

    // ── 写入确认 ──
    if (pc.isWrite) {
        emit writeCompleted(pc.dbNumber, pc.start, pc.cmdId);
        sendNextCommand();
        return;
    }

    // ── 读取解析 ──
    switch (pc.cmdId) {
    case kCmdReadReal: {
        if (response.size() < 6) {
            emit errorOccurred(QStringLiteral("K3 ReadReal 响应过短"));
            break;
        }
        const auto *raw = reinterpret_cast<const uchar *>(response.constData());
        const int byteCount = qFromLittleEndian<quint16>(raw + 2);
        const int count = byteCount / 4;

        // ★ QVector 单次分配，零散 QVariant 开销
        QVector<float> values(count);
        for (int i = 0; i < count; ++i)
            values[i] = qFromLittleEndian<float>(raw + 4 + i * 4);

        emit realDataReceived(pc.dbNumber, pc.start, std::move(values));
        break;
    }
    case kCmdReadBit: {
        if (response.size() < 5) {  // dev(1) + cmd(1) + byteCount(2) + data(≥1)
            emit errorOccurred(QStringLiteral("K3 ReadBit 响应过短"));
            break;
        }
        const auto *raw = reinterpret_cast<const uchar *>(response.constData());
        const int byteCount = qFromLittleEndian<quint16>(raw + 2);

        QVector<quint8> values(byteCount);
        for (int i = 0; i < byteCount; ++i)
            values[i] = static_cast<quint8>(response[4 + i]);

        emit bitDataReceived(pc.dbNumber, pc.start, std::move(values));
        break;
    }
    default:
        break;
    }

    sendNextCommand();
}

// ═══════════════════════════════════════════════════════════════
// 公开 API — 读取（全部委托给 enqueueCommand）
// ═══════════════════════════════════════════════════════════════

void K3Client::dbReadReal(int dbNumber, int start, int size)
{
    if (size <= 0) return;

    QByteArray cmd(6, '\0');
    cmd[0] = static_cast<char>(kDeviceId);
    cmd[1] = static_cast<char>(kCmdReadReal);
    const quint16 addr = static_cast<quint16>(dbNumber + start - 1);
    qToLittleEndian<quint16>(addr, reinterpret_cast<uchar *>(cmd.data()) + 2);
    qToLittleEndian<quint16>(static_cast<quint16>(size),
                              reinterpret_cast<uchar *>(cmd.data()) + 4);

    enqueueCommand(kCmdReadReal, std::move(cmd), dbNumber, start, false);
}

void K3Client::dbReadBit(int dbNumber, int start, int size)
{
    if (size <= 0) return;

    QByteArray cmd(6, '\0');
    cmd[0] = static_cast<char>(kDeviceId);
    cmd[1] = static_cast<char>(kCmdReadBit);
    const quint16 addr = static_cast<quint16>(dbNumber + start - 1);
    qToLittleEndian<quint16>(addr, reinterpret_cast<uchar *>(cmd.data()) + 2);
    qToLittleEndian<quint16>(static_cast<quint16>(size),
                              reinterpret_cast<uchar *>(cmd.data()) + 4);

    enqueueCommand(kCmdReadBit, std::move(cmd), dbNumber, start, false);
}

// ═══════════════════════════════════════════════════════════════
// 公开 API — 写入
// ═══════════════════════════════════════════════════════════════

void K3Client::dbWriteReal(float value, int dbNumber, int start)
{
    QByteArray cmd(9, '\0');
    cmd[0] = static_cast<char>(kDeviceId);
    cmd[1] = static_cast<char>(kCmdWriteReal);
    const quint16 addr = static_cast<quint16>(dbNumber + start - 1);
    qToLittleEndian<quint16>(addr, reinterpret_cast<uchar *>(cmd.data()) + 2);
    cmd[4] = 1;
    cmd[5] = 0;
    qToLittleEndian<float>(value, reinterpret_cast<uchar *>(cmd.data()) + 5);

    enqueueCommand(kCmdWriteReal, std::move(cmd), dbNumber, start, true);
}

void K3Client::dbWriteBit(bool value, int dbNumber, int start, int bit)
{
    QByteArray cmd(6, '\0');
    cmd[0] = static_cast<char>(kDeviceId);
    cmd[1] = static_cast<char>(kCmdWriteBit);
    const quint16 addr = static_cast<quint16>(dbNumber + start - 1);
    qToLittleEndian<quint16>(addr, reinterpret_cast<uchar *>(cmd.data()) + 2);
    cmd[4] = static_cast<char>(bit);
    cmd[5] = value ? 1 : 0;

    enqueueCommand(kCmdWriteBit, std::move(cmd), dbNumber, start, true);
}
