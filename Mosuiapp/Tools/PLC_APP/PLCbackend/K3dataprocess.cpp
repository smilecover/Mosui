#include "K3dataprocess.h"

#include <QQmlEngine>
#include <QCryptographicHash>
#include <QTimer>
#include <QtEndian>
#include <private/qquicktheme_p.h>

#include "K3Client.h"
#include "K3data.h"


K3dataprocess::K3dataprocess(QObject *parent)
    : QObject(parent)
    , m_pollTimer(new QTimer(this))
{
    m_pollTimer->setInterval(kPollIntervalMs);
    m_pollTimer->setTimerType(Qt::PreciseTimer);
    QObject::connect(m_pollTimer, &QTimer::timeout,
                     this, &K3dataprocess::onPollTimeout);

    auto *client = K3Client::instance();
    QObject::connect(client, &K3Client::isConnectedChanged,
                     this, [this]() {
        if (K3Client::instance()->isConnected())
            startPolling();
        else
            stopPolling();
    });

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
    switch (dbNumber) {
    case kDI_DbNumber:   // 555
        processDIData(dbNumber, start, rawBytes);
        break;
    case kValve_DbNumber:   // 444
        if (start == kValve_StartAddr)
            processValveStatus(rawBytes);
        break;
    case kBackpressure_DbNumber: {   // 333 — 多个 start 地址
        switch (start) {
        case kModeAutoHand_StartAddr:    // 1 → 自动/手动模式
            processModeAutoHand(rawBytes);
            break;
        case kModeFlags_StartAddr:       // 2 → 模式标志 (主备阀/井底/井口)
            processModeFlags(rawBytes);
            break;
        case kBackpressure_StartAddr:    // 3 → 回压过高保护 + 板卡状态
            processBackpressureStatus(rawBytes);
            break;
        case kGlobalLocal_StartAddr:     // 4 → 全局/局部追压标志
            processGlobalLocalFlags(rawBytes);
            break;
        }
        break;
    }
    }
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

    // ── 按顺序入队读取命令（K3Client 命令队列串行执行） ──
    // 1. AI 模拟量 — 对应 WPF Read_PLC_Data() §AI: DB444, 19 floats
    client->dbReadReal(kAI_DbNumber, kAI_StartAddr, kAI_Count);
    // 2. DI 数字量 — 对应 WPF Read_PLC_Data() §DI: DB555, 14 bytes
    client->dbReadBit(kDI_DbNumber, kDI_StartAddr, kDI_Count);
    // 3. 流程数据 — 对应 WPF PLCtoText(): DB222, 14 floats
    client->dbReadReal(kFlow_DbNumber, kFlow_StartAddr, kFlow_Count);
    // 4. 阀门状态 — 对应 WPF Read_Valve_Open(): DB444 byte 4
    client->dbReadBit(kValve_DbNumber, kValve_StartAddr, kValve_Count);
    // 5. 回压过高保护 — 对应 WPF Read_PLC_Data(): DB333 byte 3
    client->dbReadBit(kBackpressure_DbNumber, kBackpressure_StartAddr, kBackpressure_Count);
    // 6. 自动/手动模式 — DB333 byte 1 (bit 2)
    client->dbReadBit(kModeAutoHand_DbNumber, kModeAutoHand_StartAddr, kModeAutoHand_Count);
    // 7. 模式标志 — DB333 byte 2 (bit2=主备阀, bit3=井底, bit4=井口)
    client->dbReadBit(kModeFlags_DbNumber, kModeFlags_StartAddr, kModeFlags_Count);
    // 8. 全局/局部追压标志 — DB333 byte 4 (bit1=C, bit2=A, bit3=B)
    client->dbReadBit(kGlobalLocal_DbNumber, kGlobalLocal_StartAddr, kGlobalLocal_Count);
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
    // [0]  = AI_P_wellhead1   (井口压力1)   → WellheadPressure
    // [1]  = AI_P_wellhead2   (井口压力2)   → AI_P_wellhead2
    // [2]  = pres_liguan      (立管压力)     → StandpipePressure
    // [3]  = pres_main        (主通道压力)   → MainChannelPressure
    // [4]  = pres_second      (辅助通道压力) → AuxiliaryChannelPressure
    // [5]  = pres_jieliuhou   (节流后压力)   → ThrottledPressure
    // [6]  = temp_jieliuqian  (节流前温度)   → temp_jieliuqian
    // [7]  = pres_air         (气源压力)     → pres_air
    // [8]  = pres_yeyazhan    (液压站压力)   → pres_yeyazhan
    // [9]  = temp_yeyazhan    (液压站温度)   → temp_yeyazhan
    // [10] = AI_ValvePosition1 (节流阀C开度) → AI_ValvePosition1
    // [11] = AI_ValvePosition2 (节流阀A开度) → AI_ValvePosition2
    // [12] = AI_ValvePosition3 (节流阀B开度) → AI_ValvePosition3
    // [13] = bilifa1          (比例阀1)      → bilifa1
    // [14] = bilifa2          (比例阀2)      → bilifa2
    // [15] = bilifa3          (比例阀3)      → bilifa3
    // [16] = AI_Flow          (出口流量)     → OutletFlow
    // [17] = AI_Density       (密度)         → OutletDensity
    // [18] = AI_T_EH          (EH温度)       → AI_T_EH

    auto *data = K3data::instance();

    data->applyUpdate(QStringLiteral("WellheadPressure"),         values[0]);
    data->applyUpdate(QStringLiteral("AI_P_wellhead2"),          values[1]);
    data->applyUpdate(QStringLiteral("StandpipePressure"),        values[2]);
    data->applyUpdate(QStringLiteral("MainChannelPressure"),      values[3]);
    data->applyUpdate(QStringLiteral("AuxiliaryChannelPressure"), values[4]);
    data->applyUpdate(QStringLiteral("ThrottledPressure"),        values[5]);
    data->applyUpdate(QStringLiteral("temp_jieliuqian"),          values[6]);
    data->applyUpdate(QStringLiteral("pres_air"),                 values[7]);
    data->applyUpdate(QStringLiteral("pres_yeyazhan"),            values[8]);
    data->applyUpdate(QStringLiteral("temp_yeyazhan"),            values[9]);
    data->applyUpdate(QStringLiteral("AI_ValvePosition1"),        values[10]);
    data->applyUpdate(QStringLiteral("AI_ValvePosition2"),        values[11]);
    data->applyUpdate(QStringLiteral("AI_ValvePosition3"),        values[12]);
    data->applyUpdate(QStringLiteral("bilifa1"),                  values[13]);
    data->applyUpdate(QStringLiteral("bilifa2"),                  values[14]);
    data->applyUpdate(QStringLiteral("bilifa3"),                  values[15]);
    data->applyUpdate(QStringLiteral("OutletFlow"),               values[16]);
    data->applyUpdate(QStringLiteral("OutletDensity"),            values[17]);
    data->applyUpdate(QStringLiteral("AI_T_EH"),                  values[18]);

    data->syncToLeftAndDown();
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
    if (rawBytes.size() < 2)
        return;

    // ── 位映射 (与 WPF Read_PLC_Data DI 部分一致) ──
    // Byte 0: [0]=PlateValve1_Open, [1]=PlateValve1_Close,
    //         [2]=PlateValve2_Open, [3]=PlateValve2_Close,
    //         [4]=PlateValve3_Open, [5]=PlateValve3_Close,
    //         [6]=Level_Low,       [7]=CentralControlId
    // Byte 1: [0]=CabinetTemperatureHi,
    //         [1]=PropValve1_Fault, [2]=PropValve2_Fault, [3]=PropValve3_Fault,
    //         [4]=Contactor1,       [5]=Contactor2

    auto *data = K3data::instance();

    data->applyUpdate(QStringLiteral("PlateValve1_Open"),       getBitAt(rawBytes[0], 0));
    data->applyUpdate(QStringLiteral("PlateValve1_Close"),      getBitAt(rawBytes[0], 1));
    data->applyUpdate(QStringLiteral("PlateValve2_Open"),       getBitAt(rawBytes[0], 2));
    data->applyUpdate(QStringLiteral("PlateValve2_Close"),      getBitAt(rawBytes[0], 3));
    data->applyUpdate(QStringLiteral("PlateValve3_Open"),       getBitAt(rawBytes[0], 4));
    data->applyUpdate(QStringLiteral("PlateValve3_Close"),      getBitAt(rawBytes[0], 5));
    data->applyUpdate(QStringLiteral("Level_Low"),              getBitAt(rawBytes[0], 6));
    data->applyUpdate(QStringLiteral("CentralControlId"),       getBitAt(rawBytes[0], 7));

    data->applyUpdate(QStringLiteral("CabinetTemperatureHi"),   getBitAt(rawBytes[1], 0));
    data->applyUpdate(QStringLiteral("PropValve1_Fault"),       getBitAt(rawBytes[1], 1));
    data->applyUpdate(QStringLiteral("PropValve2_Fault"),       getBitAt(rawBytes[1], 2));
    data->applyUpdate(QStringLiteral("PropValve3_Fault"),       getBitAt(rawBytes[1], 3));
    data->applyUpdate(QStringLiteral("Contactor1"),             getBitAt(rawBytes[1], 4));
    data->applyUpdate(QStringLiteral("Contactor2"),             getBitAt(rawBytes[1], 5));

    data->syncToLeftAndDown();
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
    // [0]  = depth_drill    (钻头深度)   → BitDepth / WellDepth
    // [2]  = Flow_in        (入口流量)   → InletFlow
    // [6]  = PumpStroke1    (泵冲1)      → PumpStroke1
    // [7]  = PumpStroke2    (泵冲2)      → PumpStroke2
    // [8]  = PumpStroke3    (泵冲3)      → PumpStroke3
    // [9]  = Friction       (环空摩阻)   → Friction
    // [11] = ECD            (ECD密度)    → EcdDensity

    auto *data = K3data::instance();

    data->applyUpdate(QStringLiteral("BitDepth"),       values[0]);
    data->applyUpdate(QStringLiteral("WellDepth"),      values[0]);
    data->applyUpdate(QStringLiteral("InletFlow"),      values[2]);
    data->applyUpdate(QStringLiteral("PumpStroke1"),    values[6]);
    data->applyUpdate(QStringLiteral("PumpStroke2"),    values[7]);
    data->applyUpdate(QStringLiteral("PumpStroke3"),    values[8]);
    data->applyUpdate(QStringLiteral("Friction"),       values[9]);
    data->applyUpdate(QStringLiteral("EcdDensity"),     values[11]);

    data->syncToLeftAndDown();
}

