#ifndef TPINV_DATAPROCESSING_H
#define TPINV_DATAPROCESSING_H

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqml.h>

QT_FORWARD_DECLARE_CLASS(QThread)
QT_FORWARD_DECLARE_CLASS(QTimer)
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
    Q_PROPERTY(QVariantList portOptions READ portOptions NOTIFY portOptionsChanged FINAL)
    Q_PROPERTY(QString selectedPortName READ selectedPortName WRITE setSelectedPortName NOTIFY selectedPortNameChanged FINAL)
    Q_PROPERTY(bool wavePortOpen READ wavePortOpen NOTIFY wavePortOpenChanged FINAL)
    Q_PROPERTY(int selectedBaudRate READ selectedBaudRate WRITE setSelectedBaudRate NOTIFY selectedBaudRateChanged FINAL)
    Q_PROPERTY(bool waveformPaused READ waveformPaused WRITE setWaveformPaused NOTIFY waveformPausedChanged FINAL)
    Q_PROPERTY(int receivedByteCount READ receivedByteCount NOTIFY receiveInfoChanged FINAL)
    Q_PROPERTY(QString lastWaveHex READ lastWaveHex NOTIFY receiveInfoChanged FINAL)
    Q_PROPERTY(QString lastWaveText READ lastWaveText NOTIFY receiveInfoChanged FINAL)
    Q_PROPERTY(QString lastWaveRxTime READ lastWaveRxTime NOTIFY receiveInfoChanged FINAL)
    Q_PROPERTY(QString waveStatusText READ waveStatusText NOTIFY waveStatusTextChanged FINAL)
    Q_PROPERTY(bool voltageAEnabled READ voltageAEnabled WRITE setVoltageAEnabled NOTIFY channelEnabledChanged FINAL)
    Q_PROPERTY(bool voltageBEnabled READ voltageBEnabled WRITE setVoltageBEnabled NOTIFY channelEnabledChanged FINAL)
    Q_PROPERTY(bool voltageCEnabled READ voltageCEnabled WRITE setVoltageCEnabled NOTIFY channelEnabledChanged FINAL)
    Q_PROPERTY(bool currentAEnabled READ currentAEnabled WRITE setCurrentAEnabled NOTIFY channelEnabledChanged FINAL)
    Q_PROPERTY(bool currentBEnabled READ currentBEnabled WRITE setCurrentBEnabled NOTIFY channelEnabledChanged FINAL)
    Q_PROPERTY(bool currentCEnabled READ currentCEnabled WRITE setCurrentCEnabled NOTIFY channelEnabledChanged FINAL)
    Q_PROPERTY(QVariantList voltageSeries READ voltageSeries NOTIFY voltageSeriesChanged FINAL)
    Q_PROPERTY(QVariantList currentSeries READ currentSeries NOTIFY currentSeriesChanged FINAL)
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

    static TpInvDataProcessing *instance();
    static TpInvDataProcessing *create(QQmlEngine *, QJSEngine *);

    int sampleCapacity() const;
    void setSampleCapacity(int capacity);
    int sampleCount() const;
    int parsedFrameCount() const;
    int droppedFrameCount() const;
    QVariantList portOptions() const;
    QString selectedPortName() const;
    void setSelectedPortName(const QString &portName);
    bool wavePortOpen() const;
    int selectedBaudRate() const;
    void setSelectedBaudRate(int baudRate);
    bool waveformPaused() const;
    void setWaveformPaused(bool paused);
    int receivedByteCount() const;
    QString lastWaveHex() const;
    QString lastWaveText() const;
    QString lastWaveRxTime() const;
    QString waveStatusText() const;
    bool voltageAEnabled() const;
    void setVoltageAEnabled(bool enabled);
    bool voltageBEnabled() const;
    void setVoltageBEnabled(bool enabled);
    bool voltageCEnabled() const;
    void setVoltageCEnabled(bool enabled);
    bool currentAEnabled() const;
    void setCurrentAEnabled(bool enabled);
    bool currentBEnabled() const;
    void setCurrentBEnabled(bool enabled);
    bool currentCEnabled() const;
    void setCurrentCEnabled(bool enabled);
    QVariantList voltageSeries() const;
    QVariantList currentSeries() const;

    QVariantList voltageAValues() const;
    QVariantList voltageBValues() const;
    QVariantList voltageCValues() const;
    QVariantList currentAValues() const;
    QVariantList currentBValues() const;
    QVariantList currentCValues() const;

    Q_INVOKABLE void appendSerialData(const QByteArray &data);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantList channelValues(int channel) const;
    Q_INVOKABLE void initializeWavePage(int capacity);
    Q_INVOKABLE QVariantList refreshSerialPorts();
    Q_INVOKABLE bool toggleSerialPort();
    Q_INVOKABLE void clearWaveformData();
    // Q_INVOKABLE void generateMockData(int count);
    Q_INVOKABLE QString compactHex(const QString &hex) const;

Q_SIGNALS:
    void sampleCapacityChanged();
    void samplesChanged();
    void statsChanged();
    void portOptionsChanged();
    void selectedPortNameChanged();
    void wavePortOpenChanged();
    void selectedBaudRateChanged();
    void waveformPausedChanged();
    void receiveInfoChanged();
    void waveStatusTextChanged();
    void channelEnabledChanged();
    void voltageSeriesChanged();
    void currentSeriesChanged();

private:
    static constexpr int DefaultSampleCapacity = 512;

    void bindSerialManagerSignals();
    void updateWavePortOpen();
    void syncConnectedBaudRate();
    void handleSerialData(const QString &portName, const QByteArray &data, const QString &text, const QString &hex);
    void setWaveStatusText(const QString &text);
    void resetReceiveInfo();
    bool hasPort(const QString &portName) const;
    QString firstAvailablePort() const;
    void rebuildSeries();
    void rebuildVoltageSeries();
    void rebuildCurrentSeries();
    static QVariantMap makeSeriesItem(const QString &name, const QString &color, const QVariantList &values);
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
    int sampleCapacity_ = DefaultSampleCapacity;
    int sampleCount_ = 0;
    int parsedFrameCount_ = 0;
    int droppedFrameCount_ = 0;
    QVariantList portOptions_;
    QString selectedPortName_;
    bool wavePortOpen_ = false;
    int selectedBaudRate_ = 115200;
    bool waveformPaused_ = false;
    int receivedByteCount_ = 0;
    QString lastWaveHex_;
    QString lastWaveText_;
    QString lastWaveRxTime_;
    QString waveStatusText_ = QStringLiteral("等待波形数据");
    bool voltageAEnabled_ = true;
    bool voltageBEnabled_ = true;
    bool voltageCEnabled_ = true;
    bool currentAEnabled_ = true;
    bool currentBEnabled_ = true;
    bool currentCEnabled_ = true;
    QVariantList voltageSeries_;
    QVariantList currentSeries_;
    QVariantList voltageAValues_;
    QVariantList voltageBValues_;
    QVariantList voltageCValues_;
    QVariantList currentAValues_;
    QVariantList currentBValues_;
    QVariantList currentCValues_;
};

#endif // TPINV_DATAPROCESSING_H
