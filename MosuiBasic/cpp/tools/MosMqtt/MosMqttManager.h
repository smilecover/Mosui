#ifndef MOSMQTTMANAGER_H
#define MOSMQTTMANAGER_H

#include <QObject>
#include <QByteArray>
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
    Q_PROPERTY(int state READ state NOTIFY stateChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)
    Q_PROPERTY(QStringList subscriptions READ subscriptions NOTIFY subscriptionsChanged FINAL)
    Q_PROPERTY(int keepAlive READ keepAlive WRITE setKeepAlive NOTIFY keepAliveChanged FINAL)
    Q_PROPERTY(bool autoReconnect READ autoReconnect WRITE setAutoReconnect NOTIFY autoReconnectChanged FINAL)

public:
    ~MosMqttManager() override;

    static MosMqttManager *instance();
    static MosMqttManager *create(QQmlEngine *, QJSEngine *);

    QString host() const;
    int port() const;
    QString clientId() const;
    QString username() const;
    QString password() const;
    bool isConnected() const;
    int state() const;
    QString errorString() const;
    QStringList subscriptions() const;
    int keepAlive() const;
    bool autoReconnect() const;

    void setHost(const QString &host);
    void setPort(int port);
    void setClientId(const QString &clientId);
    void setUsername(const QString &username);
    void setPassword(const QString &password);
    void setKeepAlive(int keepAlive);
    void setAutoReconnect(bool enabled);

    Q_INVOKABLE void connectToHost();
    Q_INVOKABLE void connectToHost(const QString &host, int port);
    Q_INVOKABLE void disconnectFromHost();
    Q_INVOKABLE int publish(const QString &topic, const QString &message, int qos = 0, bool retain = false);
    Q_INVOKABLE int publishBytes(const QString &topic, const QByteArray &data, int qos = 0, bool retain = false);
    Q_INVOKABLE void subscribe(const QString &topic, int qos = 0);
    Q_INVOKABLE void unsubscribe(const QString &topic);
    Q_INVOKABLE void clearError();

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
