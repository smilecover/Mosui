#include "TpinvSerial.h"

#include "MosSerialPortManager.h"

#include <QQmlEngine>
#include <QVariantMap>

TpinvSerial::TpinvSerial(QObject *parent)
    : QObject(parent)
{
    bindManagerSignals();
    
    refreshPorts();
    syncOpenState();
    syncErrorString();
}

TpinvSerial::~TpinvSerial() = default;

TpinvSerial *TpinvSerial::instance()
{
    static TpinvSerial *ins = new TpinvSerial;
    return ins;
}

TpinvSerial *TpinvSerial::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *serial = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(serial, QQmlEngine::CppOwnership);
    }
    return serial;
}

QVariantList TpinvSerial::portOptions() const
{
    return portOptions_;
}

QString TpinvSerial::portName() const
{
    return portName_;
}

void TpinvSerial::setPortName(const QString &portName)
{
    const QString cleanPortName = portName.trimmed();
    if (portName_ == cleanPortName) {
        return;
    }

    portName_ = cleanPortName;
    emit portNameChanged();
    syncOpenState();
}

int TpinvSerial::baudRate() const
{
    return baudRate_;
}

void TpinvSerial::setBaudRate(int baudRate)
{
    if (baudRate_ == baudRate) {
        return;
    }

    baudRate_ = baudRate;
    emit baudRateChanged();
}

int TpinvSerial::dataBits() const
{
    return dataBits_;
}

void TpinvSerial::setDataBits(int dataBits)
{
    if (dataBits_ == dataBits) {
        return;
    }

    dataBits_ = dataBits;
    emit dataBitsChanged();
}

QString TpinvSerial::parity() const
{
    return parity_;
}

void TpinvSerial::setParity(const QString &parity)
{
    const QString cleanParity = parity.trimmed().toLower();
    if (parity_ == cleanParity) {
        return;
    }

    parity_ = cleanParity;
    emit parityChanged();
}

QString TpinvSerial::stopBits() const
{
    return stopBits_;
}

void TpinvSerial::setStopBits(const QString &stopBits)
{
    const QString cleanStopBits = stopBits.trimmed();
    if (stopBits_ == cleanStopBits) {
        return;
    }

    stopBits_ = cleanStopBits;
    emit stopBitsChanged();
}

QString TpinvSerial::flowControl() const
{
    return flowControl_;
}

void TpinvSerial::setFlowControl(const QString &flowControl)
{
    const QString cleanFlowControl = flowControl.trimmed().toLower();
    if (flowControl_ == cleanFlowControl) {
        return;
    }

    flowControl_ = cleanFlowControl;
    emit flowControlChanged();
}

bool TpinvSerial::isOpen() const
{
    return open_;
}

QString TpinvSerial::errorString() const
{
    return errorString_;
}

QString TpinvSerial::receivedText() const
{
    return receivedText_;
}

QString TpinvSerial::receivedHex() const
{
    return receivedHex_;
}

qint64 TpinvSerial::receivedBytes() const
{
    return receivedBytes_;
}

qint64 TpinvSerial::writtenBytes() const
{
    return writtenBytes_;
}

QVariantList TpinvSerial::refreshPorts()
{
    portOptions_ = manager()->refreshPorts();
    emit portOptionsChanged();

    if (portName_.isEmpty() && !portOptions_.isEmpty()) {
        const QVariantMap firstPort = portOptions_.first().toMap();
        setPortName(firstPort.value(QStringLiteral("value")).toString());
    }

    syncOpenState();
    return portOptions_;
}

bool TpinvSerial::openPort()
{
    if (!ensurePortSelected()) {
        return false;
    }

    const bool ok = manager()->openPort(portName_, baudRate_, dataBits_, parity_, stopBits_, flowControl_);
    syncOpenState();
    syncErrorString(ok ? QStringLiteral("") : manager()->errorString());
    return ok;
}

void TpinvSerial::closePort()
{
    if (portName_.isEmpty()) {
        return;
    }

    manager()->closePort(portName_);
    syncOpenState();
    syncErrorString();
}

bool TpinvSerial::togglePort()
{
    syncOpenState();
    if (open_) {
        closePort();
        return true;
    }

    return openPort();
}

