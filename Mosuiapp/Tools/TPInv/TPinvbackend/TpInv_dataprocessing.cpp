#include "TpInv_dataprocessing.h"

#include "MosSerialPortManager.h"
#include "ring_buffer.h"

#include <QMetaObject>
#include <QQmlEngine>
#include <QThread>
#include <QTime>
#include <QTimer>
#include <QVariantMap>
#include <QtGlobal>

#include <algorithm>
#include <array>
#include <cmath>
#include <cstring>
#include <functional>
#include <utility>
#include <vector>

namespace {

float decodeSigned16(quint8 high, quint8 low)
{
    const quint16 raw = (static_cast<quint16>(high) << 8) | static_cast<quint16>(low);
    return static_cast<float>(static_cast<qint16>(raw));
}

float decodeUnsigned16LE(quint8 low, quint8 high)
{
    return static_cast<float>((static_cast<quint16>(high) << 8) | static_cast<quint16>(low));
}

} // namespace

class TpInvDataProcessingWorker : public QObject
{
public:
    using SnapshotCallback = std::function<void(int,
                                                int,
                                                int,
                                                const QVariantList &,
                                                const QVariantList &,
                                                const QVariantList &,
                                                const QVariantList &,
                                                const QVariantList &,
                                                const QVariantList &)>;

    explicit TpInvDataProcessingWorker(SnapshotCallback snapshotCallback)
        : rxBuffer_(RxBufferCapacity),
          sampleBuffer_(DefaultSampleCapacity * sizeof(Sample)),
          snapshotCallback_(std::move(snapshotCallback))
    {
    }

    void setSampleCapacity(int capacity)
    {
        const int normalized = std::max(1, capacity);
        if (sampleCapacity_ == normalized)
            return;

        sampleCapacity_ = normalized;
        sampleBuffer_.resizeCapacity(static_cast<tpinv::RingBuffer::size_type>(sampleCapacity_) * sizeof(Sample));
        while (sampleCount() > sampleCapacity_)
            sampleBuffer_.consume(sizeof(Sample));
        emitSnapshot();
    }

    void appendSerialData(const QByteArray &data)
    {
        if (data.isEmpty())
            return;

        rxBuffer_.pushOverwrite(reinterpret_cast<const tpinv::RingBuffer::value_type *>(data.constData()),
                                static_cast<tpinv::RingBuffer::size_type>(data.size()));

        const int initialParsedFrameCount = parsedFrameCount_;
        const int initialDroppedFrameCount = droppedFrameCount_;
        while (parseNextFrame()) {
        }

        if (parsedFrameCount_ != initialParsedFrameCount || droppedFrameCount_ != initialDroppedFrameCount)
            emitSnapshot();
    }

    void clear()
    {
        rxBuffer_.clear();
        sampleBuffer_.clear();
        parsedFrameCount_ = 0;
        droppedFrameCount_ = 0;
        lastControlSample_ = Sample {};
        hasLastControlSample_ = false;
        emitSnapshot();
    }

private:
    struct Sample {
        static constexpr int StorageChannelCount = 8;
        std::array<float, StorageChannelCount> values {};
    };

    enum Channel {
        VoltageA = 0,
        VoltageB,
        VoltageC,
        CurrentA,
        CurrentB,
        CurrentC,
        ChannelCount
    };

    static constexpr int WaveFrameSize = 16;
    static constexpr int ControlFrameSize = 20;
    static constexpr int WaveHeader0 = 0xFF;
    static constexpr int WaveHeader1 = 0xCC;
    static constexpr int ControlHeader = 0xAA;
    static constexpr int ControlFrameVoltages = 0xF0;
    static constexpr int ControlFrameCurrents = 0xF1;
    static constexpr int DefaultSampleCapacity = 512;
    static constexpr int RxBufferCapacity = 8192;

    int sampleCount() const
    {
        return static_cast<int>(sampleBuffer_.size() / sizeof(Sample));
    }

