#ifndef MOSSERIALPORTMANAGER_P_H
#define MOSSERIALPORTMANAGER_P_H

#include "MosSerialPortManager.h"

#include <QHash>
#include <QSerialPort>
#include <QString>
#include <QVariantList>

class MosSerialPortManagerPrivate
{
public:
    Q_DECLARE_PUBLIC(MosSerialPortManager)

    explicit MosSerialPortManagerPrivate(MosSerialPortManager *q) : q_ptr(q) { }

    MosSerialPortManager *q_ptr { nullptr };
    QHash<QString, QSerialPort *> serialPorts;
    QVariantList portInfoList;
    bool isOpen { false };
    QString currentPortName;
    QString errorString;
};

#endif // MOSSERIALPORTMANAGER_P_H
