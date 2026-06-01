#ifndef TPINVCONTROLPROCESS_H
#define TPINVCONTROLPROCESS_H

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QVariant>
#include <QVariantList>
#include <QtQml/qqml.h>
#include <qstringview.h>

class Tpinvcontrolprocess : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpinvControlProcess)

    Q_PROPERTY(int rxBufferSize READ rxBufferSize NOTIFY rxBufferChanged FINAL)
    Q_PROPERTY(int parsedFrameCount READ parsedFrameCount NOTIFY statsChanged FINAL)
    Q_PROPERTY(int droppedFrameCount READ droppedFrameCount NOTIFY statsChanged FINAL)
    Q_PROPERTY(QString lastFrameHex READ lastFrameHex NOTIFY lastFrameChanged FINAL)
    Q_PROPERTY(QString lastErrorString READ lastErrorString NOTIFY errorChanged FINAL)

public:
    enum FrameType {
        UnknownFrame = 0,
        ParameterFrame,
        MonitorFrame,
        FaultFrame,
        AckFrame
    };
    Q_ENUM(FrameType)

    ~Tpinvcontrolprocess() override;

    static Tpinvcontrolprocess *instance();
    static Tpinvcontrolprocess *create(QQmlEngine *, QJSEngine *);

    int rxBufferSize() const;
    int parsedFrameCount() const;
    int droppedFrameCount() const;
    QString lastFrameHex() const;
    QString lastErrorString() const;

    Q_INVOKABLE void appendSerialData(const QByteArray &data);
    Q_INVOKABLE void appendHexData(const QString &hexText);
    Q_INVOKABLE void processFrame(const QByteArray &frame);
    Q_INVOKABLE void clear();

    Q_INVOKABLE QByteArray buildRequestParametersFrame();
    Q_INVOKABLE QByteArray buildApplyParametersFrame(const QVariantList &parameters);
    Q_INVOKABLE QByteArray buildStartFrame();
    Q_INVOKABLE QByteArray buildStopFrame();
    Q_INVOKABLE QByteArray buildResetFaultFrame();
    Q_INVOKABLE QString bytesToHex(const QByteArray &data) const;

Q_SIGNALS:
    void rxBufferChanged();
    void statsChanged();
    void lastFrameChanged();
    void errorChanged();

    void frameParsed(const QByteArray &frame, int frameType);
    void parameterValuesParsed(const QVariantList &values);
    void monitorValueParsed(const QString &key, const QVariant &value);
    void faultCodeParsed(const QString &faultCode);
    void commandFrameBuilt(const QByteArray &frame);
    void processErrorOccurred(const QString &message);

private:
    explicit Tpinvcontrolprocess(QObject *parent = nullptr);

    static constexpr int MaxRxBufferSize = 4096;
    static constexpr int MinFrameSize = 5;
    static constexpr int Header0 = 0xFF;
    static constexpr int Header1 = 0xCC;

    void parseBufferedFrames();
    bool tryTakeFrame(QByteArray *frame);
    bool frameChecksumIsValid(const QByteArray &frame) const;
    FrameType detectFrameType(const QByteArray &frame) const;
    void parseParameterFrame(const QByteArray &frame);
    void parseMonitorFrame(const QByteArray &frame);
    void parseFaultFrame(const QByteArray &frame);
    void parseAckFrame(const QByteArray &frame);
    QByteArray buildFrame(quint8 command, const QByteArray &payload = QByteArray()) const;
    quint8 checksum(const QByteArray &data, int begin, int end) const;
    void setLastErrorString(const QString &message);
    void setLastFrame(const QByteArray &frame);
    void trimRxBuffer();

    // 绑定逆变器控制
    void bandTpInvcontroldata();
    // 构建逆变器参数
    void buildTpInvParamet();
    
    QByteArray rxBuffer_;
    int parsedFrameCount_ = 0;
    int droppedFrameCount_ = 0;
    QString lastFrameHex_;
    QString lastErrorString_;

};

#endif // TPINVCONTROLPROCESS_H