bool TpinvSerial::writeText(const QString &text)
{
    if (!ensurePortSelected()) {
        return false;
    }

    const bool ok = manager()->writeTextToPort(portName_, text);
    syncErrorString(ok ? QStringLiteral("") : manager()->errorString());
    return ok;
}

bool TpinvSerial::writeHex(const QString &hexText)
{
    if (!ensurePortSelected()) {
        return false;
    }

    const bool ok = manager()->writeHexToPort(portName_, hexText);
    syncErrorString(ok ? QStringLiteral("") : manager()->errorString());
    return ok;
}

bool TpinvSerial::writeBytes(const QByteArray &data)
{
    if (!ensurePortSelected()) {
        return false;
    }

    const bool ok = manager()->writeBytesToPort(portName_, data);
    syncErrorString(ok ? QStringLiteral("") : manager()->errorString());
    return ok;
}

bool TpinvSerial::writeFrame(const QByteArray &frame)
{
    const bool ok = writeBytes(frame);
    if (ok) {
        emit frameWritten(frame);
    }
    return ok;
}

void TpinvSerial::clearReceived()
{
    if (receivedText_.isEmpty() && receivedHex_.isEmpty() && receivedBytes_ == 0) {
        return;
    }

    receivedText_.clear();
    receivedHex_.clear();
    receivedBytes_ = 0;
    emit receivedChanged();
}

void TpinvSerial::clearError()
{
    manager()->clearError();
    syncErrorString();
}

MosSerialPortManager *TpinvSerial::manager() const
{
    return MosSerialPortManager::instance();
}

void TpinvSerial::bindManagerSignals()
{
    auto *serialManager = manager();

    connect(serialManager,
            &MosSerialPortManager::portInfoListChanged,
            this,
            [this, serialManager]() {
        portOptions_ = serialManager->portInfoList();
        emit portOptionsChanged();
    });

    connect(serialManager,
            &MosSerialPortManager::openPortsChanged,
            this,
            [this]() {
        syncOpenState();
    });

    connect(serialManager,
            &MosSerialPortManager::errorStringChanged,
            this,
            [this]() {
        syncErrorString(manager()->errorString());
    });

    connect(serialManager,
            &MosSerialPortManager::dataReceivedFromPort,
            this,
            [this](const QString &portName, const QByteArray &data, const QString &text, const QString &hex) {
        if (portName != portName_) {
            return;
        }

        receivedText_.append(text);
        if (!receivedHex_.isEmpty() && !hex.isEmpty()) {
            receivedHex_.append(QLatin1Char(' '));
        }
        receivedHex_.append(hex);
        receivedBytes_ += data.size();

        emit dataReceived(data, text, hex);
        emit frameReceived(data);
        emit receivedChanged();
    });

    connect(serialManager,
            &MosSerialPortManager::bytesWrittenFromPort,
            this,
            [this](const QString &portName, qint64 bytes) {
        if (portName != portName_) {
            return;
        }

        writtenBytes_ += bytes;
        emit writtenBytesChanged();
    });

    connect(serialManager,
            &MosSerialPortManager::errorOccurredFromPort,
            this,
            [this](const QString &portName, const QString &message) {
        if (!portName_.isEmpty() && portName != portName_) {
            return;
        }

        syncErrorString(message);
        emit serialErrorOccurred(message);
    });
}

void TpinvSerial::syncOpenState()
{
    const bool open = !portName_.isEmpty() && manager()->isPortOpen(portName_);
    if (open_ == open) {
        return;
    }

    open_ = open;
    emit openChanged();
}

void TpinvSerial::syncErrorString(const QString &message)
{
    const QString nextError = message.isNull() ? manager()->errorString() : message;
    if (errorString_ == nextError) {
        return;
    }

    errorString_ = nextError;
    emit errorStringChanged();
}

bool TpinvSerial::ensurePortSelected()
{
    if (!portName_.isEmpty()) {
        return true;
    }

    refreshPorts();
    if (!portName_.isEmpty()) {
        return true;
    }

    syncErrorString(tr("Serial port name is empty."));
    emit serialErrorOccurred(errorString_);
    return false;
}