void K3dataprocess::Flag_Auto_Hand(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();

    // Helper: 从 k3data_all 中按 key 查找 value
    auto valueForKey = [data](const QString &key) -> float {
        for (const QVariant &g : data->k3data_all()) {
            const QVariantMap group = g.toMap();
            const QVariantList metrics = group[QStringLiteral("metrics")].toList();
            for (const QVariant &m : metrics) {
                QVariantMap item = m.toMap();
                if (item[QStringLiteral("key")].toString() == key)
                    return item[QStringLiteral("value")].toFloat();
            }
        }
        return 0.0f;
    };

    if(data->flag_auto_hand())
    {
        // 设置手动模式
        // 1. 将当前节流阀开度值写入PLC
        client->dbWriteReal(valueForKey(QStringLiteral("AI_ValvePosition2")), 111, 3);
        client->dbWriteReal(valueForKey(QStringLiteral("AI_ValvePosition3")), 111, 22);
        client->dbWriteReal(valueForKey(QStringLiteral("AI_ValvePosition1")), 111, 21);

        // 2. 设置标志位并写入PLC
        data->setFlag_auto_hand(false);
        client->dbWriteBit(false, 333, 1, 3);

        // 3. 关闭井底压力模式
        client->dbWriteBit(false, 333, 2, 4);

        // 4. 关闭井口压力模式
        client->dbWriteBit(false, 333, 2, 5);

        // 5. 进入井口标志位清零
        client->dbWriteBit(false, 333, 5, 3);

        // 6. 井底准备标志位清零
        client->dbWriteBit(false, 333, 4, 6);
        client->dbWriteBit(false, 333, 4, 5);
    }
    else
    {
        // 设置为自动模式 
        data->setFlag_auto_hand(true);
        client->dbWriteBit(data->flag_auto_hand(), 333, 1, 3);
    }
}
void K3dataprocess::Flag_Model_Downhole(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();

    if(data->flag_model_downhole())
    {
        // 关闭井底压力模式 
        data->setflag_model_downhole(false);
        client->dbWriteBit(false, 333, 2, 4);
    }
    else
    {
        // 开启井底压力模式 
        data->setflag_model_downhole(true);
        client->dbWriteBit(true, 333, 2, 4);
        client->dbWriteBit(false, 333, 2, 5);
    }
}
void K3dataprocess::Flag_Model_Ground(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if (data->flag_model_ground()) {
        // 关闭井口压力模式 
        data->setflag_model_ground(false);
        client->dbWriteBit(false, 333, 2, 5);
    }
    else {
        // 开启井口压力模式
        data->setflag_model_ground(true);
        client->dbWriteBit(true, 333, 2, 5);
        client->dbWriteBit(false, 333, 2, 4);
    }   
}
void K3dataprocess::Flag_Model_Mainsecond(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if(data->flag_model_mainsecond())
    {
        // 关闭主备阀切换模式 (参照 WPF Close_Model_MainSecond)
        data->setflag_model_mainsecond(false);
        client->dbWriteBit(false, 333, 2, 3);
    }
    else
    {
        // 打开主备阀切换模式 (参照 WPF Open_Model_MainSecond)
        data->setflag_model_mainsecond(true);
        client->dbWriteBit(true, 333, 2, 3);
    }
}
void K3dataprocess::Flag_Model_Profession(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if(data->flag_model_profession())
    {
        // 关闭专家模式
        data->setflag_model_profession(false);
        client->dbWriteBit(false, 333, 1, 2);
    }
    else
    {
        // 打开专家模式 (参照 WPF Open_model_profession)
        data->setflag_model_profession(true);
        client->dbWriteBit(true, 333, 1, 2);
    }
}

