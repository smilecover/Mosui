#include "MosSerialPortManager.h"
#include "MosSerialPortManager_p.h"
#include <qtclasshelpermacros.h>

MosSerialPortManager::MosSerialPortManager(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosSerialPortManagerPrivate(this))
{


}

MosSerialPortManager::~MosSerialPortManager()
{
}

// 单例实例
MosSerialPortManager *MosSerialPortManager::instance()
{
    static MosSerialPortManager ins;
    return &ins;
}


MosSerialPortManager *MosSerialPortManager::create(QQmlEngine *, QJSEngine *)
{
    MosSerialPortManager *singleton = instance();
    return singleton;
}

QSerialPort *MosSerialPortManager::CreateSerialPort(QString *ClassName ,uint8_t con)
{
    Q_UNUSED(ClassName);
    Q_UNUSED(con);
    
    return new QSerialPort(this);
}
void MosSerialPortManager::GetSerialPortInfo()
{
    Q_D(MosSerialPortManager);
    d->portInfoList = QSerialPortInfo::availablePorts();
}
