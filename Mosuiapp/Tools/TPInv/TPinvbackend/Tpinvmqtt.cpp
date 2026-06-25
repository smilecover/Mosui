#include "Tpinvmqtt.h"

#include "MosMqttManager.h"
#include "TpInvcontroldata.h"
#include "TpInv_dataprocessing.h"
#include "Tpinvcontrolprocess.h"

#include <QDebug>
#include <QQmlEngine>
#include <QSettings>
#include <qdebug.h>

Tpinvmqtt::Tpinvmqtt(QObject *parent)
    : QObject(parent)
{
    bindMqttSignals();
    connectSettingsPersistence();
    loadSettings();  // 构造时立即加载持久化配置，确保 saveSettings 连接在用户操作前已就绪
}

Tpinvmqtt::~Tpinvmqtt() = default;

// ── 单例 ──

Tpinvmqtt *Tpinvmqtt::instance()
{
    static Tpinvmqtt *ins = new Tpinvmqtt;
    return ins;
}

Tpinvmqtt *Tpinvmqtt::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *mqtt = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(mqtt, QQmlEngine::CppOwnership);
    }
    return mqtt;
}

bool Tpinvmqtt::isConnected() const
{
    return isConnected_;
}

// ── 依赖 ──

MosMqttManager *Tpinvmqtt::mqttManager() const
{
    return MosMqttManager::instance();
}

Tpinvcontrolprocess *Tpinvmqtt::controlProcess() const
{
    return Tpinvcontrolprocess::instance();
}

TpInvcontroldata *Tpinvmqtt::controlData() const
{
    return TpInvcontroldata::instance();
}

// ── 信号绑定 ──

void Tpinvmqtt::bindMqttSignals()
{
    auto *manager = mqttManager();

    connect(manager, &MosMqttManager::connected, this, [this]() {
        isConnected_ = true;
        emit isConnectedChanged();
        qDebug() << "[TpinvMqtt] 已连接到 MQTT Broker";

        // 连接成功后自动订阅数据主题
        if (!m_dataTopic.isEmpty()) {
            subscribeTopic(m_dataTopic);
        }
        // 自动订阅波形数据主题
        if (!m_waveDataTopic.isEmpty() && m_waveDataTopic != m_dataTopic) {
            subscribeTopic(m_waveDataTopic);
        }
    });

    connect(manager, &MosMqttManager::disconnected, this, [this]() {
        isConnected_ = false;
        emit isConnectedChanged();
        qDebug() << "[TpinvMqtt] 已断开 MQTT 连接";
    });

    connect(manager, &MosMqttManager::errorOccurred, this, [this](const QString &message) {
        qWarning() << "[TpinvMqtt] 错误:" << message;
        emit errorOccurred(message);
    });

    // 数据主题消息 → 推入控制处理流水线 / 波形处理流水线
    connect(manager, &MosMqttManager::bytesReceived, this,
            [this](const QString &topic, const QByteArray &data) {
        emit mqttMessageReceived(topic, data);

        if (topic == m_dataTopic && !data.isEmpty()) {
            auto *proc = controlProcess();
            proc->cmdBuffer()->pushOverwrite(
                reinterpret_cast<const tpinv::RingBuffer::value_type *>(data.constData()),
                static_cast<tpinv::RingBuffer::size_type>(data.size()));
            proc->controntroldataProcess();
        }

        // 波形数据主题 → 推入 MQTT 批量波形处理流水线
        if (topic == m_waveDataTopic && !data.isEmpty()) {
            TpInvDataProcessing::instance()->handleMqttWaveData(data);
        }
    });

    // 模式切换帧 → MQTT 转发
    connect(controlData(), &TpInvcontroldata::modeSwitchCmdTx, this,
            [this](const QByteArray &data) {
        publishCommand(data);
    });
}

// ── 初始化 ──

int Tpinvmqtt::InitMqtt()
{
    qDebug() << "[TpinvMqtt] 初始化 MQTT 后端 (配置已在构造函数中加载)";
    return 0;
}

// ── 委托属性 (读写 MosMqttManager，实现 TPInvcontrol.qml 与 TPInvmqttconnect.qml 数据共享) ──

QString Tpinvmqtt::host() const { return mqttManager()->host(); }
int Tpinvmqtt::port() const { return mqttManager()->port(); }
QString Tpinvmqtt::clientId() const { return mqttManager()->clientId(); }
QString Tpinvmqtt::username() const { return mqttManager()->username(); }
QString Tpinvmqtt::password() const { return mqttManager()->password(); }

void Tpinvmqtt::setHost(const QString &v) { mqttManager()->setHost(v); }
void Tpinvmqtt::setPort(int v) { mqttManager()->setPort(v); }
void Tpinvmqtt::setClientId(const QString &v) { mqttManager()->setClientId(v); }
void Tpinvmqtt::setUsername(const QString &v) { mqttManager()->setUsername(v); }
void Tpinvmqtt::setPassword(const QString &v) { mqttManager()->setPassword(v); }