    bool tryReadByte(quint8 *value)
    {
        if (!value)
            return false;

        tpinv::RingBuffer::value_type byte = 0;
        if (!rxBuffer_.pop(byte))
            return false;

        *value = byte;
        return true;
    }

    bool parseNextFrame()
    {
        while (!rxBuffer_.empty()) {
            if (rxBuffer_[0] == WaveHeader0) {
                if (rxBuffer_.size() < WaveFrameSize)
                    return false;

                if (rxBuffer_[1] != WaveHeader1) {
                    quint8 ignored = 0;
                    tryReadByte(&ignored);
                    ++droppedFrameCount_;
                    continue;
                }

                std::array<quint8, WaveFrameSize> frame {};
                for (int i = 0; i < WaveFrameSize; ++i)
                    frame[i] = rxBuffer_[static_cast<tpinv::RingBuffer::size_type>(i)];

                if (!waveFrameChecksumIsValid(frame)) {
                    quint8 ignored = 0;
                    tryReadByte(&ignored);
                    ++droppedFrameCount_;
                    continue;
                }

                rxBuffer_.consume(WaveFrameSize);
                appendSample(decodeWaveSample(frame));
                ++parsedFrameCount_;
                return true;
            }

            if (rxBuffer_[0] == ControlHeader) {
                if (rxBuffer_.size() < ControlFrameSize)
                    return false;

                std::array<quint8, ControlFrameSize> frame {};
                for (int i = 0; i < ControlFrameSize; ++i)
                    frame[i] = rxBuffer_[static_cast<tpinv::RingBuffer::size_type>(i)];

                if (!controlFrameChecksumIsValid(frame)) {
                    quint8 ignored = 0;
                    tryReadByte(&ignored);
                    ++droppedFrameCount_;
                    continue;
                }

                rxBuffer_.consume(ControlFrameSize);
                appendControlSample(frame);
                ++parsedFrameCount_;
                return true;
            }

            quint8 ignored = 0;
            tryReadByte(&ignored);
            ++droppedFrameCount_;
        }

        return false;
    }

    bool waveFrameChecksumIsValid(const std::array<quint8, WaveFrameSize> &frame) const
    {
        quint16 sum = 0;
        for (int i = 0; i < WaveFrameSize - 2; ++i)
            sum = static_cast<quint16>(sum + frame[i]);

        return frame[WaveFrameSize - 2] == static_cast<quint8>((sum >> 8) & 0xFF)
                && frame[WaveFrameSize - 1] == static_cast<quint8>(sum & 0xFF);
    }

    bool controlFrameChecksumIsValid(const std::array<quint8, ControlFrameSize> &frame) const
    {
        quint16 sum = 0;
        for (int i = 0; i < ControlFrameSize - 2; ++i)
            sum = static_cast<quint16>(sum + frame[i]);

        return frame[ControlFrameSize - 2] == static_cast<quint8>(sum & 0xFF)
                && frame[ControlFrameSize - 1] == static_cast<quint8>((sum >> 8) & 0xFF);
    }

    Sample decodeWaveSample(const std::array<quint8, WaveFrameSize> &frame) const
    {
        Sample sample;
        sample.values[VoltageA] = decodeSigned16(frame[2], frame[3]) / 10.0f;
        sample.values[VoltageB] = decodeSigned16(frame[4], frame[5]) / 10.0f;
        sample.values[VoltageC] = decodeSigned16(frame[6], frame[7]) / 10.0f;
        sample.values[CurrentA] = decodeSigned16(frame[8], frame[9]) / 100.0f;
        sample.values[CurrentB] = decodeSigned16(frame[10], frame[11]) / 100.0f;
        sample.values[CurrentC] = decodeSigned16(frame[12], frame[13]) / 100.0f;
        return sample;
    }

