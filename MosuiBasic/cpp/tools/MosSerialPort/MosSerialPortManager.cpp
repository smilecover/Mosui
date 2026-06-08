#include "MosSerialPortManager.h"
#include "MosSerialPortManager_p.h"

#include <QHash>
#include <QIODevice>
#include <QMetaObject>
#include <QQmlEngine>
#include <QSemaphore>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QStringList>
#include <QThread>
#include <QVariantMap>

#include <functional>
#include <memory>
#include <optional>

namespace {

constexpr int SerialOperationTimeoutMs = 1500;
constexpr int SerialShutdownTimeoutMs = 3000;

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
    if (d->isOpen == open)
        return;

    d->isOpen = open;
    emit q->isOpenChanged();
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
    if (value == "even" || value == "鍋?")
        return QSerialPort::EvenParity;
    if (value == "odd" || value == "濂?")
        return QSerialPort::OddParity;
    if (value == "mark")
        return QSerialPort::MarkParity;
    if (value == "space")
        return QSerialPort::SpaceParity;
    return QSerialPort::NoParity;
}

QSerialPort::StopBits parseStopBits(QString value)
{
    value = value.trimmed().toLower();
    if (value == "1.5")
        return QSerialPort::OneAndHalfStop;
    if (value == "2")
        return QSerialPort::TwoStop;
    return QSerialPort::OneStop;
}

QSerialPort::FlowControl parseFlowControl(QString value)
{
    value = value.trimmed().toLower();
    if (value == "hardware" || value == "纭欢")
        return QSerialPort::HardwareControl;
    if (value == "software" || value == "杞欢")
        return QSerialPort::SoftwareControl;
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

QString mapPortName(const QVariantMap &port)
{
    return port.value(QStringLiteral("portName")).toString();
}

bool mapPortIsOpen(const QVariantMap &port)
{
    return port.value(QStringLiteral("isOpen")).toBool();
}

QStringList openPortNames(const QVariantList &ports)
{
    QStringList names;
    for (const QVariant &value : ports) {
        const QVariantMap port = value.toMap();
        if (mapPortIsOpen(port))
            names.push_back(mapPortName(port));
    }
    names.sort();
    return names;
}

bool portIsOpen(const MosSerialPortManagerPrivate *d, const QString &portName)
{
    for (const QVariant &value : d->openPortList) {
        const QVariantMap port = value.toMap();
        if (mapPortName(port) == portName)
            return mapPortIsOpen(port);
    }
    return false;
}

int openPortCount(const MosSerialPortManagerPrivate *d)
{
    return openPortNames(d->openPortList).size();
}

void syncCurrentOpenState(MosSerialPortManager *q, MosSerialPortManagerPrivate *d)
{
    setOpen(q, d, portIsOpen(d, d->currentPortName));
}

void emitOpenPortsChanged(MosSerialPortManager *q)
{
    emit q->openPortsChanged();
}

bool setOpenPortList(MosSerialPortManagerPrivate *d, const QVariantList &openPorts)
{
    if (d->openPortList == openPorts)
        return false;

    d->openPortList = openPorts;
    return true;
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
    if (!portName.isEmpty())
        emit q->errorOccurredFromPort(portName, message);
}

void ensureCurrentOpenPort(MosSerialPortManager *q, MosSerialPortManagerPrivate *d)
{
    if (!d->currentPortName.isEmpty() && portIsOpen(d, d->currentPortName)) {
        syncCurrentOpenState(q, d);
        return;
    }

    const QStringList names = openPortNames(d->openPortList);
    setCurrentPortName(q, d, names.isEmpty() ? QString() : names.first());
}

} // namespace

class MosSerialPortWorker : public QObject
{
public:
    struct OperationResult {
        bool ok { false };
        QString error;
        bool openPortsChanged { false };
        QVariantList openPorts;
    };

    using DataCallback = std::function<void(QString, QByteArray, QString, QString)>;
    using BytesCallback = std::function<void(const QString &, qint64)>;
    using ErrorCallback = std::function<void(QString, QString, bool, QVariantList)>;

    MosSerialPortWorker(DataCallback dataCallback,
                        BytesCallback bytesCallback,
                        ErrorCallback errorCallback)
        : dataCallback_(std::move(dataCallback)),
          bytesCallback_(std::move(bytesCallback)),
          errorCallback_(std::move(errorCallback))
    {
    }

    ~MosSerialPortWorker() override
    {
        closeAllPorts();
    }

