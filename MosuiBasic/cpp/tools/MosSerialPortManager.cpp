#include "MosSerialPortManager.h"

MosSerialPortManager::MosSerialPortManager(QObject *parent)
    : QObject{parent}
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

// QML 单例工厂函数（必须写）
MosSerialPortManager *MosSerialPortManager::create(QQmlEngine *, QJSEngine *)
{
    MosSerialPortManager *singleton = instance();

    return singleton;
}