// ── 设置持久化 ──

void Tpinvmqtt::connectSettingsPersistence()
{
    auto *m = mqttManager();

    // MosMqttManager 属性变化 → 转发信号 + 保存设置
    connect(m, &MosMqttManager::hostChanged, this, &Tpinvmqtt::hostChanged);
    connect(m, &MosMqttManager::portChanged, this, &Tpinvmqtt::portChanged);
    connect(m, &MosMqttManager::clientIdChanged, this, &Tpinvmqtt::clientIdChanged);
    connect(m, &MosMqttManager::usernameChanged, this, &Tpinvmqtt::usernameChanged);
    connect(m, &MosMqttManager::passwordChanged, this, &Tpinvmqtt::passwordChanged);

    // 属性变化时自动保存
    connect(m, &MosMqttManager::hostChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::portChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::clientIdChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::usernameChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::passwordChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::keepAliveChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::autoReconnectChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::reconnectIntervalChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::sslEnabledChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::sslCaCertPathChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::sslPeerVerifyChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::willTopicChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::willMessageChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::willQosChanged, this, &Tpinvmqtt::saveSettings);
    connect(m, &MosMqttManager::willRetainChanged, this, &Tpinvmqtt::saveSettings);

    // TpinvMqtt 独有主题属性变化时也保存
    connect(this, &Tpinvmqtt::controlTopicChanged, this, &Tpinvmqtt::saveSettings);
    connect(this, &Tpinvmqtt::dataTopicChanged, this, &Tpinvmqtt::saveSettings);
    connect(this, &Tpinvmqtt::waveDataTopicChanged, this, &Tpinvmqtt::saveSettings);
}

void Tpinvmqtt::loadSettings()
{
    m_loadingSettings = true;

    QSettings s;
    auto *m = mqttManager();

    // 以 MosMqttManager 当前值作为默认值
    m->setHost(s.value(QStringLiteral("tpinv/mqtt/host"), m->host()).toString());
    m->setPort(s.value(QStringLiteral("tpinv/mqtt/port"), m->port()).toInt());
    m->setClientId(s.value(QStringLiteral("tpinv/mqtt/clientId"), m->clientId()).toString());
    m->setUsername(s.value(QStringLiteral("tpinv/mqtt/username"), m->username()).toString());
    m->setPassword(s.value(QStringLiteral("tpinv/mqtt/password"), m->password()).toString());
    m->setKeepAlive(s.value(QStringLiteral("tpinv/mqtt/keepAlive"), m->keepAlive()).toInt());
    m->setAutoReconnect(s.value(QStringLiteral("tpinv/mqtt/autoReconnect"), m->autoReconnect()).toBool());
    m->setReconnectInterval(s.value(QStringLiteral("tpinv/mqtt/reconnectInterval"), m->reconnectInterval()).toInt());
    m->setSslEnabled(s.value(QStringLiteral("tpinv/mqtt/sslEnabled"), m->sslEnabled()).toBool());
    m->setSslCaCertPath(s.value(QStringLiteral("tpinv/mqtt/sslCaCertPath"), m->sslCaCertPath()).toString());
    m->setSslPeerVerify(s.value(QStringLiteral("tpinv/mqtt/sslPeerVerify"), m->sslPeerVerify()).toBool());
    m->setWillTopic(s.value(QStringLiteral("tpinv/mqtt/willTopic"), m->willTopic()).toString());
    m->setWillMessage(s.value(QStringLiteral("tpinv/mqtt/willMessage"), m->willMessage()).toString());
    m->setWillQos(s.value(QStringLiteral("tpinv/mqtt/willQos"), m->willQos()).toInt());
    m->setWillRetain(s.value(QStringLiteral("tpinv/mqtt/willRetain"), m->willRetain()).toBool());

    // TpinvMqtt 独有主题
    setControlTopic(s.value(QStringLiteral("tpinv/mqtt/controlTopic"), controlTopic()).toString());
    setDataTopic(s.value(QStringLiteral("tpinv/mqtt/dataTopic"), dataTopic()).toString());
    setWaveDataTopic(s.value(QStringLiteral("tpinv/mqtt/waveDataTopic"), waveDataTopic()).toString());

    m_loadingSettings = false;

    qDebug() << "[TpinvMqtt] 已加载持久化 MQTT 配置"
             << "host:" << m->host() << "port:" << m->port();
}

