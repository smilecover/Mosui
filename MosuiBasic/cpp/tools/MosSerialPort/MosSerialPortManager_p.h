#ifndef MOSSERIALPORTMANAGER_P_H
#define MOSSERIALPORTMANAGER_P_H

#include "MosSerialPortManager.h"

#include <QString>
#include <QStringList>
#include <QThread>
#include <QVariantList>

class MosSerialPortWorker;

class MosSerialPortManagerPrivate
{
public:
    Q_DECLARE_PUBLIC(MosSerialPortManager)

    explicit MosSerialPortManagerPrivate(MosSerialPortManager *q) : q_ptr(q) { }

    MosSerialPortManager *q_ptr { nullptr };
    QThread *serialThread { nullptr };
    MosSerialPortWorker *worker { nullptr };
    QVariantList portInfoList;
    QVariantList openPortList;
    bool isOpen { false };
    QString currentPortName;
    QString errorString;
};

#endif // MOSSERIALPORTMANAGER_P_H
