#include "K3data.h"

#include <QQmlEngine>

K3data::K3data(QObject *parent)
    : QObject(parent)
{
    init_k3dataAllDefaults();
    init_k3dataleftDefaults();
    init_k3datadownDefaults();
}
K3data::~K3data() = default;

K3data *K3data::instance()
{
    static K3data ins;
    return &ins;
}

bool K3data::InitK3data()
{
    init_k3dataAllDefaults();
    init_k3dataleftDefaults();
    init_k3datadownDefaults();
    emit k3data_allChanged();
    emit k3data_leftChanged();
    emit k3data_downChanged();

    return true;
}

K3data *K3data::create(QQmlEngine *, QJSEngine *)
{
    auto *k3data = instance();
    QQmlEngine::setObjectOwnership(k3data, QQmlEngine::CppOwnership);
    return k3data;
}

// ═══════════════════════════════════════════════════════════════════
// 构造辅助
// ═══════════════════════════════════════════════════════════════════

QVariantMap K3data::makeMonitorGroup(const QString &title,
                              const QVariant &rows,
                              const QVariantList &metrics) const
{
    return {
        {QStringLiteral("title"), title},
        {QStringLiteral("rows"), rows},
        {QStringLiteral("metrics"), metrics},
    };
}
QVariantMap K3data::makeMonitorItem(const QString &key,
                             const QString &name,
                             const QVariant &value,
                             const QVariant &accent) const
{
    return {
        {QStringLiteral("key"), key},
        {QStringLiteral("name"), name},
        {QStringLiteral("value"), value},
        {QStringLiteral("accent"), accent},
    };
}

// ═══════════════════════════════════════════════════════════════════
// 统一数据源 — k3data_all
// ═══════════════════════════════════════════════════════════════════

void K3data::init_k3dataAllDefaults()
{
    m_k3data_all = {
        // ═══ DB444 — AI 模拟量 (19 floats, start=1) ═══
        makeMonitorGroup(QStringLiteral("DB444 AI 模拟量"), 7, {
            makeMonitorItem(QStringLiteral("WellheadPressure"),        QStringLiteral("井口压力"),      0.0, true),
            makeMonitorItem(QStringLiteral("AI_P_wellhead2"),         QStringLiteral("井口压力2"),     0.0, false),
            makeMonitorItem(QStringLiteral("MainChannelPressure"),    QStringLiteral("主通道压力"),    0.0, true),
            makeMonitorItem(QStringLiteral("AuxiliaryChannelPressure"),QStringLiteral("辅助通道压力"),  0.0, true),
            makeMonitorItem(QStringLiteral("StandpipePressure"),      QStringLiteral("立管压力"),      0.0, true),
            makeMonitorItem(QStringLiteral("ThrottledPressure"),      QStringLiteral("节流后压力"),    0.0, false),
            makeMonitorItem(QStringLiteral("pres_air"),               QStringLiteral("气源压力"),      0.0, false),
            makeMonitorItem(QStringLiteral("pres_yeyazhan"),          QStringLiteral("液压站压力"),    0.0, false),
            makeMonitorItem(QStringLiteral("AI_ValvePosition2"),      QStringLiteral("节流阀A开度"),   0.0, true),
            makeMonitorItem(QStringLiteral("AI_ValvePosition3"),      QStringLiteral("节流阀B开度"),   0.0, true),
            makeMonitorItem(QStringLiteral("AI_ValvePosition1"),      QStringLiteral("节流阀C开度"),   0.0, true),
            makeMonitorItem(QStringLiteral("temp_jieliuqian"),        QStringLiteral("节流前温度"),     0.0, false),
            makeMonitorItem(QStringLiteral("temp_yeyazhan"),          QStringLiteral("液压站温度"),     0.0, false),
            makeMonitorItem(QStringLiteral("AI_T_EH"),                QStringLiteral("EH温度"),         0.0, false),
            makeMonitorItem(QStringLiteral("bilifa1"),                QStringLiteral("比例阀1"),        0.0, false),
            makeMonitorItem(QStringLiteral("bilifa2"),                QStringLiteral("比例阀2"),        0.0, false),
            makeMonitorItem(QStringLiteral("bilifa3"),                QStringLiteral("比例阀3"),        0.0, false),
            makeMonitorItem(QStringLiteral("OutletFlow"),             QStringLiteral("出口流量(L/s)"),  0.0, true),
            makeMonitorItem(QStringLiteral("OutletDensity"),          QStringLiteral("出口密度(g/cm³)"), 0.0, false),
        }),

        // ═══ DB555 — DI 数字量 (14 bytes, start=1) ═══
        makeMonitorGroup(QStringLiteral("DB555 DI 数字量"), 5, {
            makeMonitorItem(QStringLiteral("PlateValve1_Open"),       QStringLiteral("节流阀A开"),     false, false),
            makeMonitorItem(QStringLiteral("PlateValve1_Close"),      QStringLiteral("节流阀A关"),     false, false),
            makeMonitorItem(QStringLiteral("PlateValve2_Open"),       QStringLiteral("节流阀B开"),     false, false),
            makeMonitorItem(QStringLiteral("PlateValve2_Close"),      QStringLiteral("节流阀B关"),     false, false),
            makeMonitorItem(QStringLiteral("PlateValve3_Open"),       QStringLiteral("节流阀C开"),     false, false),
            makeMonitorItem(QStringLiteral("PlateValve3_Close"),      QStringLiteral("节流阀C关"),     false, false),
            makeMonitorItem(QStringLiteral("Level_Low"),              QStringLiteral("液位低"),        false, false),
            makeMonitorItem(QStringLiteral("CentralControlId"),       QStringLiteral("中控标识"),      false, false),
            makeMonitorItem(QStringLiteral("CabinetTemperatureHi"),   QStringLiteral("柜温高"),        false, false),
            makeMonitorItem(QStringLiteral("PropValve1_Fault"),       QStringLiteral("比例阀1故障"),   false, false),
            makeMonitorItem(QStringLiteral("PropValve2_Fault"),       QStringLiteral("比例阀2故障"),   false, false),
            makeMonitorItem(QStringLiteral("PropValve3_Fault"),       QStringLiteral("比例阀3故障"),   false, false),
            makeMonitorItem(QStringLiteral("Contactor1"),             QStringLiteral("接触器1"),       false, false),
            makeMonitorItem(QStringLiteral("Contactor2"),             QStringLiteral("接触器2"),       false, false),
        }),

        // ═══ DB222 — 流程数据 (14 floats, start=1) ═══
        makeMonitorGroup(QStringLiteral("DB222 流程数据"), 5, {
            makeMonitorItem(QStringLiteral("BitDepth"),               QStringLiteral("钻头深度(m)"),     0.0, false),
            makeMonitorItem(QStringLiteral("WellDepth"),              QStringLiteral("井深(m)"),         0.0, false),
            makeMonitorItem(QStringLiteral("InletFlow"),              QStringLiteral("入口流量(L/s)"),   0.0, true),
            makeMonitorItem(QStringLiteral("PumpStroke1"),            QStringLiteral("泵冲1"),           0.0, false),
            makeMonitorItem(QStringLiteral("PumpStroke2"),            QStringLiteral("泵冲2"),           0.0, false),
            makeMonitorItem(QStringLiteral("PumpStroke3"),            QStringLiteral("泵冲3"),           0.0, false),
            makeMonitorItem(QStringLiteral("EcdDensity"),             QStringLiteral("ECD密度(g/cm³)"),  0.0, false),
            makeMonitorItem(QStringLiteral("Friction"),               QStringLiteral("环空摩阻"),         0.0, false),
        }),
    };
}