    void appendControlSample(const std::array<quint8, ControlFrameSize> &frame)
    {
        Sample sample = hasLastControlSample_ ? lastControlSample_ : Sample {};
        bool hasSample = false;

        switch (frame[1]) {
        case ControlFrameVoltages:
            sample.values[VoltageA] = decodeUnsigned16LE(frame[6], frame[7]) / 10.0f;
            sample.values[VoltageB] = decodeUnsigned16LE(frame[8], frame[9]) / 10.0f;
            sample.values[VoltageC] = decodeUnsigned16LE(frame[10], frame[11]) / 10.0f;
            hasSample = true;
            break;
        case ControlFrameCurrents:
            sample.values[CurrentA] = decodeUnsigned16LE(frame[6], frame[7]) / 100.0f;
            sample.values[CurrentB] = decodeUnsigned16LE(frame[8], frame[9]) / 100.0f;
            sample.values[CurrentC] = decodeUnsigned16LE(frame[10], frame[11]) / 100.0f;
            hasSample = true;
            break;
        default:
            break;
        }

        if (!hasSample)
            return;

        lastControlSample_ = sample;
        hasLastControlSample_ = true;
        appendSample(sample);
    }

    void appendSample(const Sample &sample)
    {
        while (sampleCount() >= sampleCapacity_)
            sampleBuffer_.consume(sizeof(Sample));

        sampleBuffer_.pushOverwrite(reinterpret_cast<const tpinv::RingBuffer::value_type *>(&sample),
                                    sizeof(Sample));
    }

    QVariantList valuesForChannel(Channel channel) const
    {
        QVariantList result;
        const int count = sampleCount();
        result.reserve(count);

        if (count == 0)
            return result;

        std::vector<tpinv::RingBuffer::value_type> raw(static_cast<std::size_t>(count) * sizeof(Sample));
        sampleBuffer_.peek(raw.data(), raw.size());

        for (int i = 0; i < count; ++i) {
            Sample sample;
            std::memcpy(&sample, raw.data() + static_cast<std::size_t>(i) * sizeof(Sample), sizeof(Sample));
            result.push_back(sample.values[channel]);
        }

        return result;
    }

    void emitSnapshot()
    {
        snapshotCallback_(sampleCount(),
                          parsedFrameCount_,
                          droppedFrameCount_,
                          valuesForChannel(VoltageA),
                          valuesForChannel(VoltageB),
                          valuesForChannel(VoltageC),
                          valuesForChannel(CurrentA),
                          valuesForChannel(CurrentB),
                          valuesForChannel(CurrentC));
    }

    tpinv::RingBuffer rxBuffer_;
    tpinv::RingBuffer sampleBuffer_;
    int sampleCapacity_ = DefaultSampleCapacity;
    int parsedFrameCount_ = 0;
    int droppedFrameCount_ = 0;
    Sample lastControlSample_;
    bool hasLastControlSample_ = false;
    SnapshotCallback snapshotCallback_;
};

TpInvDataProcessing::TpInvDataProcessing(QObject *parent)
    : QObject(parent)
{
    // 下位机改为 100Hz 自动推送模式，不再需要主动请求
    workerThread_ = new QThread(this);
    workerThread_->setObjectName(QStringLiteral("TpInvDataProcessingThread"));
    worker_ = new TpInvDataProcessingWorker(
        [this](int sampleCount,
               int parsedFrameCount,
               int droppedFrameCount,
               const QVariantList &voltageAValues,
               const QVariantList &voltageBValues,
               const QVariantList &voltageCValues,
               const QVariantList &currentAValues,
               const QVariantList &currentBValues,
               const QVariantList &currentCValues) {
            QMetaObject::invokeMethod(this,
                                      [this,
                                       sampleCount,
                                       parsedFrameCount,
                                       droppedFrameCount,
                                       voltageAValues,
                                       voltageBValues,
                                       voltageCValues,
                                       currentAValues,
                                       currentBValues,
                                       currentCValues]() {
                applySnapshot(sampleCount,
                              parsedFrameCount,
                              droppedFrameCount,
                              voltageAValues,
                              voltageBValues,
                              voltageCValues,
                              currentAValues,
                              currentBValues,
                              currentCValues);
            }, Qt::QueuedConnection);
        });
    worker_->moveToThread(workerThread_);
    connect(workerThread_, &QThread::finished, worker_, &QObject::deleteLater);
    workerThread_->start();

    bindSerialManagerSignals();
    rebuildSeries();
}

