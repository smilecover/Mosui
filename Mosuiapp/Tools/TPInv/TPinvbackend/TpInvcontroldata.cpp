#include "TpInvcontroldata.h"

#include <QQmlEngine>
#include <QtGlobal>
#include <qdebug.h>

namespace {
constexpr auto CommandConfirmParameters = "confirmParameters";
constexpr auto CommandApplyParameters = "applyParameters";
constexpr auto CommandRequestParameters = "requestParameters";
constexpr auto CommandStartInverter = "startInverter";
constexpr auto CommandStopInverter = "stopInverter";
constexpr auto CommandResetFault = "resetFault";
}


TpInvcontroldata::TpInvcontroldata(QObject *parent)
    : QObject(parent)
{
    initializeDefaults();
}

TpInvcontroldata::~TpInvcontroldata() = default;

TpInvcontroldata *TpInvcontroldata::instance()
{
    static TpInvcontroldata *ins = new TpInvcontroldata;
    return ins;
}

TpInvcontroldata *TpInvcontroldata::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *controlData = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(controlData, QQmlEngine::CppOwnership);
    }
    return controlData;
}

QVariantList TpInvcontroldata::parameterItems() const
{
    return parameterItems_;
}

QVariantList TpInvcontroldata::monitorGroups() const
{
    return monitorGroups_;
}

bool TpInvcontroldata::running() const
{
    return running_;
}

void TpInvcontroldata::setRunning(bool running)
{
    if (running_ == running) {
        return;
    }

    running_ = running;
    emit runningChanged();
}

QString TpInvcontroldata::runStateText() const
{
    return running_ ? QStringLiteral("Running") : QStringLiteral("Stopped");
}

QString TpInvcontroldata::runSummaryText() const
{
    return runSummaryText_;
}

void TpInvcontroldata::setRunSummaryText(const QString &text)
{
    if (runSummaryText_ == text) {
        return;
    }

    runSummaryText_ = text;
    emit runSummaryTextChanged();
}

QString TpInvcontroldata::faultCode() const
{
    return faultCode_;
}

void TpInvcontroldata::setFaultCode(const QString &code)
{
    if (faultCode_ == code) {
        return;
    }

    faultCode_ = code;
    setMonitorValueInGroups(QStringLiteral("faultCode"), faultCode_);
    emit faultChanged();
    emit monitorGroupsChanged();
}

QString TpInvcontroldata::faultDescription() const
{
    return faultDescription_;
}

void TpInvcontroldata::setFaultDescription(const QString &description)
{
    if (faultDescription_ == description) {
        return;
    }

    faultDescription_ = description;
    emit faultChanged();
}

double TpInvcontroldata::dcVoltage() const
{
    return dcVoltage_;
}

void TpInvcontroldata::setDcVoltage(double value)
{
    if (qFuzzyCompare(dcVoltage_, value)) {
        return;
    }

    dcVoltage_ = value;
    setMonitorValueInGroups(QStringLiteral("dcVoltage"), QString::number(value, 'f', 1));
    syncSummaryMeasurements();
    emit measurementsChanged();
    emit monitorGroupsChanged();
}

double TpInvcontroldata::acVoltage() const
{
    return acVoltage_;
}

void TpInvcontroldata::setAcVoltage(double value)
{
    if (qFuzzyCompare(acVoltage_, value)) {
        return;
    }

    acVoltage_ = value;
    setMonitorValueInGroups(QStringLiteral("acVoltage"), QString::number(value, 'f', 1));
    syncSummaryMeasurements();
    emit measurementsChanged();
    emit monitorGroupsChanged();
}

double TpInvcontroldata::acFrequency() const
{
    return acFrequency_;
}

void TpInvcontroldata::setAcFrequency(double value)
{
    if (qFuzzyCompare(acFrequency_, value)) {
        return;
    }

    acFrequency_ = value;
    setMonitorValueInGroups(QStringLiteral("acFrequencyA"), QString::number(value, 'f', 2));
    setMonitorValueInGroups(QStringLiteral("acFrequencyB"), QString::number(value, 'f', 2));
    setMonitorValueInGroups(QStringLiteral("acFrequencyC"), QString::number(value, 'f', 2));
    syncSummaryMeasurements();
    emit measurementsChanged();
    emit monitorGroupsChanged();
}

QVariant TpInvcontroldata::parameterValue(const QString &key) const
{
    const int index = parameterIndex(key);
    if (index < 0) {
        return {};
    }

    return parameterItems_.at(index).toMap().value(QStringLiteral("value"));
}

