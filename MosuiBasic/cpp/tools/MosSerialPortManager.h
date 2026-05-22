#ifndef MOSSERIALPORTMANAGER_H
#define MOSSERIALPORTMANAGER_H

#include <QObject>
#include <QByteArray>
#include <QString>
#include <QVariantList>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosSerialPortManagerPrivate)

class QJSEngine;
class QQmlEngine;

class MOSUIBASIC_EXPORT MosSerialPortManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosSerialPortManager)

    Q_PROPERTY(QVariantList portInfoList READ portInfoList NOTIFY portInfoListChanged FINAL)
    Q_PROPERTY(bool isOpen READ isOpen NOTIFY isOpenChanged FINAL)
    Q_PROPERTY(QString currentPortName READ currentPortName NOTIFY currentPortNameChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)

public:
    ~MosSerialPortManager() override;

    static MosSerialPortManager *instance();
    static MosSerialPortManager *create(QQmlEngine *, QJSEngine *);

    QVariantList portInfoList() const;
    bool isOpen() const;
    QString currentPortName() const;
    QString errorString() const;

    Q_INVOKABLE QVariantList refreshPorts();
    Q_INVOKABLE bool openPort(const QString &portName,
                              int baudRate,
                              int dataBits,
                              const QString &parity,
                              const QString &stopBits,
                              const QString &flowControl);
    Q_INVOKABLE void closePort();
    Q_INVOKABLE bool writeText(const QString &text);
    Q_INVOKABLE bool writeHex(const QString &hexText);
    Q_INVOKABLE bool writeBytes(const QByteArray &data);
    Q_INVOKABLE void clearError();
    Q_INVOKABLE QString bytesToHex(const QByteArray &data) const;

Q_SIGNALS:
    void portInfoListChanged();
    void isOpenChanged();
    void currentPortNameChanged();
    void errorStringChanged();
    void dataReceived(const QByteArray &data, const QString &text, const QString &hex);
    void bytesWritten(qint64 bytes);
    void errorOccurred(const QString &message);

private:
    explicit MosSerialPortManager(QObject *parent = nullptr);

    Q_DECLARE_PRIVATE(MosSerialPortManager)
    QScopedPointer<MosSerialPortManagerPrivate> d_ptr;
};

#endif // MOSSERIALPORTMANAGER_H
