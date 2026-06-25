#include "TpInvcontroldata.h"

#include <QQmlEngine>
#include <QtGlobal>
#include <qdebug.h>
#include "Tpinvcontrolprocess.h"

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
QVariantList TpInvcontroldata::parametermodelItems() const
{
    return parametermodelItems_;
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

double TpInvcontroldata::dcVoltage() const
{
    return dcVoltage_;
}

double TpInvcontroldata::acVoltage() const
{
    return acVoltage_;
}

double TpInvcontroldata::acFrequency() const
{
    return acFrequency_;
}

QString TpInvcontroldata::faultCode() const
{
    return faultCode_;
}

int TpInvcontroldata::inverterState() const
{
    return inverterState_;
}

double TpInvcontroldata::acVoltageStep() const
{
    return acVoltageStep_;
}

QVariantMap TpInvcontroldata::calibrationData() const
{
    return calibrationData_;
}

void TpInvcontroldata::setallParameters(const QList<double> &value)
{
    bool changed = false;
    bool stepChanged = false;
    const int count = qMin(parameterItems_.size(), value.size());

    for (int i = 0; i < count; ++i) {
        QVariantMap param = parameterItems_.at(i).toMap();
        if (qFuzzyCompare(param.value(QStringLiteral("value")).toDouble(), value.at(i))) {
            continue;
        }

        param.insert(QStringLiteral("value"), value.at(i));
        parameterItems_[i] = param;
        changed = true;

        // 索引 2 是交流电压步长
        if (i == 2) {
            const double newStep = value.at(i);
            if (!qFuzzyCompare(acVoltageStep_, newStep)) {
                acVoltageStep_ = newStep;
                stepChanged = true;
            }
        }
    }

    if (changed) {
        qDebug() << "设置成功";
        emit parameterItemsChanged();
    }
    if (stepChanged) {
        emit acVoltageStepChanged();
    }
}

void TpInvcontroldata::startInverter(const QString &SerialPort)
{
    setRunning(true);
    emit parameterItemsChanged();
    const QByteArray fresh = Tpinvcontrolprocess::instance()->txBuffer().value(0);
    emit cmdTx(SerialPort, fresh);
}

void TpInvcontroldata::stopInverter(const QString &SerialPort)
{
    setRunning(false);
    emit parameterItemsChanged();
    const QByteArray fresh = Tpinvcontrolprocess::instance()->txBuffer().value(0);
    emit cmdTx(SerialPort, fresh);
}

QVariantMap TpInvcontroldata::makeParameterModel(const QString &key,
                                               const QString &label,
                                               const QString &value,
                                               bool enabled) const
{
    return {
        {QStringLiteral("key"), key},
        {QStringLiteral("label"), label},
        {QStringLiteral("value"), value},
        {QStringLiteral("enabled"), enabled},
    };
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

void TpInvcontroldata::initializeDefaults()
{
    running_ = false;
    faultCode_ = QStringLiteral("0x00000000");

    parametermodelItems_ = {
        makeParameterModel(QStringLiteral("SinglephaseInverter"), QStringLiteral("单相逆变"), QStringLiteral("0"), true),
        makeParameterModel(QStringLiteral("ThreePhaseInverter"), QStringLiteral("三相逆变"), QStringLiteral("1"), true),
        makeParameterModel(QStringLiteral("ThreePhaseInverterReverse"), QStringLiteral("三电平逆变"), QStringLiteral("2"), true),
    };

    parameterItems_ = {
        makeParameter(QStringLiteral("acVoltageSetpoint"), QStringLiteral("〰️"), QStringLiteral("交流电压设定(V)"), 15.0, 0.0, 1000.0, 0.1, 1, QStringLiteral("V"), true),
        makeParameter(QStringLiteral("ratedFrequency"), QStringLiteral("🔄"), QStringLiteral("设定频率(Hz)"), 50.0, 0.0, 400.0, 0.1, 1, QStringLiteral("Hz"), false),
        makeParameter(QStringLiteral("acVoltageStep"), QStringLiteral("↕️"), QStringLiteral("交流电压步长(V)"), 1.0, 0.0, 100.0, 0.1, 1, QStringLiteral("V"), false),
    };

    monitorGroups_ = {
        makeMonitorGroup(QStringLiteral("电压"), QStringLiteral("#2f8dff"), {
            makeMonitorItem(QStringLiteral("dcVoltage"), QStringLiteral("直流电压"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("halfBusVoltage"), QStringLiteral("半母线电压"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("phaseVoltageA"), QStringLiteral("A相电压"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("phaseVoltageB"), QStringLiteral("B相电压"), QStringLiteral("0.0"), QStringLiteral("V")),
            makeMonitorItem(QStringLiteral("phaseVoltageC"), QStringLiteral("C相电压"), QStringLiteral("0.0"), QStringLiteral("V")),
        }),
        makeMonitorGroup(QStringLiteral("电流"), QStringLiteral("#37d6a3"), {
            makeMonitorItem(QStringLiteral("dcCurrent"), QStringLiteral("直流电流"), QStringLiteral("0.0"), QStringLiteral("A")),
            makeMonitorItem(QStringLiteral("phaseCurrentA"), QStringLiteral("A相电流"), QStringLiteral("0.0"), QStringLiteral("A")),
            makeMonitorItem(QStringLiteral("phaseCurrentB"), QStringLiteral("B相电流"), QStringLiteral("0.0"), QStringLiteral("A")),
            makeMonitorItem(QStringLiteral("phaseCurrentC"), QStringLiteral("C相电流"), QStringLiteral("0.0"), QStringLiteral("A")),
        }),
        makeMonitorGroup(QStringLiteral("频率与功率"), QStringLiteral("#f7b955"), {
            makeMonitorItem(QStringLiteral("acFrequencyA"), QStringLiteral("A相频率"), QStringLiteral("0.00"), QStringLiteral("Hz")),
            makeMonitorItem(QStringLiteral("acFrequencyB"), QStringLiteral("B相频率"), QStringLiteral("0.00"), QStringLiteral("Hz")),
            makeMonitorItem(QStringLiteral("acFrequencyC"), QStringLiteral("C相频率"), QStringLiteral("0.00"), QStringLiteral("Hz")),
            makeMonitorItem(QStringLiteral("dcPower"), QStringLiteral("直流侧功率"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("activePower"), QStringLiteral("交流有功功率"), QStringLiteral("0.0"), QStringLiteral("W")),
            makeMonitorItem(QStringLiteral("reactivePower"), QStringLiteral("交流无功功率"), QStringLiteral("0.0"), QStringLiteral("var")),
            makeMonitorItem(QStringLiteral("apparentPower"), QStringLiteral("交流视在功率"), QStringLiteral("0.0"), QStringLiteral("VA")),
            makeMonitorItem(QStringLiteral("powerFactor"), QStringLiteral("功率因数"), QStringLiteral("0.00"), QString()),
            makeMonitorItem(QStringLiteral("efficiency"), QStringLiteral("效率"), QStringLiteral("0.0"), QStringLiteral("%")),
        }),
        // makeMonitorGroup(QStringLiteral("三相功率"), QStringLiteral("#b88cff"), {
        //     makeMonitorItem(QStringLiteral("activePowerA"), QStringLiteral("A相有功功率"), QStringLiteral("0.0"), QStringLiteral("W")),
        //     makeMonitorItem(QStringLiteral("activePowerB"), QStringLiteral("B相有功功率"), QStringLiteral("0.0"), QStringLiteral("W")),
        //     makeMonitorItem(QStringLiteral("activePowerC"), QStringLiteral("C相有功功率"), QStringLiteral("0.0"), QStringLiteral("W")),
        //     makeMonitorItem(QStringLiteral("reactivePowerA"), QStringLiteral("A相无功功率"), QStringLiteral("0.0"), QStringLiteral("var")),
        //     makeMonitorItem(QStringLiteral("reactivePowerB"), QStringLiteral("B相无功功率"), QStringLiteral("0.0"), QStringLiteral("var")),
        //     makeMonitorItem(QStringLiteral("reactivePowerC"), QStringLiteral("C相无功功率"), QStringLiteral("0.0"), QStringLiteral("var")),
        //     makeMonitorItem(QStringLiteral("apparentPowerA"), QStringLiteral("A相视在功率"), QStringLiteral("0.0"), QStringLiteral("VA")),
        //     makeMonitorItem(QStringLiteral("apparentPowerB"), QStringLiteral("B相视在功率"), QStringLiteral("0.0"), QStringLiteral("VA")),
        //     makeMonitorItem(QStringLiteral("apparentPowerC"), QStringLiteral("C相视在功率"), QStringLiteral("0.0"), QStringLiteral("VA")),
        // }),
        makeMonitorGroup(QStringLiteral("温度与版本"), QStringLiteral("#ff8a4c"), {
            makeMonitorItem(QStringLiteral("ambientTemperature"), QStringLiteral("环境温度"), QStringLiteral("0.0"), QStringLiteral("C")),
            makeMonitorItem(QStringLiteral("auxTemperature"), QStringLiteral("辅助温度"), QStringLiteral("0.0"), QStringLiteral("C")),
            makeMonitorItem(QStringLiteral("igbtTemperature"), QStringLiteral("IGBT温度"), QStringLiteral("0.0"), QStringLiteral("C")),
            makeMonitorItem(QStringLiteral("hardwareVersion"), QStringLiteral("硬件版本"), QStringLiteral("--"), QString()),
            makeMonitorItem(QStringLiteral("softwareVersion"), QStringLiteral("软件版本"), QStringLiteral("--"), QString()),
        }),
        makeMonitorGroup(QStringLiteral("诊断"), QStringLiteral("#ff5f68"), {
            makeMonitorItem(QStringLiteral("faultCode"), QStringLiteral("故障代码"), faultCode_, QString()),
        }),
    };
}

void TpInvcontroldata::sendCommand(const QString &SerialPort, const QByteArray &data)
{

    emit cmdTx(SerialPort, data);
}

void TpInvcontroldata::switchConnectMode(int mode, const QString &SerialPort)
{
    setConnectMode(mode);
    // setConnectMode 内部 emit ConnectModeChanged → Tpinvcontrolprocess::buildControlMode() 重建 txBuffer[1]
    const QByteArray data = Tpinvcontrolprocess::instance()->txBuffer().value(1);
    if (mode) {
        emit modeSwitchCmdTx(data);   
    } else {
        emit cmdTx(SerialPort, data);   
    }
}

void TpInvcontroldata::applyMonitorSnapshot(const QVariantMap &values)
{
    if (values.isEmpty())
        return;

    bool anyGroupChanged = false;

    for (int gi = 0; gi < monitorGroups_.size(); ++gi) {
        QVariantMap group = monitorGroups_.at(gi).toMap();
        QVariantList items = group.value(QStringLiteral("items")).toList();
        bool changed = false;

        for (int ii = 0; ii < items.size(); ++ii) {
            QVariantMap item = items.at(ii).toMap();
            const QString key = item.value(QStringLiteral("key")).toString();
            if (values.contains(key)) {
                item[QStringLiteral("value")] = values[key];
                items[ii] = item;
                changed = true;
            }
        }

        if (changed) {
            group[QStringLiteral("items")] = items;
            monitorGroups_[gi] = group;
            anyGroupChanged = true;
        }
    }

    if (anyGroupChanged)
        emit monitorGroupsChanged();

    // 提取逆变器状态 (COM_F3 帧 raw[3])，并同步 running_ 标志
    if (values.contains(QStringLiteral("inverterState"))) {
        const int newState = values.value(QStringLiteral("inverterState")).toInt();
        if (inverterState_ != newState) {
            inverterState_ = newState;
            emit inverterStateChanged();
        }
        // 根据逆变器状态同步 running_：只有 INV_RUNNING(4) 算运行中
        const bool shouldRun = (newState == 4);
        if (running_ != shouldRun) {
            running_ = shouldRun;
            emit runningChanged();
        }
    }

    // 提取校正系数 (COM_F8/F9 帧)
    // 映射 DSP 字段 → QML correctionTypes.value
    static const QVector<QPair<QString, QPair<QString, QString>>> calibMappings = {
        {QStringLiteral("dcVoltage"),     {QStringLiteral("caliDcVoltA"),    QStringLiteral("caliDcVoltB")}},
        {QStringLiteral("halfBusVoltage"),{QStringLiteral("caliHalfVoltA"),  QStringLiteral("caliHalfVoltB")}},
        {QStringLiteral("acVoltageRms"),  {QStringLiteral("caliPhaseVoltA"), QStringLiteral("caliPhaseVoltB")}},
        {QStringLiteral("dcCurrent"),     {QStringLiteral("caliDcCurrA"),    QStringLiteral("caliDcCurrB")}},
        {QStringLiteral("acCurrentRms"),  {QStringLiteral("caliPhaseCurrA"), QStringLiteral("caliPhaseCurrB")}},
    };

    bool calibChanged = false;
    for (const auto &mapping : calibMappings) {
        const QString &typeKey = mapping.first;
        const QString &keyA = mapping.second.first;
        const QString &keyB = mapping.second.second;
        if (values.contains(keyA) || values.contains(keyB)) {
            QVariantMap coeff;
            coeff[QStringLiteral("a")] = values.value(keyA, calibrationData_.value(typeKey).toMap().value(QStringLiteral("a"), 1.0));
            coeff[QStringLiteral("b")] = values.value(keyB, calibrationData_.value(typeKey).toMap().value(QStringLiteral("b"), 0.0));
            calibrationData_[typeKey] = coeff;
            calibChanged = true;
        }
    }
    if (calibChanged)
        emit calibrationDataChanged();

    extractKeyMetrics();
}

QVariant TpInvcontroldata::findMonitorValue(const QString &key) const
{
    for (const QVariant &g : monitorGroups_) {
        const QVariantMap group = g.toMap();
        const QVariantList items = group.value(QStringLiteral("items")).toList();
        for (const QVariant &i : items) {
            const QVariantMap item = i.toMap();
            if (item.value(QStringLiteral("key")).toString() == key)
                return item.value(QStringLiteral("value"));
        }
    }
    return {};
}

void TpInvcontroldata::extractKeyMetrics()
{
    // 电压数据：DSP 精度 UINT_VOLT=10 → 0.1V，四舍五入到 1 位小数
    const double newDcVoltage = findMonitorValue(QStringLiteral("dcVoltage")).toDouble();
    const double phaseA = findMonitorValue(QStringLiteral("phaseVoltageA")).toDouble();
    const double phaseB = findMonitorValue(QStringLiteral("phaseVoltageB")).toDouble();
    const double phaseC = findMonitorValue(QStringLiteral("phaseVoltageC")).toDouble();
    const double newAcVoltage = (phaseA + phaseB + phaseC) / 3.0;      
    const double newAcFrequency = findMonitorValue(QStringLiteral("acFrequencyA")).toDouble();
    const QString newFaultCode = findMonitorValue(QStringLiteral("faultCode")).toString();

    bool changed = false;

    if (!qFuzzyCompare(dcVoltage_, newDcVoltage)) {
        dcVoltage_ = newDcVoltage;
        changed = true;
    }
    if (!qFuzzyCompare(acVoltage_, newAcVoltage)) {
        acVoltage_ = newAcVoltage;
        changed = true;
    }
    if (!qFuzzyCompare(acFrequency_, newAcFrequency)) {
        acFrequency_ = newAcFrequency;
        changed = true;
    }
    if (faultCode_ != newFaultCode) {
        faultCode_ = newFaultCode;
        changed = true;
    }

    if (changed)
        emit keyMetricsChanged();
}