void TpInvcontroldata::setParameterValue(const QString &key, const QVariant &value)
{
    const int index = parameterIndex(key);
    if (index < 0) {
        return;
    }

    QVariantMap item = parameterItems_.at(index).toMap();
    if (item.value(QStringLiteral("value")) == value) {
        return;
    }

    item.insert(QStringLiteral("value"), value);
    parameterItems_[index] = item;
    emit parameterItemsChanged();
}
void TpInvcontroldata::setallParameters(const QList<double> &value)
{
    // 取最小长度，防止越界崩溃
    const int count = qMin(parameterItems_.size(), value.size());
    bool changed = false;

    for (int i = 0; i < count; ++i) {
        QVariantMap param = parameterItems_.at(i).toMap();
        if (param.value(QStringLiteral("value")).toInt() == value.at(i)) {
            continue;
        }

        param.insert(QStringLiteral("value"), value.at(i));
        parameterItems_[i] = param;
        changed = true;
        QString name = param["name"].toString();
        setParameterValue(name, value[i]);
    }
    qDebug()<<"设置成功";
    if (changed) {
        emit parameterItemsChanged();
    }
}

void TpInvcontroldata::confirmParameters()
{
    emit commandRequested(QString::fromLatin1(CommandConfirmParameters),
                          QVariantMap{{QStringLiteral("parameters"), parameterItems_}});
}

void TpInvcontroldata::applyParameters()
{
    emit commandRequested(QString::fromLatin1(CommandApplyParameters),
                          QVariantMap{{QStringLiteral("parameters"), parameterItems_}});
}

void TpInvcontroldata::requestParameters()
{
    emit commandRequested(QString::fromLatin1(CommandRequestParameters), {});
}

void TpInvcontroldata::startInverter()
{
    setRunning(true);
    emit commandRequested(QString::fromLatin1(CommandStartInverter), {});
}

void TpInvcontroldata::stopInverter()
{
    setRunning(false);
    emit commandRequested(QString::fromLatin1(CommandStopInverter), {});
}

void TpInvcontroldata::resetFault()
{
    setFaultCode(QStringLiteral("0x0000"));
    setFaultDescription(QStringLiteral("Normal"));
    emit commandRequested(QString::fromLatin1(CommandResetFault), {});
}

void TpInvcontroldata::updateMonitorValue(const QString &key, const QVariant &value)
{
    if (!setMonitorValueInGroups(key, value)) {
        return;
    }

    if (key == QStringLiteral("dcVoltage")) {
        dcVoltage_ = value.toDouble();
        syncSummaryMeasurements();
        emit measurementsChanged();
    } else if (key == QStringLiteral("acVoltage")) {
        acVoltage_ = value.toDouble();
        syncSummaryMeasurements();
        emit measurementsChanged();
    } else if (key == QStringLiteral("acFrequencyA")) {
        acFrequency_ = value.toDouble();
        syncSummaryMeasurements();
        emit measurementsChanged();
    } else if (key == QStringLiteral("faultCode")) {
        faultCode_ = value.toString();
        emit faultChanged();
    }

    emit monitorGroupsChanged();
}

void TpInvcontroldata::reset()
{
    const bool wasRunning = running_;
    initializeDefaults();

    emit parameterItemsChanged();
    emit monitorGroupsChanged();
    emit runSummaryTextChanged();
    emit faultChanged();
    emit measurementsChanged();

    if (wasRunning != running_) {
        emit runningChanged();
    }
}

QVariantMap TpInvcontroldata::makeParameter(const QString &key,
                                            const QString &icon,
                                            const QString &label,
                                            double value,
                                            double minimum,
                                            double maximum,
                                            double step,
                                            int precision,
                                            const QString &unit,
                                            bool stepper) const
{
    return {
        {QStringLiteral("key"), key},
        {QStringLiteral("icon"), icon},
        {QStringLiteral("label"), label},
        {QStringLiteral("value"), value},
        {QStringLiteral("minimum"), minimum},
        {QStringLiteral("maximum"), maximum},
        {QStringLiteral("step"), step},
        {QStringLiteral("precision"), precision},
        {QStringLiteral("unit"), unit},
        {QStringLiteral("stepper"), stepper},
    };
}

QVariantMap TpInvcontroldata::makeMonitorGroup(const QString &title,
                                               const QString &accent,
                                               const QVariantList &items) const
{
    return {
        {QStringLiteral("title"), title},
        {QStringLiteral("accent"), accent},
        {QStringLiteral("items"), items},
    };
}

