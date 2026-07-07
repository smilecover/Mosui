#include "K3dataprocess.h"

#include <QQmlEngine>
#include <QTimer>
#include <QtEndian>

#include "K3Client.h"
#include "K3data.h"


K3dataprocess::K3dataprocess(QObject *parent)
    : QObject(parent)
    , m_pollTimer(new QTimer(this))
{
    // ── 设置 1 秒定时器 ──
    m_pollTimer->setInterval(kPollIntervalMs);
    m_pollTimer->setTimerType(Qt::PreciseTimer);
    QObject::connect(m_pollTimer, &QTimer::timeout,
                     this, &K3dataprocess::onPollTimeout);

    // ── 连接状态变化时自动启停轮询 ──
    auto *client = K3Client::instance();
    QObject::connect(client, &K3Client::isConnectedChanged,
                     this, [this]() {
        if (K3Client::instance()->isConnected())
            startPolling();
        else
            stopPolling();
    });

    // ── 数据分发：信号 → 命名槽（比 lambda 更可靠） ──
    QObject::connect(client, &K3Client::realDataReceived,
                     this, &K3dataprocess::onRealDataReceived);
    QObject::connect(client, &K3Client::bitDataReceived,
                     this, &K3dataprocess::onBitDataReceived);
}

void K3dataprocess::InitK3dataprocess()
{
    // 如果已经连接，立即开始轮询
    if (K3Client::instance()->isConnected())
        startPolling();
}

// ═══════════════════════════════════════════════════════════
// 数据分发槽
// ═══════════════════════════════════════════════════════════

void K3dataprocess::onRealDataReceived(int dbNumber, int start,
                                        QVector<float> values)
{
    if (dbNumber == kAI_DbNumber)
        processAIData(dbNumber, start, values);
    else if (dbNumber == kFlow_DbNumber)
        processFlowData(dbNumber, start, values);
}

void K3dataprocess::onBitDataReceived(int dbNumber, int start,
                                       QVector<quint8> rawBytes)
{
    if (dbNumber == kDI_DbNumber)
        processDIData(dbNumber, start, rawBytes);
}

K3dataprocess::~K3dataprocess() = default;


K3dataprocess *K3dataprocess::instance()
{
    static K3dataprocess ins;
    return &ins;
}

K3dataprocess *K3dataprocess::create(QQmlEngine *, QJSEngine *)
{
    auto *dataprocess = instance();
    QQmlEngine::setObjectOwnership(dataprocess, QQmlEngine::CppOwnership);
    return dataprocess;
}

void K3dataprocess::startPolling()
{
    if (!m_pollTimer->isActive()) {
        m_pollTimer->start();
        // 立即触发一次，不等第一个间隔
        onPollTimeout();
    }
}

void K3dataprocess::stopPolling()
{
    if (m_pollTimer->isActive())
        m_pollTimer->stop();
}

void K3dataprocess::onPollTimeout()
{
    auto *client = K3Client::instance();
    if (!client->isConnected())
        return;

    // ── 按顺序入队 3 个读取命令（K3Client 命令队列串行执行） ──
    // 1. AI 模拟量 — 对应 WPF Read_PLC_Data() §AI: DB444, 19 floats
    client->dbReadReal(kAI_DbNumber, kAI_StartAddr, kAI_Count);
    // 2. DI 数字量 — 对应 WPF Read_PLC_Data() §DI: DB555, 14 bytes
    client->dbReadBit(kDI_DbNumber, kDI_StartAddr, kDI_Count);
    // 3. 流程数据 — 对应 WPF PLCtoText(): DB222, 14 floats
    client->dbReadReal(kFlow_DbNumber, kFlow_StartAddr, kFlow_Count);
}

