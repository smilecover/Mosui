#include "Tpinvcontrolprocess.h"

#include "TpInvcontroldata.h"
#include <QDebug>
#include <QQmlEngine>
#include <QtGlobal>
#include <cstdint>
#include <qcontainerfwd.h>
#include <qdebug.h>
#include <qjsvalue.h>
#include <qlogging.h>
#include <qvariant.h>

namespace {

    // 帧协议常量 (需根据 DSP 固件实际值调整)
    static constexpr uint8_t COM_R  = 0xAA;
    static constexpr uint8_t COM_T  = 0xBB;   // PC→DSP 帧头
    static constexpr uint8_t COM_F0 = 0xF0;
    static constexpr int FrameSize = 20;

    // DSP 数据缩放系数 (与下位机 Monitor.h 保持一致)
    static constexpr int UINT_VOLT  = 10;     // 电压 ×10
    static constexpr int UINT_CURR  = 100;    // 电流 ×100
    static constexpr int UINT_FREQ  = 100;    // 频率 ×100
    static constexpr int UINT_TEMP  = 10;     // 温度 ×10
    static constexpr int UINT_PF    = 100;    // 功率因数 ×100
    static constexpr int UINT_CALI  = 1000;   // 校正系数 ×1000

    // 倒数 (用于接收解析时还原工程值)
    static constexpr double INV_VOLT = 1.0 / UINT_VOLT;
    static constexpr double INV_CURR = 1.0 / UINT_CURR;
    static constexpr double INV_FREQ = 1.0 / UINT_FREQ;
    static constexpr double INV_TEMP = 1.0 / UINT_TEMP;
    static constexpr double INV_PF   = 1.0 / UINT_PF;
    static constexpr double INV_CALI = 1.0 / UINT_CALI;

    // 数据低八位
    uint8_t lowByte(uint16_t value) {
        return static_cast<uint8_t>(value & 0xFF);
    }
    // 数据高八位
    uint8_t highByte(uint16_t value) {
        return static_cast<uint8_t>((value >> 8) & 0xFF);
    }
    // 校验和前18位
    uint16_t calculateChecksum(const uint8_t *frame) {
        uint16_t sum = 0;
        for (int i = 0; i < 18; ++i)
            sum += frame[i];
        return sum;
    }
    // 两字节合成 uint16 (低字节在前)
    uint16_t makeU16(uint8_t lo, uint8_t hi) {
        return static_cast<uint16_t>(lo) | (static_cast<uint16_t>(hi) << 8);
    }
    // 校验帧合法
    bool frameValid(const uint8_t *frame) {
        if (frame[0] != COM_R)
            return false;
        const uint16_t expected = makeU16(frame[18], frame[19]);
        const uint16_t actual   = calculateChecksum(frame);
        return expected == actual;
    }

}

Tpinvcontrolprocess::Tpinvcontrolprocess(QObject *parent)
    : QObject(parent)
{

    // 环形数组配置
    m_cmdBuffer.resizeCapacity(MaxRxBufferSize);

    bandTpInvcontroldata();

    buildTpInvParamet();
}
tpinv::RingBuffer *Tpinvcontrolprocess::cmdBuffer() const
{
    return const_cast<tpinv::RingBuffer*>(&m_cmdBuffer);
}
int Tpinvcontrolprocess::Initprocess() const
{
    qDebug() << "初始化逆变器控制进程";
    return 0;
}
Tpinvcontrolprocess::~Tpinvcontrolprocess() = default;

Tpinvcontrolprocess *Tpinvcontrolprocess::instance()
{
    static Tpinvcontrolprocess *ins = new Tpinvcontrolprocess;
    return ins;
}