// ═══════════════════════════════════════════════════════════════════
// 从 k3data_all 中按 key 查找 item
// ═══════════════════════════════════════════════════════════════════

QVariantMap K3data::findItemInAll(const QString &key) const
{
    for (const QVariant &g : m_k3data_all) {
        const QVariantMap group = g.toMap();
        const QVariantList metrics = group[QStringLiteral("metrics")].toList();
        for (const QVariant &m : metrics) {
            QVariantMap item = m.toMap();
            if (item[QStringLiteral("key")].toString() == key)
                return item;
        }
    }
    return {};
}

// ═══════════════════════════════════════════════════════════════════
// 统一更新入口 — K3dataprocess 只调用此方法写数据
// ═══════════════════════════════════════════════════════════════════

void K3data::applyUpdate(const QString &key, const QVariant &newValue)
{
    for (int gi = 0; gi < m_k3data_all.size(); ++gi) {
        QVariantMap group = m_k3data_all[gi].toMap();
        QVariantList metrics = group[QStringLiteral("metrics")].toList();
        for (int mi = 0; mi < metrics.size(); ++mi) {
            QVariantMap item = metrics[mi].toMap();
            if (item[QStringLiteral("key")].toString() == key) {
                item[QStringLiteral("value")] = newValue;
                metrics[mi] = item;
                group[QStringLiteral("metrics")] = metrics;
                m_k3data_all[gi] = group;
                return;
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// 将 k3data_all 的数据同步到 k3data_left / k3data_down
// ═══════════════════════════════════════════════════════════════════

void K3data::syncToLeftAndDown()
{
    emit k3data_allChanged();
    syncLeftFromAll();
    syncDownFromAll();
}

void K3data::syncLeftFromAll()
{
    // 从 k3data_all 中取值，不存在则用 fallback
    auto val = [this](const QString &key, double fallback = 0.0) -> QVariant {
        QVariantMap item = findItemInAll(key);
        return item.isEmpty() ? QVariant(fallback) : item[QStringLiteral("value")];
    };
    auto acc = [this](const QString &key, bool fallback = false) -> QVariant {
        QVariantMap item = findItemInAll(key);
        return item.isEmpty() ? QVariant(fallback) : item[QStringLiteral("accent")];
    };

    m_k3data_left = {
        makeMonitorGroup(QStringLiteral("井口压力控制参数(MPa)"), 1, {
            makeMonitorItem(QStringLiteral("CirculatingBackpressure"), QStringLiteral("循环回压"), 0.0, false),
            makeMonitorItem(QStringLiteral("AdditionalBackpressure"),   QStringLiteral("附加回压"), 0.0, false),
        }),
        makeMonitorGroup(QStringLiteral("实际测量压力(MPa)"), 4, {
            makeMonitorItem(QStringLiteral("MainChannelPressure"),       QStringLiteral("主通道压力"),   val("MainChannelPressure", 7.5),    acc("MainChannelPressure", true)),
            makeMonitorItem(QStringLiteral("WellheadPressure"),          QStringLiteral("井口压力"),     val("WellheadPressure"),            acc("WellheadPressure", true)),
            makeMonitorItem(QStringLiteral("AuxiliaryChannelPressure"),  QStringLiteral("辅助通道压力"), val("AuxiliaryChannelPressure", 1.2), acc("AuxiliaryChannelPressure", true)),
            makeMonitorItem(QStringLiteral("StandpipePressure"),         QStringLiteral("立管压力"),     val("StandpipePressure"),           acc("StandpipePressure", true)),
            makeMonitorItem(QStringLiteral("ThrottledPressure"),         QStringLiteral("节流后压力"),   val("ThrottledPressure", 0.8),      false),
            makeMonitorItem(QStringLiteral("PumpStroke1"),               QStringLiteral("泵冲1"),        val("PumpStroke1", 70.143),         false),
            makeMonitorItem(QStringLiteral("PumpStroke2"),               QStringLiteral("泵冲2"),        val("PumpStroke2", 70.265),         false),
            makeMonitorItem(QStringLiteral("PumpStroke3"),               QStringLiteral("泵冲3"),        val("PumpStroke3", 70.396),         false),
        }),
        makeMonitorGroup(QStringLiteral("流量测量(L/s)"), 1, {
            makeMonitorItem(QStringLiteral("InletFlow"),  QStringLiteral("入口流量"), val("InletFlow"),  acc("InletFlow", true)),
            makeMonitorItem(QStringLiteral("OutletFlow"), QStringLiteral("出口流量"), val("OutletFlow"), acc("OutletFlow", true)),
        }),
        makeMonitorGroup(QStringLiteral("深度测量(m)"), 1, {
            makeMonitorItem(QStringLiteral("BitDepth"),  QStringLiteral("钻头深度"), val("BitDepth", 3660.6), false),
            makeMonitorItem(QStringLiteral("WellDepth"), QStringLiteral("井深"),     val("WellDepth", 3660.6), false),
        }),
        makeMonitorGroup(QStringLiteral("密度测量(g/cm³)"), 1, {
            makeMonitorItem(QStringLiteral("OutletDensity"), QStringLiteral("出口密度"), val("OutletDensity", 1.141), false),
            makeMonitorItem(QStringLiteral("EcdDensity"),    QStringLiteral("ECD密度"),  val("EcdDensity", 1.141),    false),
        }),
    };
    emit k3data_leftChanged();
}

void K3data::syncDownFromAll()
{
    auto val = [this](const QString &key) -> QVariant {
        QVariantMap item = findItemInAll(key);
        return item.isEmpty() ? QVariant(0.0) : item[QStringLiteral("value")];
    };

    m_k3data_down = {
        makeMonitorItem(QStringLiteral("AI_ValvePosition2"), QStringLiteral("节流阀A"), val("AI_ValvePosition2"), false),
        makeMonitorItem(QStringLiteral("AI_ValvePosition3"), QStringLiteral("节流阀B"), val("AI_ValvePosition3"), false),
        makeMonitorItem(QStringLiteral("AI_ValvePosition1"), QStringLiteral("节流阀C"), val("AI_ValvePosition1"), false),
    };
    emit k3data_downChanged();
}

void K3data::init_k3dataleftDefaults()
{
    syncLeftFromAll();
}

void K3data::init_k3datadownDefaults()
{
    syncDownFromAll();
}

// ═══════════════════════════════════════════════════════════════════
// 直接 setter（保留兼容）
// ═══════════════════════════════════════════════════════════════════

void K3data::setK3data_left(const QVariantList &list)
{
    if (m_k3data_left != list) {
        m_k3data_left = list;
        emit k3data_leftChanged();
    }
}
void K3data::setK3data_down(const QVariantList &list)
{
    if (m_k3data_down != list) {
        m_k3data_down = list;
        emit k3data_downChanged();
    }
}
void K3data::setK3data_all(const QVariantList &list)
{
    if (m_k3data_all != list) {
        m_k3data_all = list;
        emit k3data_allChanged();
    }
}
