#ifndef MOSSERIALPORTMANAGER_H
#define MOSSERIALPORTMANAGER_H

#include <QObject>
#include <QtQml/qqml.h>
#include "Mosglobal.h"
#include "Mosdefinitions.h"

class MOSUIBASIC_EXPORT MosSerialPortManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosSerialPortManager)
public:
    ~MosSerialPortManager();

    static MosSerialPortManager *instance();
    static MosSerialPortManager *create(QQmlEngine *, QJSEngine *);

private:
    explicit MosSerialPortManager(QObject *parent = nullptr);

    
};




#endif// MOSSERIALPORTMANAGER_H
