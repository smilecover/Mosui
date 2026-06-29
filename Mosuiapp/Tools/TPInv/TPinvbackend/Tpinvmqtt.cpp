#include "Tpinvmqtt.h"

#include "MosMqttManager.h"
#include "TpInvcontroldata.h"
#include "TpInv_dataprocessing.h"
#include "Tpinvcontrolprocess.h"

#include <QDebug>
#include <QQmlEngine>
#include <qdebug.h>

Tpinvmqtt::Tpinvmqtt(QObject *parent)
    : QObject(parent)
{
    bindMqttSignals();
}

Tpinvmqtt::~Tpinvmqtt() = default;

// ── 波形数据桥接 (从 TpInvDataProcessing 读取) ──

int Tpinvmqtt::waveSampleCount() const
{
    return TpInvDataProcessing::instance()->sampleCount();
}

QVariantList Tpinvmqtt::waveVoltageAValues() const
{
    return TpInvDataProcessing::instance()->voltageAValues();
}

QVariantList Tpinvmqtt::waveVoltageBValues() const
{
    return TpInvDataProcessing::instance()->voltageBValues();
}

QVariantList Tpinvmqtt::waveVoltageCValues() const
{
    return TpInvDataProcessing::instance()->voltageCValues();
}

QVariantList Tpinvmqtt::waveCurrentAValues() const
{
    return TpInvDataProcessing::instance()->currentAValues();
}

QVariantList Tpinvmqtt::waveCurrentBValues() const
{
    return TpInvDataProcessing::instance()->currentBValues();
}

QVariantList Tpinvmqtt::waveCurrentCValues() const
{
    return TpInvDataProcessing::instance()->currentCValues();
}

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
    });

    connect(manager, &MosMqttManager::errorOccurred, this, [this](const QString &message) {
        emit errorOccurred(message);
    });

    // 桥接 TpInvDataProcessing 的数据变化信号 → TpinvMqtt::waveDataChanged
    auto *dataProc = TpInvDataProcessing::instance();
    connect(dataProc, &TpInvDataProcessing::samplesChanged,
            this, &Tpinvmqtt::waveDataChanged);
    connect(dataProc, &TpInvDataProcessing::voltageSeriesChanged,
            this, &Tpinvmqtt::waveDataChanged);
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
        if (topic == m_waveDataTopic && !data.isEmpty()) {
            TpInvDataProcessing::instance()->handleMqttWaveData(data);
            qDebug() << "接收到 MQTT 波形数据";
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