void Tpinvmqtt::saveSettings()
{
    if (m_loadingSettings)
        return;

    QSettings s;
    auto *m = mqttManager();

    s.setValue(QStringLiteral("tpinv/mqtt/host"), m->host());
    s.setValue(QStringLiteral("tpinv/mqtt/port"), m->port());
    s.setValue(QStringLiteral("tpinv/mqtt/clientId"), m->clientId());
    s.setValue(QStringLiteral("tpinv/mqtt/username"), m->username());
    s.setValue(QStringLiteral("tpinv/mqtt/password"), m->password());
    s.setValue(QStringLiteral("tpinv/mqtt/keepAlive"), m->keepAlive());
    s.setValue(QStringLiteral("tpinv/mqtt/autoReconnect"), m->autoReconnect());
    s.setValue(QStringLiteral("tpinv/mqtt/reconnectInterval"), m->reconnectInterval());
    s.setValue(QStringLiteral("tpinv/mqtt/sslEnabled"), m->sslEnabled());
    s.setValue(QStringLiteral("tpinv/mqtt/sslCaCertPath"), m->sslCaCertPath());
    s.setValue(QStringLiteral("tpinv/mqtt/sslPeerVerify"), m->sslPeerVerify());
    s.setValue(QStringLiteral("tpinv/mqtt/willTopic"), m->willTopic());
    s.setValue(QStringLiteral("tpinv/mqtt/willMessage"), m->willMessage());
    s.setValue(QStringLiteral("tpinv/mqtt/willQos"), m->willQos());
    s.setValue(QStringLiteral("tpinv/mqtt/willRetain"), m->willRetain());

    s.setValue(QStringLiteral("tpinv/mqtt/controlTopic"), controlTopic());
    s.setValue(QStringLiteral("tpinv/mqtt/dataTopic"), dataTopic());
    s.setValue(QStringLiteral("tpinv/mqtt/waveDataTopic"), waveDataTopic());
}

// ── 连接管理 ──

void Tpinvmqtt::connectToHost()
{
    auto *manager = mqttManager();
    if (manager->host().trimmed().isEmpty())
        return;

    // 逆变器控制场景：强制启用自动重连
    manager->setAutoReconnect(true);
    manager->setReconnectInterval(5000);

    qDebug() << "[TpinvMqtt] 正在连接" << manager->host() << ":" << manager->port();
    manager->connectToHost();
}

void Tpinvmqtt::connectToHost(const QString &host, int port)
{
    auto *manager = mqttManager();
    manager->setHost(host);
    manager->setPort(port);
    connectToHost();
}

void Tpinvmqtt::disconnectFromHost()
{
    qDebug() << "[TpinvMqtt] 正在断开连接";
    mqttManager()->disconnectFromHost();
}

// ── 逆变器控制 ──

void Tpinvmqtt::startInverter()
{
    auto *data = controlData();

    // 触发运行状态变更，让 controlProcess 重新构建控制帧
    data->setRunning(true);
    emit data->parameterItemsChanged();

    // 获取构建好的控制帧并通过 MQTT 发布
    const QByteArray frame = controlProcess()->txBuffer().value(0);
    if (!frame.isEmpty()) {
        publishCommand(frame);
    }

    qDebug() << "[TpinvMqtt] 逆变器启动命令已发送";
}

void Tpinvmqtt::stopInverter()
{
    auto *data = controlData();

    // 触发运行状态变更
    data->setRunning(false);
    emit data->parameterItemsChanged();

    // 获取构建好的控制帧并通过 MQTT 发布
    const QByteArray frame = controlProcess()->txBuffer().value(0);
    if (!frame.isEmpty()) {
        publishCommand(frame);
    }

    qDebug() << "[TpinvMqtt] 逆变器停止命令已发送";
}

// ── 消息收发 ──

int Tpinvmqtt::publishCommand(const QByteArray &data)
{
    return publishMessage(m_controlTopic, data);
}

int Tpinvmqtt::publishMessage(const QString &topic, const QByteArray &data,
                              int qos, bool retain)
{
    if (topic.isEmpty()) {
        qWarning() << "[TpinvMqtt] 发布主题为空";
        return -1;
    }

    if (!isConnected_) {
        qWarning() << "[TpinvMqtt] 未连接，无法发布消息";
        return -1;
    }

    qDebug() << "[TpinvMqtt] 发布到" << topic
             << "数据:" << data.toHex(' ').toUpper();
    return mqttManager()->publishBytes(topic, data, qos, retain);
}

// ── 主题订阅 ──

void Tpinvmqtt::subscribeTopic(const QString &topic, int qos)
{
    if (topic.isEmpty()) {
        qWarning() << "[TpinvMqtt] 订阅主题为空";
        return;
    }

    if (!isConnected_) {
        qWarning() << "[TpinvMqtt] 未连接，无法订阅主题:" << topic;
        return;
    }

    qDebug() << "[TpinvMqtt] 订阅主题:" << topic << "QoS:" << qos;
    mqttManager()->subscribe(topic, qos);
}

void Tpinvmqtt::unsubscribeTopic(const QString &topic)
{
    if (topic.isEmpty()) {
        qWarning() << "[TpinvMqtt] 取消订阅主题为空";
        return;
    }

    qDebug() << "[TpinvMqtt] 取消订阅主题:" << topic;
    mqttManager()->unsubscribe(topic);
}