TpInvDataProcessing::~TpInvDataProcessing()
{
    if (workerThread_) {
        workerThread_->quit();
        workerThread_->wait();
    }
}

TpInvDataProcessing *TpInvDataProcessing::instance()
{
    static TpInvDataProcessing *ins = new TpInvDataProcessing;
    return ins;
}

TpInvDataProcessing *TpInvDataProcessing::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *proc = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(proc, QQmlEngine::CppOwnership);
    }
    return proc;
}

int TpInvDataProcessing::sampleCapacity() const
{
    return sampleCapacity_;
}

void TpInvDataProcessing::setSampleCapacity(int capacity)
{
    const int normalized = std::max(1, capacity);
    if (sampleCapacity_ == normalized)
        return;

    sampleCapacity_ = normalized;
    QMetaObject::invokeMethod(worker_, [worker = worker_, normalized]() {
        worker->setSampleCapacity(normalized);
    }, Qt::QueuedConnection);
    emit sampleCapacityChanged();
}

int TpInvDataProcessing::sampleCount() const
{
    return sampleCount_;
}

int TpInvDataProcessing::parsedFrameCount() const
{
    return parsedFrameCount_;
}

int TpInvDataProcessing::droppedFrameCount() const
{
    return droppedFrameCount_;
}

QVariantList TpInvDataProcessing::portOptions() const
{
    return portOptions_;
}

QString TpInvDataProcessing::selectedPortName() const
{
    return selectedPortName_;
}

void TpInvDataProcessing::setSelectedPortName(const QString &portName)
{
    const QString cleanPortName = portName.trimmed();
    if (selectedPortName_ == cleanPortName)
        return;

    selectedPortName_ = cleanPortName;
    emit selectedPortNameChanged();
    updateWavePortOpen();
    syncConnectedBaudRate();

}

bool TpInvDataProcessing::wavePortOpen() const
{
    return wavePortOpen_;
}

int TpInvDataProcessing::selectedBaudRate() const
{
    return selectedBaudRate_;
}

void TpInvDataProcessing::setSelectedBaudRate(int baudRate)
{
    const int normalized = baudRate > 0 ? baudRate : 115200;
    if (selectedBaudRate_ == normalized)
        return;

    selectedBaudRate_ = normalized;
    emit selectedBaudRateChanged();
}

bool TpInvDataProcessing::waveformPaused() const
{
    return waveformPaused_;
}

void TpInvDataProcessing::setWaveformPaused(bool paused)
{
    if (waveformPaused_ == paused)
        return;

    waveformPaused_ = paused;
    emit waveformPausedChanged();
    if (!waveformPaused_)
        rebuildSeries();

}

int TpInvDataProcessing::receivedByteCount() const
{
    return receivedByteCount_;
}

QString TpInvDataProcessing::lastWaveHex() const
{
    return lastWaveHex_;
}

QString TpInvDataProcessing::lastWaveText() const
{
    return lastWaveText_;
}

QString TpInvDataProcessing::lastWaveRxTime() const
{
    return lastWaveRxTime_;
}

QString TpInvDataProcessing::waveStatusText() const
{
    return waveStatusText_;
}

bool TpInvDataProcessing::voltageAEnabled() const
{
    return voltageAEnabled_;
}

void TpInvDataProcessing::setVoltageAEnabled(bool enabled)
{
    if (voltageAEnabled_ == enabled)
        return;

    voltageAEnabled_ = enabled;
    emit channelEnabledChanged();
    rebuildVoltageSeries();
}

