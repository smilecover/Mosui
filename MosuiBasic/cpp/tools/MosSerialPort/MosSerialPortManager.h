#ifndef MOSSERIALPORTMANAGER_H
#define MOSSERIALPORTMANAGER_H

#include <QObject>
#include <QByteArray>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosSerialPortManagerPrivate)


class MOSUIBASIC_EXPORT MosSerialPortManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosSerialPortManager)

    Q_PROPERTY(QVariantList portInfoList READ portInfoList NOTIFY portInfoListChanged FINAL)
    Q_PROPERTY(bool isOpen READ isOpen NOTIFY isOpenChanged FINAL)
    Q_PROPERTY(bool hasOpenPorts READ hasOpenPorts NOTIFY openPortsChanged FINAL)
    Q_PROPERTY(int openPortCount READ openPortCount NOTIFY openPortsChanged FINAL)
    Q_PROPERTY(QString currentPortName READ currentPortName NOTIFY currentPortNameChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)
    Q_PROPERTY(QStringList openPortNames READ openPortNames NOTIFY openPortsChanged FINAL)
    Q_PROPERTY(QVariantList openPortList READ openPortList NOTIFY openPortsChanged FINAL)

public:
    ~MosSerialPortManager() override;

    static MosSerialPortManager *instance();
    static MosSerialPortManager *create(QQmlEngine *, QJSEngine *);

    QVariantList portInfoList() const;
    bool isOpen() const;
    bool hasOpenPorts() const;
    int openPortCount() const;
    QString currentPortName() const;
    QString errorString() const;
    QStringList openPortNames() const;
    QVariantList openPortList() const;

    Q_INVOKABLE QVariantList refreshPorts();
    Q_INVOKABLE bool selectPort(const QString &portName);
    Q_INVOKABLE bool isPortOpen(const QString &portName) const;
    Q_INVOKABLE bool openPort(const QString &portName,
                              int baudRate,
                              int dataBits,
                              const QString &parity,
                              const QString &stopBits,
                              const QString &flowControl);
    Q_INVOKABLE void closePort();
    Q_INVOKABLE void closePort(const QString &portName);
    Q_INVOKABLE void closeAllPorts();
    Q_INVOKABLE bool SendText(const QString &text);
    Q_INVOKABLE bool SendTextToPort(const QString &portName, const QString &text);
    Q_INVOKABLE bool SendHex(const QString &hexText);
    Q_INVOKABLE bool SendHexToPort(const QString &portName, const QString &hexText);
    Q_INVOKABLE bool SendBytes(const QByteArray &data);
    Q_INVOKABLE bool SendBytesToPort(const QString &portName, const QByteArray &data);
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void shutdown();
    Q_INVOKABLE QString bytesToHex(const QByteArray &data) const;

Q_SIGNALS:
    void portInfoListChanged();
    void isOpenChanged();
    void currentPortNameChanged();
    void errorStringChanged();
    void openPortsChanged();
    void ReceiveData(const QByteArray &data, const QString &text, const QString &hex);
    void ReceiveDataFromPort(const QString &portName, const QByteArray &data, const QString &text, const QString &hex);
    void BytesSent(qint64 bytes);
    void BytesSentFromPort(const QString &portName, qint64 bytes);
    void errorOccurred(const QString &message);
    void errorOccurredFromPort(const QString &portName, const QString &message);

private:
    explicit MosSerialPortManager(QObject *parent = nullptr);

    Q_DECLARE_PRIVATE(MosSerialPortManager)
    QScopedPointer<MosSerialPortManagerPrivate> d_ptr;
};

#endif // MOSSERIALPORTMANAGER_H
