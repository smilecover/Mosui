pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import MosuiBasic 1.0

MosRectangle {
    id: mqttPage

    color: "transparent"

    property bool advancedExpanded: false
    property int publishQos: 0
    property bool publishRetain: false
    property int subscribeQos: 0

    readonly property bool compactLayout: mqttPage.width < 940
    readonly property int pageMargin: compactLayout ? 12 : 20
    readonly property color accentColor: MosTheme.Primary.colorPrimary
    readonly property color panelBg: MosTheme.Primary.colorFillQuaternary
    readonly property color panelBorder: MosTheme.Primary.colorSplit
    readonly property color textStrong: MosTheme.Primary.colorTextPrimary
    readonly property color textMuted: MosTheme.Primary.colorTextSecondary
    readonly property color textSubtle: MosTheme.Primary.colorTextTertiary
    readonly property var qosOptions: [
        { value: 0, label: "QoS 0" },
        { value: 1, label: "QoS 1" },
        { value: 2, label: "QoS 2" }
    ]

    function stateText() {
        switch (MosMqttManager.state) {
        case MosMqttManager.Connected:
            return "已连接"
        case MosMqttManager.Connecting:
            return "连接中"
        default:
            return "未连接"
        }
    }

    function stateColor() {
        switch (MosMqttManager.state) {
        case MosMqttManager.Connected:
            return MosTheme.Primary.colorSuccess
        case MosMqttManager.Connecting:
            return MosTheme.Primary.colorWarning
        default:
            return textSubtle
        }
    }

    function stateBackground() {
        switch (MosMqttManager.state) {
        case MosMqttManager.Connected:
            return MosTheme.Primary.colorSuccessBg
        case MosMqttManager.Connecting:
            return MosTheme.Primary.colorWarningBg
        default:
            return MosTheme.Primary.colorFillQuaternary
        }
    }

    function stateBorderColor() {
        switch (MosMqttManager.state) {
        case MosMqttManager.Connected:
            return MosTheme.Primary.colorSuccessBorder
        case MosMqttManager.Connecting:
            return MosTheme.Primary.colorWarningBorder
        default:
            return panelBorder
        }
    }

    function logAccent(kind) {
        switch (kind) {
        case "success":
            return MosTheme.Primary.colorSuccess
        case "error":
            return MosTheme.Primary.colorError
        case "receive":
            return MosTheme.Primary.colorInfo
        case "publish":
            return MosTheme.Primary.colorPrimary
        case "subscribe":
            return MosTheme.Primary.colorWarning
        default:
            return textSubtle
        }
    }

    function logLabel(kind) {
        switch (kind) {
        case "success":
            return "状态"
        case "error":
            return "错误"
        case "receive":
            return "接收"
        case "publish":
            return "发布"
        case "subscribe":
            return "订阅"
        default:
            return "系统"
        }
    }

    function appendLog(kind, title, detail) {
        const now = new Date()
        eventLogModel.append({
            kind: kind,
            timestamp: now.toLocaleTimeString(Qt.locale(), "HH:mm:ss"),
            title: String(title || ""),
            detail: String(detail || "")
        })

        while (eventLogModel.count > 300)
            eventLogModel.remove(0)

        Qt.callLater(function() {
            if (logList.count > 0)
                logList.positionViewAtEnd()
        })
    }

    function initializeManagerDefaults() {
        if (MosMqttManager.host.trim().length === 0)
            MosMqttManager.host = "127.0.0.1"
        if (MosMqttManager.port <= 0 || MosMqttManager.port > 65535)
            MosMqttManager.port = 1883
        if (MosMqttManager.clientId.trim().length === 0) {
            const suffix = Math.floor(Math.random() * 0xffffff).toString(16).padStart(6, "0")
            MosMqttManager.clientId = "mosui-tpinv-" + suffix
        }
        appendLog("system", "MQTT 控制台已就绪",
                  "配置 Broker 后即可订阅主题和发布消息")
    }

    function toggleConnection() {
        if (MosMqttManager.state === MosMqttManager.Disconnected) {
            let cid = MosMqttManager.clientId

            // 阿里云/华为云 IoT 平台格式（含签名参数），保持原样不修改
            // 因为密码签名依赖完整 ClientID，修改任何字符都会导致签名失效
            if (!/\|securemode=/.test(cid)) {
                // 普通 Broker：附加时间戳防止重复 ClientID
                cid = cid.replace(/-\d{13}$/, "") + "-" + Date.now()
                MosMqttManager.clientId = cid
            }

            MosMqttManager.connectToHost()
        } else {
            MosMqttManager.disconnectFromHost()
        }
    }

    function subscribeCurrentTopic() {
        const topic = subscribeTopicInput.text.trim()
        if (!MosMqttManager.isConnected || topic.length === 0)
            return

        MosMqttManager.subscribe(topic, subscribeQos)
        if (MosMqttManager.subscriptions.indexOf(topic) >= 0) {
            appendLog("subscribe", topic, "QoS " + subscribeQos)
            subscribeTopicInput.clear()
        }
    }

    function removeSubscription(topic) {
        MosMqttManager.unsubscribe(topic)
        if (MosMqttManager.subscriptions.indexOf(topic) < 0)
            appendLog("system", "已取消订阅", topic)
    }

    function publishCurrentMessage() {
        const topic = publishTopicInput.text.trim()
        if (!MosMqttManager.isConnected || topic.length === 0)
            return

        const messageId = MosMqttManager.publish(
                    topic,
                    publishPayloadInput.text,
                    publishQos,
                    publishRetain)
        if (messageId >= 0) {
            appendLog("publish", topic,
                      publishPayloadInput.text.length > 0
                      ? publishPayloadInput.text
                      : "<空消息>")
        }
    }

    function urlToFilePath(urlString) {
        if (urlString.startsWith("file:///"))
            return urlString.substring(8)
        if (urlString.startsWith("file://"))
            return urlString.substring(7)
        return urlString
    }

    Component.onCompleted: {
        // 确保 TpinvMqtt 单例已创建，持久化连接和 saveSettings 信号绑定已就绪
        TpinvMqtt.InitMqtt()
        initializeManagerDefaults()
    }

    Connections {
        target: MosMqttManager

        function onConnected() {
            mqttPage.appendLog(
                        "success",
                        "连接成功",
                        MosMqttManager.host + ":" + MosMqttManager.port)
        }

        function onDisconnected() {
            mqttPage.appendLog("system", "连接已断开", "")
        }

        function onErrorOccurred(message) {
            mqttPage.appendLog("error", "MQTT 操作失败", message)
        }

        function onMessageReceived(topic, message) {
            mqttPage.appendLog("receive", topic,
                               message.length > 0 ? message : "<空消息>")
        }

        function onPublished(id) {
            mqttPage.appendLog("success", "Broker 已确认消息", "消息 ID " + id)
        }
    }

    ListModel {
        id: eventLogModel
    }

    Component {
        id: inputBackground

        MosRectangle {
            color: "transparent"
            border.color: MosTheme.Primary.colorSplit
            border.width: 1
            radius: 10
        }
    }

    Flickable {
        id: pageFlick

        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        contentWidth: width
        contentHeight: contentLayout.implicitHeight + mqttPage.pageMargin * 2

        ScrollBar.vertical: MosScrollBar {
            anchors.right: parent.right
        }

        ColumnLayout {
            id: contentLayout

            x: mqttPage.pageMargin
            y: mqttPage.pageMargin
            width: pageFlick.width - mqttPage.pageMargin * 2
            spacing: 14

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: mqttPage.compactLayout ? 92 : 78
                color: mqttPage.panelBg
                border.color: mqttPage.panelBorder
                border.width: 1
                radius: 22

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 14

                    MosRectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        Layout.alignment: Qt.AlignVCenter
                        color: MosTheme.Primary.colorPrimaryBg
                        border.color: MosTheme.Primary.colorPrimaryBorder
                        border.width: 1
                        radius: 14

                        MosIconText {
                            anchors.centerIn: parent
                            iconSource: MosIcon.UniversalOutlined
                            iconSize: 23
                            color: mqttPage.accentColor
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        MosText {
                            Layout.fillWidth: true
                            text: "MQTT 控制台"
                            color: mqttPage.textStrong
                            font.pixelSize: 22
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "设备消息连接、主题订阅与指令发布"
                            color: mqttPage.textMuted
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }

                    ColumnLayout {
                        visible: !mqttPage.compactLayout
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        MosText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            text: "当前 Broker"
                            color: mqttPage.textSubtle
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        MosText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            text: MosMqttManager.host + ":" + MosMqttManager.port
                            color: mqttPage.textMuted
                            font.family: "Consolas"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }

                    MosRectangle {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 34
                        Layout.alignment: Qt.AlignVCenter
                        color: mqttPage.stateBackground()
                        border.color: mqttPage.stateBorderColor()
                        border.width: 1
                        radius: 17

                        Row {
                            id: statusRow

                            anchors.centerIn: parent
                            width: Math.min(implicitWidth, parent.width - 12)
                            spacing: 7
                            clip: true

                            MosRectangle {
                                width: 8
                                height: 8
                                anchors.verticalCenter: statusRow.verticalCenter
                                radius: 4
                                color: mqttPage.stateColor()

                                SequentialAnimation on opacity {
                                    running: MosMqttManager.state === MosMqttManager.Connecting
                                    loops: -1
                                    NumberAnimation { to: 0.35; duration: 500 }
                                    NumberAnimation { to: 1; duration: 500 }
                                }
                            }

                            MosText {
                                anchors.verticalCenter: statusRow.verticalCenter
                                text: mqttPage.stateText()
                                color: MosMqttManager.state === MosMqttManager.Connected
                                       ? MosTheme.Primary.colorSuccessText
                                       : MosMqttManager.state === MosMqttManager.Connecting
                                         ? MosTheme.Primary.colorWarningText
                                         : mqttPage.textMuted
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            MosRectangle {
                id: errorBanner

                Layout.fillWidth: true
                Layout.preferredHeight: errorBanner.visible ? 44 : 0
                visible: MosMqttManager.errorString.length > 0
                color: MosTheme.Primary.colorErrorBg
                border.color: MosTheme.Primary.colorErrorBorder
                border.width: 1
                radius: 12
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 8
                    spacing: 10

                    MosRectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        Layout.alignment: Qt.AlignVCenter
                        radius: 4
                        color: MosTheme.Primary.colorError
                    }

                    MosText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: MosMqttManager.errorString
                        color: MosTheme.Primary.colorErrorText
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    MosIconButton {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        type: MosButton.Type_Text
                        shape: MosButton.Shape_Circle
                        iconSource: MosIcon.CloseOutlined
                        iconSize: 13
                        contentDescription: "关闭错误提示"
                        onClicked: MosMqttManager.clearError()
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: mqttPage.compactLayout ? 1 : 3
                columnSpacing: 14
                rowSpacing: 14

                MosRectangle {
                    id: configPanel

                    Layout.fillWidth: true
                    Layout.fillHeight: !mqttPage.compactLayout
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: mqttPage.advancedExpanded ? 880 : 460
                    color: mqttPage.panelBg
                    border.color: mqttPage.panelBorder
                    border.width: 1
                    radius: 22
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            spacing: 10

                            MosRectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter
                                radius: 10
                                color: MosTheme.Primary.colorPrimaryBg

                                MosIconText {
                                    anchors.centerIn: parent
                                    iconSource: MosIcon.SettingsOutlined
                                    iconSize: 17
                                    color: mqttPage.accentColor
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 0

                                MosText {
                                    text: "连接配置"
                                    color: mqttPage.textStrong
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                MosText {
                                    text: "MQTT TCP Broker"
                                    color: mqttPage.textSubtle
                                    font.pixelSize: 11
                                }
                            }
                        }

                        MosDivider {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            Layout.topMargin: 12
                            Layout.bottomMargin: 14
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    MosText {
                                        text: "Broker 地址"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                    }

                                    MosInput {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        text: MosMqttManager.host
                                        placeholderText: "127.0.0.1"
                                        clearEnabled: true
                                        enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                        colorBg: "transparent"
                                        bgDelegate: inputBackground
                                        onTextEdited: MosMqttManager.host = text
                                    }
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 88
                                    spacing: 4

                                    MosText {
                                        text: "端口"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                    }

                                    MosInputInteger {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        value: MosMqttManager.port
                                        min: 1
                                        max: 65535
                                        step: 1
                                        showHandler: false
                                        enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                        colorBg: "transparent"
                                        radiusBg.all: 10
                                        onValueModified: MosMqttManager.port = value
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                MosText {
                                    text: "Client ID"
                                    color: mqttPage.textMuted
                                    font.pixelSize: 11
                                }

                                MosInput {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    text: MosMqttManager.clientId
                                    placeholderText: "MQTT 客户端标识"
                                    clearEnabled: true
                                    enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                    colorBg: "transparent"
                                    bgDelegate: inputBackground
                                    onTextEdited: MosMqttManager.clientId = text
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    MosText {
                                        text: "用户名"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                    }

                                    MosInput {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        text: MosMqttManager.username
                                        placeholderText: "可选"
                                        clearEnabled: true
                                        enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                        colorBg: "transparent"
                                        bgDelegate: inputBackground
                                        onTextEdited: MosMqttManager.username = text
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    MosText {
                                        text: "密码"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                    }

                                    MosInput {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        text: MosMqttManager.password
                                        echoMode: TextInput.Password
                                        placeholderText: "可选"
                                        clearEnabled: true
                                        enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                        colorBg: "transparent"
                                        bgDelegate: inputBackground
                                        onTextEdited: MosMqttManager.password = text
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                MosText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "自动重连"
                                    color: mqttPage.textMuted
                                    font.pixelSize: 12
                                }

                                MosSwitch {
                                    checked: MosMqttManager.autoReconnect
                                    enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                    checkedText: "开"
                                    uncheckedText: "关"
                                    onToggled: MosMqttManager.autoReconnect = checked
                                }
                            }

                            MosButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                type: MosButton.Type_Text
                                text: mqttPage.advancedExpanded ? "收起高级设置" : "展开高级设置"
                                colorText: mqttPage.accentColor
                                onClicked: mqttPage.advancedExpanded = !mqttPage.advancedExpanded
                            }

                            MosRectangle {
                                id: advancedPanel

                                Layout.fillWidth: true
                                Layout.preferredHeight: advancedPanel.visible
                                                        ? advancedContent.implicitHeight + 24
                                                        : 0
                                visible: mqttPage.advancedExpanded
                                color: "transparent"
                                border.color: mqttPage.panelBorder
                                border.width: 1
                                radius: 14
                                clip: true

                                ColumnLayout {
                                    id: advancedContent

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 12
                                    spacing: 9

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            MosText {
                                                text: "心跳（秒）"
                                                color: mqttPage.textMuted
                                                font.pixelSize: 11
                                            }

                                            MosInputInteger {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 34
                                                value: MosMqttManager.keepAlive
                                                min: 1
                                                max: 65535
                                                step: 5
                                                showHandler: false
                                                enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                                colorBg: "transparent"
                                                radiusBg.all: 10
                                                onValueModified: MosMqttManager.keepAlive = value
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            MosText {
                                                text: "重连间隔（ms）"
                                                color: mqttPage.textMuted
                                                font.pixelSize: 11
                                            }

                                            MosInputInteger {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 34
                                                value: MosMqttManager.reconnectInterval
                                                min: 1000
                                                max: 60000
                                                step: 1000
                                                showHandler: false
                                                enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                                colorBg: "transparent"
                                                radiusBg.all: 10
                                                onValueModified: MosMqttManager.reconnectInterval = value
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true

                                        MosText {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            text: "TLS 加密"
                                            color: mqttPage.textMuted
                                            font.pixelSize: 12
                                        }

                                        MosSwitch {
                                            checked: MosMqttManager.sslEnabled
                                            enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                            checkedText: "开"
                                            uncheckedText: "关"
                                            onToggled: MosMqttManager.sslEnabled = checked
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        visible: MosMqttManager.sslEnabled
                                        spacing: 4

                                        MosText {
                                            text: "CA 证书"
                                            color: mqttPage.textMuted
                                            font.pixelSize: 11
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            MosInput {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 34
                                                text: MosMqttManager.sslCaCertPath
                                                placeholderText: "可选，使用系统证书时留空"
                                                clearEnabled: true
                                                enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                                colorBg: "transparent"
                                                bgDelegate: inputBackground
                                                onTextEdited: MosMqttManager.sslCaCertPath = text
                                            }

                                            MosButton {
                                                Layout.preferredWidth: 38
                                                Layout.preferredHeight: 34
                                                text: "..."
                                                enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                                radiusBg.all: 10
                                                onClicked: sslCertFileDialog.open()
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        visible: MosMqttManager.sslEnabled

                                        MosText {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            text: "验证服务端证书"
                                            color: mqttPage.textMuted
                                            font.pixelSize: 12
                                        }

                                        MosSwitch {
                                            checked: MosMqttManager.sslPeerVerify
                                            enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                            checkedText: "是"
                                            uncheckedText: "否"
                                            onToggled: MosMqttManager.sslPeerVerify = checked
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        MosText {
                                            text: "遗嘱主题"
                                            color: mqttPage.textMuted
                                            font.pixelSize: 11
                                        }

                                        MosInput {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 34
                                            text: MosMqttManager.willTopic
                                            placeholderText: "例如 device/status"
                                            clearEnabled: true
                                            enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                            colorBg: "transparent"
                                            bgDelegate: inputBackground
                                            onTextEdited: MosMqttManager.willTopic = text
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        MosText {
                                            text: "遗嘱消息"
                                            color: mqttPage.textMuted
                                            font.pixelSize: 11
                                        }

                                        MosInput {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 34
                                            text: MosMqttManager.willMessage
                                            placeholderText: "例如 offline"
                                            clearEnabled: true
                                            enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                            colorBg: "transparent"
                                            bgDelegate: inputBackground
                                            onTextEdited: MosMqttManager.willMessage = text
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        MosSelect {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 34
                                            model: mqttPage.qosOptions
                                            currentIndex: MosMqttManager.willQos
                                            clearEnabled: false
                                            enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                            colorBg: "transparent"
                                            radiusBg.all: 10
                                            onActivated: MosMqttManager.willQos = currentValue
                                        }

                                        MosText {
                                            Layout.fillWidth: true
                                            text: "保留遗嘱消息"
                                            color: mqttPage.textMuted
                                            font.pixelSize: 12
                                        }

                                        MosSwitch {
                                            checked: MosMqttManager.willRetain
                                            enabled: MosMqttManager.state === MosMqttManager.Disconnected
                                            checkedText: "是"
                                            uncheckedText: "否"
                                            onToggled: MosMqttManager.willRetain = checked
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            MosIconButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                type: MosMqttManager.state === MosMqttManager.Disconnected
                                      ? MosButton.Type_Primary
                                      : MosButton.Type_Default
                                iconSource: MosMqttManager.state === MosMqttManager.Disconnected
                                            ? MosIcon.PlayCircleOutlined
                                            : MosIcon.CloseOutlined
                                iconSize: 15
                                loading: MosMqttManager.state === MosMqttManager.Connecting
                                text: MosMqttManager.state === MosMqttManager.Connected
                                      ? "断开连接"
                                      : MosMqttManager.state === MosMqttManager.Connecting
                                        ? "取消连接"
                                        : "连接 Broker"
                                enabled: MosMqttManager.state !== MosMqttManager.Disconnected
                                         || (MosMqttManager.host.trim().length > 0
                                             && MosMqttManager.port > 0)
                                radiusBg.all: 12
                                font.bold: true
                                onClicked: mqttPage.toggleConnection()
                            }

                            MosRectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                color: "transparent"
                                border.color: mqttPage.panelBorder
                                border.width: 1
                                radius: 12

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    MosRectangle {
                                        Layout.preferredWidth: 7
                                        Layout.preferredHeight: 7
                                        radius: 4
                                        color: mqttPage.stateColor()
                                    }

                                    MosText {
                                        Layout.fillWidth: true
                                        text: MosMqttManager.sslEnabled
                                              ? "TLS · " + MosMqttManager.host + ":" + MosMqttManager.port
                                              : "TCP · " + MosMqttManager.host + ":" + MosMqttManager.port
                                        color: mqttPage.textSubtle
                                        font.family: "Consolas"
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }

                MosRectangle {
                    id: subscribePanel

                    Layout.fillWidth: true
                    Layout.fillHeight: !mqttPage.compactLayout
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: mqttPage.advancedExpanded ? 880 : 460
                    color: mqttPage.panelBg
                    border.color: mqttPage.panelBorder
                    border.width: 1
                    radius: 22
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            spacing: 10

                            MosRectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter
                                radius: 10
                                color: MosTheme.Primary.colorInfoBg

                                MosIconText {
                                    anchors.centerIn: parent
                                    iconSource: MosIcon.CodeOutlined
                                    iconSize: 17
                                    color: MosTheme.Primary.colorInfo
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 0

                                MosText {
                                    text: "订阅主题"
                                    color: mqttPage.textStrong
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                MosText {
                                    text: "监听设备上行消息"
                                    color: mqttPage.textSubtle
                                    font.pixelSize: 11
                                }
                            }

                            MosTag {
                                Layout.alignment: Qt.AlignVCenter
                                text: String(MosMqttManager.subscriptions.length)
                                presetColor: "blue"
                                radiusBg.all: 10
                            }
                        }

                        MosDivider {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            Layout.topMargin: 12
                            Layout.bottomMargin: 14
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                MosText {
                                    text: "主题过滤器"
                                    color: mqttPage.textMuted
                                    font.pixelSize: 11
                                }

                                MosInput {
                                    id: subscribeTopicInput

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    placeholderText: "例如 inverter/+/telemetry"
                                    clearEnabled: true
                                    enabled: MosMqttManager.isConnected
                                    colorBg: "transparent"
                                    bgDelegate: inputBackground
                                    onAccepted: mqttPage.subscribeCurrentTopic()
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                MosSelect {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 36
                                    model: mqttPage.qosOptions
                                    currentIndex: mqttPage.subscribeQos
                                    clearEnabled: false
                                    enabled: MosMqttManager.isConnected
                                    colorBg: "transparent"
                                    radiusBg.all: 10
                                    onActivated: mqttPage.subscribeQos = currentValue
                                }

                                MosIconButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    type: MosButton.Type_Primary
                                    iconSource: MosIcon.PlayCircleOutlined
                                    iconSize: 14
                                    text: "订阅"
                                    enabled: MosMqttManager.isConnected
                                             && subscribeTopicInput.text.trim().length > 0
                                    radiusBg.all: 10
                                    onClicked: mqttPage.subscribeCurrentTopic()
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 2

                                MosText {
                                    Layout.fillWidth: true
                                    text: "当前订阅"
                                    color: mqttPage.textStrong
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                MosText {
                                    text: MosMqttManager.isConnected ? "实时同步" : "连接后可管理"
                                    color: MosMqttManager.isConnected
                                           ? MosTheme.Primary.colorSuccessText
                                           : mqttPage.textSubtle
                                    font.pixelSize: 11
                                }
                            }

                            MosRectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                border.color: mqttPage.panelBorder
                                border.width: 1
                                radius: 14
                                clip: true

                                ListView {
                                    id: subscriptionList

                                    anchors.fill: parent
                                    anchors.margins: 6
                                    boundsBehavior: Flickable.StopAtBounds
                                    clip: true
                                    model: MosMqttManager.subscriptions
                                    spacing: 4

                                    ScrollBar.vertical: MosScrollBar { }

                                    delegate: MosRectangle {
                                        id: subscriptionRow

                                        required property string modelData

                                        width: ListView.view.width
                                        height: 40
                                        color: rowHover.hovered
                                               ? MosTheme.Primary.colorFillQuaternary
                                               : "transparent"
                                        radius: 10

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 4
                                            spacing: 8

                                            MosRectangle {
                                                Layout.preferredWidth: 7
                                                Layout.preferredHeight: 7
                                                Layout.alignment: Qt.AlignVCenter
                                                radius: 4
                                                color: MosTheme.Primary.colorInfo
                                            }

                                            MosText {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                text: subscriptionRow.modelData
                                                color: mqttPage.textMuted
                                                font.family: "Consolas"
                                                font.pixelSize: 12
                                                elide: Text.ElideMiddle
                                            }

                                            MosButton {
                                                Layout.preferredWidth: 52
                                                Layout.preferredHeight: 30
                                                Layout.alignment: Qt.AlignVCenter
                                                type: MosButton.Type_Text
                                                text: "取消"
                                                colorText: MosTheme.Primary.colorErrorText
                                                enabled: MosMqttManager.isConnected
                                                onClicked: mqttPage.removeSubscription(
                                                               subscriptionRow.modelData)
                                            }
                                        }

                                        HoverHandler {
                                            id: rowHover
                                        }
                                    }

                                    MosText {
                                        anchors.centerIn: parent
                                        width: parent.width - 32
                                        visible: subscriptionList.count === 0
                                        text: MosMqttManager.isConnected
                                              ? "暂无订阅\n输入主题后开始监听"
                                              : "连接 Broker 后管理订阅"
                                        color: mqttPage.textSubtle
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        lineHeight: 1.4
                                    }
                                }
                            }

                            MosRectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                color: "transparent"
                                border.color: mqttPage.panelBorder
                                border.width: 1
                                radius: 12

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    MosText {
                                        Layout.fillWidth: true
                                        text: "支持通配符 + 与 #"
                                        color: mqttPage.textSubtle
                                        font.pixelSize: 11
                                    }

                                    MosText {
                                        text: MosMqttManager.subscriptions.length + " 个主题"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }

                MosRectangle {
                    id: publishPanel

                    Layout.fillWidth: true
                    Layout.fillHeight: !mqttPage.compactLayout
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: mqttPage.advancedExpanded ? 880 : 460
                    color: mqttPage.panelBg
                    border.color: mqttPage.panelBorder
                    border.width: 1
                    radius: 22
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            spacing: 10

                            MosRectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter
                                radius: 10
                                color: MosTheme.Primary.colorPrimaryBg

                                MosIconText {
                                    anchors.centerIn: parent
                                    iconSource: MosIcon.PlayCircleOutlined
                                    iconSize: 17
                                    color: mqttPage.accentColor
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 0

                                MosText {
                                    text: "发布消息"
                                    color: mqttPage.textStrong
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                MosText {
                                    text: "向设备下发控制指令"
                                    color: mqttPage.textSubtle
                                    font.pixelSize: 11
                                }
                            }

                            MosTag {
                                Layout.alignment: Qt.AlignVCenter
                                text: mqttPage.publishRetain ? "Retain" : "普通"
                                presetColor: mqttPage.publishRetain ? "orange" : "geekblue"
                                radiusBg.all: 10
                            }
                        }

                        MosDivider {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            Layout.topMargin: 12
                            Layout.bottomMargin: 14
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                MosText {
                                    text: "发布主题"
                                    color: mqttPage.textMuted
                                    font.pixelSize: 11
                                }

                                MosInput {
                                    id: publishTopicInput

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    text: "inverter/command"
                                    placeholderText: "例如 inverter/command"
                                    clearEnabled: true
                                    colorBg: "transparent"
                                    bgDelegate: inputBackground
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    MosText {
                                        text: "服务质量"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                    }

                                    MosSelect {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        model: mqttPage.qosOptions
                                        currentIndex: mqttPage.publishQos
                                        clearEnabled: false
                                        colorBg: "transparent"
                                        radiusBg.all: 10
                                        onActivated: mqttPage.publishQos = currentValue
                                    }
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 100
                                    spacing: 4

                                    MosText {
                                        text: "保留消息"
                                        color: mqttPage.textMuted
                                        font.pixelSize: 11
                                    }

                                    MosRectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        color: "transparent"
                                        border.color: mqttPage.panelBorder
                                        border.width: 1
                                        radius: 10

                                        MosSwitch {
                                            anchors.centerIn: parent
                                            checked: mqttPage.publishRetain
                                            checkedText: "是"
                                            uncheckedText: "否"
                                            onToggled: mqttPage.publishRetain = checked
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                MosText {
                                    Layout.fillWidth: true
                                    text: "消息载荷"
                                    color: mqttPage.textMuted
                                    font.pixelSize: 11
                                }

                                MosText {
                                    text: publishPayloadInput.length + " 字符"
                                    color: mqttPage.textSubtle
                                    font.pixelSize: 11
                                }
                            }

                            MosTextArea {
                                id: publishPayloadInput

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 130
                                text: "{\n  \"command\": \"start\"\n}"
                                placeholderText: "输入文本或 JSON 消息"
                                colorBg: "transparent"
                                colorBorder: mqttPage.panelBorder
                                radiusBg.all: 14
                                font.family: "Consolas"
                                font.pixelSize: 12
                            }

                            MosIconButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                type: MosButton.Type_Primary
                                iconSource: MosIcon.PlayCircleOutlined
                                iconSize: 15
                                text: MosMqttManager.isConnected ? "发布消息" : "连接后可发布"
                                enabled: MosMqttManager.isConnected
                                         && publishTopicInput.text.trim().length > 0
                                radiusBg.all: 12
                                font.bold: true
                                onClicked: mqttPage.publishCurrentMessage()
                            }

                            MosRectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                color: "transparent"
                                border.color: mqttPage.panelBorder
                                border.width: 1
                                radius: 12

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    MosText {
                                        Layout.fillWidth: true
                                        text: "空载荷 + Retain 可清除保留消息"
                                        color: mqttPage.textSubtle
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                color: mqttPage.panelBg
                border.color: mqttPage.panelBorder
                border.width: 1
                radius: 22
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        Layout.leftMargin: 18
                        Layout.rightMargin: 12
                        spacing: 10

                        MosIconText {
                            Layout.alignment: Qt.AlignVCenter
                            iconSource: MosIcon.CodeOutlined
                            iconSize: 17
                            color: mqttPage.accentColor
                        }

                        MosText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: "消息与事件日志"
                            color: mqttPage.textStrong
                            font.pixelSize: 15
                            font.bold: true
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            text: eventLogModel.count + " 条"
                            presetColor: "geekblue"
                            radiusBg.all: 10
                        }

                        MosButton {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignVCenter
                            type: MosButton.Type_Text
                            text: "清空"
                            colorText: MosTheme.Primary.colorErrorText
                            enabled: eventLogModel.count > 0
                            onClicked: eventLogModel.clear()
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }

                    ListView {
                        id: logList

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.topMargin: 6
                        Layout.bottomMargin: 8
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true
                        model: eventLogModel
                        spacing: 3

                        ScrollBar.vertical: MosScrollBar { }

                        delegate: MosRectangle {
                            id: logRow

                            required property string kind
                            required property string timestamp
                            required property string title
                            required property string detail

                            width: ListView.view.width
                            height: 34
                            color: logHover.hovered
                                   ? MosTheme.Primary.colorFillQuaternary
                                   : "transparent"
                            radius: 9

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 9

                                MosRectangle {
                                    Layout.preferredWidth: 3
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 2
                                    color: mqttPage.logAccent(logRow.kind)
                                }

                                MosText {
                                    Layout.preferredWidth: 48
                                    Layout.alignment: Qt.AlignVCenter
                                    text: logRow.timestamp
                                    color: mqttPage.textSubtle
                                    font.family: "Consolas"
                                    font.pixelSize: 10
                                }

                                MosTag {
                                    Layout.preferredWidth: 44
                                    Layout.alignment: Qt.AlignVCenter
                                    text: mqttPage.logLabel(logRow.kind)
                                    colorBg: "transparent"
                                    colorBorder: mqttPage.logAccent(logRow.kind)
                                    colorText: mqttPage.logAccent(logRow.kind)
                                    radiusBg.all: 9
                                }

                                MosText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: logRow.detail.length > 0
                                          ? logRow.title + "  ·  " + logRow.detail
                                          : logRow.title
                                    color: mqttPage.textMuted
                                    font.family: logRow.kind === "receive"
                                                 || logRow.kind === "publish"
                                                 ? "Consolas"
                                                 : Qt.application.font.family
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }

                            HoverHandler {
                                id: logHover
                            }
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: sslCertFileDialog

        title: "选择 CA 证书"
        fileMode: FileDialog.OpenFile
        nameFilters: [
            "证书文件 (*.crt *.pem *.cer *.der)",
            "所有文件 (*)"
        ]
        onAccepted: {
            MosMqttManager.sslCaCertPath = mqttPage.urlToFilePath(
                        selectedFile.toString())
        }
    }
}
