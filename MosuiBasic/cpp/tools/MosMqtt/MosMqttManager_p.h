#ifndef MOSMQTTMANAGER_P_H
#define MOSMQTTMANAGER_P_H

#include "MosMqttManager.h"

#include <QString>
#include <QStringList>
#include <QThread>
#include <QVariantMap>

class MosMqttWorker;

class MosMqttManagerPrivate
{
public:
    Q_DECLARE_PUBLIC(MosMqttManager)

    explicit MosMqttManagerPrivate(MosMqttManager *q) : q_ptr(q) { }

    MosMqttManager *q_ptr { nullptr };
    QThread *mqttThread { nullptr };
    MosMqttWorker *worker { nullptr };

    QString host;
    int port { 1883 };
    QString clientId;
    QString username;
    QString password;
    bool isConnected { false };
    int state { 0 };
    QString errorString;
    QStringList subscriptions;
    int keepAlive { 60 };
    bool autoReconnect { false };
};

#endif // MOSMQTT_P_H
