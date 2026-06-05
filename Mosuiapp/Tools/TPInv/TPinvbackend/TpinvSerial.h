#ifndef TPINVSERIAL_H
#define TPINVSERIAL_H

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QtQml/qqml.h>
#include "Mosdefinitions.h"

class MosSerialPortManager;
class TpInvcontroldata;
class Tpinvcontrolprocess;

class TpinvSerial : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpinvSerial)

    MOSUI_PROPERTY_INIT(QString,controlPortName,setControlPortName,"");
    MOSUI_PROPERTY_INIT(QString,wavePortName,setWavePortName,"");

public:
    ~TpinvSerial() override;

    static TpinvSerial *instance();
    static TpinvSerial *create(QQmlEngine *, QJSEngine *);

    Q_INVOKABLE int InitTpinvSerial();

Q_SIGNALS:
    void serialTextReceived(const QString &portName, const QString &text, const QString &hex);


private:
    explicit TpinvSerial(QObject *parent = nullptr);

    MosSerialPortManager *manager() const;
    void bindManagerSignals();

    TpInvcontroldata *controlData() const;
    void bindControlDataSignals();

    Tpinvcontrolprocess *controlProcess() const;
    void bindControlProcessSignals();

};

#endif // TPINVSERIAL_H
