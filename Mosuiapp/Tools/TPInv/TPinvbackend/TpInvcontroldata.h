#ifndef TPINVCONTROLDATA_H
#define TPINVCONTROLDATA_H

#include <QByteArray>
#include <QList>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QtQml/qqml.h>
#include <qtmetamacros.h>

class TpInvcontroldata : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpInvcontroldata)

    Q_PROPERTY(QVariantList parameterItems READ parameterItems NOTIFY parameterItemsChanged FINAL)
    Q_PROPERTY(QVariantList monitorGroups READ monitorGroups NOTIFY monitorGroupsChanged FINAL)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged FINAL)
    Q_PROPERTY(QString runStateText READ runStateText NOTIFY runningChanged FINAL)
    Q_PROPERTY(QString runSummaryText READ runSummaryText WRITE setRunSummaryText NOTIFY runSummaryTextChanged FINAL)
    Q_PROPERTY(QString faultCode READ faultCode WRITE setFaultCode NOTIFY faultChanged FINAL)
    Q_PROPERTY(QString faultDescription READ faultDescription WRITE setFaultDescription NOTIFY faultChanged FINAL)
    Q_PROPERTY(double dcVoltage READ dcVoltage WRITE setDcVoltage NOTIFY measurementsChanged FINAL)
    Q_PROPERTY(double acVoltage READ acVoltage WRITE setAcVoltage NOTIFY measurementsChanged FINAL)
    Q_PROPERTY(double acFrequency READ acFrequency WRITE setAcFrequency NOTIFY measurementsChanged FINAL)

public:
    ~TpInvcontroldata() override;

    static TpInvcontroldata *instance();
    static TpInvcontroldata *create(QQmlEngine *, QJSEngine *);

    QVariantList parameterItems() const;
    QVariantList monitorGroups() const;

    bool running() const;
    void setRunning(bool running);
    QString runStateText() const;

    QString runSummaryText() const;
    void setRunSummaryText(const QString &text);

    QString faultCode() const;
    void setFaultCode(const QString &code);

    QString faultDescription() const;
    void setFaultDescription(const QString &description);

    double dcVoltage() const;
    void setDcVoltage(double value);

    double acVoltage() const;
    void setAcVoltage(double value);

    double acFrequency() const;
    void setAcFrequency(double value);

    Q_INVOKABLE QVariant parameterValue(const QString &key) const;
    Q_INVOKABLE void setParameterValue(const QString &key, const QVariant &value);
    Q_INVOKABLE void setallParameters(const QList<double> &value);
    Q_INVOKABLE void confirmParameters();
    Q_INVOKABLE void applyParameters();
    Q_INVOKABLE void requestParameters();
    Q_INVOKABLE void startInverter();
    Q_INVOKABLE void stopInverter();
    Q_INVOKABLE void resetFault();
    Q_INVOKABLE void updateMonitorValue(const QString &key, const QVariant &value);
    Q_INVOKABLE void reset();

Q_SIGNALS:
    void parameterItemsChanged();
    void monitorGroupsChanged();
    void runningChanged();
    void runSummaryTextChanged();
    void faultChanged();
    void measurementsChanged();

    void commandRequested(const QString &command, const QVariantMap &payload);

private:
    explicit TpInvcontroldata(QObject *parent = nullptr);

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
    int parameterIndex(const QString &key) const;
    bool setMonitorValueInGroups(const QString &key, const QVariant &value);
    void initializeDefaults();
    void syncSummaryMeasurements();

    QVariantList parameterItems_;
    QVariantList monitorGroups_;
    bool running_ = false;
    QString runSummaryText_;
    QString faultCode_;
    QString faultDescription_;
    double dcVoltage_ = 0.0;
    double acVoltage_ = 0.0;
    double acFrequency_ = 0.0;
};

#endif
