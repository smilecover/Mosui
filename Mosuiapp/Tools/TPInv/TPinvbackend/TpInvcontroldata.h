#ifndef TPINVCONTROLDATA_H
#define TPINVCONTROLDATA_H

#include <QList>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QtQml/qqml.h>
#include <qtmetamacros.h>
#include "Mosdefinitions.h"


class TpInvcontroldata : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpInvcontroldata)

    Q_PROPERTY(QVariantList parametermodelItems READ parametermodelItems NOTIFY parametermodelItemsChanged FINAL)
    Q_PROPERTY(QVariantList parameterItems READ parameterItems NOTIFY parameterItemsChanged FINAL)
    Q_PROPERTY(QVariantList monitorGroups READ monitorGroups NOTIFY monitorGroupsChanged FINAL)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged FINAL)
    Q_PROPERTY(double dcVoltage READ dcVoltage NOTIFY keyMetricsChanged FINAL)
    Q_PROPERTY(double acVoltage READ acVoltage NOTIFY keyMetricsChanged FINAL)
    Q_PROPERTY(double acFrequency READ acFrequency NOTIFY keyMetricsChanged FINAL)
    Q_PROPERTY(QString faultCode READ faultCode NOTIFY keyMetricsChanged FINAL)
    Q_PROPERTY(int inverterState READ inverterState NOTIFY inverterStateChanged FINAL)
    Q_PROPERTY(double acVoltageStep READ acVoltageStep NOTIFY acVoltageStepChanged FINAL)
    Q_PROPERTY(QVariantMap calibrationData READ calibrationData NOTIFY calibrationDataChanged FINAL)
    MOSUI_PROPERTY_INIT(QVariant,parameterSelectIndex,setParameterSelectIndex,1);
    MOSUI_PROPERTY_INIT(QVariant,ConnectMode,setConnectMode,0);/*0: 串口，1： mqtt*/

public:
    ~TpInvcontroldata() override;

    static TpInvcontroldata *instance();
    static TpInvcontroldata *create(QQmlEngine *, QJSEngine *);

    QVariantList parameterItems() const;
    QVariantList parametermodelItems() const;
    QVariantList monitorGroups() const;

    bool running() const;
    void setRunning(bool running);

    double dcVoltage() const;
    double acVoltage() const;
    double acFrequency() const;
    QString faultCode() const;
    int inverterState() const;
    double acVoltageStep() const;
    QVariantMap calibrationData() const;

    Q_INVOKABLE void setallParameters(const QList<double> &value);
    Q_INVOKABLE void startInverter(const QString &SerialPort);
    Q_INVOKABLE void stopInverter(const QString &SerialPort);
    Q_INVOKABLE void sendCommand(const QString &SerialPort, const QByteArray &data);
    Q_INVOKABLE void switchConnectMode(int mode, const QString &SerialPort);

    void applyMonitorSnapshot(const QVariantMap &values);

Q_SIGNALS:
    void parametermodelItemsChanged();
    void parameterItemsChanged();
    void monitorGroupsChanged();
    void runningChanged();
    void keyMetricsChanged();
    void inverterStateChanged();
    void acVoltageStepChanged();
    void calibrationDataChanged();

    void cmdTx(const QString &SerialPort,const QByteArray &data);
    void modeSwitchCmdTx(const QByteArray &data);

private:
    explicit TpInvcontroldata(QObject *parent = nullptr);
    QVariantMap makeParameterModel(const QString &key,
                                   const QString &label,
                                   const QString &value,
                                   bool enabled) const;
    QVariantMap makeParameter(const QString &key,
                              const QString &icon,
                              const QString &label,
                              double value,
                              double minimum,
                              double maximum,
                              double step,
                              int precision,
                              const QString &unit,
                              bool stepper) const;
    QVariantMap makeMonitorGroup(const QString &title,
                                 const QString &accent,
                                 const QVariantList &items) const;
    QVariantMap makeMonitorItem(const QString &key,
                                const QString &name,
                                const QVariant &value,
                                const QString &unit) const;
    void initializeDefaults();
    QVariant findMonitorValue(const QString &key) const;
    void extractKeyMetrics();


    QVariantList parametermodelItems_;
    QVariantList parameterItems_;
    QVariantList monitorGroups_;
    bool running_ = false;
    double dcVoltage_ = 0.0;
    double acVoltage_ = 0.0;
    double acFrequency_ = 0.0;
    QString faultCode_;
    int inverterState_ = 0;
    double acVoltageStep_ = 1.0;
    QVariantMap calibrationData_;

};

#endif