bool K3dataprocess::checkProfessionPassword(const QString &password)
{
    // SHA-256 哈希比对，二进制中不存储明文密码
    // 预计算 "123456" 的 SHA-256，static 确保只解析一次
    static const QByteArray kExpected = QByteArray::fromHex(
        "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92");

    return QCryptographicHash::hash(
        password.toUtf8(), QCryptographicHash::Sha256) == kExpected;
}
void K3dataprocess::Flag_Stop(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if (data->flag_stop()) {
        // ── 开车 / 恢复正常
        client->dbWriteBit(false, 333, 2, 1);   // 清除停车标志位
        data->setflag_stop(false);
    }
    else
    {
        // ── 停车
        // 1. 强制切换到手动模式
        data->setFlag_auto_hand(false);
        client->dbWriteBit(false, 333, 1, 3);

        // 2. 关闭井底/井口压力模式
        client->dbWriteBit(false, 333, 2, 4);
        client->dbWriteBit(false, 333, 2, 5);

        // 3. 清零标志位
        client->dbWriteBit(false, 333, 5, 3);
        client->dbWriteBit(false, 333, 4, 6);
        client->dbWriteBit(false, 333, 4, 5);

        // 4. 打开平板阀 A / B
        client->dbWriteBit(true, 333, 2, 8);    // ValveA_Chose
        client->dbWriteBit(true, 333, 3, 1);    // ValveB_Chose

        // 5. 阀门开度设 100%
        client->dbWriteReal(100.0f, 111, 3);
        client->dbWriteReal(100.0f, 111, 22);

        // 6. 停车标志位写入 PLC
        client->dbWriteBit(true, 333, 2, 1);
        data->setflag_stop(true);
    }
}