Tpinvcontrolprocess *Tpinvcontrolprocess::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *process = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(process, QQmlEngine::CppOwnership);
    }
    return process;
}
// 绑定逆变器数据
void Tpinvcontrolprocess::bandTpInvcontroldata()
{
    const auto *tpInvcontroldata = TpInvcontroldata::instance();
    
    connect(
        tpInvcontroldata,
        &TpInvcontroldata::parameterItemsChanged,
        this,
        [this](){
            this->buildTpInvParamet();
        }
    );
    connect(
        tpInvcontroldata,
        &TpInvcontroldata::runningChanged,
        this,
        [this](){
            this->controntroldataProcess();
        }
    );
}

void Tpinvcontrolprocess::buildTpInvParamet()
{
    auto controlData = TpInvcontroldata::instance();
    const QVariantList TpInvParamet_ = TpInvcontroldata::instance()->parameterItems();

    if (m_txBuffer.isEmpty()) {
        m_txBuffer.resize(1);
    }
    QByteArray &txbuf = m_txBuffer[0];
    if (txbuf.size() < 20) {
        txbuf.resize(20);
    }
    txbuf.fill(0);

    // DSP 接收端: COM_T=0xBB 帧头 + COM_F0=0xF0 帧类型
    txbuf[0] = COM_T;                                                      // 帧头
    txbuf[1] = COM_F0;                                                     // 帧类型
    txbuf[2] = controlData->running() ? 0x01 : 0x00;                      // 启停控制
    txbuf[3] = 0x00;                                                       // 保留
    txbuf[4] = static_cast<char>(controlData->parameterSelectIndex().toInt() & 0xFF); // 工作模式
    txbuf[5] = 0x00;                                                       // 保留
    // 交流电压设定值: DSP 期望 实际值 × UINT_VOLT(10)
    {
        const uint16_t voltRaw = static_cast<uint16_t>(qRound((TpInvParamet_.at(0).toMap())[QStringLiteral("value")].toDouble() * UINT_VOLT));
        txbuf[6] = lowByte(voltRaw);
        txbuf[7] = highByte(voltRaw);
    }
    // 交流频率设定值: DSP 期望 实际值 × UINT_FREQ(100)
    {
        const uint16_t freqRaw = static_cast<uint16_t>(qRound((TpInvParamet_.at(1).toMap())[QStringLiteral("value")].toDouble() * UINT_FREQ));
        txbuf[8] = lowByte(freqRaw);
        txbuf[9] = highByte(freqRaw);
    }
    // 母线电压设定值: DSP 期望 实际值 × UINT_VOLT(10)
    {
        const uint16_t busRaw = 0; // 暂不设置母线电压
        txbuf[10] = lowByte(busRaw);
        txbuf[11] = highByte(busRaw);
    }
    txbuf[12] = 0x00;
    txbuf[13] = 0x00;
    txbuf[14] = 0x00;
    txbuf[15] = 0x00;
    txbuf[16] = 0x00;
    txbuf[17] = 0x00; 
    uint16_t checksum = calculateChecksum(reinterpret_cast<const uint8_t *>(txbuf.constData()));
    txbuf[18] = lowByte(checksum); // 校验位低字节
    txbuf[19] = highByte(checksum); // 校验位高字节
}
void Tpinvcontrolprocess::controntroldataProcess()
{
    while (m_cmdBuffer.size() >= FrameSize) {
        // 帧同步：找帧头
        if (m_cmdBuffer[0] != COM_R) {
            uint8_t ignored = 0;
            m_cmdBuffer.pop(ignored);
            ++droppedFrameCount_;
            continue;
        }

        if (m_cmdBuffer.size() < FrameSize)
            break;

        uint8_t raw[FrameSize] {};
        for (int i = 0; i < FrameSize; ++i)
            raw[i] = m_cmdBuffer[i];

        if (!frameValid(raw)) {
            uint8_t ignored = 0;
            m_cmdBuffer.pop(ignored);
            ++droppedFrameCount_;
            continue;
        }

        m_cmdBuffer.consume(FrameSize);
        ++parsedFrameCount_;

        const uint8_t frameId = raw[1];
        QVariantMap values;

        switch (frameId) {
        case COM_F0:  // 0xF0 — 直流/交流电压 + 温度
            values[QStringLiteral("dcVoltage")]         = makeU16(raw[2],  raw[3])  * INV_VOLT;
            values[QStringLiteral("halfBusVoltage")]    = makeU16(raw[4],  raw[5])  * INV_VOLT;
            values[QStringLiteral("phaseVoltageA")]     = makeU16(raw[6],  raw[7])  * INV_VOLT;
            values[QStringLiteral("phaseVoltageB")]     = makeU16(raw[8],  raw[9])  * INV_VOLT;
            values[QStringLiteral("phaseVoltageC")]     = makeU16(raw[10], raw[11]) * INV_VOLT;
            values[QStringLiteral("auxTemperature")]    = makeU16(raw[12], raw[13]) * INV_TEMP;  // 辅源温度 TempPower
            values[QStringLiteral("igbtTemperature")]   = makeU16(raw[14], raw[15]) * INV_TEMP;  // IGBT温度 TempMos
            values[QStringLiteral("ambientTemperature")]= makeU16(raw[16], raw[17]) * INV_TEMP;  // 环境温度
            break;
        case COM_F0 + 1:  // 0xF1 — 直流/交流电流 + 频率
            values[QStringLiteral("dcCurrent")]     = makeU16(raw[2],  raw[3])  * INV_CURR;
            values[QStringLiteral("powerFactor")]   = makeU16(raw[4],  raw[5])  * INV_PF;    // 功率因数，非 outputPower
            values[QStringLiteral("phaseCurrentA")] = makeU16(raw[6],  raw[7])  * INV_CURR;
            values[QStringLiteral("phaseCurrentB")] = makeU16(raw[8],  raw[9])  * INV_CURR;
            values[QStringLiteral("phaseCurrentC")] = makeU16(raw[10], raw[11]) * INV_CURR;
            values[QStringLiteral("acFrequencyA")]  = makeU16(raw[12], raw[13]) * INV_FREQ;
            values[QStringLiteral("acFrequencyB")]  = makeU16(raw[14], raw[15]) * INV_FREQ;
            values[QStringLiteral("acFrequencyC")]  = makeU16(raw[16], raw[17]) * INV_FREQ;
            break;
        case COM_F0 + 2:  // 0xF2 — 功率 (DSP 未区分有功/无功/视在，多处填同一 AcPower)
            values[QStringLiteral("dcPower")]       = static_cast<double>(makeU16(raw[2],  raw[3]));   // UINT_POWER=1
            values[QStringLiteral("activePower")]   = static_cast<double>(makeU16(raw[4],  raw[5]));   // 交流总功率
            values[QStringLiteral("apparentPower")] = static_cast<double>(makeU16(raw[6],  raw[7]));   // 同上(重复)
            values[QStringLiteral("reactivePower")] = 0.0;                                              // DSP 未计算
            break;
        case COM_F0 + 3: {  // 0xF3 — 运行状态 + 故障码
            const uint64_t fault = (static_cast<uint64_t>(raw[10]) << 0)
                                 | (static_cast<uint64_t>(raw[11]) << 8)
                                 | (static_cast<uint64_t>(raw[12]) << 16)
                                 | (static_cast<uint64_t>(raw[13]) << 24)
                                 | (static_cast<uint64_t>(raw[14]) << 32)
                                 | (static_cast<uint64_t>(raw[15]) << 40)
                                 | (static_cast<uint64_t>(raw[16]) << 48)
                                 | (static_cast<uint64_t>(raw[17]) << 56);
            values[QStringLiteral("runMode")]       = raw[2];
            values[QStringLiteral("inverterState")] = raw[3];
            values[QStringLiteral("rmsSet")]        = makeU16(raw[4], raw[5]) * INV_VOLT;   // DSP 已×UINT_VOLT
            values[QStringLiteral("freqSet")]       = makeU16(raw[6], raw[7]) * INV_FREQ;   // DSP 已×UINT_FREQ
            values[QStringLiteral("faultCode")]     = QStringLiteral("0x%1").arg(fault, 8, 16, QLatin1Char('0'));
            break;
        }
        case COM_F0 + 8:  // 0xF8 — 电压校正系数 (DSP 已×UINT_CALI=1000)
            values[QStringLiteral("caliDcVoltA")]    = makeU16(raw[2],  raw[3])  * INV_CALI;
            values[QStringLiteral("caliDcVoltB")]    = makeU16(raw[4],  raw[5])  * INV_CALI;
            values[QStringLiteral("caliHalfVoltA")]  = makeU16(raw[6],  raw[7])  * INV_CALI;
            values[QStringLiteral("caliHalfVoltB")]  = makeU16(raw[8],  raw[9])  * INV_CALI;
            values[QStringLiteral("caliPhaseVoltA")] = makeU16(raw[10], raw[11]) * INV_CALI;
            values[QStringLiteral("caliPhaseVoltB")] = makeU16(raw[12], raw[13]) * INV_CALI;
            break;
        case COM_F0 + 9:  // 0xF9 — 电流校正系数 (DSP 已×UINT_CALI=1000)
            values[QStringLiteral("caliDcCurrA")]    = makeU16(raw[2], raw[3]) * INV_CALI;
            values[QStringLiteral("caliDcCurrB")]    = makeU16(raw[4], raw[5]) * INV_CALI;
            values[QStringLiteral("caliPhaseCurrA")] = makeU16(raw[6], raw[7]) * INV_CALI;
            values[QStringLiteral("caliPhaseCurrB")] = makeU16(raw[8], raw[9]) * INV_CALI;
            break;
        case COM_F0 + 10:
            for (int i = 0; i < 8; ++i)
                values[QStringLiteral("debug_%1").arg(i)] = makeU16(raw[2 + i * 2], raw[3 + i * 2]);
            break;
        case COM_F0 + 11:
            values[QStringLiteral("dataLen")]  = makeU16(raw[2], raw[3]);
            values[QStringLiteral("cnt")]      = makeU16(raw[4], raw[5]);
            values[QStringLiteral("debugBuf1")] = makeU16(raw[6], raw[7]);
            values[QStringLiteral("debugBuf2")] = makeU16(raw[8], raw[9]);
            values[QStringLiteral("debugBuf3")] = makeU16(raw[10], raw[11]);
            values[QStringLiteral("debugBuf4")] = makeU16(raw[12], raw[13]);
            values[QStringLiteral("debugBuf5")] = makeU16(raw[14], raw[15]);
            values[QStringLiteral("debugBuf6")] = makeU16(raw[16], raw[17]);
            break;
        case COM_F0 + 14:
            for (int j = 0; j < 5; ++j) {
                const int off = 2 + j * 3;
                values[QStringLiteral("cmdEn_%1").arg(j)] = raw[off];
                values[QStringLiteral("cmdVal_%1").arg(j)] = makeU16(raw[off + 1], raw[off + 2]);
            }
            break;
        case COM_F0 + 15:
            for (int j = 0; j < 3; ++j) {
                const int off = 2 + j * 3;
                values[QStringLiteral("cmdEn_%1").arg(j + 5)] = raw[off];
                values[QStringLiteral("cmdVal_%1").arg(j + 5)] = makeU16(raw[off + 1], raw[off + 2]);
            }
            break;
        default:
            // ComR4~7, ComR12~13 保留帧，暂不处理
            break;
        }

        if (!values.isEmpty()) {
            QByteArray hex;
            for (int i = 0; i < FrameSize; ++i)
                hex.append(QByteArray::number(raw[i], 16).rightJustified(2, '0'));
            lastFrameHex_ = QString::fromLatin1(hex.toUpper());

            auto *data = TpInvcontroldata::instance();
            QMetaObject::invokeMethod(data, [data, values]() {
                data->applyMonitorSnapshot(values);
            }, Qt::QueuedConnection);
        }
    }
}
