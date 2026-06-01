#ifndef TPINVSERIAL_H
#define TPINVSERIAL_H

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QtQml/qqml.h>

class MosSerialPortManager;

class TpinvSerial : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpinvSerial)

    Q_PROPERTY(QVariantList portOptions READ portOptions NOTIFY portOptionsChanged FINAL)
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged FINAL)
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged FINAL)
    Q_PROPERTY(int dataBits READ dataBits WRITE setDataBits NOTIFY dataBitsChanged FINAL)
    Q_PROPERTY(QString parity READ parity WRITE setParity NOTIFY parityChanged FINAL)
    Q_PROPERTY(QString stopBits READ stopBits WRITE setStopBits NOTIFY stopBitsChanged FINAL)
    Q_PROPERTY(QString flowControl READ flowControl WRITE setFlowControl NOTIFY flowControlChanged FINAL)
    Q_PROPERTY(bool open READ isOpen NOTIFY openChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)
    Q_PROPERTY(QString receivedText READ receivedText NOTIFY receivedChanged FINAL)
    Q_PROPERTY(QString receivedHex READ receivedHex NOTIFY receivedChanged FINAL)
    Q_PROPERTY(qint64 receivedBytes READ receivedBytes NOTIFY receivedChanged FINAL)
    Q_PROPERTY(qint64 writtenBytes READ writtenBytes NOTIFY writtenBytesChanged FINAL)

public:
    ~TpinvSerial() override;

    static TpinvSerial *instance();
    static TpinvSerial *create(QQmlEngine *, QJSEngine *);

    QVariantList portOptions() const;

    QString portName() const;
    void setPortName(const QString &portName);

    int baudRate() const;
    void setBaudRate(int baudRate);

    int dataBits() const;
    void setDataBits(int dataBits);

    QString parity() const;
    void setParity(const QString &parity);

    QString stopBits() const;
    void setStopBits(const QString &stopBits);

    QString flowControl() const;
    void setFlowControl(const QString &flowControl);

    bool isOpen() const;
    QString errorString() const;
    QString receivedText() const;
    QString receivedHex() const;
    qint64 receivedBytes() const;
    qint64 writtenBytes() const;

    Q_INVOKABLE QVariantList refreshPorts();
    Q_INVOKABLE bool openPort();
    Q_INVOKABLE void closePort();
    Q_INVOKABLE bool togglePort();
    Q_INVOKABLE bool writeText(const QString &text);
    Q_INVOKABLE bool writeHex(const QString &hexText);
    Q_INVOKABLE bool writeBytes(const QByteArray &data);
    Q_INVOKABLE bool writeFrame(const QByteArray &frame);
    Q_INVOKABLE void clearReceived();
    Q_INVOKABLE void clearError();

Q_SIGNALS:
    void portOptionsChanged();
    void portNameChanged();
    void baudRateChanged();
    void dataBitsChanged();
    void parityChanged();
    void stopBitsChanged();
    void flowControlChanged();
    void openChanged();
    void errorStringChanged();
    void receivedChanged();
    void writtenBytesChanged();

    void dataReceived(const QByteArray &data, const QString &text, const QString &hex);
    void frameReceived(const QByteArray &data);
    void frameWritten(const QByteArray &data);
    void serialErrorOccurred(const QString &message);

private:
    explicit TpinvSerial(QObject *parent = nullptr);

    MosSerialPortManager *manager() const;
    void bindManagerSignals();
    
    void syncOpenState();
    void syncErrorString(const QString &message = QString());
    bool ensurePortSelected();

    QVariantList portOptions_;
    QString portName_;
    int baudRate_ = 9600;
    int dataBits_ = 8;
    QString parity_ = QStringLiteral("none");
    QString stopBits_ = QStringLiteral("1");
    QString flowControl_ = QStringLiteral("none");
    bool open_ = false;
    QString errorString_;
    QString receivedText_;
    QString receivedHex_;
    qint64 receivedBytes_ = 0;
    qint64 writtenBytes_ = 0;
};

#endif // TPINVSERIAL_H
