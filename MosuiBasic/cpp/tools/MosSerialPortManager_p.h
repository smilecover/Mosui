#ifndef MOSSERIALPORTMANAGER_P_H
#define MOSSERIALPORTMANAGER_P_H

#include "MosSerialPortManager.h"

#include <QSerialPort>
#include <QVariantList>

class MosSerialPortManagerPrivate
{
public:
    Q_DECLARE_PUBLIC(MosSerialPortManager)

    explicit MosSerialPortManagerPrivate(MosSerialPortManager *q) : q_ptr(q) { }

    MosSerialPortManager *q_ptr { nullptr };
    QSerialPort serialPort;
    QVariantList portInfoList;
    bool isOpen { false };
    QString currentPortName;
    QString errorString;
};

#endif // MOSSERIALPORTMANAGER_P_H
