#ifndef TPINVMQTT_H
#define TPINVMQTT_H

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QtQml/qqml.h>
#include "Mosdefinitions.h"

class MosMqttManager;
class Tpinvcontrolprocess;
class TpInvcontroldata;

class Tpinvmqtt : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpinvMqtt)

    // ── MQTT 连接配置 ──
    MOSUI_PROPERTY_INIT(QString, host, setHost, "127.0.0.1")
    MOSUI_PROPERTY_INIT(int,     port, setPort, 1883)
    MOSUI_PROPERTY_INIT(QString, clientId, setClientId, "")
    MOSUI_PROPERTY_INIT(QString, username, setUsername, "")
    MOSUI_PROPERTY_INIT(QString, password, setPassword, "")

    // ── 主题配置 ──
    MOSUI_PROPERTY_INIT(QString, controlTopic, setControlTopic, "tpinv/control")
    MOSUI_PROPERTY_INIT(QString, dataTopic,    setDataTopic,    "tpinv/data")

    // ── 连接状态 (只读) ──
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged FINAL)

public:
    ~Tpinvmqtt() override;

    static Tpinvmqtt *instance();
    static Tpinvmqtt *create(QQmlEngine *, QJSEngine *);

    bool isConnected() const;

    // ── 初始化 ──
    Q_INVOKABLE int InitMqtt();

    // ── 连接管理 ──
    Q_INVOKABLE void connectToHost();
    Q_INVOKABLE void connectToHost(const QString &host, int port);
    Q_INVOKABLE void disconnectFromHost();

    // ── 逆变器控制 (通过 MQTT) ──
    Q_INVOKABLE void startInverter();
    Q_INVOKABLE void stopInverter();

    // ── 消息收发 ──
    Q_INVOKABLE int publishCommand(const QByteArray &data);
    Q_INVOKABLE int publishMessage(const QString &topic, const QByteArray &data,
                                   int qos = 0, bool retain = false);

    // ── 主题订阅 ──
    Q_INVOKABLE void subscribeTopic(const QString &topic, int qos = 0);
    Q_INVOKABLE void unsubscribeTopic(const QString &topic);

Q_SIGNALS:
    void isConnectedChanged();
    void mqttMessageReceived(const QString &topic, const QByteArray &data);
    void errorOccurred(const QString &message);

private:
    explicit Tpinvmqtt(QObject *parent = nullptr);

    MosMqttManager      *mqttManager()     const;
    Tpinvcontrolprocess *controlProcess()  const;
    TpInvcontroldata    *controlData()     const;

    void bindMqttSignals();

    bool isConnected_ = false;
};

#endif // TPINVMQTT_H