bool TpInvDataProcessing::voltageBEnabled() const
{
    return voltageBEnabled_;
}

void TpInvDataProcessing::setVoltageBEnabled(bool enabled)
{
    if (voltageBEnabled_ == enabled)
        return;

    voltageBEnabled_ = enabled;
    emit channelEnabledChanged();
    rebuildVoltageSeries();
}

bool TpInvDataProcessing::voltageCEnabled() const
{
    return voltageCEnabled_;
}

void TpInvDataProcessing::setVoltageCEnabled(bool enabled)
{
    if (voltageCEnabled_ == enabled)
        return;

    voltageCEnabled_ = enabled;
    emit channelEnabledChanged();
    rebuildVoltageSeries();
}

bool TpInvDataProcessing::currentAEnabled() const
{
    return currentAEnabled_;
}

void TpInvDataProcessing::setCurrentAEnabled(bool enabled)
{
    if (currentAEnabled_ == enabled)
        return;

    currentAEnabled_ = enabled;
    emit channelEnabledChanged();
    rebuildCurrentSeries();
}

bool TpInvDataProcessing::currentBEnabled() const
{
    return currentBEnabled_;
}

void TpInvDataProcessing::setCurrentBEnabled(bool enabled)
{
    if (currentBEnabled_ == enabled)
        return;

    currentBEnabled_ = enabled;
    emit channelEnabledChanged();
    rebuildCurrentSeries();
}

bool TpInvDataProcessing::currentCEnabled() const
{
    return currentCEnabled_;
}

void TpInvDataProcessing::setCurrentCEnabled(bool enabled)
{
    if (currentCEnabled_ == enabled)
        return;

    currentCEnabled_ = enabled;
    emit channelEnabledChanged();
    rebuildCurrentSeries();
}

QVariantList TpInvDataProcessing::voltageSeries() const
{
    return voltageSeries_;
}

QVariantList TpInvDataProcessing::currentSeries() const
{
    return currentSeries_;
}

QVariantList TpInvDataProcessing::voltageAValues() const
{
    return voltageAValues_;
}

QVariantList TpInvDataProcessing::voltageBValues() const
{
    return voltageBValues_;
}

QVariantList TpInvDataProcessing::voltageCValues() const
{
    return voltageCValues_;
}

QVariantList TpInvDataProcessing::currentAValues() const
{
    return currentAValues_;
}

QVariantList TpInvDataProcessing::currentBValues() const
{
    return currentBValues_;
}

QVariantList TpInvDataProcessing::currentCValues() const
{
    return currentCValues_;
}

void TpInvDataProcessing::appendSerialData(const QByteArray &data)
{
    if (data.isEmpty())
        return;

    QMetaObject::invokeMethod(worker_, [worker = worker_, data]() {
        worker->appendSerialData(data);
    }, Qt::QueuedConnection);
}

void TpInvDataProcessing::clear()
{
    resetCachedValues();
    QMetaObject::invokeMethod(worker_, [worker = worker_]() {
        worker->clear();
    }, Qt::QueuedConnection);
}

QVariantList TpInvDataProcessing::channelValues(int channel) const
{
    switch (channel) {
    case VoltageA: return voltageAValues_;
    case VoltageB: return voltageBValues_;
    case VoltageC: return voltageCValues_;
    case CurrentA: return currentAValues_;
    case CurrentB: return currentBValues_;
    case CurrentC: return currentCValues_;
    default: return {};
    }
}

void TpInvDataProcessing::initializeWavePage(int capacity)
{
    setSampleCapacity(capacity);
    clear();
    refreshSerialPorts();
    updateWavePortOpen();
    setWaveStatusText(wavePortOpen_ ? QStringLiteral("等待波形数据") : QStringLiteral("串口未连接"));

}