QVariantMap TpInvcontroldata::makeMonitorItem(const QString &key,
                                              const QString &name,
                                              const QVariant &value,
                                              const QString &unit) const
{
    return {
        {QStringLiteral("key"), key},
        {QStringLiteral("name"), name},
        {QStringLiteral("value"), value},
        {QStringLiteral("unit"), unit},
    };
}

int TpInvcontroldata::parameterIndex(const QString &key) const
{
    for (int i = 0; i < parameterItems_.size(); ++i) {
        if (parameterItems_.at(i).toMap().value(QStringLiteral("key")).toString() == key) {
            return i;
        }
    }

    return -1;
}

bool TpInvcontroldata::setMonitorValueInGroups(const QString &key, const QVariant &value)
{
    for (int groupIndex = 0; groupIndex < monitorGroups_.size(); ++groupIndex) {
        QVariantMap group = monitorGroups_.at(groupIndex).toMap();
        QVariantList items = group.value(QStringLiteral("items")).toList();

        for (int itemIndex = 0; itemIndex < items.size(); ++itemIndex) {
            QVariantMap item = items.at(itemIndex).toMap();
            if (item.value(QStringLiteral("key")).toString() != key) {
                continue;
            }

            if (item.value(QStringLiteral("value")) == value) {
                return false;
            }

            item.insert(QStringLiteral("value"), value);
            items[itemIndex] = item;
            group.insert(QStringLiteral("items"), items);
            monitorGroups_[groupIndex] = group;
            return true;
        }
    }

    return false;
}

