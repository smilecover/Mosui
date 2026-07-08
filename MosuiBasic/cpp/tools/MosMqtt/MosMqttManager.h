#ifndef MOSMQTTMANAGER_H
#define MOSMQTTMANAGER_H

#include <QObject>
#include <QByteArray>
#include <QSslConfiguration>
#include <QString>
#include <QStringList>
#include <QVariantMap>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosMqttManagerPrivate)

class MOSUIBASIC_EXPORT MosMqttManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosMqttManager)

    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged FINAL)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged FINAL)
    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged FINAL)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged FINAL)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged FINAL)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged FINAL)
    Q_PROPERTY(State state READ state NOTIFY stateChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)
    Q_PROPERTY(QStringList subscriptions READ subscriptions NOTIFY subscriptionsChanged FINAL)
    Q_PROPERTY(int keepAlive READ keepAlive WRITE setKeepAlive NOTIFY keepAliveChanged FINAL)
    Q_PROPERTY(bool autoReconnect READ autoReconnect WRITE setAutoReconnect NOTIFY autoReconnectChanged FINAL)
    Q_PROPERTY(int reconnectInterval READ reconnectInterval WRITE setReconnectInterval NOTIFY reconnectIntervalChanged FINAL)
    Q_PROPERTY(bool sslEnabled READ sslEnabled WRITE setSslEnabled NOTIFY sslEnabledChanged FINAL)
    Q_PROPERTY(QString sslCaCertPath READ sslCaCertPath WRITE setSslCaCertPath NOTIFY sslCaCertPathChanged FINAL)
    Q_PROPERTY(bool sslPeerVerify READ sslPeerVerify WRITE setSslPeerVerify NOTIFY sslPeerVerifyChanged FINAL)
    Q_PROPERTY(QString willTopic READ willTopic WRITE setWillTopic NOTIFY willTopicChanged FINAL)
    Q_PROPERTY(QString willMessage READ willMessage WRITE setWillMessage NOTIFY willMessageChanged FINAL)
    Q_PROPERTY(int willQos READ willQos WRITE setWillQos NOTIFY willQosChanged FINAL)
    Q_PROPERTY(bool willRetain READ willRetain WRITE setWillRetain NOTIFY willRetainChanged FINAL)

public:
    enum State {
        Disconnected = 0,
        Connecting  = 1,
        Connected   = 2
    };
    Q_ENUM(State)

    ~MosMqttManager() override;

    static MosMqttManager *instance();
    static MosMqttManager *create(QQmlEngine *, QJSEngine *);

    QString host() const;
    int port() const;
    QString clientId() const;
    QString username() const;
    QString password() const;
    bool isConnected() const;
    State state() const;
    QString errorString() const;
    QStringList subscriptions() const;
    int keepAlive() const;
    bool autoReconnect() const;
    int reconnectInterval() const;
    bool sslEnabled() const;
    QString sslCaCertPath() const;
    bool sslPeerVerify() const;
    QString willTopic() const;
    QString willMessage() const;
    int willQos() const;
    bool willRetain() const;

    void setHost(const QString &host);
    void setPort(int port);
    void setClientId(const QString &clientId);
    void setUsername(const QString &username);
    void setPassword(const QString &password);
    void setKeepAlive(int keepAlive);
    void setAutoReconnect(bool enabled);
    void setReconnectInterval(int ms);
    void setSslEnabled(bool enabled);
    void setSslCaCertPath(const QString &path);
    void setSslPeerVerify(bool enabled);
    void setWillTopic(const QString &topic);
    void setWillMessage(const QString &message);
    void setWillQos(int qos);
    void setWillRetain(bool retain);

    Q_INVOKABLE void connectToHost();
    Q_INVOKABLE void connectToHost(const QString &host, int port);
    Q_INVOKABLE void disconnectFromHost();
    Q_INVOKABLE int publish(const QString &topic, const QString &message, int qos = 0, bool retain = false);
    Q_INVOKABLE int publishBytes(const QString &topic, const QByteArray &data, int qos = 0, bool retain = false);
    Q_INVOKABLE void subscribe(const QString &topic, int qos = 0);
    Q_INVOKABLE void unsubscribe(const QString &topic);
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void shutdown();

Q_SIGNALS:
    void hostChanged();
    void portChanged();
    void clientIdChanged();
    void usernameChanged();
    void passwordChanged();
    void isConnectedChanged();
    void stateChanged();
    void errorStringChanged();
    void subscriptionsChanged();
    void keepAliveChanged();
    void autoReconnectChanged();
    void reconnectIntervalChanged();
    void sslEnabledChanged();
    void sslCaCertPathChanged();
    void sslPeerVerifyChanged();
    void willTopicChanged();
    void willMessageChanged();
    void willQosChanged();
    void willRetainChanged();

    void connected();
    void disconnected();
    void messageReceived(const QString &topic, const QString &message);
    void bytesReceived(const QString &topic, const QByteArray &data);
    void published(int id);
    void errorOccurred(const QString &message);

private:
    explicit MosMqttManager(QObject *parent = nullptr);

    Q_DECLARE_PRIVATE(MosMqttManager)
    QScopedPointer<MosMqttManagerPrivate> d_ptr;
};

#endif // MOSMQTTMANAGER_H