void K3dataprocess::Flag_Board(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if (data->flag_board()) {
        // 当前板A → 切换到板B
        client->dbWriteBit(true, 335, 1, 3);
        data->setflag_board(false);
    }
    else
    {
        // 当前板B → 切换到板A
        client->dbWriteBit(true, 335, 1, 3);
        data->setflag_board(true);
    }
}

// ═══════════════════════════════════════════════════════════════
// 阀门切换 — 对应 WPF ValveA_Chose / ValveB_Chose / ValveC_Chose
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::Flag_Valve_A(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if (data->flag_valve_a()) {
        // 关闭A阀
        data->setFlag_valve_a(false);
        client->dbWriteBit(false, 333, 2, 8);
    } else {
        // 打开A阀 (WPF ValveA_Chose: DB333, byte 2, bit 8)
        data->setFlag_valve_a(true);
        client->dbWriteBit(true, 333, 2, 8);
    }
}

void K3dataprocess::Flag_Valve_B(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if (data->flag_valve_b()) {
        // 关闭B阀
        data->setFlag_valve_b(false);
        client->dbWriteBit(false, 333, 3, 1);
    } else {
        // 打开B阀 (WPF ValveB_Chose: DB333, byte 3, bit 1)
        data->setFlag_valve_b(true);
        client->dbWriteBit(true, 333, 3, 1);
    }
}

