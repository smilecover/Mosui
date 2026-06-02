#include "Tpinvcontrolprocess.h"

#include "TpInvcontroldata.h"
#include <QDebug>
#include <QQmlEngine>
#include <QtGlobal>

namespace {
constexpr quint8 CommandRequestParameters = 0x10;
constexpr quint8 CommandApplyParameters = 0x11;
constexpr quint8 CommandStart = 0x20;
constexpr quint8 CommandStop = 0x21;
constexpr quint8 CommandResetFault = 0x30;
}

Tpinvcontrolprocess::Tpinvcontrolprocess(QObject *parent)
    : QObject(parent)
{
    bandTpInvcontroldata();
}
int Tpinvcontrolprocess::Initprocess() const
{
    qDebug() << "初始化逆变器控制进程";
    return 0;
}
Tpinvcontrolprocess::~Tpinvcontrolprocess() = default;

Tpinvcontrolprocess *Tpinvcontrolprocess::instance()
{
    static Tpinvcontrolprocess *ins = new Tpinvcontrolprocess;
    return ins;
}

Tpinvcontrolprocess *Tpinvcontrolprocess::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *process = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(process, QQmlEngine::CppOwnership);
    }
    return process;
}

int Tpinvcontrolprocess::rxBufferSize() const
{
    return rxBuffer_.size();
}

int Tpinvcontrolprocess::parsedFrameCount() const
{
    return parsedFrameCount_;
}

int Tpinvcontrolprocess::droppedFrameCount() const
{
    return droppedFrameCount_;
}

QString Tpinvcontrolprocess::lastFrameHex() const
{
    return lastFrameHex_;
}

QString Tpinvcontrolprocess::lastErrorString() const
{
    return lastErrorString_;
}

void Tpinvcontrolprocess::appendSerialData(const QByteArray &data)
{
    if (data.isEmpty()) {
        return;
    }

    rxBuffer_.append(data);
    trimRxBuffer();
    emit rxBufferChanged();
    parseBufferedFrames();
}

void Tpinvcontrolprocess::appendHexData(const QString &hexText)
{
    const QByteArray data = QByteArray::fromHex(hexText.toLatin1());
    if (data.isEmpty() && !hexText.trimmed().isEmpty()) {
        setLastErrorString(tr("Invalid HEX data."));
        return;
    }

    appendSerialData(data);
}

void Tpinvcontrolprocess::processFrame(const QByteArray &frame)
{
    if (frame.size() < MinFrameSize) {
        ++droppedFrameCount_;
        emit statsChanged();
        setLastErrorString(tr("Frame is too short."));
        return;
    }

    setLastFrame(frame);
    if (!frameChecksumIsValid(frame)) {
        ++droppedFrameCount_;
        emit statsChanged();
        setLastErrorString(tr("Frame checksum is invalid."));
        return;
    }

    const FrameType frameType = detectFrameType(frame);
    switch (frameType) {
    case ParameterFrame:
        parseParameterFrame(frame);
        break;
    case MonitorFrame:
        parseMonitorFrame(frame);
        break;
    case FaultFrame:
        parseFaultFrame(frame);
        break;
    case AckFrame:
        parseAckFrame(frame);
        break;
    case UnknownFrame:
        setLastErrorString(tr("Unknown frame type."));
        break;
    }

    ++parsedFrameCount_;
    emit frameParsed(frame, frameType);
    emit statsChanged();
}

void Tpinvcontrolprocess::clear()
{
    const bool hadRxData = !rxBuffer_.isEmpty();
    rxBuffer_.clear();
    parsedFrameCount_ = 0;
    droppedFrameCount_ = 0;
    lastFrameHex_.clear();
    lastErrorString_.clear();

    if (hadRxData) {
        emit rxBufferChanged();
    }
    emit statsChanged();
    emit lastFrameChanged();
    emit errorChanged();
}

QByteArray Tpinvcontrolprocess::buildRequestParametersFrame()
{
    const QByteArray frame = buildFrame(CommandRequestParameters);
    emit commandFrameBuilt(frame);
    return frame;
}

QByteArray Tpinvcontrolprocess::buildApplyParametersFrame(const QVariantList &parameters)
{
    QByteArray payload;
    payload.reserve(parameters.size() * 2);

    for (const QVariant &parameter : parameters) {
        const qint16 value = static_cast<qint16>(parameter.toDouble() * 10.0);
        payload.append(static_cast<char>((value >> 8) & 0xFF));
        payload.append(static_cast<char>(value & 0xFF));
    }

    const QByteArray frame = buildFrame(CommandApplyParameters, payload);
    emit commandFrameBuilt(frame);
    return frame;
}

QByteArray Tpinvcontrolprocess::buildStartFrame()
{
    const QByteArray frame = buildFrame(CommandStart);
    emit commandFrameBuilt(frame);
    return frame;
}

QByteArray Tpinvcontrolprocess::buildStopFrame()
{
    const QByteArray frame = buildFrame(CommandStop);
    emit commandFrameBuilt(frame);
    return frame;
}

QByteArray Tpinvcontrolprocess::buildResetFaultFrame()
{
    const QByteArray frame = buildFrame(CommandResetFault);
    emit commandFrameBuilt(frame);
    return frame;
}

QString Tpinvcontrolprocess::bytesToHex(const QByteArray &data) const
{
    return QString::fromLatin1(data.toHex(' ').toUpper());
}

void Tpinvcontrolprocess::parseBufferedFrames()
{
    QByteArray frame;
    bool changed = false;

    while (tryTakeFrame(&frame)) {
        changed = true;
        processFrame(frame);
    }

    if (changed) {
        emit rxBufferChanged();
    }
}