QVariantList TpInvDataProcessing::refreshSerialPorts()
{
    const QVariantList ports = MosSerialPortManager::instance()->refreshPorts();
    if (portOptions_ != ports) {
        portOptions_ = ports;
        emit portOptionsChanged();
    }

    if (selectedPortName_.isEmpty() || !hasPort(selectedPortName_)) {
        const QString nextPort = firstAvailablePort();
        if (selectedPortName_ != nextPort) {
            selectedPortName_ = nextPort;
            emit selectedPortNameChanged();
        }
    }

    updateWavePortOpen();
    syncConnectedBaudRate();

    return portOptions_;
}

bool TpInvDataProcessing::toggleSerialPort()
{
    auto *serialManager = MosSerialPortManager::instance();
    if (selectedPortName_.isEmpty())
        refreshSerialPorts();

    if (selectedPortName_.isEmpty()) {
        setWaveStatusText(QStringLiteral("未找到可用串口"));
        return false;
    }

    if (serialManager->isPortOpen(selectedPortName_)) {
        serialManager->closePort(selectedPortName_);
        updateWavePortOpen();
    
        setWaveStatusText(QStringLiteral("串口已关闭"));
        return true;
    }

    const QString previousPortName = serialManager->currentPortName();
    const bool opened = serialManager->openPort(selectedPortName_,
                                                selectedBaudRate_,
                                                8,
                                                QStringLiteral("none"),
                                                QStringLiteral("1"),
                                                QStringLiteral("none"));
    if (opened
            && !previousPortName.isEmpty()
            && previousPortName != selectedPortName_
            && serialManager->isPortOpen(previousPortName)) {
        serialManager->selectPort(previousPortName);
    }

    updateWavePortOpen();
    syncConnectedBaudRate();

    setWaveStatusText(opened ? QStringLiteral("等待波形数据")
                             : QStringLiteral("打开串口失败: %1").arg(serialManager->errorString()));
    return opened;
}

void TpInvDataProcessing::clearWaveformData()
{
    clear();
    resetReceiveInfo();
    setWaveStatusText(QStringLiteral("已清空波形数据"));
}

// void TpInvDataProcessing::generateMockData(int count)
// {
//     const int n = std::max(1, count);
//     constexpr int samplesPerCycle = 100;
//     constexpr double voltageAmplitude = 311.0;
//     constexpr double currentAmplitude = 10.0;
//     constexpr double pi = 3.14159265358979323846;
//     constexpr double phaseB = 2.0 * pi / 3.0;
//     constexpr double phaseC = 4.0 * pi / 3.0;

//     QVariantList va, vb, vc, ca, cb, cc;
//     va.reserve(n);
//     vb.reserve(n);
//     vc.reserve(n);
//     ca.reserve(n);
//     cb.reserve(n);
//     cc.reserve(n);

//     for (int i = 0; i < n; ++i) {
//         const double angle = (i % samplesPerCycle) * 2.0 * pi / static_cast<double>(samplesPerCycle);

//         const double vA = voltageAmplitude * (std::sin(angle)
//                            + 0.08 * std::sin(3.0 * angle)
//                            + 0.03 * std::sin(5.0 * angle));
//         const double vB = voltageAmplitude * (std::sin(angle + phaseB)
//                            + 0.08 * std::sin(3.0 * angle)
//                            + 0.03 * std::sin(5.0 * angle));
//         const double vC = voltageAmplitude * (std::sin(angle + phaseC)
//                            + 0.08 * std::sin(3.0 * angle)
//                            + 0.03 * std::sin(5.0 * angle));

//         const double cA = currentAmplitude * (std::sin(angle)
//                            + 0.04 * std::sin(3.0 * angle));
//         const double cB = currentAmplitude * (std::sin(angle + phaseB)
//                            + 0.04 * std::sin(3.0 * angle));
//         const double cC = currentAmplitude * (std::sin(angle + phaseC)
//                            + 0.04 * std::sin(3.0 * angle));

//         va.append(vA);
//         vb.append(vB);
//         vc.append(vC);
//         ca.append(cA);
//         cb.append(cB);
//         cc.append(cC);
//     }

