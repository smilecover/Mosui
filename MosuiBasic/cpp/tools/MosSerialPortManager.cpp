#include "MosSerialPortManager.h"
#include "MosSerialPortManager_p.h"

#include <QIODevice>
#include <QQmlEngine>
#include <QSerialPortInfo>
#include <QStringList>
#include <QVariantMap>

namespace {

QString toHexString(const QByteArray &data)
{
    return QString::fromLatin1(data.toHex(' ').toUpper());
}

void setError(MosSerialPortManager *q, MosSerialPortManagerPrivate *d, const QString &message)
{
    if (d->errorString == message) {
        emit q->errorOccurred(message);
        return;
    }

    d->errorString = message;
    emit q->errorStringChanged();
    emit q->errorOccurred(message);
}

void setOpen(MosSerialPortManager *q, MosSerialPortManagerPrivate *d, bool open)
{
    if (d->isOpen == open) {
        return;
    }

    d->isOpen = open;
    emit q->isOpenChanged();
}

void setCurrentPortName(MosSerialPortManager *q, MosSerialPortManagerPrivate *d, const QString &portName)
{
    if (d->currentPortName == portName) {
        return;
    }

    d->currentPortName = portName;
    emit q->currentPortNameChanged();
}

QSerialPort::DataBits parseDataBits(int value)
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

QByteArray parseHexText(QString text, bool *ok)
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

} // namespace

MosSerialPortManager::MosSerialPortManager(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosSerialPortManagerPrivate(this))
{
    Q_D(MosSerialPortManager);
    d->serialPort.setReadBufferSize(1024 * 1024);

    connect(&d->serialPort, &QSerialPort::readyRead, this, [this]() {
        Q_D(MosSerialPortManager);
        const QByteArray data = d->serialPort.readAll();
        if (data.isEmpty()) {
            return;
        }
        emit dataReceived(data, QString::fromUtf8(data), toHexString(data));
    });

    connect(&d->serialPort, &QSerialPort::bytesWritten, this, &MosSerialPortManager::bytesWritten);

    connect(&d->serialPort, &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError error) {
        if (error == QSerialPort::NoError) {
            return;
        }

        Q_D(MosSerialPortManager);
        const QString message = d->serialPort.errorString();
        if (error == QSerialPort::ResourceError) {
            d->serialPort.close();
            setOpen(this, d, false);
        }
        setError(this, d, message);
    });
}

MosSerialPortManager::~MosSerialPortManager()
{
    closePort();
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

    if (d->serialPort.isOpen()) {
        d->serialPort.close();
        setOpen(this, d, false);
    }

    d->serialPort.setPortName(cleanPortName);
    d->serialPort.setBaudRate(baudRate);
    d->serialPort.setDataBits(parseDataBits(dataBits));
    d->serialPort.setParity(parseParity(parity));
    d->serialPort.setStopBits(parseStopBits(stopBits));
    d->serialPort.setFlowControl(parseFlowControl(flowControl));

    if (!d->serialPort.open(QIODevice::ReadWrite)) {
        setCurrentPortName(this, d, cleanPortName);
        setError(this, d, d->serialPort.errorString());
        return false;
    }

    d->serialPort.clear();
    setCurrentPortName(this, d, cleanPortName);
    setOpen(this, d, true);
    clearError();
    return true;
}

void MosSerialPortManager::closePort()
{
    Q_D(MosSerialPortManager);
    if (d->serialPort.isOpen()) {
        d->serialPort.close();
    }
    setOpen(this, d, false);
}

bool MosSerialPortManager::writeText(const QString &text)
{
    return writeBytes(text.toUtf8());
}

bool MosSerialPortManager::writeHex(const QString &hexText)
{
    bool ok = false;
    const QByteArray data = parseHexText(hexText, &ok);
    if (!ok) {
        Q_D(MosSerialPortManager);
        setError(this, d, tr("Invalid HEX data."));
        return false;
    }
    return writeBytes(data);
}

bool MosSerialPortManager::writeBytes(const QByteArray &data)
{
    Q_D(MosSerialPortManager);
    if (!d->serialPort.isOpen()) {
        setError(this, d, tr("Serial port is not open."));
        return false;
    }

    if (data.isEmpty()) {
        return true;
    }

    const qint64 written = d->serialPort.write(data);
    if (written != data.size()) {
        setError(this, d, d->serialPort.errorString());
        return false;
    }

    d->serialPort.flush();
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
