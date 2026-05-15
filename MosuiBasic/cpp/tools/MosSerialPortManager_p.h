#include "MosSerialPortManager.h"
#include <QtCore>


class MosSerialPortManagerPrivate
{   

    public:
        Q_DECLARE_PUBLIC(MosSerialPortManager);
        MosSerialPortManagerPrivate(MosSerialPortManager *q) : q_ptr(q) { };
        MosSerialPortManager *q_ptr { nullptr };

        QList<QSerialPortInfo> portInfoList;


    
};
