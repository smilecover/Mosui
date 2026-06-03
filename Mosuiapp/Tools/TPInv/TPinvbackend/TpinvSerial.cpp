#include "TpinvSerial.h"

#include "MosSerialPortManager.h"
#include "TpInvcontroldata.h"

#include <QQmlEngine>
#include <QVariantMap>
#include <QDebug>
#include <qdebug.h>

TpinvSerial::TpinvSerial(QObject *parent)
    : QObject(parent)
{
    bindManagerSignals();
    bindControlDataSignals();

}

TpinvSerial::~TpinvSerial() = default;

TpinvSerial *TpinvSerial::instance()
{
    static TpinvSerial *ins = new TpinvSerial;
    return ins;
}
int TpinvSerial::InitTpinvSerial()
{
    qDebug() << "初始化逆变器串口通信";

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
            if (!m_controlPortName.isEmpty() && portName != m_controlPortName)
                return;
            qDebug() << "从串口" << portName << "接收到数据:" << data;
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
            auto *serialManager = manager();
            qDebug() << "发送命令到串口" << SerialPort << "数据:" << data;
        }
    );
}