    OperationResult openPort(const QString &portName,
                             int baudRate,
                             int dataBits,
                             const QString &parity,
                             const QString &stopBits,
                             const QString &flowControl)
    {
        OperationResult result;
        QSerialPort *serialPort = ensureSerialPort(portName);
        if (serialPort->isOpen())
            serialPort->close();

        serialPort->setPortName(portName);
        serialPort->setBaudRate(baudRate);
        serialPort->setDataBits(parseDataBits(dataBits));
        serialPort->setParity(parseParity(parity));
        serialPort->setStopBits(parseStopBits(stopBits));
        serialPort->setFlowControl(parseFlowControl(flowControl));

        result.ok = serialPort->open(QIODevice::ReadWrite);
        if (result.ok) {
            serialPort->clear();
        } else {
            result.error = serialPort->errorString();
        }

        result.openPortsChanged = true;
        result.openPorts = openPortList();
        return result;
    }

    OperationResult closePort(const QString &portName)
    {
        OperationResult result;
        QSerialPort *serialPort = serialPorts_.take(portName);
        if (!serialPort) {
            result.error = tr("Serial port is not open.");
            result.openPortsChanged = true;
            result.openPorts = openPortList();
            return result;
        }

        if (serialPort->isOpen())
            serialPort->close();
        serialPort->deleteLater();

        result.ok = true;
        result.openPortsChanged = true;
        result.openPorts = openPortList();
        return result;
    }

    OperationResult closeAllPorts()
    {
        OperationResult result;
        const auto ports = serialPorts_;
        serialPorts_.clear();
        for (QSerialPort *serialPort : ports) {
            if (!serialPort)
                continue;
            if (serialPort->isOpen())
                serialPort->close();
            serialPort->deleteLater();
        }
        result.ok = true;
        result.openPortsChanged = true;
        result.openPorts = openPortList();
        return result;
    }

    OperationResult SendBytesToPort(const QString &portName, const QByteArray &data)
    {
        OperationResult result;
        QSerialPort *serialPort = serialPorts_.value(portName, nullptr);
        if (!serialPort || !serialPort->isOpen()) {
            result.error = tr("Serial port is not open.");
            result.openPortsChanged = true;
            result.openPorts = openPortList();
            return result;
        }

        if (data.isEmpty()) {
            result.ok = true;
            return result;
        }

        const qint64 written = serialPort->write(data);
        result.ok = written == data.size();
        if (!result.ok)
            result.error = serialPort->errorString();
        serialPort->flush();
        return result;
    }