// ═══════════════════════════════════════════════════════════════
// 数据处理 — 对应 WPF Read_PLC_Data() §AI 模块
// DB444, start=1, 19 floats
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::processAIData(int /*dbNumber*/, int /*start*/,
                                  const QVector<float> &values)
{
    if (values.size() < 19)
        return;

    // ── 索引映射 (与 WPF Read_PLC_Data 的 iValue_Single 一致) ──
    // [0]  = AI_P_wellhead1   (井口压力1)
    // [1]  = AI_P_wellhead2   (井口压力2)
    // [2]  = pres_liguan      (立管压力)
    // [3]  = pres_main        (主通道压力)
    // [4]  = pres_second      (辅助通道压力)
    // [5]  = pres_jieliuhou   (节流后压力)
    // [6]  = temp_jieliuqian  (节流前温度)
    // [7]  = pres_air         (气源压力)
    // [8]  = pres_yeyazhan    (液压站压力)
    // [9]  = temp_yeyazhan    (液压站温度)
    // [10] = AI_ValvePosition1 (节流阀C位置)
    // [11] = AI_ValvePosition2 (节流阀A位置)
    // [12] = AI_ValvePosition3 (节流阀B位置)
    // [13] = bilifa1          (比例阀1)
    // [14] = bilifa2          (比例阀2)
    // [15] = bilifa3          (比例阀3)
    // [16] = AI_Flow          (出口流量)
    // [17] = AI_Density       (密度)
    // [18] = AI_T_EH          (EH温度)

    auto *data = K3data::instance();
    auto list = data->k3data_left();

    // 辅助函数：更新指定 key 的 value
    auto updateItem = [&](const QString &key, float v) {
        for (int gi = 0; gi < list.size(); ++gi) {
            QVariantMap group = list[gi].toMap();
            QVariantList metrics = group[QStringLiteral("metrics")].toList();
            for (int mi = 0; mi < metrics.size(); ++mi) {
                QVariantMap item = metrics[mi].toMap();
                if (item[QStringLiteral("key")].toString() == key) {
                    item[QStringLiteral("value")] = v;
                    metrics[mi] = item;
                    group[QStringLiteral("metrics")] = metrics;
                    list[gi] = group;
                    return;
                }
            }
        }
    };

    updateItem(QStringLiteral("MainChannelPressure"),      values[3]);
    updateItem(QStringLiteral("WellheadPressure"),         values[0]);
    updateItem(QStringLiteral("AuxiliaryChannelPressure"), values[4]);
    updateItem(QStringLiteral("StandpipePressure"),        values[2]);
    updateItem(QStringLiteral("ThrottledPressure"),        values[5]);
    updateItem(QStringLiteral("OutletFlow"),               values[16]);
    updateItem(QStringLiteral("OutletDensity"),            values[17]);

    data->setK3data_left(list);
}

// ═══════════════════════════════════════════════════════════════
// 数据处理 — 对应 WPF Read_PLC_Data() §DI 模块
// DB555, start=1, 14 bytes → 112 bits
// ═══════════════════════════════════════════════════════════════

static bool getBitAt(quint8 byte, int bitnum)
{
    return (byte & (1 << bitnum)) != 0;
}

void K3dataprocess::processDIData(int /*dbNumber*/, int /*start*/,
                                  const QVector<quint8> &rawBytes)
{
    if (rawBytes.size() < 14)
        return;

    // ── 位映射 (与 WPF Read_PLC_Data DI 部分一致) ──
    // Byte 0: [0]=PlateValve1_Open, [1]=PlateValve1_Close,
    //         [2]=PlateValve2_Open, [3]=PlateValve2_Close,
    //         [4]=PlateValve3_Open, [5]=PlateValve3_Close,
    //         [6]=Level_Low,       [7]=CentralControlId
    // Byte 1: [0]=CabinetTemperatureHi,
    //         [1]=PropValve1_Fault, [2]=PropValve2_Fault, [3]=PropValve3_Fault,
    //         [4]=Contactor1,       [5]=Contactor2

    // DI 状态暂存（后续可扩展为 K3data 属性或 QML 信号）
    Q_UNUSED(rawBytes);
}

// ═══════════════════════════════════════════════════════════════
// 数据处理 — 对应 WPF PLCtoText()
// DB222, start=1, 14 floats
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::processFlowData(int /*dbNumber*/, int /*start*/,
                                    const QVector<float> &values)
{
    if (values.size() < 14)
        return;

    // ── 索引映射 (与 WPF PLCtoText 一致) ──
    // [0]  = depth_drill    (钻头深度)
    // [2]  = Flow_in        (入口流量)
    // [6]  = PumpStroke1    (泵冲1)
    // [7]  = PumpStroke2    (泵冲2)
    // [8]  = PumpStroke3    (泵冲3)
    // [9]  = Friction       (环空摩阻)
    // [11] = ECD            (ECD密度)

    auto *data = K3data::instance();
    auto list = data->k3data_left();

    auto updateItem = [&](const QString &key, float v) {
        for (int gi = 0; gi < list.size(); ++gi) {
            QVariantMap group = list[gi].toMap();
            QVariantList metrics = group[QStringLiteral("metrics")].toList();
            for (int mi = 0; mi < metrics.size(); ++mi) {
                QVariantMap item = metrics[mi].toMap();
                if (item[QStringLiteral("key")].toString() == key) {
                    item[QStringLiteral("value")] = v;
                    metrics[mi] = item;
                    group[QStringLiteral("metrics")] = metrics;
                    list[gi] = group;
                    return;
                }
            }
        }
    };

    updateItem(QStringLiteral("BitDepth"),       values[0]);
    updateItem(QStringLiteral("WellDepth"),      values[0]);
    updateItem(QStringLiteral("InletFlow"),      values[2]);
    updateItem(QStringLiteral("PumpStroke1"),    values[6]);
    updateItem(QStringLiteral("PumpStroke2"),    values[7]);
    updateItem(QStringLiteral("PumpStroke3"),    values[8]);
    updateItem(QStringLiteral("EcdDensity"),     values[11]);

    data->setK3data_left(list);
}