void K3dataprocess::Flag_Valve_C(){
    auto *data = K3data::instance();
    auto *client = K3Client::instance();
    if (data->flag_valve_c()) {
        // 关闭C阀
        data->setFlag_valve_c(false);
        client->dbWriteBit(false, 333, 2, 7);
    } else {
        // 打开C阀 (WPF ValveC_Chose: DB333, byte 2, bit 7)
        data->setFlag_valve_c(true);
        client->dbWriteBit(true, 333, 2, 7);
    }
}

// ═══════════════════════════════════════════════════════════════
// 阀门开度调节 — 对应 WPF ValveX_Add_Minus()
// flag: 1=快减(-1%), 2=快加(+1%), 3=慢减(-0.1%), 4=慢加(+0.1%)
// ═══════════════════════════════════════════════════════════════

// Helper: 从 k3data_all 读取 float 值
static float getFloatFromData(const K3data *data, const QString &key)
{
    for (const QVariant &g : data->k3data_all()) {
        const QVariantMap group = g.toMap();
        const QVariantList metrics = group[QStringLiteral("metrics")].toList();
        for (const QVariant &m : metrics) {
            QVariantMap item = m.toMap();
            if (item[QStringLiteral("key")].toString() == key)
                return item[QStringLiteral("value")].toFloat();
        }
    }
    return 0.0f;
}

void K3dataprocess::ValveA_Adjust(int flag)
{
    auto *data = K3data::instance();
    auto *client = K3Client::instance();

    float value = getFloatFromData(data, QStringLiteral("AI_ValvePosition2"));
    switch (flag) {
    case 1: value -= 1.0f; break;   // 快减
    case 2: value += 1.0f; break;   // 快加
    case 3: value -= 0.1f; break;   // 慢减
    case 4: value += 0.1f; break;   // 慢加
    }
    value = qBound(0.0f, value, 100.0f);

    // WPF WriteAutoManA: DB111, start=3 和 start=5
    client->dbWriteReal(value, 111, 5);
    client->dbWriteReal(value, 111, 3);
    // 自动追压标志 (WPF: client.DBWrite_Bit(true, 333, 1, 7))
    client->dbWriteBit(true, 333, 1, 7);
}

void K3dataprocess::ValveB_Adjust(int flag)
{
    auto *data = K3data::instance();
    auto *client = K3Client::instance();

    float value = getFloatFromData(data, QStringLiteral("AI_ValvePosition3"));
    switch (flag) {
    case 1: value -= 1.0f; break;
    case 2: value += 1.0f; break;
    case 3: value -= 0.1f; break;
    case 4: value += 0.1f; break;
    }
    value = qBound(0.0f, value, 100.0f);

    // WPF WriteAutoManB: DB111, start=22 和 start=24
    client->dbWriteReal(value, 111, 22);
    client->dbWriteReal(value, 111, 24);
    client->dbWriteBit(true, 333, 1, 7);
}

void K3dataprocess::ValveC_Adjust(int flag)
{
    auto *data = K3data::instance();
    auto *client = K3Client::instance();

    float value = getFloatFromData(data, QStringLiteral("AI_ValvePosition1"));
    switch (flag) {
    case 1: value -= 1.0f; break;
    case 2: value += 1.0f; break;
    case 3: value -= 0.1f; break;
    case 4: value += 0.1f; break;
    }
    value = qBound(0.0f, value, 100.0f);

    // WPF WriteAutoManC: DB111, start=21 和 start=23
    client->dbWriteReal(value, 111, 21);
    client->dbWriteReal(value, 111, 23);
    client->dbWriteBit(true, 333, 1, 7);
}

