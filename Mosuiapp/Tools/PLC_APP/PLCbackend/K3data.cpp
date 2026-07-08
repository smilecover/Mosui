#include "K3data.h"

#include <QQmlEngine>

K3data::K3data(QObject *parent)
    : QObject(parent)
{
    init_k3dataleftDefaults();
    init_k3datadownDefaults();
}
K3data::~K3data() = default;

K3data *K3data::instance()
{
    static K3data ins;
    return &ins;
}
void K3data::setK3data_left(const QVariantList &list)
{
    if (m_k3data_left != list) {
        m_k3data_left = list;
        emit k3data_leftChanged();
    }
}

bool K3data::InitK3data()
{
    init_k3dataleftDefaults();
    init_k3datadownDefaults();
    emit k3data_leftChanged();

    return true;
}

K3data *K3data::create(QQmlEngine *, QJSEngine *)
{
    auto *k3data = instance();
    QQmlEngine::setObjectOwnership(k3data, QQmlEngine::CppOwnership);
    return k3data;
}
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

void K3data::init_k3dataleftDefaults()
{
    m_k3data_left = {
        makeMonitorGroup(QStringLiteral("井口压力控制参数(MPa)"), 1, {
                makeMonitorItem(QStringLiteral("CirculatingBackpressure"), QStringLiteral("循环回压"), 0.0, false),
                makeMonitorItem(QStringLiteral("AdditionalBackpressure"),   QStringLiteral("附加回压"), 0.0, false),
            }
        ),
        makeMonitorGroup(QStringLiteral("实际测量压力(MPa)"), 4, {
                makeMonitorItem(QStringLiteral("MainChannelPressure"),       QStringLiteral("主通道压力"),   7.5,    true),
                makeMonitorItem(QStringLiteral("WellheadPressure"),          QStringLiteral("井口压力"),     0.0,    true),
                makeMonitorItem(QStringLiteral("AuxiliaryChannelPressure"),  QStringLiteral("辅助通道压力"), 1.2,    true),
                makeMonitorItem(QStringLiteral("StandpipePressure"),         QStringLiteral("立管压力"),     0.0,    true),
                makeMonitorItem(QStringLiteral("ThrottledPressure"),         QStringLiteral("节流后压力"),   0.8,    false),
                makeMonitorItem(QStringLiteral("PumpStroke1"),               QStringLiteral("泵冲1"),        70.143, false),
                makeMonitorItem(QStringLiteral("PumpStroke2"),               QStringLiteral("泵冲2"),        70.265, false),
                makeMonitorItem(QStringLiteral("PumpStroke3"),               QStringLiteral("泵冲3"),        70.396, false),
            }
        ),
        makeMonitorGroup(QStringLiteral("流量测量(L/s)"), 1, {
                makeMonitorItem(QStringLiteral("InletFlow"),  QStringLiteral("入口流量"), 0.0, true),
                makeMonitorItem(QStringLiteral("OutletFlow"), QStringLiteral("出口流量"), 0.0, true),
            }
        ),
        makeMonitorGroup(QStringLiteral("深度测量(m)"), 1, {
                makeMonitorItem(QStringLiteral("BitDepth"),  QStringLiteral("钻头深度"), 3660.6, false),
                makeMonitorItem(QStringLiteral("WellDepth"), QStringLiteral("井深"),     3660.6, false),
            }
        ),
        makeMonitorGroup(QStringLiteral("密度测量(g/cm³)"), 1, {
                makeMonitorItem(QStringLiteral("OutletDensity"), QStringLiteral("出口密度"), 1.141, false),
                makeMonitorItem(QStringLiteral("EcdDensity"),    QStringLiteral("ECD密度"),  1.141, false),
            }
        ),
    };

}
void K3data::setK3data_down(const QVariantList &list)
{
    if (m_k3data_down != list) {
        m_k3data_down = list;
        emit k3data_downChanged();
    }
}
void K3data::init_k3datadownDefaults()
{
    m_k3data_down = {
   
        makeMonitorItem(QStringLiteral("PlateValve1_Open"), QStringLiteral("节流阀A"), 0.0, false),
        makeMonitorItem(QStringLiteral("PlateValve2_Open"), QStringLiteral("节流阀B"), 0.0, false),
        makeMonitorItem(QStringLiteral("PlateValve3_Open"), QStringLiteral("节流阀C"), 0.0, false),
    };

}
