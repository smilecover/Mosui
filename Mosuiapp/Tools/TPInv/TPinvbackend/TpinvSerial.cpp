#include "TpinvSerial.h"

#include "MosSerialPortManager.h"
#include "TpInvcontroldata.h"

#include "Tpinvcontrolprocess.h"

#include <QQmlEngine>
#include <QVariantMap>
#include <QDebug>
#include <qdebug.h>

TpinvSerial::TpinvSerial(QObject *parent)
    : QObject(parent)
{
    bindManagerSignals();
    bindControlDataSignals();
    bindControlProcessSignals();
}

TpinvSerial::~TpinvSerial() = default;

TpinvSerial *TpinvSerial::instance()
{
    static TpinvSerial *ins = new TpinvSerial;
    return ins;
}
int TpinvSerial::InitTpinvSerial()
{
    // qDebug() << "初始化逆变器串口通信";

    return 0;
}

TpinvSerial *TpinvSerial::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *serial = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(serial, QQmlEngine::CppOwnership);
    }
    return serial;
}

MosSerialPortManager *TpinvSerial::manager() const
{
    return MosSerialPortManager::instance();
}

void TpinvSerial::bindManagerSignals()
{
    auto *serialManager = manager();
    connect(
        serialManager,
        &MosSerialPortManager::errorOccurred,
        this,
        [this](const QString &message) {
            qDebug() << "串口错误:" << message;
        }
    );
    connect(
        serialManager,
        &MosSerialPortManager::errorOccurredFromPort,
        this,
        [this](const QString &portName, const QString &message) {
            qDebug() << "串口" << portName << "发生错误:" << message;
        }
    );
    connect(
        serialManager,
        &MosSerialPortManager::ReceiveDataFromPort,
        this,
        [this](const QString &portName, const QByteArray &data, const QString &text, const QString &hex) {
            emit serialTextReceived(portName, text, hex);

            const bool isControlPort = !m_controlPortName.isEmpty() && portName == m_controlPortName;
            if (isControlPort) {
                auto *controlProc = controlProcess();
                controlProc->cmdBuffer()->pushOverwrite(
                    reinterpret_cast<const tpinv::RingBuffer::value_type *>(data.constData()),
                    static_cast<tpinv::RingBuffer::size_type>(data.size()));
                // 数据到达后立即触发解析，不等待定时器
                controlProc->controntroldataProcess();
            }
        }
    );

}

TpInvcontroldata *TpinvSerial::controlData() const
{
    return TpInvcontroldata::instance();
}

void TpinvSerial::bindControlDataSignals()
{
    auto *contData = controlData();

    connect(
        contData,
        &TpInvcontroldata::cmdTx,
        this,
        [this](const QString &SerialPort, const QByteArray &data) {
            if (SerialPort.isEmpty()) {
                qWarning() << "控制串口为空，无法发送命令";
                return;
            }
            auto *serialManager = manager();
            if (!serialManager->isPortOpen(SerialPort)) {
                qWarning() << "控制串口" << SerialPort << "未打开，无法发送命令";
                return;
            }
            qDebug() << "发送命令到串口" << SerialPort << "数据:" << data.toHex(' ').toUpper();
            const bool ok = serialManager->SendBytesToPort(SerialPort, data);
            if (!ok) {
                qWarning() << "发送失败:" << serialManager->errorString();
            } else {
                qDebug() << "发送成功, 共" << data.size() << "字节";
            }
        }
    );

}

Tpinvcontrolprocess *TpinvSerial::controlProcess() const
{
    return Tpinvcontrolprocess::instance();
}
void TpinvSerial::bindControlProcessSignals()
{
    auto *controlProc = controlProcess();

}
