#include "Tpinvcontrolprocess.h"

#include "TpInvcontroldata.h"
#include <QDebug>
#include <QQmlEngine>
#include <QtGlobal>
#include <cstdint>
#include <qcontainerfwd.h>
#include <qjsvalue.h>
#include <qlogging.h>
#include <qvariant.h>

namespace {
    // 数据低八位
    uint8_t lowByte(uint16_t value) {
        return static_cast<uint8_t>(static_cast<int>(value) & 0xFF);
    }
    // 数据高八位
    uint8_t highByte(uint16_t value) {
        return static_cast<uint8_t>((static_cast<int>(value) >> 8) & 0xFF);
    }
    // 校验和前18位
    uint16_t calculateChecksum(const QByteArray &data) {
        uint16_t checksum = 0;
        for (int i = 0; i < 18 && i < data.size(); ++i) {
            checksum += static_cast<uint8_t>(data[i]);
        }
        return checksum;
    }
    

}

Tpinvcontrolprocess::Tpinvcontrolprocess(QObject *parent)
    : QObject(parent)
{
    bandTpInvcontroldata();

    buildTpInvParamet();
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
}

void Tpinvcontrolprocess::buildTpInvParamet()
{
    auto controlData = TpInvcontroldata::instance();
    QVariantList TpInvParamet_ = TpInvcontroldata::instance()->parameterItems();
    QVariant value = (TpInvParamet_.at(0).toMap())["value"];

    if (m_txBuffer.isEmpty()) {
        m_txBuffer.resize(1);
    }
    QByteArray &txbuf = m_txBuffer[0];
    if (txbuf.size() < 20) {
        txbuf.resize(20);
    }
    txbuf.fill(0);

    txbuf[0] = 0xBB;
    txbuf[1] = 0xF0;
    txbuf[2] = controlData->running() ? 0x01 : 0x00;
    txbuf[3] = 0x00;
    txbuf[4] = static_cast<char>(controlData->parameterSelectIndex().toInt() & 0xFF); // 工作模式
    txbuf[5] = 0x00;
    // 0 交流电压 1 交流频率 
    txbuf[6] = lowByte((TpInvParamet_.at(0).toMap())["value"].toInt()); // 交流有效值低字节，暂时固定
    txbuf[7] = highByte((TpInvParamet_.at(0).toMap())["value"].toInt()); // 交流有效值高字节，暂时固定
    txbuf[8] = lowByte((TpInvParamet_.at(1).toMap())["value"].toInt()); // 交流频率低字节，暂时固定
    txbuf[9] = highByte((TpInvParamet_.at(1).toMap())["value"].toInt()); // 交流频率高字节，暂时固定
    txbuf[10] = 0x00; // 母线电压低字节，暂时固定
    txbuf[11] = 0x00; // 母线电压高字节，暂时固定
    txbuf[12] = 0x00;
    txbuf[13] = 0x00;
    txbuf[14] = 0x00;
    txbuf[15] = 0x00;
    txbuf[16] = 0x00;
    txbuf[17] = 0x00; 
    uint16_t checksum = calculateChecksum(txbuf);
    txbuf[18] = lowByte(checksum); // 校验位低字节
    txbuf[19] = highByte(checksum); // 校验位高字节
}

