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

    // ── MQTT 连接配置 (委托给 MosMqttManager，实现多页面共享数据) ──
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged FINAL)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged FINAL)
    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged FINAL)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged FINAL)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged FINAL)

    // ── 主题配置 ──
    MOSUI_PROPERTY_INIT(QString, controlTopic,  setControlTopic,  "tpinv/control")
    MOSUI_PROPERTY_INIT(QString, dataTopic,     setDataTopic,     "tpinv/data")
    MOSUI_PROPERTY_INIT(QString, waveDataTopic, setWaveDataTopic, "tpinv/wave/data")

    // ── 连接状态 (只读) ──
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged FINAL)

public:
    ~Tpinvmqtt() override;

    static Tpinvmqtt *instance();
    static Tpinvmqtt *create(QQmlEngine *, QJSEngine *);

    bool isConnected() const;

    // ── 委托属性 (读写 MosMqttManager，实现多页面共享) ──
    QString host() const;
    int port() const;
    QString clientId() const;
    QString username() const;
    QString password() const;

    void setHost(const QString &v);
    void setPort(int v);
    void setClientId(const QString &v);
    void setUsername(const QString &v);
    void setPassword(const QString &v);

    // ── 持久化 ──
    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void saveSettings();

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

    // ── 委托属性变更信号 ──
    void hostChanged();
    void portChanged();
    void clientIdChanged();
    void usernameChanged();
    void passwordChanged();

private:
    explicit Tpinvmqtt(QObject *parent = nullptr);

    MosMqttManager      *mqttManager()     const;
    Tpinvcontrolprocess *controlProcess()  const;
    TpInvcontroldata    *controlData()     const;

    void bindMqttSignals();
    void connectSettingsPersistence();

    bool isConnected_ = false;
    bool m_loadingSettings = false;
};

#endif // TPINVMQTT_H