bool Tpinvcontrolprocess::tryTakeFrame(QByteArray *frame)
{
    if (!frame || rxBuffer_.size() < MinFrameSize) {
        return false;
    }

    while (rxBuffer_.size() >= 2) {
        const auto byte0 = static_cast<quint8>(rxBuffer_.at(0));
        const auto byte1 = static_cast<quint8>(rxBuffer_.at(1));
        if (byte0 == Header0 && byte1 == Header1) {
            break;
        }

        rxBuffer_.remove(0, 1);
        ++droppedFrameCount_;
        emit statsChanged();
    }

    if (rxBuffer_.size() < MinFrameSize) {
        return false;
    }

    const int payloadLength = static_cast<quint8>(rxBuffer_.at(3));
    const int frameSize = 2 + 1 + 1 + payloadLength + 1;
    if (frameSize < MinFrameSize) {
        rxBuffer_.remove(0, 1);
        ++droppedFrameCount_;
        emit statsChanged();
        return false;
    }

    if (rxBuffer_.size() < frameSize) {
        return false;
    }

    *frame = rxBuffer_.left(frameSize);
    rxBuffer_.remove(0, frameSize);
    return true;
}

bool Tpinvcontrolprocess::frameChecksumIsValid(const QByteArray &frame) const
{
    if (frame.size() < MinFrameSize) {
        return false;
    }

    const int checksumIndex = frame.size() - 1;
    return checksum(frame, 0, checksumIndex) == static_cast<quint8>(frame.at(checksumIndex));
}

Tpinvcontrolprocess::FrameType Tpinvcontrolprocess::detectFrameType(const QByteArray &frame) const
{
    if (frame.size() < MinFrameSize) {
        return UnknownFrame;
    }

    const quint8 command = static_cast<quint8>(frame.at(2));
    switch (command) {
    case 0x90:
        return ParameterFrame;
    case 0x91:
        return MonitorFrame;
    case 0x92:
        return FaultFrame;
    case 0xA0:
        return AckFrame;
    default:
        return UnknownFrame;
    }
}

void Tpinvcontrolprocess::parseParameterFrame(const QByteArray &frame)
{
    Q_UNUSED(frame)

    QVariantList values;
    // TODO: Decode parameter payload and fill values.
    emit parameterValuesParsed(values);
}

void Tpinvcontrolprocess::parseMonitorFrame(const QByteArray &frame)
{
    Q_UNUSED(frame)

    // TODO: Decode monitor payload and emit one signal per value.
    // emit monitorValueParsed(QStringLiteral("dcVoltage"), value);
}

void Tpinvcontrolprocess::parseFaultFrame(const QByteArray &frame)
{
    Q_UNUSED(frame)

    QString faultCode = QStringLiteral("0x0000");
    // TODO: Decode fault payload.
    emit faultCodeParsed(faultCode);
}

void Tpinvcontrolprocess::parseAckFrame(const QByteArray &frame)
{
    Q_UNUSED(frame)

    // TODO: Decode ACK result if the protocol carries one.
}

QByteArray Tpinvcontrolprocess::buildFrame(quint8 command, const QByteArray &payload) const
{
    QByteArray frame;
    frame.reserve(2 + 1 + 1 + payload.size() + 1);
    frame.append(static_cast<char>(Header0));
    frame.append(static_cast<char>(Header1));
    frame.append(static_cast<char>(command));
    frame.append(static_cast<char>(payload.size() & 0xFF));
    frame.append(payload);
    frame.append(static_cast<char>(checksum(frame, 0, frame.size())));
    return frame;
}

quint8 Tpinvcontrolprocess::checksum(const QByteArray &data, int begin, int end) const
{
    quint8 sum = 0;
    const int safeBegin = qMax(0, begin);
    const int safeEnd = qMin(end, data.size());
    for (int i = safeBegin; i < safeEnd; ++i) {
        sum = static_cast<quint8>(sum + static_cast<quint8>(data.at(i)));
    }
    return sum;
}

void Tpinvcontrolprocess::setLastErrorString(const QString &message)
{
    if (lastErrorString_ == message) {
        return;
    }

    lastErrorString_ = message;
    emit errorChanged();
    if (!message.isEmpty()) {
        emit processErrorOccurred(message);
    }
}

void Tpinvcontrolprocess::setLastFrame(const QByteArray &frame)
{
    const QString hex = bytesToHex(frame);
    if (lastFrameHex_ == hex) {
        return;
    }

    lastFrameHex_ = hex;
    emit lastFrameChanged();
}

void Tpinvcontrolprocess::trimRxBuffer()
{
    if (rxBuffer_.size() <= MaxRxBufferSize) {
        return;
    }

    const int removeCount = rxBuffer_.size() - MaxRxBufferSize;
    rxBuffer_.remove(0, removeCount);
    droppedFrameCount_ += removeCount;
    emit statsChanged();
}
// 绑定逆变器数据
void Tpinvcontrolprocess::bandTpInvcontroldata()
{
    const auto *tpInvcontroldata = TpInvcontroldata::instance();
    
    connect(
        tpInvcontroldata,
        &TpInvcontroldata::parameterItemsChanged,
        this,
        [this](){
            this->buildTpInvParamet();
        }
    );
}

void Tpinvcontrolprocess::buildTpInvParamet()
{
    QVariantList TpInvParamet_ = TpInvcontroldata::instance()->parameterItems();
    
    for(int i = 0; i < TpInvParamet_.size(); ++i){
        QVariantMap param = TpInvParamet_.at(i).toMap();
        QString label = param["label"].toString();
        QVariant value = param["value"];
        qDebug() << "参数" << label << ":" << value;
      
    }
 
}

