#ifndef MOSSERIALPORTMANAGER_H
#define MOSSERIALPORTMANAGER_H

#include <QObject>
#include <QtQml/qqml.h>
#include <qobject.h>
#include <qtmetamacros.h>
#include <QSerialPort>
#include <QSerialPortInfo>
#include "Mosglobal.h"
#include "Mosdefinitions.h"
QT_FORWARD_DECLARE_CLASS(MosSerialPortManagerPrivate)
class MOSUIBASIC_EXPORT MosSerialPortManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosSerialPortManager)
    MOSUI_PROPERTY_READONLY(QList<QSerialPortInfo>, portInfoList)
public:
    ~MosSerialPortManager();

    static MosSerialPortManager *instance();
    static MosSerialPortManager *create(QQmlEngine *, QJSEngine *);
    Q_INVOKABLE QSerialPort *CreateSerialPort(QString *ClassName, uint8_t con);
    Q_INVOKABLE void GetSerialPortInfo();

private:
    explicit MosSerialPortManager(QObject *parent = nullptr);

    Q_DECLARE_PRIVATE(MosSerialPortManager)
    QScopedPointer<MosSerialPortManagerPrivate> d_ptr;

    
};




#endif// MOSSERIALPORTMANAGER_H
