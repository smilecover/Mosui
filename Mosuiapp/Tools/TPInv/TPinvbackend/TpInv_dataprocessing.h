#ifndef TPINV_DATAPROCESSING_H
#define TPINV_DATAPROCESSING_H

#include "ring_buffer.h"

#include <QByteArray>
#include <QObject>
#include <QVariantList>
#include <QtQml/qqml.h>

#include <array>

QT_FORWARD_DECLARE_CLASS(QThread)
class TpInvDataProcessingWorker;

class TpInvDataProcessing : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpInvDataProcessing)

    Q_PROPERTY(int sampleCapacity READ sampleCapacity WRITE setSampleCapacity NOTIFY sampleCapacityChanged FINAL)
    Q_PROPERTY(int sampleCount READ sampleCount NOTIFY samplesChanged FINAL)
    Q_PROPERTY(int parsedFrameCount READ parsedFrameCount NOTIFY statsChanged FINAL)
    Q_PROPERTY(int droppedFrameCount READ droppedFrameCount NOTIFY statsChanged FINAL)
    Q_PROPERTY(QVariantList voltageAValues READ voltageAValues NOTIFY samplesChanged FINAL)
    Q_PROPERTY(QVariantList voltageBValues READ voltageBValues NOTIFY samplesChanged FINAL)
    Q_PROPERTY(QVariantList voltageCValues READ voltageCValues NOTIFY samplesChanged FINAL)
    Q_PROPERTY(QVariantList currentAValues READ currentAValues NOTIFY samplesChanged FINAL)
    Q_PROPERTY(QVariantList currentBValues READ currentBValues NOTIFY samplesChanged FINAL)
    Q_PROPERTY(QVariantList currentCValues READ currentCValues NOTIFY samplesChanged FINAL)

public:
    enum Channel {
        VoltageA = 0,
        VoltageB,
        VoltageC,
        CurrentA,
        CurrentB,
        CurrentC,
        ChannelCount
    };
    Q_ENUM(Channel)

    explicit TpInvDataProcessing(QObject *parent = nullptr);
    ~TpInvDataProcessing() override;

    int sampleCapacity() const;
    void setSampleCapacity(int capacity);
    int sampleCount() const;
    int parsedFrameCount() const;
    int droppedFrameCount() const;

    QVariantList voltageAValues() const;
    QVariantList voltageBValues() const;
    QVariantList voltageCValues() const;
    QVariantList currentAValues() const;
    QVariantList currentBValues() const;
    QVariantList currentCValues() const;

    Q_INVOKABLE void appendSerialData(const QByteArray &data);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantList channelValues(int channel) const;

Q_SIGNALS:
    void sampleCapacityChanged();
    void samplesChanged();
    void statsChanged();

private:
    struct Sample {
        static constexpr int StorageChannelCount = 8;
        std::array<float, StorageChannelCount> values {};
    };

    static constexpr int FrameSize = 16;
    static constexpr int FramePayloadBytes = 12;
    static constexpr int Header0 = 0xFF;
    static constexpr int Header1 = 0xCC;
    static constexpr int DefaultSampleCapacity = 512;
    static constexpr int RxBufferCapacity = 8192;

    bool tryReadByte(quint8 *value);
    bool parseNextFrame();
    bool frameChecksumIsValid(const std::array<quint8, FrameSize> &frame) const;
    Sample decodeSample(const std::array<quint8, FrameSize> &frame) const;
    void appendSample(const Sample &sample);
    QVariantList valuesForChannel(Channel channel) const;
    void applySnapshot(int sampleCount,
                       int parsedFrameCount,
                       int droppedFrameCount,
                       const QVariantList &voltageAValues,
                       const QVariantList &voltageBValues,
                       const QVariantList &voltageCValues,
                       const QVariantList &currentAValues,
                       const QVariantList &currentBValues,
                       const QVariantList &currentCValues);
    void resetCachedValues();

    QThread *workerThread_ = nullptr;
    TpInvDataProcessingWorker *worker_ = nullptr;
    tpinv::RingBuffer rxBuffer_;
    tpinv::RingBuffer sampleBuffer_;
    int sampleCapacity_ = DefaultSampleCapacity;
    int sampleCount_ = 0;
    int parsedFrameCount_ = 0;
    int droppedFrameCount_ = 0;
    QVariantList voltageAValues_;
    QVariantList voltageBValues_;
    QVariantList voltageCValues_;
    QVariantList currentAValues_;
    QVariantList currentBValues_;
    QVariantList currentCValues_;
};

#endif // TPINV_DATAPROCESSING_H
