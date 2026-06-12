import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }

    Column {
        id: column
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 15
        spacing: 30

        MosDescription {
            desc: qsTr(`
# MosMqttManager MQTT 连接管理器

\`MosMqttManager\` 是基于 \`QMqttClient\` 的 QML 单例，用于 MQTT Broker 连接、主题订阅/取消订阅、消息发布/接收、TLS/SSL 加密传输。

* **模块 { MosuiBasic }**
* **类型 { QML Singleton }**
* **C++ 单例 { MosMqttManager::instance() }**
* **底层 { QMqttClient + 独立 MQTT 线程 }**
* **MQTT 版本 { MQTT 3.1.1 / 5.0 }**

<br/>

### 设计要点

\`MosMqttManager\` 将 \`QMqttClient\` 运行在独立线程中，所有网络操作通过 \`invokeOperation\` 跨线程调用，避免阻塞 UI 线程。QML 页面、C++ 协议解析器拿到的是同一个全局单例，可以在不同页面同时监听同一份 MQTT 数据流。

连接、订阅、发布、取消订阅均为异步操作，带超时保护（默认 5 秒）。超时后会自动取消底层连接操作，防止资源泄漏。

支持 TLS/SSL 加密传输，可加载自定义 CA 证书并控制对等验证。支持遗愿消息（Will Message），连接断开时 Broker 自动发布。
                       `)
        }

        MosDescription {
            title: qsTr('属性')
            desc: qsTr(`
属性名 | 类型 | 默认值 | 说明
------ | --- | --- | ---
host | string | \`"127.0.0.1"\` | MQTT Broker 主机地址
port | int | \`1883\` | MQTT Broker 端口
clientId | string | \`""\` | 客户端标识（空时由 Broker 自动分配）
username | string | \`""\` | 认证用户名
password | string | \`""\` | 认证密码
isConnected | bool | \`false\` | 是否已连接
state | State | \`Disconnected\` | 连接状态枚举
errorString | string | \`""\` | 最近错误文本
subscriptions | QStringList | \`[]\` | 当前订阅主题列表（排序后）
keepAlive | int | \`60\` | 心跳间隔（秒）
autoReconnect | bool | \`false\` | 意外断线后是否自动重连
reconnectInterval | int | \`5000\` | 重连基础间隔（毫秒），最小 1000
sslEnabled | bool | \`false\` | 是否启用 TLS/SSL 加密
sslCaCertPath | string | \`""\` | CA 证书文件路径
sslPeerVerify | bool | \`true\` | 是否验证对等证书（自签名证书设为 false）
willTopic | string | \`""\` | 遗嘱消息主题（空=不设置）
willMessage | string | \`""\` | 遗嘱消息内容
willQos | int | \`0\` | 遗嘱消息 QoS（0/1/2）
willRetain | bool | \`false\` | 遗嘱消息是否保留

<br/>

### State 枚举值

值 | 说明
--- | ---
MosMqttManager.Disconnected (0) | 未连接
MosMqttManager.Connecting (1) | 正在连接
MosMqttManager.Connected (2) | 已连接

### 自动重连行为

\`autoReconnect=true\` 且 \`willTopic\` 为空时：意外断线后自动重连，并恢复全部订阅（含原始 QoS）。

\`autoReconnect=true\` 且 \`willTopic\` 有值时：Broker 将通过遗嘱消息通知其他客户端本客户端离线。

重连采用指数退避策略：间隔 = \`min(reconnectInterval * 2^attempt, 60s)\`，每次成功连接后重置。
                       `)
        }

        MosDescription {
            title: qsTr('方法')
            desc: qsTr(`
名称 | 返回值 | 说明
------ | --- | ---
connectToHost() | void | 使用当前属性连接 Broker
connectToHost(host, port) | void | 指定主机和端口连接 Broker
disconnectFromHost() | void | 断开连接并清除订阅
publish(topic, message, qos, retain) | int | 发布文本消息，返回消息 ID（失败返回 -1）
publishBytes(topic, data, qos, retain) | int | 发布二进制消息，返回消息 ID（失败返回 -1）
subscribe(topic, qos) | void | 订阅主题
unsubscribe(topic) | void | 取消订阅主题
clearError() | void | 清空 errorString

<br/>

### publish 返回值

- 成功：返回消息 ID（>= 0）
- 主题为空：返回 -1，errorString 为 \`"MQTT topic is empty."\`
- 未连接：返回 -1，errorString 为 \`"MQTT client is not connected."\`
- 操作超时：返回 -1，errorString 为 \`"MQTT operation timed out."\`

**注意**：空消息在 MQTT 协议中是合法的，常用于清除 retained 消息（向同一主题发布空 payload）。
                       `)
        }

        MosDescription {
            title: qsTr('信号')
            desc: qsTr(`
名称 | 参数 | 说明
------ | --- | ---
connected() | | 连接成功
disconnected() | | 断开连接
messageReceived(topic, message) | string, string | 收到 UTF-8 文本消息
bytesReceived(topic, data) | string, QByteArray | 收到原始字节消息
published(id) | int | 消息已确认发送（id 来自 publish 返回值）
errorOccurred(message) | string | 发生错误

<br/>

### 属性变更信号

\`hostChanged()\`, \`portChanged()\`, \`clientIdChanged()\`, \`usernameChanged()\`, \`passwordChanged()\`,
\`isConnectedChanged()\`, \`stateChanged()\`, \`errorStringChanged()\`, \`subscriptionsChanged()\`,
\`keepAliveChanged()\`, \`autoReconnectChanged()\`, \`reconnectIntervalChanged()\`,
\`sslEnabledChanged()\`, \`sslCaCertPathChanged()\`, \`sslPeerVerifyChanged()\`,
\`willTopicChanged()\`, \`willMessageChanged()\`, \`willQosChanged()\`, \`willRetainChanged()\`
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        // ========== 基础连接 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
最简连接示例。设置主机和端口后调用 \`connectToHost()\`，监听 \`isConnected\` 和 \`errorString\` 获取状态。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

ColumnLayout {
    Component.onCompleted: {
        MosMqttManager.host = "127.0.0.1"
        MosMqttManager.port = 1883
        MosMqttManager.clientId = "mosui_client"
    }

    MosText {
        text: MosMqttManager.isConnected ? qsTr("已连接") : qsTr("未连接")
        color: MosMqttManager.isConnected ? MosTheme.Primary.colorSuccessText
                                          : MosTheme.Primary.colorTextSecondary
    }

    MosText {
        text: MosMqttManager.errorString
        color: MosTheme.Primary.colorErrorText
        visible: text.length > 0
    }

    MosButton {
        text: MosMqttManager.isConnected ? qsTr("断开") : qsTr("连接")
        type: MosMqttManager.isConnected ? MosButton.Type_Default : MosButton.Type_Primary
        onClicked: {
            if (MosMqttManager.isConnected)
                MosMqttManager.disconnectFromHost()
            else
                MosMqttManager.connectToHost()
        }
    }
}
            `
            exampleDelegate: ColumnLayout {
                id: basicConnectExample
                width: parent ? parent.width : 760
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    MosText {
                        text: qsTr("主机:")
                        Layout.preferredWidth: 50
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    MosInput {
                        id: hostInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        text: "127.0.0.1"
                        placeholderText: "127.0.0.1"
                        clearEnabled: true
                        colorBg: "transparent"
                        bgDelegate: MosRectangle {
                            color: "transparent"
                            border.color: MosTheme.Primary.colorSplit
                            border.width: 1
                            radius: 4
                        }
                        onTextChanged: MosMqttManager.host = text
                    }
                    MosText {
                        text: qsTr("端口:")
                        Layout.preferredWidth: 40
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    MosInputInteger {
                        id: portInput
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        value: 1883
                        min: 1
                        max: 65535
                        onValueModified: MosMqttManager.port = value
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    MosButton {
                        text: MosMqttManager.isConnected ? qsTr("断开连接") : qsTr("连接")
                        Layout.preferredWidth: 120
                        type: MosMqttManager.isConnected ? MosButton.Type_Default : MosButton.Type_Primary
                        onClicked: {
                            if (MosMqttManager.isConnected)
                                MosMqttManager.disconnectFromHost()
                            else
                                MosMqttManager.connectToHost()
                        }
                    }
                    MosCheckBox {
                        id: autoReconnectCheck
                        text: qsTr("自动重连")
                        checked: false
                        onToggled: MosMqttManager.autoReconnect = checked
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    MosText {
                        text: qsTr("状态:") + (MosMqttManager.isConnected ? qsTr(" 已连接") : qsTr(" 未连接"))
                        color: MosMqttManager.isConnected ? MosTheme.Primary.colorSuccessText
                                                          : MosTheme.Primary.colorTextSecondary
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                }

                MosText {
                    id: statusText
                    Layout.fillWidth: true
                    text: MosMqttManager.errorString
                    color: MosTheme.Primary.colorErrorText
                    visible: text.length > 0
                }

                Connections {
                    target: MosMqttManager
                    function onConnected() { statusText.text = qsTr("连接成功") }
                    function onDisconnected() { statusText.text = qsTr("已断开") }
                    function onErrorOccurred(msg) { statusText.text = msg }
                }
            }
        }

        // ========== 订阅与接收 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
订阅主题并接收消息。使用 \`subscribe()\` 订阅感兴趣的主题，监听 \`messageReceived\` 或 \`bytesReceived\` 处理入站消息。

重连后会自动恢复所有订阅（含原始 QoS），无需手动重新订阅。
                       `)
            code: `
// 订阅主题
MosMqttManager.subscribe("sensor/temperature", 1)
MosMqttManager.subscribe("sensor/+/status", 0)

// 取消订阅
MosMqttManager.unsubscribe("sensor/temperature")

// 查看当前订阅
console.log(MosMqttManager.subscriptions)

// 接收消息
Connections {
    target: MosMqttManager

    function onMessageReceived(topic, message) {
        console.log("[" + topic + "] " + message)
        // 处理文本消息
    }

    function onBytesReceived(topic, data) {
        // data 是 QByteArray，用于二进制协议
        console.log("[" + topic + "] bytes:", data.length)
    }
}
            `
            exampleDelegate: ColumnLayout {
                id: subscribeExample
                width: parent ? parent.width : 760
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    MosInput {
                        id: subscribeTopicInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        placeholderText: qsTr("输入主题，如 sensor/temperature")
                        clearEnabled: true
                        colorBg: "transparent"
                        bgDelegate: MosRectangle {
                            color: "transparent"
                            border.color: MosTheme.Primary.colorSplit
                            border.width: 1
                            radius: 4
                        }
                    }
                    MosSelect {
                        id: subscribeQosSelect
                        Layout.preferredWidth: 80
                        model: [
                            { value: 0, label: 'QoS 0' },
                            { value: 1, label: 'QoS 1' },
                            { value: 2, label: 'QoS 2' }
                        ]
                        currentIndex: 0
                    }
                    MosButton {
                        text: qsTr("订阅")
                        Layout.preferredWidth: 60
                        enabled: MosMqttManager.isConnected && subscribeTopicInput.text.trim().length > 0
                        onClicked: {
                            MosMqttManager.subscribe(subscribeTopicInput.text.trim(), subscribeQosSelect.currentValue)
                            subscribeTopicInput.clear()
                        }
                    }
                }

                MosText {
                    text: qsTr("当前订阅: ") + MosMqttManager.subscriptions.join(", ")
                    color: MosTheme.Primary.colorTextSecondary
                    Layout.fillWidth: true
                    visible: MosMqttManager.subscriptions.length > 0
                }

                MosText {
                    text: qsTr("无订阅")
                    color: MosTheme.Primary.colorTextSecondary
                    visible: MosMqttManager.subscriptions.length === 0
                }

                MosTextArea {
                    id: receiveArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    readOnly: true
                    autoSize: true
                    colorBg: "transparent"
                    colorBorder: MosTheme.Primary.colorSplit
                    placeholderText: qsTr("收到的消息将显示在这里")
                }

                MosButton {
                    text: qsTr("清空")
                    Layout.preferredWidth: 70
                    onClicked: receiveArea.clear()
                }

                Connections {
                    target: MosMqttManager
                    function onMessageReceived(topic, message) {
                        const time = new Date().toLocaleTimeString()
                        receiveArea.text += "[" + time + "] [" + topic + "] " + message + "\n"
                        receiveArea.scrollToEnd()
                    }
                }
            }
        }

        // ========== 发布消息 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
向指定主题发布消息。文本消息使用 \`publish()\`，二进制消息使用 \`publishBytes()\`。

返回值是消息 ID（>= 0 成功，-1 失败）。成功发送后 \`published(id)\` 信号会被触发。

空消息可以用来清除 retained 消息：向同一主题发布空 payload。
                       `)
            code: `
// 发布文本消息
const id = MosMqttManager.publish("device/command", "START", 1, false)
if (id < 0) {
    console.warn("Publish failed:", MosMqttManager.errorString)
}

// 发布二进制消息
const rawData = new Uint8Array([0x01, 0x02, 0x03])
MosMqttManager.publishBytes("device/binary", rawData, 0, false)

// 清除 retained 消息（发空消息）
MosMqttManager.publish("sensor/status", "", 0, true)

// 监听发布确认
Connections {
    target: MosMqttManager
    function onPublished(id) {
        console.log("Message", id, "confirmed")
    }
}
            `
            exampleDelegate: ColumnLayout {
                id: publishExample
                width: parent ? parent.width : 760
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    MosText {
                        text: qsTr("主题:")
                        Layout.preferredWidth: 40
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    MosInput {
                        id: publishTopicInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        placeholderText: qsTr("发布主题")
                        text: "mosui/test"
                        clearEnabled: true
                        colorBg: "transparent"
                        bgDelegate: MosRectangle {
                            color: "transparent"
                            border.color: MosTheme.Primary.colorSplit
                            border.width: 1
                            radius: 4
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    MosTextArea {
                        id: publishMessageInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        autoSize: true
                        colorBg: "transparent"
                        colorBorder: MosTheme.Primary.colorSplit
                        placeholderText: qsTr("消息内容")
                        text: "Hello MQTT!"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MosSelect {
                        id: publishQosSelect
                        Layout.preferredWidth: 90
                        model: [
                            { value: 0, label: 'QoS 0' },
                            { value: 1, label: 'QoS 1' },
                            { value: 2, label: 'QoS 2' }
                        ]
                        currentIndex: 0
                    }

                    MosCheckBox {
                        id: retainCheck
                        text: qsTr("Retain")
                    }

                    Item { Layout.fillWidth: true }

                    MosButton {
                        text: qsTr("发送")
                        Layout.preferredWidth: 80
                        type: MosButton.Type_Primary
                        enabled: MosMqttManager.isConnected && publishTopicInput.text.trim().length > 0
                        onClicked: {
                            const id = MosMqttManager.publish(
                                publishTopicInput.text.trim(),
                                publishMessageInput.text,
                                publishQosSelect.currentValue,
                                retainCheck.checked
                            )
                            publishResultText.text = id >= 0
                                ? qsTr("已发送 (id: ") + id + ")"
                                : qsTr("失败: ") + MosMqttManager.errorString
                        }
                    }
                }

                MosText {
                    id: publishResultText
                    Layout.fillWidth: true
                    color: MosTheme.Primary.colorTextSecondary
                }

                Connections {
                    target: MosMqttManager
                    function onPublished(id) {
                        publishResultText.text = qsTr("消息 ") + id + qsTr(" 已确认")
                    }
                }
            }
        }

        // ========== SSL/TLS 安全连接 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
启用 TLS/SSL 加密传输。设置 \`sslEnabled=true\` 后，\`connectToHost()\` 将通过加密通道连接 Broker（默认端口 8883）。

可以加载自定义 CA 证书，也可以关闭对等验证以使用自签名证书（仅开发环境推荐）。
                       `)
            code: `
// 启用 SSL
MosMqttManager.sslEnabled = true
MosMqttManager.port = 8883

// 加载 CA 证书（可选）
MosMqttManager.sslCaCertPath = "/path/to/ca.crt"

// 自签名证书（仅开发环境）
MosMqttManager.sslPeerVerify = false

// 连接
MosMqttManager.connectToHost()
            `
        }

        // ========== 遗愿消息 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
遗愿消息（Will Message）在客户端异常断开时由 Broker 自动发布到指定主题，用于通知其他设备本客户端离线。

在调用 \`connectToHost()\` 之前设置遗嘱属性，连接建立后立即生效。重连时自动恢复。
                       `)
            code: `
// 设置遗愿消息
MosMqttManager.willTopic = "device/status"
MosMqttManager.willMessage = "offline"
MosMqttManager.willQos = 1
MosMqttManager.willRetain = true

// 连接后 Broker 会监视此连接
MosMqttManager.connectToHost()

// 正常断开（不会触发遗愿）
MosMqttManager.disconnectFromHost()

// 异常断开（会触发遗愿）
// 例如：网络中断、进程崩溃、未调用 disconnectFromHost() 直接退出
            `
        }

        MosDescription {
            title: qsTr('使用建议')
            desc: qsTr(`
- 连接前先设置 \`host\`、\`port\`、认证和 SSL 属性，再调用 \`connectToHost()\`。已连接状态下修改属性不会自动重连。
- **空消息合法**：向某主题发布空 payload 是清除 retained 消息的标准方式。不要过滤空消息。
- **重连恢复订阅**：\`autoReconnect=true\` 时，意外断线会自动重连并恢复所有订阅（保留原始 QoS）。主动调用 \`disconnectFromHost()\` 会清除订阅，不会重连。
- **重连指数退避**：基础间隔通过 \`reconnectInterval\` 配置（默认 5s），实际等待 = \`min(reconnectInterval * 2^attempt, 60s)\`。连接成功后重置计数。
- 接收消息可监听 \`messageReceived\`（UTF-8 文本）或 \`bytesReceived\`（原始字节）。两者同时触发。
- \`published(id)\` 表示消息已确认发送，可用于实现可靠传输确认机制。
- **遗嘱消息**仅在非正常断开时发布。正常调用 \`disconnectFromHost()\` 不会触发。
- SSL 证书加载失败会通过 \`errorOccurred\` 信号报告详细错误（含文件路径），连接操作会中止。
- 所有异步操作带 5 秒超时保护，超时后会自动取消底层连接操作。
- C++ 后端可直接连接 \`MosMqttManager::instance()\` 的信号，无需从 QML 页面转发数据。
                       `)
        }
    }
}