void TpInvcontroldata::initializeDefaults()
{
    running_ = false;
    runSummaryText_ = QStringLiteral("System normal");
    faultCode_ = QStringLiteral("0x0000");
    faultDescription_ = QStringLiteral("Normal");
    dcVoltage_ = 0.0;
    acVoltage_ = 0.0;
    acFrequency_ = 0.0;

    parameterItems_ = {
        makeParameter(QStringLiteral("dcVoltageRms"), QStringLiteral("⚡"), QStringLiteral("直流电压有效值"), 15.0, 0.0, 1000.0, 0.1, 1, QStringLiteral("V"), false),
        makeParameter(QStringLiteral("ratedFrequency"), QStringLiteral("🔄"), QStringLiteral("额定频率(Hz)"), 50.0, 0.0, 400.0, 0.1, 1, QStringLiteral("Hz"), false),
        makeParameter(QStringLiteral("acVoltageSetpoint"), QStringLiteral("〰️"), QStringLiteral("交流电压设定(V)"), 220.0, 0.0, 1000.0, 0.1, 1, QStringLiteral("V"), true),
        makeParameter(QStringLiteral("acVoltageStep"), QStringLiteral("↕️"), QStringLiteral("交流电压步长(V)"), 1.0, 0.0, 100.0, 0.1, 1, QStringLiteral("V"), false),
        makeParameter(QStringLiteral("acFrequencySetpoint"), QStringLiteral("🔄"), QStringLiteral("交流频率给定(Hz)"), 50.0, 0.0, 400.0, 0.1, 1, QStringLiteral("Hz"), false),
    };

    monitorGroups_ = {
        makeMonitorGroup(QStringLiteral("Voltage"), QStringLiteral("#2f8dff"), {
            makeMonitorItem(QStringLiteral("dcVoltage"), QStringLiteral("DC voltage"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("halfBusVoltage"), QStringLiteral("Half bus voltage"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("phaseVoltageA"), QStringLiteral("Phase A voltage"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("phaseVoltageB"), QStringLiteral("Phase B voltage"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("phaseVoltageC"), QStringLiteral("Phase C voltage"), QStringLiteral("0.0"), QStringLiteral("V")),
        }),
        makeMonitorGroup(QStringLiteral("Current"), QStringLiteral("#37d6a3"), {
            makeMonitorItem(QStringLiteral("dcCurrent"), QStringLiteral("DC current"), QStringLiteral("0.0"), QStringLiteral("A")),
            makeMonitorItem(QStringLiteral("phaseCurrentA"), QStringLiteral("Phase A current"), QStringLiteral("0.0"), QStringLiteral("A")),
            makeMonitorItem(QStringLiteral("phaseCurrentB"), QStringLiteral("Phase B current"), QStringLiteral("0.0"), QStringLiteral("A")),
            makeMonitorItem(QStringLiteral("phaseCurrentC"), QStringLiteral("Phase C current"), QStringLiteral("0.0"), QStringLiteral("A")),
        }),
        makeMonitorGroup(QStringLiteral("Frequency and power"), QStringLiteral("#f7b955"), {
            makeMonitorItem(QStringLiteral("acFrequencyA"), QStringLiteral("Phase A frequency"), QStringLiteral("0.00"), QStringLiteral("Hz")),
            makeMonitorItem(QStringLiteral("acFrequencyB"), QStringLiteral("Phase B frequency"), QStringLiteral("0.00"), QStringLiteral("Hz")),
            makeMonitorItem(QStringLiteral("acFrequencyC"), QStringLiteral("Phase C frequency"), QStringLiteral("0.00"), QStringLiteral("Hz")),
            makeMonitorItem(QStringLiteral("dcPower"), QStringLiteral("DC side power"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("activePower"), QStringLiteral("AC active power"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("reactivePower"), QStringLiteral("AC reactive power"), QStringLiteral("0.0"), QStringLiteral("var")),
            makeMonitorItem(QStringLiteral("apparentPower"), QStringLiteral("AC apparent power"), QStringLiteral("0.0"), QStringLiteral("VA")),
            makeMonitorItem(QStringLiteral("powerFactor"), QStringLiteral("Power factor"), QStringLiteral("0.00"), QString()),
            makeMonitorItem(QStringLiteral("efficiency"), QStringLiteral("Efficiency"), QStringLiteral("0.0"), QStringLiteral("%")),
        }),
        makeMonitorGroup(QStringLiteral("Three-phase power"), QStringLiteral("#b88cff"), {
            makeMonitorItem(QStringLiteral("activePowerA"), QStringLiteral("Phase A active power"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("activePowerB"), QStringLiteral("Phase B active power"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("activePowerC"), QStringLiteral("Phase C active power"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("reactivePowerA"), QStringLiteral("Phase A reactive power"), QStringLiteral("0.0"), QStringLiteral("var")),
            makeMonitorItem(QStringLiteral("reactivePowerB"), QStringLiteral("Phase B reactive power"), QStringLiteral("0.0"), QStringLiteral("var")),
            makeMonitorItem(QStringLiteral("reactivePowerC"), QStringLiteral("Phase C reactive power"), QStringLiteral("0.0"), QStringLiteral("var")),
            makeMonitorItem(QStringLiteral("apparentPowerA"), QStringLiteral("Phase A apparent power"), QStringLiteral("0.0"), QStringLiteral("VA")),
            makeMonitorItem(QStringLiteral("apparentPowerB"), QStringLiteral("Phase B apparent power"), QStringLiteral("0.0"), QStringLiteral("VA")),
            makeMonitorItem(QStringLiteral("apparentPowerC"), QStringLiteral("Phase C apparent power"), QStringLiteral("0.0"), QStringLiteral("VA")),
        }),
        makeMonitorGroup(QStringLiteral("Temperature and version"), QStringLiteral("#ff8a4c"), {
            makeMonitorItem(QStringLiteral("ambientTemperature"), QStringLiteral("Ambient temperature"), QStringLiteral("0.0"), QStringLiteral("C")),
            makeMonitorItem(QStringLiteral("auxTemperature"), QStringLiteral("Aux temperature"), QStringLiteral("0.0"), QStringLiteral("C")),
            makeMonitorItem(QStringLiteral("igbtTemperature"), QStringLiteral("IGBT temperature"), QStringLiteral("0.0"), QStringLiteral("C")),
            makeMonitorItem(QStringLiteral("hardwareVersion"), QStringLiteral("Hardware version"), QStringLiteral("--"), QString()),
            makeMonitorItem(QStringLiteral("softwareVersion"), QStringLiteral("Software version"), QStringLiteral("--"), QString()),
        }),
        makeMonitorGroup(QStringLiteral("Diagnosis"), QStringLiteral("#ff5f68"), {
            makeMonitorItem(QStringLiteral("faultCode"), QStringLiteral("Fault code"), faultCode_, QString()),
        }),
    };
}

void TpInvcontroldata::syncSummaryMeasurements()
{
    setRunSummaryText(QStringLiteral("DC %1 V, AC %2 V, %3 Hz")
                          .arg(dcVoltage_, 0, 'f', 1)
                          .arg(acVoltage_, 0, 'f', 1)
                          .arg(acFrequency_, 0, 'f', 2));
}