//     applySnapshot(n, 1, 0, va, vb, vc, ca, cb, cc);
//     setWaveStatusText(QStringLiteral("模拟波形数据 (%1 点)").arg(n));
// }

QString TpInvDataProcessing::compactHex(const QString &hex) const
{
    const QString compact = hex.simplified();
    constexpr qsizetype MaxLength = 96;
    if (compact.size() <= MaxLength)
        return compact;
    return compact.left(MaxLength) + QStringLiteral(" ...");
}

void TpInvDataProcessing::bindSerialManagerSignals()
{
    auto *serialManager = MosSerialPortManager::instance();
    connect(serialManager, &MosSerialPortManager::openPortsChanged, this, [this]() {
        updateWavePortOpen();
        syncConnectedBaudRate();
    
    });

    connect(serialManager,
            &MosSerialPortManager::ReceiveDataFromPort,
            this,
            &TpInvDataProcessing::handleSerialData);

    connect(serialManager,
            &MosSerialPortManager::errorOccurredFromPort,
            this,
            [this](const QString &portName, const QString &message) {
        if (portName == selectedPortName_)
            setWaveStatusText(QStringLiteral("串口错误: %1").arg(message));
    });
}

void TpInvDataProcessing::updateWavePortOpen()
{
    const bool open = !selectedPortName_.isEmpty()
            && MosSerialPortManager::instance()->isPortOpen(selectedPortName_);
    if (wavePortOpen_ == open)
        return;

    wavePortOpen_ = open;
    emit wavePortOpenChanged();
    if (!wavePortOpen_)
        setWaveStatusText(QStringLiteral("串口未连接"));
}

void TpInvDataProcessing::syncConnectedBaudRate()
{
    if (selectedPortName_.isEmpty())
        return;

    const QVariantList openPorts = MosSerialPortManager::instance()->openPortList();
    for (const QVariant &value : openPorts) {
        const QVariantMap port = value.toMap();
        if (port.value(QStringLiteral("portName")).toString() != selectedPortName_)
            continue;

        const int baudRate = port.value(QStringLiteral("baudRate"), selectedBaudRate_).toInt();
        if (baudRate > 0 && selectedBaudRate_ != baudRate) {
            selectedBaudRate_ = baudRate;
            emit selectedBaudRateChanged();
        }
        return;
    }
}


void TpInvDataProcessing::handleSerialData(const QString &portName,
                                           const QByteArray &data,
                                           const QString &text,
                                           const QString &hex)
{
    if (portName != selectedPortName_ || data.isEmpty())
        return;

    receivedByteCount_ += data.size();
    lastWaveHex_ = hex;
    lastWaveText_ = text;
    lastWaveRxTime_ = QTime::currentTime().toString(QStringLiteral("hh:mm:ss.zzz"));
    emit receiveInfoChanged();

    setWaveStatusText(QStringLiteral("收到数据，等待解析"));
    appendSerialData(data);
}

void TpInvDataProcessing::setWaveStatusText(const QString &text)
{
    if (waveStatusText_ == text)
        return;

    waveStatusText_ = text;
    emit waveStatusTextChanged();
}

void TpInvDataProcessing::resetReceiveInfo()
{
    receivedByteCount_ = 0;
    lastWaveHex_.clear();
    lastWaveText_.clear();
    lastWaveRxTime_.clear();
    emit receiveInfoChanged();
}

bool TpInvDataProcessing::hasPort(const QString &portName) const
{
    if (portName.isEmpty())
        return false;

    for (const QVariant &value : portOptions_) {
        const QVariantMap port = value.toMap();
        if (port.value(QStringLiteral("value")).toString() == portName)
            return true;
    }
    return false;
}

QString TpInvDataProcessing::firstAvailablePort() const
{
    for (const QVariant &value : portOptions_) {
        const QString portName = value.toMap().value(QStringLiteral("value")).toString();
        if (!portName.isEmpty())
            return portName;
    }
    return {};
}

