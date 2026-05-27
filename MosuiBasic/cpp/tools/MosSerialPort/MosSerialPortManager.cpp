#include "MosSerialPortManager.h"
#include "MosSerialPortManager_p.h"

#include <QIODevice>
#include <QQmlEngine>
#include <QSerialPortInfo>
#include <QStringList>
#include <QVariantMap>

namespace {

QString toHexString(const QByteArray &data) // 将字节数组转换为十六进制字符串
{
    return QString::fromLatin1(data.toHex(' ').toUpper());
}

void setError(MosSerialPortManager *q, MosSerialPortManagerPrivate *d, const QString &message)// 设置错误信息
{
    if (d->errorString == message) {
        emit q->errorOccurred(message);
        return;
    }

    d->errorString = message;
    emit q->errorStringChanged();
    emit q->errorOccurred(message);
}

void setOpen(MosSerialPortManager *q, MosSerialPortManagerPrivate *d, bool open)// 设置打开状态
{
    if (d->isOpen == open) {
        return;
    }

    d->isOpen = open;
    emit q->isOpenChanged();
}

bool portIsOpen(const MosSerialPortManagerPrivate *d, const QString &portName)
{
    QSerialPort *serialPort = d->serialPorts.value(portName, nullptr);
    return serialPort && serialPort->isOpen();
}

void syncCurrentOpenState(MosSerialPortManager *q, MosSerialPortManagerPrivate *d)
{
    setOpen(q, d, portIsOpen(d, d->currentPortName));
}

void emitOpenPortsChanged(MosSerialPortManager *q)
{
    emit q->openPortsChanged();
}

void setCurrentPortName(MosSerialPortManager *q, MosSerialPortManagerPrivate *d, const QString &portName)
{
    if (d->currentPortName == portName) {
        syncCurrentOpenState(q, d);
        return;
    }

    d->currentPortName = portName;
    emit q->currentPortNameChanged();
    syncCurrentOpenState(q, d);
}

void setError(MosSerialPortManager *q,
              MosSerialPortManagerPrivate *d,
              const QString &portName,
              const QString &message)
{
    setError(q, d, message);
    if (!portName.isEmpty()) {
        emit q->errorOccurredFromPort(portName, message);
    }
}

QSerialPort::DataBits parseDataBits(int value)// 将数据位解析为QSerialPort::DataBits
{
    switch (value) {
    case 5: return QSerialPort::Data5;
    case 6: return QSerialPort::Data6;
    case 7: return QSerialPort::Data7;
    case 8:
    default: return QSerialPort::Data8;
    }
}

QSerialPort::Parity parseParity(QString value)
{
    value = value.trimmed().toLower();
    if (value == "even" || value == "偶") {
        return QSerialPort::EvenParity;
    }
    if (value == "odd" || value == "奇") {
        return QSerialPort::OddParity;
    }
    if (value == "mark") {
        return QSerialPort::MarkParity;
    }
    if (value == "space") {
        return QSerialPort::SpaceParity;
    }
    return QSerialPort::NoParity;
}

QSerialPort::StopBits parseStopBits(QString value)
{
    value = value.trimmed().toLower();
    if (value == "1.5") {
        return QSerialPort::OneAndHalfStop;
    }
    if (value == "2") {
        return QSerialPort::TwoStop;
    }
    return QSerialPort::OneStop;
}

QSerialPort::FlowControl parseFlowControl(QString value)
{
    value = value.trimmed().toLower();
    if (value == "hardware" || value == "硬件") {
        return QSerialPort::HardwareControl;
    }
    if (value == "software" || value == "软件") {
        return QSerialPort::SoftwareControl;
    }
    return QSerialPort::NoFlowControl;
}

QByteArray parseHexText(QString text, bool *ok)// 将十六进制字符串解析为字节数组
{
    text = text.trimmed();
    text.replace("0x", "", Qt::CaseInsensitive);
    text.replace(",", " ");
    text.replace(";", " ");
    text.replace("\r", " ");
    text.replace("\n", " ");
    text.remove(QChar(' '));
    text.remove(QChar('\t'));

    if (text.isEmpty() || text.size() % 2 != 0) {
        *ok = false;
        return {};
    }

    QByteArray hex = text.toLatin1();
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

QStringList openPortNames(const MosSerialPortManagerPrivate *d)
{
    QStringList names;
    for (auto it = d->serialPorts.cbegin(); it != d->serialPorts.cend(); ++it) {
        if (it.value() && it.value()->isOpen()) {
            names.push_back(it.key());
        }
    }
    names.sort();
    return names;
}

QVariantList openPortList(const MosSerialPortManagerPrivate *d)
{
    QVariantList ports;
    const QStringList names = openPortNames(d);
    ports.reserve(names.size());
    for (const QString &name : names) {
        const QSerialPort *serialPort = d->serialPorts.value(name, nullptr);
        if (!serialPort) {
            continue;
        }

        QVariantMap port;
        port.insert(QStringLiteral("portName"), name);
        port.insert(QStringLiteral("isOpen"), serialPort->isOpen());
        port.insert(QStringLiteral("baudRate"), serialPort->baudRate());
        port.insert(QStringLiteral("dataBits"), static_cast<int>(serialPort->dataBits()));
        port.insert(QStringLiteral("parity"), static_cast<int>(serialPort->parity()));
        port.insert(QStringLiteral("stopBits"), static_cast<int>(serialPort->stopBits()));
        port.insert(QStringLiteral("flowControl"), static_cast<int>(serialPort->flowControl()));
        port.insert(QStringLiteral("errorString"), serialPort->errorString());
        ports.push_back(port);
    }
    return ports;
}

QSerialPort *ensureSerialPort(MosSerialPortManager *q,
                              MosSerialPortManagerPrivate *d,
                              const QString &portName)
{
    QSerialPort *serialPort = d->serialPorts.value(portName, nullptr);
    if (serialPort) {
        return serialPort;
    }

    serialPort = new QSerialPort(q);
    serialPort->setReadBufferSize(1024 * 1024);
    d->serialPorts.insert(portName, serialPort);

    QObject::connect(serialPort, &QSerialPort::readyRead, q, [q, serialPort, portName]() {
        const QByteArray data = serialPort->readAll();
        if (data.isEmpty()) {
            return;
        }

        const QString text = QString::fromUtf8(data);
        const QString hex = toHexString(data);
        emit q->dataReceivedFromPort(portName, data, text, hex);
        emit q->dataReceived(data, text, hex);
    });

    QObject::connect(serialPort, &QSerialPort::bytesWritten, q, [q, portName](qint64 bytes) {
        emit q->bytesWrittenFromPort(portName, bytes);
        emit q->bytesWritten(bytes);
    });

    QObject::connect(serialPort, &QSerialPort::errorOccurred, q, [q, d, serialPort, portName](QSerialPort::SerialPortError error) {
        if (error == QSerialPort::NoError) {
            return;
        }

        const QString message = serialPort->errorString();
        if (error == QSerialPort::ResourceError) {
            serialPort->close();
            syncCurrentOpenState(q, d);
            emitOpenPortsChanged(q);
        }
        setError(q, d, portName, message);
    });

    return serialPort;
}

} // namespace

MosSerialPortManager::MosSerialPortManager(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosSerialPortManagerPrivate(this))
{
}

MosSerialPortManager::~MosSerialPortManager()
{
    closeAllPorts();
}

MosSerialPortManager *MosSerialPortManager::instance()
{
    static MosSerialPortManager ins;
    return &ins;
}

MosSerialPortManager *MosSerialPortManager::create(QQmlEngine *, QJSEngine *)
{
    auto *manager = instance();
    QQmlEngine::setObjectOwnership(manager, QQmlEngine::CppOwnership);
    return manager;
}

QVariantList MosSerialPortManager::portInfoList() const
{
    Q_D(const MosSerialPortManager);
    return d->portInfoList;
}

bool MosSerialPortManager::isOpen() const
{
    Q_D(const MosSerialPortManager);
    return d->isOpen;
}

QString MosSerialPortManager::currentPortName() const
{
    Q_D(const MosSerialPortManager);
    return d->currentPortName;
}

QString MosSerialPortManager::errorString() const
{
    Q_D(const MosSerialPortManager);
    return d->errorString;
}

QStringList MosSerialPortManager::openPortNames() const
{
    Q_D(const MosSerialPortManager);
    return ::openPortNames(d);
}

QVariantList MosSerialPortManager::openPortList() const
{
    Q_D(const MosSerialPortManager);
    return ::openPortList(d);
}

QVariantList MosSerialPortManager::refreshPorts()
{
    Q_D(MosSerialPortManager);

    QVariantList ports;
    const auto infos = QSerialPortInfo::availablePorts();
    ports.reserve(infos.size());
    for (const QSerialPortInfo &info : infos) {
        QVariantMap port;
        const QString description = info.description();
        const QString label = description.isEmpty() ? info.portName()
                                                    : QStringLiteral("%1 (%2)").arg(info.portName(), description);
        port.insert(QStringLiteral("value"), info.portName());
        port.insert(QStringLiteral("label"), label);
        port.insert(QStringLiteral("portName"), info.portName());
        port.insert(QStringLiteral("systemLocation"), info.systemLocation());
        port.insert(QStringLiteral("description"), description);
        port.insert(QStringLiteral("manufacturer"), info.manufacturer());
        port.insert(QStringLiteral("serialNumber"), info.serialNumber());
        if (info.hasVendorIdentifier()) {
            port.insert(QStringLiteral("vendorIdentifier"), info.vendorIdentifier());
        }
        if (info.hasProductIdentifier()) {
            port.insert(QStringLiteral("productIdentifier"), info.productIdentifier());
        }
        ports.push_back(port);
    }

    d->portInfoList = ports;
    emit portInfoListChanged();
    return d->portInfoList;
}

bool MosSerialPortManager::selectPort(const QString &portName)
{
    Q_D(MosSerialPortManager);

    const QString cleanPortName = portName.trimmed();
    if (cleanPortName.isEmpty()) {
        setError(this, d, tr("Serial port name is empty."));
        return false;
    }

    setCurrentPortName(this, d, cleanPortName);
    return true;
}

bool MosSerialPortManager::isPortOpen(const QString &portName) const
{
    Q_D(const MosSerialPortManager);
    return portIsOpen(d, portName.trimmed());
}

bool MosSerialPortManager::openPort(const QString &portName,
                                    int baudRate,
                                    int dataBits,
                                    const QString &parity,
                                    const QString &stopBits,
                                    const QString &flowControl)
{
    Q_D(MosSerialPortManager);

    const QString cleanPortName = portName.trimmed();
    if (cleanPortName.isEmpty()) {
        setError(this, d, tr("Serial port name is empty."));
        return false;
    }

    QSerialPort *serialPort = ensureSerialPort(this, d, cleanPortName);
    const bool wasOpen = serialPort->isOpen();
    if (wasOpen) {
        serialPort->close();
    }

    serialPort->setPortName(cleanPortName);
    serialPort->setBaudRate(baudRate);
    serialPort->setDataBits(parseDataBits(dataBits));
    serialPort->setParity(parseParity(parity));
    serialPort->setStopBits(parseStopBits(stopBits));
    serialPort->setFlowControl(parseFlowControl(flowControl));

    if (!serialPort->open(QIODevice::ReadWrite)) {
        setCurrentPortName(this, d, cleanPortName);
        if (wasOpen) {
            emitOpenPortsChanged(this);
        }
        setError(this, d, cleanPortName, serialPort->errorString());
        return false;
    }

    serialPort->clear();
    setCurrentPortName(this, d, cleanPortName);
    emitOpenPortsChanged(this);
    clearError();
    return true;
}

void MosSerialPortManager::closePort()
{
    Q_D(MosSerialPortManager);
    if (d->currentPortName.isEmpty()) {
        return;
    }
    closePort(d->currentPortName);
}

void MosSerialPortManager::closePort(const QString &portName)
{
    Q_D(MosSerialPortManager);

    const QString cleanPortName = portName.trimmed();
    if (cleanPortName.isEmpty()) {
        closePort();
        return;
    }

    QSerialPort *serialPort = d->serialPorts.take(cleanPortName);
    if (!serialPort) {
        setError(this, d, cleanPortName, tr("Serial port is not open."));
        return;
    }

    if (serialPort->isOpen()) {
        serialPort->close();
    }
    serialPort->deleteLater();

    emitOpenPortsChanged(this);
    syncCurrentOpenState(this, d);
}

void MosSerialPortManager::closeAllPorts()
{
    Q_D(MosSerialPortManager);

    if (d->serialPorts.isEmpty()) {
        setCurrentPortName(this, d, QString());
        return;
    }

    const auto ports = d->serialPorts;
    d->serialPorts.clear();
    for (QSerialPort *serialPort : ports) {
        if (!serialPort) {
            continue;
        }
        if (serialPort->isOpen()) {
            serialPort->close();
        }
        serialPort->deleteLater();
    }

    emitOpenPortsChanged(this);
    setCurrentPortName(this, d, QString());
}

bool MosSerialPortManager::writeText(const QString &text)
{
    return writeBytes(text.toUtf8());
}

bool MosSerialPortManager::writeTextToPort(const QString &portName, const QString &text)
{
    return writeBytesToPort(portName, text.toUtf8());
}

bool MosSerialPortManager::writeHex(const QString &hexText)
{
    Q_D(MosSerialPortManager);
    if (d->currentPortName.isEmpty()) {
        setError(this, d, tr("Serial port is not open."));
        return false;
    }

    return writeHexToPort(d->currentPortName, hexText);
}

bool MosSerialPortManager::writeHexToPort(const QString &portName, const QString &hexText)
{
    bool ok = false;
    const QByteArray data = parseHexText(hexText, &ok);
    if (!ok) {
        Q_D(MosSerialPortManager);
        setError(this, d, portName.trimmed(), tr("Invalid HEX data."));
        return false;
    }
    return writeBytesToPort(portName, data);
}

bool MosSerialPortManager::writeBytes(const QByteArray &data)// 写入字节数组
{
    Q_D(MosSerialPortManager);
    if (d->currentPortName.isEmpty()) {
        setError(this, d, tr("Serial port is not open."));
        return false;
    }

    return writeBytesToPort(d->currentPortName, data);
}

bool MosSerialPortManager::writeBytesToPort(const QString &portName, const QByteArray &data)
{
    Q_D(MosSerialPortManager);

    const QString cleanPortName = portName.trimmed();
    QSerialPort *serialPort = d->serialPorts.value(cleanPortName, nullptr);
    if (!serialPort || !serialPort->isOpen()) {
        setError(this, d, cleanPortName, tr("Serial port is not open."));
        return false;
    }

    if (data.isEmpty()) {
        return true;
    }

    const qint64 written = serialPort->write(data);
    if (written != data.size()) {
        setError(this, d, cleanPortName, serialPort->errorString());
        return false;
    }

    serialPort->flush();
    return true;
}

void MosSerialPortManager::clearError()
{
    Q_D(MosSerialPortManager);
    if (d->errorString.isEmpty()) {
        return;
    }

    d->errorString.clear();
    emit errorStringChanged();
}

QString MosSerialPortManager::bytesToHex(const QByteArray &data) const
{
    return toHexString(data);
}
