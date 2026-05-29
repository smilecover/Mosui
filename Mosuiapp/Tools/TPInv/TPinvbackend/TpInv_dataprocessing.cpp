#include "TpInv_dataprocessing.h"

#include <QMetaObject>
#include <QThread>
#include <QtGlobal>

#include <algorithm>
#include <cstring>
#include <functional>
#include <vector>

namespace {

float decodeSigned16(quint8 high, quint8 low)
{
    const quint16 raw = (static_cast<quint16>(high) << 8) | static_cast<quint16>(low);
    return static_cast<float>(static_cast<qint16>(raw));
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

        bool changed = false;
        while (parseNextFrame())
            changed = true;

        if (changed)
            emitSnapshot();
    }

    void clear()
    {
        rxBuffer_.clear();
        sampleBuffer_.clear();
        parsedFrameCount_ = 0;
        droppedFrameCount_ = 0;
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

    static constexpr int FrameSize = 16;
    static constexpr int Header0 = 0xFF;
    static constexpr int Header1 = 0xCC;
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
        while (rxBuffer_.size() >= FrameSize) {
            if (rxBuffer_[0] != Header0) {
                quint8 ignored = 0;
                tryReadByte(&ignored);
                ++droppedFrameCount_;
                continue;
            }

            if (rxBuffer_[1] != Header1) {
                quint8 ignored = 0;
                tryReadByte(&ignored);
                ++droppedFrameCount_;
                continue;
            }

            std::array<quint8, FrameSize> frame {};
            for (int i = 0; i < FrameSize; ++i)
                frame[i] = rxBuffer_[static_cast<tpinv::RingBuffer::size_type>(i)];

            if (!frameChecksumIsValid(frame)) {
                quint8 ignored = 0;
                tryReadByte(&ignored);
                ++droppedFrameCount_;
                continue;
            }

            rxBuffer_.consume(FrameSize);
            appendSample(decodeSample(frame));
            ++parsedFrameCount_;
            return true;
        }

        return false;
    }

    bool frameChecksumIsValid(const std::array<quint8, FrameSize> &frame) const
    {
        quint16 sum = 0;
        for (int i = 0; i < FrameSize - 2; ++i)
            sum = static_cast<quint16>(sum + frame[i]);

        return frame[FrameSize - 2] == static_cast<quint8>((sum >> 8) & 0xFF)
                && frame[FrameSize - 1] == static_cast<quint8>(sum & 0xFF);
    }

    Sample decodeSample(const std::array<quint8, FrameSize> &frame) const
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
    SnapshotCallback snapshotCallback_;
};

TpInvDataProcessing::TpInvDataProcessing(QObject *parent)
    : QObject(parent),
      rxBuffer_(RxBufferCapacity),
      sampleBuffer_(DefaultSampleCapacity * sizeof(Sample))
{
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
}

TpInvDataProcessing::~TpInvDataProcessing()
{
    if (workerThread_) {
        workerThread_->quit();
        workerThread_->wait();
    }
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
}

bool TpInvDataProcessing::tryReadByte(quint8 *value)
{
    if (!value)
        return false;

    tpinv::RingBuffer::value_type byte = 0;
    if (!rxBuffer_.pop(byte))
        return false;

    *value = byte;
    return true;
}

bool TpInvDataProcessing::parseNextFrame()
{
    while (rxBuffer_.size() >= FrameSize) {
        if (rxBuffer_[0] != Header0) {
            quint8 ignored = 0;
            tryReadByte(&ignored);
            ++droppedFrameCount_;
            continue;
        }

        if (rxBuffer_[1] != Header1) {
            quint8 ignored = 0;
            tryReadByte(&ignored);
            ++droppedFrameCount_;
            continue;
        }

        std::array<quint8, FrameSize> frame {};
        for (int i = 0; i < FrameSize; ++i)
            frame[i] = rxBuffer_[static_cast<tpinv::RingBuffer::size_type>(i)];

        if (!frameChecksumIsValid(frame)) {
            quint8 ignored = 0;
            tryReadByte(&ignored);
            ++droppedFrameCount_;
            continue;
        }

        rxBuffer_.consume(FrameSize);
        appendSample(decodeSample(frame));
        ++parsedFrameCount_;
        return true;
    }

    return false;
}

bool TpInvDataProcessing::frameChecksumIsValid(const std::array<quint8, FrameSize> &frame) const
{
    quint16 sum = 0;
    for (int i = 0; i < FrameSize - 2; ++i)
        sum = static_cast<quint16>(sum + frame[i]);

    return frame[FrameSize - 2] == static_cast<quint8>((sum >> 8) & 0xFF)
            && frame[FrameSize - 1] == static_cast<quint8>(sum & 0xFF);
}

TpInvDataProcessing::Sample TpInvDataProcessing::decodeSample(const std::array<quint8, FrameSize> &frame) const
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

void TpInvDataProcessing::appendSample(const Sample &sample)
{
    while (sampleCount() >= sampleCapacity_)
        sampleBuffer_.consume(sizeof(Sample));

    sampleBuffer_.pushOverwrite(reinterpret_cast<const tpinv::RingBuffer::value_type *>(&sample),
                                sizeof(Sample));
}

QVariantList TpInvDataProcessing::valuesForChannel(Channel channel) const
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