void TpInvDataProcessing::rebuildSeries()
{
    rebuildVoltageSeries();
    rebuildCurrentSeries();
}

void TpInvDataProcessing::rebuildVoltageSeries()
{
    QVariantList nextSeries;
    if (voltageAEnabled_)
        nextSeries.push_back(makeSeriesItem(QStringLiteral("A相电压"), QStringLiteral("#FFCC00"), voltageAValues_));
    if (voltageBEnabled_)
        nextSeries.push_back(makeSeriesItem(QStringLiteral("B相电压"), QStringLiteral("#01ff45"), voltageBValues_));
    if (voltageCEnabled_)
        nextSeries.push_back(makeSeriesItem(QStringLiteral("C相电压"), QStringLiteral("#ff4f63"), voltageCValues_));

    if (voltageSeries_ == nextSeries)
        return;

    voltageSeries_ = nextSeries;
    emit voltageSeriesChanged();
}

void TpInvDataProcessing::rebuildCurrentSeries()
{
    QVariantList nextSeries;
    if (currentAEnabled_)
        nextSeries.push_back(makeSeriesItem(QStringLiteral("A相电流"), QStringLiteral("#FFCC00"), currentAValues_));
    if (currentBEnabled_)
        nextSeries.push_back(makeSeriesItem(QStringLiteral("B相电流"), QStringLiteral("#01ff45"), currentBValues_));
    if (currentCEnabled_)
        nextSeries.push_back(makeSeriesItem(QStringLiteral("C相电流"), QStringLiteral("#ff4f63"), currentCValues_));

    if (currentSeries_ == nextSeries)
        return;

    currentSeries_ = nextSeries;
    emit currentSeriesChanged();
}

QVariantMap TpInvDataProcessing::makeSeriesItem(const QString &name,
                                                const QString &color,
                                                const QVariantList &values)
{
    QVariantList wrapped;
    wrapped.reserve(values.size());
    for (const QVariant &v : values) {
        QVariantMap point;
        point.insert(QStringLiteral("value"), v);
        wrapped.append(point);
    }

    QVariantMap item;
    item.insert(QStringLiteral("name"), name);
    item.insert(QStringLiteral("color"), color);
    item.insert(QStringLiteral("values"), wrapped);
    return item;
}

void TpInvDataProcessing::applySnapshot(int sampleCount,
                                        int parsedFrameCount,
                                        int droppedFrameCount,
                                        const QVariantList &voltageAValues,
                                        const QVariantList &voltageBValues,
                                        const QVariantList &voltageCValues,
                                        const QVariantList &currentAValues,
                                        const QVariantList &currentBValues,
                                        const QVariantList &currentCValues)
{
    sampleCount_ = sampleCount;
    parsedFrameCount_ = parsedFrameCount;
    droppedFrameCount_ = droppedFrameCount;
    voltageAValues_ = voltageAValues;
    voltageBValues_ = voltageBValues;
    voltageCValues_ = voltageCValues;
    currentAValues_ = currentAValues;
    currentBValues_ = currentBValues;
    currentCValues_ = currentCValues;
    emit samplesChanged();
    emit statsChanged();
    if (!waveformPaused_)
        rebuildSeries();

    if (sampleCount_ > 0) {
        setWaveStatusText(QStringLiteral("已解析波形数据"));
    } else if (!lastWaveHex_.isEmpty()) {
        setWaveStatusText(QStringLiteral("收到数据，暂未解析到有效帧"));
    }
}

void TpInvDataProcessing::resetCachedValues()
{
    sampleCount_ = 0;
    parsedFrameCount_ = 0;
    droppedFrameCount_ = 0;
    voltageAValues_.clear();
    voltageBValues_.clear();
    voltageCValues_.clear();
    currentAValues_.clear();
    currentBValues_.clear();
    currentCValues_.clear();
    emit samplesChanged();
    emit statsChanged();
    rebuildSeries();
}