// ═══════════════════════════════════════════════════════════════
// 阀门状态读取 — 对应 WPF Read_Valve_Open()
// DB444 byte 4: bit[1]=B阀, bit[2]=A阀, bit[7]=C阀
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::processValveStatus(const QVector<quint8> &rawBytes)
{
    if (rawBytes.isEmpty())
        return;

    auto *data = K3data::instance();
    quint8 byte = rawBytes[0];

    // WPF Read_Valve_Open 中对应:
    // bit 1 → B阀, bit 2 → A阀, bit 7 → C阀
    data->setFlag_valve_a(getBitAt(byte, 2));
    data->setFlag_valve_b(getBitAt(byte, 1));
    data->setFlag_valve_c(getBitAt(byte, 7));
}

// ═══════════════════════════════════════════════════════════════
// 回压过高保护状态读取 — 对应 WPF Read_PLC_Data()
// DB333 byte 3, bit 3
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::processBackpressureStatus(const QVector<quint8> &rawBytes)
{
    // DB333 byte 3:
    //   bit 3 → 回压过高保护 (WPF: iValue_bool_Read[3])
    //   bit 4 → 板卡状态 (WPF: iValue_bool_Read[4]=true→板B, false→板A)
    if (rawBytes.isEmpty())
        return;

    auto *data = K3data::instance();
    data->setFlag_high_backpressure(getBitAt(rawBytes[0], 3));
    // WPF: bit4=true→板B, flag_board: true=板A, 取反
    data->setflag_board(!getBitAt(rawBytes[0], 4));
}

// ═══════════════════════════════════════════════════════════════
// 全局/局部追压标志 — 对应 WPF load_Click §全局or局部追压
// DB333 byte 4: bit1=C, bit2=A, bit3=B
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::processGlobalLocalFlags(const QVector<quint8> &rawBytes)
{
    if (rawBytes.isEmpty())
        return;

    auto *data = K3data::instance();
    // WPF: flag_global_localA = iValue_bool_Read[2]
    //       flag_global_localB = iValue_bool_Read[3]
    //       flag_global_localC = iValue_bool_Read[1]
    data->setFlag_global_local_a(getBitAt(rawBytes[0], 2));
    data->setFlag_global_local_b(getBitAt(rawBytes[0], 3));
    data->setFlag_global_local_c(getBitAt(rawBytes[0], 1));
}

// ═══════════════════════════════════════════════════════════════
// 模式读取处理器 — 对应 WPF load_Click 初始化
// ═══════════════════════════════════════════════════════════════

void K3dataprocess::processModeAutoHand(const QVector<quint8> &rawBytes)
{
    // DB333 byte 1, bit 2 → 自动/手动模式
    // WPF: flag_auto_hand = iValue_bool_Read[2]
    if (rawBytes.isEmpty())
        return;

    auto *data = K3data::instance();
    bool isAuto = getBitAt(rawBytes[0], 2);
    data->setFlag_auto_hand(isAuto);
}

void K3dataprocess::processModeFlags(const QVector<quint8> &rawBytes)
{
    // DB333 byte 2:
    //   bit 2 → 主备阀切换模式  (WPF: flag_model_main_second)
    //   bit 3 → 井底压力模式    (WPF: flag_model_downhole)
    //   bit 4 → 井口压力模式    (WPF: flag_model_groud)
    if (rawBytes.isEmpty())
        return;

    auto *data = K3data::instance();
    data->setflag_model_mainsecond(getBitAt(rawBytes[0], 2));
    data->setflag_model_downhole(getBitAt(rawBytes[0], 3));
    data->setflag_model_ground(getBitAt(rawBytes[0], 4));
}

void K3dataprocess::InitFromPlc()
{
    auto *client = K3Client::instance();
    if (!client->isConnected())
        return;

    startPolling();

    client->dbReadBit(kModeAutoHand_DbNumber, kModeAutoHand_StartAddr, kModeAutoHand_Count);
    client->dbReadBit(kModeFlags_DbNumber, kModeFlags_StartAddr, kModeFlags_Count);
    client->dbReadBit(kBackpressure_DbNumber, kBackpressure_StartAddr, kBackpressure_Count);
    client->dbReadBit(kGlobalLocal_DbNumber, kGlobalLocal_StartAddr, kGlobalLocal_Count);
    client->dbReadBit(kValve_DbNumber, kValve_StartAddr, kValve_Count);
}