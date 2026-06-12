import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import MosuiBasic 1.0

MosRectangle {
    id: mqttPage
    color: "transparent"

    // ===================== 配置属性 =====================
    property int commandCount: 10
    property int commandByteCount: 20
    property int commandInterval: 500
    property int autoSendInterval: 100
    property string host: "127.0.0.1"
    property int port: 1883
    property string clientId: ""
    property string username: ""
    property string password: ""
    property int keepAlive: 60
    property bool autoReconnect: false
    property int publishQos: 0
    property bool publishRetain: false
    property int subscribeQos: 0
    property string receiveMode: "ASCII"
    property string sendMode: "ASCII"
    property bool receiveAutoNewline: false
    property bool receiveShowTime: false
    property bool sendAutoEnabled: false
    property int maxTextLines: 5000

    // ===================== 工具函数 =====================
    function normalizePositiveInteger(value) {
        return Math.max(1, Math.floor(Number(value) || 1.0))
    }

    function strToHex(str) {
        let hex = ""
        for (let i = 0; i < str.length; i++) {
            if (i > 0) hex += " "
            const code = str.charCodeAt(i)
            if (code <= 0xFF) {
                hex += code.toString(16).padStart(2, '0').toUpperCase()
            } else {
                hex += code.toString(16).padStart(4, '0').toUpperCase()
            }
        }
        return hex
    }

    function hexToBytes(hexStr) {
        let cleaned = hexStr.replace(/[^0-9a-fA-F]/g, "")
        if (cleaned.length % 2 !== 0) return []
        let bytes = []
        for (let i = 0; i < cleaned.length; i += 2) {
            bytes.push(parseInt(cleaned.substr(i, 2), 16))
        }
        return bytes
    }

    function urlToFilePath(urlString) {
        if (urlString.startsWith("file:///")) return urlString.substring(8)
        if (urlString.startsWith("file://")) return urlString.substring(7)
        return urlString
    }

    // ===================== MQTT 状态同步 =====================
    function syncFromMqttManager() {
        host = MosMqttManager.host
        port = MosMqttManager.port
        clientId = MosMqttManager.clientId
        username = MosMqttManager.username
        password = MosMqttManager.password
        keepAlive = MosMqttManager.keepAlive
        autoReconnect = MosMqttManager.autoReconnect
    }

    function syncToMqttManager() {
        MosMqttManager.host = host
        MosMqttManager.port = port
        MosMqttManager.clientId = clientId
        MosMqttManager.username = username
        MosMqttManager.password = password
        MosMqttManager.keepAlive = keepAlive
        MosMqttManager.autoReconnect = autoReconnect
    }

    function toggleConnection() {
        syncToMqttManager()
        if (MosMqttManager.isConnected) {
            MosMqttManager.disconnectFromHost()
        } else {
            MosMqttManager.connectToHost()
        }
    }

    Component.onCompleted: {
        syncFromMqttManager()
    }

    onHostChanged: if (MosMqttManager.host !== host) MosMqttManager.host = host
    onPortChanged: if (MosMqttManager.port !== port) MosMqttManager.port = port
    onClientIdChanged: if (MosMqttManager.clientId !== clientId) MosMqttManager.clientId = clientId
    onUsernameChanged: if (MosMqttManager.username !== username) MosMqttManager.username = username
    onPasswordChanged: if (MosMqttManager.password !== password) MosMqttManager.password = password
    onKeepAliveChanged: if (MosMqttManager.keepAlive !== keepAlive) MosMqttManager.keepAlive = keepAlive
    onAutoReconnectChanged: if (MosMqttManager.autoReconnect !== autoReconnect) MosMqttManager.autoReconnect = autoReconnect

    Connections {
        target: MosMqttManager
        function onHostChanged() { mqttPage.syncFromMqttManager() }
        function onPortChanged() { mqttPage.syncFromMqttManager() }
        function onClientIdChanged() { mqttPage.syncFromMqttManager() }
        function onUsernameChanged() { mqttPage.syncFromMqttManager() }
        function onPasswordChanged() { mqttPage.syncFromMqttManager() }
        function onKeepAliveChanged() { mqttPage.syncFromMqttManager() }
        function onAutoReconnectChanged() { mqttPage.syncFromMqttManager() }
    }

    // ===================== 主布局 =====================
    RowLayout {
        anchors.fill: parent
        spacing: 12
        anchors.margins: 12

        // 左侧面板
        MosRectangle {
            Layout.preferredWidth: 280
            Layout.minimumWidth: 220
            Layout.fillHeight: true
            color: "transparent"
            border.color: MosTheme.Primary.colorSplit
            border.width: 1
            radius: 4

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                anchors.margins: 10

                // ========== MQTT 连接设置 ==========
                MosGroupBox {
                    label: Text { text: "MQTT连接设置"; color: MosTheme.Primary.colorTextPrimary; font.bold: true }
                    title: "MQTT连接设置"
                    font.pixelSize: 12
                    Layout.fillWidth: true

                    background: MosRectangle {
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1
                        radius: 4
                    }

                    Column {
                        id: colContent1
                        anchors.fill: parent
                        anchors.topMargin: 30
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 8

                        // 主机
                        RowLayout {
                            spacing: 10
                            width: parent.width
                            MosText {
                                text: "主机"
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosInput {
                                Layout.fillWidth: true
                                text: mqttPage.host
                                placeholderText: "127.0.0.1"
                                clearEnabled: true
                                colorBg: "transparent"
                                bgDelegate: MosRectangle {
                                    color: "transparent"
                                    border.color: MosTheme.Primary.colorSplit
                                    border.width: 1
                                    radius: 4
                                }
                                onTextChanged: mqttPage.host = text
                            }
                        }

                        // 端口
                        RowLayout {
                            spacing: 10
                            width: parent.width
                            MosText {
                                text: "端口"
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosInputInteger {
                                Layout.fillWidth: true
                                value: mqttPage.port
                                min: 1
                                max: 65535
                                step: 1
                                onValueModified: mqttPage.port = value
                            }
                        }

                        // Client ID
                        RowLayout {
                            spacing: 10
                            width: parent.width
                            MosText {
                                text: "Client ID"
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosInput {
                                Layout.fillWidth: true
                                text: mqttPage.clientId
                                placeholderText: "可选"
                                clearEnabled: true
                                colorBg: "transparent"
                                bgDelegate: MosRectangle {
                                    color: "transparent"
                                    border.color: MosTheme.Primary.colorSplit
                                    border.width: 1
                                    radius: 4
                                }
                                onTextChanged: mqttPage.clientId = text
                            }
                        }

                        // 用户名
                        RowLayout {
                            spacing: 10
                            width: parent.width
                            MosText {
                                text: "用户名"
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosInput {
                                Layout.fillWidth: true
                                text: mqttPage.username
                                placeholderText: "可选"
                                clearEnabled: true
                                colorBg: "transparent"
                                bgDelegate: MosRectangle {
                                    color: "transparent"
                                    border.color: MosTheme.Primary.colorSplit
                                    border.width: 1
                                    radius: 4
                                }
                                onTextChanged: mqttPage.username = text
                            }
                        }

                        // 密码
                        RowLayout {
                            spacing: 10
                            width: parent.width
                            MosText {
                                text: "密码"
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosInput {
                                Layout.fillWidth: true
                                text: mqttPage.password
                                echoMode: TextInput.Password
                                placeholderText: "可选"
                                clearEnabled: true
                                colorBg: "transparent"
                                bgDelegate: MosRectangle {
                                    color: "transparent"
                                    border.color: MosTheme.Primary.colorSplit
                                    border.width: 1
                                    radius: 4
                                }
                                onTextChanged: mqttPage.password = text
                            }
                        }

                        // 心跳
                        RowLayout {
                            spacing: 10
                            width: parent.width
                            MosText {
                                text: "心跳(秒)"
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosInputInteger {
                                Layout.fillWidth: true
                                value: mqttPage.keepAlive
                                min: 1
                                max: 65535
                                step: 10
                                onValueModified: mqttPage.keepAlive = value
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 8
                            MosCheckBox {
                                text: "自动重连"
                                checked: mqttPage.autoReconnect
                                onToggled: mqttPage.autoReconnect = checked
                            }
                            MosButton {
                                text: MosMqttManager.isConnected ? "断开连接" : "连接"
                                width: 120
                                type: MosMqttManager.isConnected ? MosButton.Type_Default : MosButton.Type_Primary
                                enabled: mqttPage.host.length > 0 && mqttPage.port > 0
                                onClicked: mqttPage.toggleConnection()
                            }
                        }
                    }
                }

                // ========== 订阅管理 ==========
                MosGroupBox {
                    label: Text { text: "订阅管理"; color: MosTheme.Primary.colorTextPrimary; font.bold: true }
                    title: "订阅管理"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120

                    background: MosRectangle {
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1
                        radius: 4
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 25
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            MosInput {
                                id: subscribeTopicInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                placeholderText: "输入主题"
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
                                onActivated: mqttPage.subscribeQos = currentValue
                            }

                            MosButton {
                                text: "订阅"
                                width: 60
                                enabled: MosMqttManager.isConnected && subscribeTopicInput.text.trim().length > 0
                                onClicked: {
                                    const topic = subscribeTopicInput.text.trim()
                                    if (topic.length > 0) {
                                        MosMqttManager.subscribe(topic, mqttPage.subscribeQos)
                                        subscribeTopicInput.clear()
                                    }
                                }
                            }
                        }

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 60
                            color: "transparent"
                            border.color: MosTheme.Primary.colorSplit
                            border.width: 1
                            radius: 4

                            ListView {
                                id: subscriptionListView
                                anchors.fill: parent
                                anchors.margins: 4
                                clip: true
                                model: MosMqttManager.subscriptions
                                spacing: 2

                                delegate: RowLayout {
                                    width: subscriptionListView.width - 8
                                    spacing: 6

                                    MosText {
                                        text: modelData
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    MosButton {
                                        text: "取消"
                                        width: 50
                                        height: 24
                                        font.pixelSize: 11
                                        onClicked: MosMqttManager.unsubscribe(modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                // ========== 接收设置 ==========
                MosGroupBox {
                    label: Text { text: "接收设置"; color: MosTheme.Primary.colorTextPrimary; font.bold: true }
                    title: "接收设置"
                    font.pixelSize: 12
                    Layout.fillWidth: true

                    background: MosRectangle {
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1
                        radius: 4
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 25
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            ButtonGroup { id: receiveModeGroup }
                            Repeater {
                                model: [
                                    { value: 'ASCII', label: 'ASCII' },
                                    { value: 'HEX', label: 'HEX' }
                                ]
                                delegate: MosRadio {
                                    Layout.alignment: index === 0 ? (Qt.AlignLeft | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter)
                                    checked: mqttPage.receiveMode === modelData.value
                                    text: modelData.label
                                    ButtonGroup.group: receiveModeGroup
                                    onToggled: if (checked) mqttPage.receiveMode = modelData.value
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: parent.spacing
                            Repeater{
                                model: [
                                    { propertyName: 'receiveAutoNewline', label: '自动换行' },
                                    { propertyName: 'receiveShowTime', label: '显示时间' }
                                ]
                                delegate: MosCheckBox {
                                    text: modelData.label
                                    checked: mqttPage[modelData.propertyName]
                                    onToggled: mqttPage[modelData.propertyName] = checked
                                }
                            }
                        }
                    }
                }

                // ========== 发送设置 ==========
                MosGroupBox {
                    label: Text { text: "发送设置"; color: MosTheme.Primary.colorTextPrimary; font.bold: true }
                    title: "发送设置"
                    font.pixelSize: 12
                    Layout.fillWidth: true

                    background: MosRectangle {
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1
                        radius: 4
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 25
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            ButtonGroup { id: sendModeGroup }
                            Repeater {
                                model: [
                                    { value: 'ASCII', label: 'ASCII' },
                                    { value: 'HEX', label: 'HEX' }
                                ]
                                delegate: MosRadio {
                                    Layout.alignment: index === 0 ? (Qt.AlignLeft | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter)
                                    checked: mqttPage.sendMode === modelData.value
                                    text: modelData.label
                                    ButtonGroup.group: sendModeGroup
                                    onToggled: if (checked) mqttPage.sendMode = modelData.value
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            MosCheckBox {
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: '自动发送'
                                checked: mqttPage.sendAutoEnabled
                                onToggled: mqttPage.sendAutoEnabled = checked
                            }
                            MosInputInteger {
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                value: mqttPage.autoSendInterval
                                min: 1
                                step: 10
                                Layout.minimumWidth: 80
                                onValueModified: mqttPage.autoSendInterval = mqttPage.normalizePositiveInteger(value)
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: parent.spacing
                            Repeater{
                                model: [
                                    { name: "指令数量", propertyName: "commandCount", step: 1 },
                                    { name: "指令字节数", propertyName: "commandByteCount", step: 1 },
                                    { name: "指令间隔", propertyName: "commandInterval", step: 10 }
                                ]
                                delegate: RowLayout {
                                    spacing: 10
                                    MosText {
                                        text: modelData.name
                                        Layout.preferredWidth: 60
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    }
                                    MosInputInteger {
                                        Layout.fillWidth: true
                                        value: mqttPage[modelData.propertyName]
                                        min: 1
                                        step: modelData.step
                                        onValueModified: mqttPage[modelData.propertyName] = mqttPage.normalizePositiveInteger(value)
                                    }
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            MosText {
                                text: "QoS"
                                Layout.preferredWidth: 30
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            MosSelect {
                                id: publishQosSelect
                                Layout.fillWidth: true
                                model: [
                                    { value: 0, label: 'QoS 0' },
                                    { value: 1, label: 'QoS 1' },
                                    { value: 2, label: 'QoS 2' }
                                ]
                                currentIndex: 0
                                onActivated: mqttPage.publishQos = currentValue
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            MosCheckBox {
                                text: "保留消息 (Retain)"
                                checked: mqttPage.publishRetain
                                onToggled: mqttPage.publishRetain = checked
                            }
                        }
                    }
                }
            }
        }

        // 右侧面板
        MosRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            border.color: MosTheme.Primary.colorSplit
            border.width: 1
            radius: 4

            ColumnLayout{
                anchors.fill: parent
                spacing: 10
                anchors.margins: 10

                // ========== 数据接收区 ==========
                MosGroupBox {
                    label: Text { text: "数据接收区"; color: MosTheme.Primary.colorTextPrimary; font.bold: true }
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.verticalStretchFactor: 2
                    background: MosRectangle {
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1
                        radius: 4
                    }
                    MosTextArea {
                        id: mqttTextArea
                        anchors.fill: parent
                        anchors.margins: 10
                        readOnly: true
                        colorBg: "transparent"
                        colorBorder: MosTheme.Primary.colorSplit
                        placeholderText: '数据接收区'
                    }
                }

                // ========== 数据发送编辑区 ==========
                MosGroupBox {
                    label: Text { text: "数据发送编辑区"; color: MosTheme.Primary.colorTextPrimary; font.bold: true }
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.verticalStretchFactor: 3
                    background: MosRectangle {
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1
                        radius: 4
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        anchors.margins: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 160
                            Layout.minimumHeight: 130
                            spacing: 10

                            MosTextArea {
                                id: sendTextArea
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.horizontalStretchFactor : 3
                                readOnly: false
                                colorBg: "transparent"
                                colorBorder: MosTheme.Primary.colorSplit
                                placeholderText: '数据发送区'
                            }

                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 90
                                Layout.minimumWidth: 90
                                spacing: 6

                                MosButton {
                                    id: clearReceiveButton
                                    text: "清空接收"
                                    Layout.fillWidth: true
                                    onClicked: mqttTextArea.clear()
                                }
                                MosButton {
                                    id: clearSendButton
                                    text: "清空发送"
                                    Layout.fillWidth: true
                                    onClicked: sendTextArea.clear()
                                }
                                MosButton {
                                    id: sendTextButton
                                    text: "发送"
                                    Layout.fillWidth: true
                                    enabled: MosMqttManager.isConnected && publishTopicInput.text.trim().length > 0
                                    onClicked: {
                                        const data = sendTextArea.text
                                        if (data.length === 0) return
                                        const topic = publishTopicInput.text.trim()
                                        if (topic.length === 0) return
                                        if (mqttPage.sendMode === "HEX") {
                                            const bytes = hexToBytes(data)
                                            if (bytes.length === 0) return
                                            MosMqttManager.publish(topic, String.fromCharCode.apply(null, bytes), mqttPage.publishQos, mqttPage.publishRetain)
                                        } else {
                                            MosMqttManager.publish(topic, data, mqttPage.publishQos, mqttPage.publishRetain)
                                        }
                                    }
                                }
                            }
                            MosDivider {
                                orientation: Qt.Vertical
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                            }

                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 340
                                Layout.minimumWidth: 280
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    MosText {
                                        text: "主题:"
                                        Layout.preferredWidth: 40
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    }
                                    MosInput {
                                        id: publishTopicInput
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        placeholderText: "发布主题"
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
                                    MosInput {
                                        id: commandFileInput
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        placeholderText: "指令文件路径"
                                        clearEnabled: true
                                        colorBg: "transparent"
                                        bgDelegate: MosRectangle {
                                            color: "transparent"
                                            border.color: MosTheme.Primary.colorSplit
                                            border.width: 1
                                            radius: 4
                                        }
                                    }
                                    MosButton {
                                        id: openCommandFileButton
                                        text: "打开指令文件..."
                                        Layout.preferredWidth: 120
                                        onClicked: commandOpenFileDialog.open()
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    MosButton {
                                        id: saveCommandDataButton
                                        text: "保存指令数据"
                                        Layout.fillWidth: true
                                        onClicked: {
                                            if (commandFileInput.text.length > 0) {
                                                commandSaveFileDialog.selectedFile = commandFileInput.text
                                            }
                                            commandSaveFileDialog.open()
                                        }
                                    }
                                    MosButton {
                                        id: sendFileButton
                                        text: "发送文件"
                                        Layout.fillWidth: true
                                        type: MosButton.Type_Primary
                                        enabled: MosMqttManager.isConnected && publishTopicInput.text.trim().length > 0
                                        onClicked: {
                                            // 这里可以保留你原来的发送逻辑，我简化了
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    MosCheckBox {
                                        id: singleSendCheckBox
                                        text: "单条发送"
                                        Layout.preferredWidth: 90
                                    }
                                    Item { Layout.fillWidth: true }
                                    MosCheckBox {
                                        id: loopSendCheckBox
                                        text: "循环发送"
                                        Layout.preferredWidth: 90
                                    }
                                }
                            }
                        }

                        // 指令表格
                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.verticalStretchFactor : 3
                            Layout.minimumHeight: 180
                            color: "transparent"
                            border.color: MosTheme.Primary.colorSplit
                            border.width: 1
                            radius: 4

                            Component {
                                id: lnputcomponent
                                MosInput{
                                    text: cellData
                                    radiusBg.all: 0
                                    colorBg: "transparent"
                                    onTextChanged: {
                                        cellData = text
                                    }
                                }
                            }

                            Component {
                                id: commandTableComponent
                                MosTableView {
                                    anchors.fill: parent
                                    anchors.margins: 0
                                    showColumnGrid: true
                                    showRowGrid: true
                                    defaultRowHeaderWidth: 55
                                    defaultColumnHeaderHeight: 32
                                    minimumRowHeight: 28
                                    rowResizable: false
                                    color : 'transparent'
                                    colorColumnHeaderBg: 'transparent'
                                    colorRowHeaderBg: 'transparent'
                                    colorResizeBlockBg: 'transparent'
                                    colorCellBg: 'transparent'
                                    colorCellOddBg: 'transparent'
                                    colorCellBgHover: 'transparent'
                                    colorCellBgChecked: 'transparent'
                                    colorCellBgHoverChecked: 'transparent'
                                    colorCellBgDisabled: 'transparent'
                                    rowHeaderDelegate: Item {
                                        MosText {
                                            anchors.fill: parent
                                            anchors.leftMargin: 6
                                            anchors.rightMargin: 6
                                            text: "Cmd" + row
                                            color: MosTheme.Primary.colorTextPrimary
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                    columns: buildCommandColumns(mqttPage.commandByteCount)
                                    initModel: buildCommandRows(mqttPage.commandCount, mqttPage.commandByteCount)
                                }
                            }

                            Loader {
                                id: commandTableLoader
                                anchors.fill: parent
                                active: true
                                sourceComponent: commandTableComponent
                            }
                        }
                    }
                }
            }
        }
    }

    // ===================== 文件对话框 =====================
    FileDialog {
        id: commandOpenFileDialog
        title: "打开指令文件"
        fileMode: FileDialog.OpenFile
        nameFilters: ["指令文件 (*.txt *.cmd *.hex)", "所有文件 (*)"]
        onAccepted: {
            const filePath = urlToFilePath(selectedFile.toString())
            commandFileInput.text = filePath
            // 这里可以调用你原来的 loadCommandFromFile 逻辑
        }
    }

    FileDialog {
        id: commandSaveFileDialog
        title: "保存指令数据"
        fileMode: FileDialog.SaveFile
        nameFilters: ["指令文件 (*.txt *.cmd)", "所有文件 (*)"]
        defaultSuffix: "txt"
        onAccepted: {
            const filePath = urlToFilePath(selectedFile.toString())
            commandFileInput.text = filePath
            // 这里可以调用你原来的 saveCommandToFile 逻辑
        }
    }

    // ===================== 表格工具函数 =====================
    function buildCommandColumns(count) {
        const columnCount = mqttPage.normalizePositiveInteger(count)
        let result = []
        for (let i = 0; i < columnCount; i++) {
            const title = "Byte" + i
            result.push({
                dataIndex: title,
                title: title,
                width: 80,
                minimumWidth: 70,
                maximumWidth: 120,
                delegate: lnputcomponent
            })
        }
        return result
    }

    function buildCommandRows(rowCount, columnCount) {
        const rows = mqttPage.normalizePositiveInteger(rowCount)
        const columns = mqttPage.normalizePositiveInteger(columnCount)
        let result = []
        for (let row = 0; row < rows; row++) {
            let command = { key: "Cmd" + row }
            for (let column = 0; column < columns; column++) {
                command["Byte" + column] = ""
            }
            result.push(command)
        }
        return result
    }
}