    QVariantList openPortList() const
    {
        QVariantList ports;
        const QStringList names = openPortNames();
        ports.reserve(names.size());
        for (const QString &name : names) {
            const QSerialPort *serialPort = serialPorts_.value(name, nullptr);
            if (!serialPort)
                continue;

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

private:
    QStringList openPortNames() const
    {
        QStringList names;
        for (auto it = serialPorts_.cbegin(); it != serialPorts_.cend(); ++it) {
            if (it.value() && it.value()->isOpen())
                names.push_back(it.key());
        }
        names.sort();
        return names;
    }

    QSerialPort *ensureSerialPort(const QString &portName)
    {
        QSerialPort *serialPort = serialPorts_.value(portName, nullptr);
        if (serialPort)
            return serialPort;

        serialPort = new QSerialPort(this);
        serialPort->setReadBufferSize(1024 * 1024);
        serialPorts_.insert(portName, serialPort);

        QObject::connect(serialPort, &QSerialPort::readyRead, this, [this, serialPort, portName]() {
            QByteArray data = serialPort->readAll();
            if (data.isEmpty())
                return;

            QString text = QString::fromUtf8(data);
            QString hex = toHexString(data);
            dataCallback_(portName, std::move(data), std::move(text), std::move(hex));
        });

        QObject::connect(serialPort, &QSerialPort::bytesWritten, this, [this, portName](qint64 bytes) {
            bytesCallback_(portName, bytes);
        });

        QObject::connect(serialPort, &QSerialPort::errorOccurred, this, [this, serialPort, portName](QSerialPort::SerialPortError error) {
            if (error == QSerialPort::NoError)
                return;

            const QString message = serialPort->errorString();
            const bool resourceError = error == QSerialPort::ResourceError;
            if (resourceError && serialPort->isOpen())
                serialPort->close();
            errorCallback_(portName, message, resourceError, resourceError ? openPortList() : QVariantList());
        });

        return serialPort;
    }

    QHash<QString, QSerialPort *> serialPorts_;
    DataCallback dataCallback_;
    BytesCallback bytesCallback_;
    ErrorCallback errorCallback_;
};

template <typename Function>
std::optional<MosSerialPortWorker::OperationResult> invokeOperation(MosSerialPortWorker *worker,
                                                                    int timeoutMs,
                                                                    Function &&function)
{
    if (!worker)
        return std::nullopt;
    if (QThread::currentThread() == worker->thread())
        return function();

    struct InvocationState {
        QSemaphore done { 0 };
        std::optional<MosSerialPortWorker::OperationResult> result;
    };

    auto state = std::make_shared<InvocationState>();
    const bool posted = QMetaObject::invokeMethod(worker,
                                                  [state, function = std::forward<Function>(function)]() mutable {
        state->result = function();
        state->done.release();
    }, Qt::QueuedConnection);

    if (!posted)
        return std::nullopt;
    if (!state->done.tryAcquire(1, timeoutMs))
        return std::nullopt;

    return std::move(state->result);
}

MosSerialPortManager::MosSerialPortManager(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosSerialPortManagerPrivate(this))
{
    Q_D(MosSerialPortManager);

    d->serialThread = new QThread(this);
    d->serialThread->setObjectName(QStringLiteral("MosSerialPortThread"));
    d->worker = new MosSerialPortWorker(
        [this](QString portName, QByteArray data, QString text, QString hex) {
            QMetaObject::invokeMethod(this,
                                      [this,
                                       portName = std::move(portName),
                                       data = std::move(data),
                                       text = std::move(text),
                                       hex = std::move(hex)]() {
                emit ReceiveDataFromPort(portName, data, text, hex);
                emit ReceiveData(data, text, hex);
            }, Qt::QueuedConnection);
        },
        [this](const QString &portName, qint64 bytes) {
            QMetaObject::invokeMethod(this, [this, portName, bytes]() {
                emit BytesSentFromPort(portName, bytes);
                emit BytesSent(bytes);
            }, Qt::QueuedConnection);
        },
        [this](QString portName, QString message, bool resourceError, QVariantList openPorts) {
            QMetaObject::invokeMethod(this,
                                      [this,
                                       portName = std::move(portName),
                                       message = std::move(message),
                                       resourceError,
                                       openPorts = std::move(openPorts)]() {
                Q_D(MosSerialPortManager);
                if (resourceError) {
                    const bool portsChanged = setOpenPortList(d, openPorts);
                    ensureCurrentOpenPort(this, d);
                    if (portsChanged)
                        emitOpenPortsChanged(this);
                }
                setError(this, d, portName, message);
            }, Qt::QueuedConnection);
        });

    d->worker->moveToThread(d->serialThread);
    connect(d->serialThread, &QThread::finished, d->worker, &QObject::deleteLater);
    d->serialThread->start();
}

MosSerialPortManager::~MosSerialPortManager()
{
    Q_D(MosSerialPortManager);

    if (d->worker)
        invokeOperation(d->worker, SerialShutdownTimeoutMs, [worker = d->worker]() {
            return worker->closeAllPorts();
        });

    if (d->serialThread) {
        d->serialThread->quit();
        if (!d->serialThread->wait(SerialShutdownTimeoutMs)) {
            d->serialThread->terminate();
            d->serialThread->wait();
        }
    }
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

bool MosSerialPortManager::hasOpenPorts() const
{
    return openPortCount() > 0;
}

int MosSerialPortManager::openPortCount() const
{
    Q_D(const MosSerialPortManager);
    return ::openPortCount(d);
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
    return ::openPortNames(d->openPortList);
}

QVariantList MosSerialPortManager::openPortList() const
{
    Q_D(const MosSerialPortManager);
    return d->openPortList;
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
        if (info.hasVendorIdentifier())
            port.insert(QStringLiteral("vendorIdentifier"), info.vendorIdentifier());
        if (info.hasProductIdentifier())
            port.insert(QStringLiteral("productIdentifier"), info.productIdentifier());
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

    const auto result = invokeOperation(d->worker,
                                        SerialOperationTimeoutMs,
                                        [worker = d->worker,
                                         cleanPortName,
                                         baudRate,
                                         dataBits,
                                         parity,
                                         stopBits,
                                         flowControl]() {
        return worker->openPort(cleanPortName, baudRate, dataBits, parity, stopBits, flowControl);
    });
    if (!result) {
        setError(this, d, cleanPortName, tr("Serial port operation timed out."));
        return false;
    }

    const bool portsChanged = result->openPortsChanged && setOpenPortList(d, result->openPorts);
    setCurrentPortName(this, d, cleanPortName);
    if (portsChanged)
        emitOpenPortsChanged(this);

    if (!result->ok) {
        setError(this, d, cleanPortName, result->error);
        return false;
    }

    clearError();
    return true;
}

void MosSerialPortManager::closePort()
{
    Q_D(MosSerialPortManager);
    if (d->currentPortName.isEmpty())
        return;
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

    const auto result = invokeOperation(d->worker,
                                        SerialOperationTimeoutMs,
                                        [worker = d->worker, cleanPortName]() {
        return worker->closePort(cleanPortName);
    });
    if (!result) {
        setError(this, d, cleanPortName, tr("Serial port operation timed out."));
        return;
    }

    const bool portsChanged = result->openPortsChanged && setOpenPortList(d, result->openPorts);
    if (!result->ok) {
        setError(this, d, cleanPortName, result->error);
        return;
    }

    if (d->currentPortName == cleanPortName) {
        const QStringList names = openPortNames();
        setCurrentPortName(this, d, names.isEmpty() ? QString() : names.first());
    } else {
        syncCurrentOpenState(this, d);
    }
    if (portsChanged)
        emitOpenPortsChanged(this);
}

void MosSerialPortManager::closeAllPorts()
{
    Q_D(MosSerialPortManager);

    const auto result = invokeOperation(d->worker,
                                        SerialOperationTimeoutMs,
                                        [worker = d->worker]() {
        return worker->closeAllPorts();
    });
    if (!result) {
        const bool portsChanged = !d->openPortList.isEmpty();
        setCurrentPortName(this, d, QString());
        d->openPortList.clear();
        if (portsChanged)
            emitOpenPortsChanged(this);
        return;
    }

    const bool portsChanged = result->openPortsChanged && setOpenPortList(d, result->openPorts);
    if (portsChanged)
        emitOpenPortsChanged(this);
    setCurrentPortName(this, d, QString());
}

bool MosSerialPortManager::SendText(const QString &text)
{
    return SendBytes(text.toUtf8());
}

bool MosSerialPortManager::SendTextToPort(const QString &portName, const QString &text)
{
    return SendBytesToPort(portName, text.toUtf8());
}

bool MosSerialPortManager::SendHex(const QString &hexText)
{
    Q_D(MosSerialPortManager);
    if (d->currentPortName.isEmpty()) {
        setError(this, d, tr("Serial port is not open."));
        return false;
    }

    return SendHexToPort(d->currentPortName, hexText);
}

bool MosSerialPortManager::SendHexToPort(const QString &portName, const QString &hexText)
{
    bool ok = false;
    const QByteArray data = parseHexText(hexText, &ok);
    if (!ok) {
        Q_D(MosSerialPortManager);
        setError(this, d, portName.trimmed(), tr("Invalid HEX data."));
        return false;
    }
    return SendBytesToPort(portName, data);
}

bool MosSerialPortManager::SendBytes(const QByteArray &data)
{
    Q_D(MosSerialPortManager);
    if (d->currentPortName.isEmpty()) {
        setError(this, d, tr("Serial port is not open."));
        return false;
    }

    return SendBytesToPort(d->currentPortName, data);
}

bool MosSerialPortManager::SendBytesToPort(const QString &portName, const QByteArray &data)
{
    Q_D(MosSerialPortManager);

    const QString cleanPortName = portName.trimmed();
    const auto result = invokeOperation(d->worker,
                                        SerialOperationTimeoutMs,
                                        [worker = d->worker, cleanPortName, data]() {
        return worker->SendBytesToPort(cleanPortName, data);
    });
    if (!result) {
        setError(this, d, cleanPortName, tr("Serial port operation timed out."));
        return false;
    }

    if (result->openPortsChanged) {
        const bool portsChanged = setOpenPortList(d, result->openPorts);
        ensureCurrentOpenPort(this, d);
        if (portsChanged)
            emitOpenPortsChanged(this);
    }
    if (!result->ok) {
        setError(this, d, cleanPortName, result->error);
        return false;
    }

    return true;
}

void MosSerialPortManager::clearError()
{
    Q_D(MosSerialPortManager);
    if (d->errorString.isEmpty())
        return;

    d->errorString.clear();
    emit errorStringChanged();
}

QString MosSerialPortManager::bytesToHex(const QByteArray &data) const
{
    return toHexString(data);
}
