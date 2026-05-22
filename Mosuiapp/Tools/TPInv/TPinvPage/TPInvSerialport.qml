import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle{
    id: serialportPage
    color: "transparent"

    property int commandCount: 10
    property int commandByteCount: 20
    property int commandInterval: 500
    property int autoSendInterval: 100
    property var portOptions: []
    property string selectedPortName: ""
    property int selectedBaudRate: 9600
    property int selectedDataBits: 8
    property string selectedParity: "none"
    property string selectedStopBits: "1"
    property string selectedFlowControl: "none"
    property string receiveMode: "ASCII"
    property string sendMode: "ASCII"
    property bool receiveAutoNewline: false
    property bool receiveShowTime: false
    property bool sendAutoEnabled: false

    function normalizePositiveInteger(value) {
        return Math.max(1, Math.floor(Number(value) || 1))
    }

    function refreshSerialPorts() {
        portOptions = MosSerialPortManager.refreshPorts()
        let hasSelectedPort = false
        for (let i = 0; i < portOptions.length; i++) {
            if (portOptions[i].value === selectedPortName) {
                hasSelectedPort = true
                break
            }
        }
        if (portOptions.length > 0 && !hasSelectedPort) {
            selectedPortName = portOptions[0].value
        } else if (portOptions.length === 0) {
            selectedPortName = ""
        }
    }

    function openSerialPort() {
        return MosSerialPortManager.openPort(
                    selectedPortName,
                    selectedBaudRate,
                    selectedDataBits,
                    selectedParity,
                    selectedStopBits,
                    selectedFlowControl)
    }

    function toggleSerialPort() {
        if (MosSerialPortManager.isOpen) {
            MosSerialPortManager.closePort()
            return true
        }
        return openSerialPort()
    }

    Component.onCompleted: refreshSerialPorts()

    property Component leftItemcontrols: Item{
        id : leftItem
        MosRectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: MosTheme.Primary.colorSplit
            border.width: 1
        }

        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            anchors.margins: 0
            MosGroupBox {
                label: Text { text: "串口设置"; color: MosTheme.Primary.colorTextPrimary }
                title: "串口设置"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: colContent1.implicitHeight + 30

                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }

                Column {
                    id: colContent1
                    anchors.topMargin: 50
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 5
                    anchors.margins: 0
                    Repeater {
                        model: [
                            {
                                name: "端口",
                                propertyName: "selectedPortName",
                                modelSelect: serialportPage.portOptions
                            },
                            {
                                name: "波特率",
                                propertyName: "selectedBaudRate",
                                modelSelect: [
                                    { value: 9600, label: '9600' },
                                    { value: 19200, label: '19200' },
                                    { value: 38400, label: '38400' },
                                    { value: 57600, label: '57600' },
                                    { value: 115200, label: '115200' }
                                ]
                            },
                            {
                                name: "数据位",
                                propertyName: "selectedDataBits",
                                modelSelect: [
                                    { value: 8, label: '8' },
                                    { value: 7, label: '7' },
                                    { value: 6, label: '6' },
                                    { value: 5, label: '5' }
                                ]
                            },
                            {
                                name: "校验位",
                                propertyName: "selectedParity",
                                modelSelect: [
                                    { value: 'none', label: '无' },
                                    { value: 'even', label: '偶' },
                                    { value: 'odd', label: '奇' }
                                ]
                            },
                            {
                                name: "停止位",
                                propertyName: "selectedStopBits",
                                modelSelect: [
                                    { value: '1', label: '1' },
                                    { value: '1.5', label: '1.5' },
                                    { value: '2', label: '2' }
                                ]
                            },
                            {
                                name: "流控",
                                propertyName: "selectedFlowControl",
                                modelSelect: [
                                    { value: 'none', label: '无' },
                                    { value: 'hardware', label: '硬件' },
                                    { value: 'software', label: '软件' }
                                ]
                            }

                        ]

                        delegate: RowLayout {
                            spacing: 10
                            width: parent.width

                            MosText {
                                text: modelData.name
                                Layout.topMargin: index === 0 ? 20 : 0
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }

                            MosSelect {
                                Layout.fillWidth: true
                                Layout.topMargin: index === 0 ? 20 : 0
                                model: modelData.modelSelect
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                currentIndex: {
                                    const current = serialportPage[modelData.propertyName]
                                    for (let i = 0; i < modelData.modelSelect.length; i++) {
                                        if (modelData.modelSelect[i].value === current) {
                                            return i
                                        }
                                    }
                                    return modelData.modelSelect.length > 0 ? 0 : -1
                                }
                                onActivated: {
                                    serialportPage[modelData.propertyName] = currentValue
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 8
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 12
                        MosButton {
                            text: "刷新"
                            width: 70
                            onClicked: serialportPage.refreshSerialPorts()
                        }
                        MosButton {
                            text: MosSerialPortManager.isOpen ? "关闭串口" : "打开串口"
                            width: 120
                            type: MosSerialPortManager.isOpen ? MosButton.Type_Default : MosButton.Type_Primary
                            enabled: serialportPage.selectedPortName.length > 0 || MosSerialPortManager.isOpen
                            onClicked: serialportPage.toggleSerialPort()
                        }
                    }
                }
            }
            MosGroupBox {
                label: Text { text: "接收设置"; color: MosTheme.Primary.colorTextPrimary }
                title: "接收设置"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: colContent2.implicitHeight + 30

                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                ColumnLayout {
                    id: colContent2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10
                    anchors.margins: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        ButtonGroup { id: colContent2Group}
                        Repeater {
                            model: [
                                { value: 'ASCII', label: 'ASCII' },
                                { value: 'HEX', label: 'HEX' }
                            ]

                            delegate: MosRadio {
                                Layout.alignment: index == 0 ? (Qt.AlignLeft | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter)
                                checked: index === 0
                                Layout.fillWidth: true
                                text: modelData.label
                                ButtonGroup.group: colContent2Group
                                Layout.leftMargin: index === 0 ? 20 : 0
                                Layout.rightMargin: index === 1 ? 20 : 0
                                onToggled: if (checked) serialportPage.receiveMode = modelData.value
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 20
                        spacing: parent.spacing
                        Repeater{
                            model: [
                                { propertyName: 'receiveAutoNewline', label: '自动换行' },
                                { propertyName: 'receiveShowTime', label: '显示时间' }
                            ]
                            delegate: MosCheckBox {
                                text: modelData.label
                                Layout.leftMargin: 20
                                checked: serialportPage[modelData.propertyName]
                                onToggled: serialportPage[modelData.propertyName] = checked
                            }
                        }
                    }
                }
            }
            MosGroupBox {
                label: Text { text: "发送设置"; color: MosTheme.Primary.colorTextPrimary }
                title: "发送设置"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: colContent3.implicitHeight + 30

                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                ColumnLayout {
                    id: colContent3
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10
                    anchors.margins: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        ButtonGroup { id: colContent3Group}
                        Repeater {
                            model: [
                                { value: 'ASCII', label: 'ASCII' },
                                { value: 'HEX', label: 'HEX' }
                            ]
                            delegate: MosRadio {
                                Layout.alignment: index == 0 ? (Qt.AlignLeft | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter)
                                checked: index === 0
                                Layout.fillWidth: true
                                text: modelData.label
                                ButtonGroup.group: colContent3Group
                                Layout.leftMargin: index === 0 ? 20 : 0
                                Layout.rightMargin: index === 1 ? 20 : 0
                                onToggled: if (checked) serialportPage.sendMode = modelData.value
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        MosCheckBox {
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.leftMargin: 20
                            Layout.fillWidth: true
                            text: '自动发送'
                            checked: serialportPage.sendAutoEnabled
                            onToggled: serialportPage.sendAutoEnabled = checked
                        }
                        MosInputInteger {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            value: serialportPage.autoSendInterval
                            min: 1
                            Layout.minimumWidth: implicitWidth + 20
                            step: 10
                            Layout.rightMargin: 20
                            Layout.fillWidth: true
                            onValueModified: serialportPage.autoSendInterval = serialportPage.normalizePositiveInteger(value)
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 20
                        spacing: parent.spacing
                        Repeater{
                            model: [
                                { name: "指令数量" , propertyName: "commandCount", step: 1 },
                                { name: "指令字节数" , propertyName: "commandByteCount", step: 1 },
                                { name: "指令间隔" , propertyName: "commandInterval", step: 10 }
                            ]
                            delegate: RowLayout {
                                spacing: 10
                                MosText {
                                    text: modelData.name
                                    Layout.preferredWidth: 60
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20
                                }
                                MosInputInteger {
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    value: serialportPage[modelData.propertyName]
                                    min: 1
                                    step: modelData.step
                                    Layout.rightMargin: 20
                                    Layout.minimumWidth: implicitWidth + 20
                                    Layout.fillWidth: true
                                    onValueModified: serialportPage[modelData.propertyName] = serialportPage.normalizePositiveInteger(value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    property Component rightItemcontrols: Item{
        id : rightItem
        anchors.fill: parent
        property bool commandTableRefreshPending: false
        property int renderedCommandCount: 10
        property int renderedCommandByteCount: 20
        property var pendingCommandPayloads: []
        property int pendingCommandIndex: 0
        property int autoCommandIndex: 0
        property bool commandLoopEnabled: false

        MosRectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: MosTheme.Primary.colorFillPrimary
        }
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

        function buildCommandColumns(count) {
            const columnCount = serialportPage.normalizePositiveInteger(count)
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
            const rows = serialportPage.normalizePositiveInteger(rowCount)
            const columns = serialportPage.normalizePositiveInteger(columnCount)
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

        function updateCommandTable() {
            if (!commandTableLoader || commandTableRefreshPending) {
                return
            }

            commandTableRefreshPending = true
            autoCommandIndex = 0
            commandTableLoader.active = false
            Qt.callLater(function() {
                renderedCommandCount = serialportPage.commandCount
                renderedCommandByteCount = serialportPage.commandByteCount
                commandTableRefreshPending = false
                commandTableLoader.active = true
            })
        }

        Connections {
            target: serialportPage

            function onCommandCountChanged() {
                Qt.callLater(rightItem.updateCommandTable)
            }

            function onCommandByteCountChanged() {
                Qt.callLater(rightItem.updateCommandTable)
            }
        }

        Connections {
            target: MosSerialPortManager

            function onDataReceived(data, text, hex) {
                rightItem.appendReceivedData(text, hex)
            }

            function onErrorOccurred(message) {
                rightItem.appendStatusText("错误: " + message)
            }
        }

        Timer {
            id: autoSendTimer
            interval: serialportPage.autoSendInterval
            repeat: true
            running: serialportPage.sendAutoEnabled && MosSerialPortManager.isOpen
            onTriggered: rightItem.sendAutoData()
            onRunningChanged: if (!running) rightItem.autoCommandIndex = 0
        }

        Timer {
            id: commandSendTimer
            interval: serialportPage.commandInterval
            repeat: false
            onTriggered: rightItem.sendNextCommandPayload()
        }

        function appendStatusText(message) {
            const line = "[" + Qt.formatTime(new Date(), "hh:mm:ss.zzz") + "] " + message
            serialportTextArea.text += (serialportTextArea.text.length > 0 ? "\n" : "") + line
            serialportTextArea.scrollToEnd()
        }

        function appendReceivedData(text, hex) {
            let data = serialportPage.receiveMode === "HEX" ? hex : text
            if (data.length === 0) {
                return
            }
            if (serialportPage.receiveShowTime) {
                data = "[" + Qt.formatTime(new Date(), "hh:mm:ss.zzz") + "] " + data
            }
            if (serialportPage.receiveAutoNewline && !data.endsWith("\n")) {
                data += "\n"
            }
            serialportTextArea.text += data
            serialportTextArea.scrollToEnd()
        }

        function sendTextData() {
            const data = sendTextArea.text
            if (data.length === 0) {
                return true
            }
            if (serialportPage.sendMode === "HEX") {
                return MosSerialPortManager.writeHex(data)
            }
            return MosSerialPortManager.writeText(data)
        }

        function sendAutoData() {
            const payloads = buildCommandPayloads()
            if (payloads.length === 0) {
                autoCommandIndex = 0
                return sendTextData()
            }

            if (autoCommandIndex >= payloads.length) {
                autoCommandIndex = 0
            }

            const ok = MosSerialPortManager.writeHex(payloads[autoCommandIndex])
            autoCommandIndex = (autoCommandIndex + 1) % payloads.length
            return ok
        }

        function normalizeByteCell(value) {
            let text = value === undefined || value === null ? "" : value.toString().trim()
            if (text.length === 0) {
                return ""
            }
            text = text.replace(/^0x/i, "")
            if (text.length === 1) {
                text = "0" + text
            }
            if (text.length !== 2 || !/^[0-9a-fA-F]{2}$/.test(text)) {
                return ""
            }
            return text.toUpperCase()
        }

        function buildCommandPayloads() {
            const table = commandTableLoader.item
            if (!table) {
                return []
            }

            const rows = table.getTableModel()
            let payloads = []
            for (let row = 0; row < rows.length; row++) {
                let bytes = []
                for (let column = 0; column < renderedCommandByteCount; column++) {
                    const value = normalizeByteCell(rows[row]["Byte" + column])
                    if (value.length > 0) {
                        bytes.push(value)
                    }
                }
                if (bytes.length > 0) {
                    payloads.push(bytes.join(" "))
                }
            }
            return payloads
        }

        function sendCommandData() {
            const payloads = buildCommandPayloads()
            if (payloads.length === 0) {
                appendStatusText("没有可发送的指令数据")
                return
            }

            pendingCommandPayloads = singleSendCheckBox.checked ? [payloads[0]] : payloads
            pendingCommandIndex = 0
            commandLoopEnabled = loopSendCheckBox.checked
            sendNextCommandPayload()
        }

        function sendNextCommandPayload() {
            if (pendingCommandPayloads.length === 0) {
                return
            }

            MosSerialPortManager.writeHex(pendingCommandPayloads[pendingCommandIndex])
            pendingCommandIndex++

            if (pendingCommandIndex >= pendingCommandPayloads.length) {
                if (!commandLoopEnabled) {
                    pendingCommandPayloads = []
                    pendingCommandIndex = 0
                    return
                }
                pendingCommandIndex = 0
            }

            commandSendTimer.interval = serialportPage.commandInterval
            commandSendTimer.restart()
        }

        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            anchors.margins: 0

            MosGroupBox {
                label: Text { text: "数据接收区"; color: MosTheme.Primary.colorTextPrimary }
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 2
                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                MosTextArea {
                    id: serialportTextArea
                    anchors.fill: parent
                    anchors.margins: 0
                    autoSize: true
                    readOnly: true
                    colorBg: "transparent"
                    colorBorder: MosTheme.Primary.colorSplit
                    placeholderText: '数据接收区'
                }
            }
            MosGroupBox {
                label: Text { text: "数据发送编辑区"; color: MosTheme.Primary.colorTextPrimary }
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 3
                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    anchors.topMargin: 20
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 20
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130
                        Layout.minimumHeight: 100
                        spacing: 10

                        MosTextArea {
                            id: sendTextArea
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.horizontalStretchFactor : 3
                            autoSize: true
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
                                onClicked: serialportTextArea.clear()
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
                                enabled: MosSerialPortManager.isOpen
                                onClicked: rightItem.sendTextData()
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
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                MosButton {
                                    id: saveCommandDataButton
                                    text: "保存指令数据"
                                    Layout.fillWidth: true
                                }
                                MosCheckBox {
                                    id: singleSendCheckBox
                                    text: "单条发送"
                                    Layout.preferredWidth: 90
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                MosButton {
                                    id: sendCommandButton
                                    text: "发送指令"
                                    Layout.fillWidth: true
                                    enabled: MosSerialPortManager.isOpen
                                    onClicked: rightItem.sendCommandData()
                                }
                                MosCheckBox {
                                    id: loopSendCheckBox
                                    text: "循环发送"
                                    Layout.preferredWidth: 90
                                }
                            }
                        }
                    }
                    MosRectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.verticalStretchFactor : 3
                        Layout.minimumHeight: 180
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit
                        border.width: 1

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
                                columns: rightItem.buildCommandColumns(rightItem.renderedCommandByteCount)
                                initModel: rightItem.buildCommandRows(rightItem.renderedCommandCount, rightItem.renderedCommandByteCount)
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

    Loader {
        id: leftLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width/4
        active: true
        sourceComponent: serialportPage.leftItemcontrols
    }

    Loader {
        id: rightLoader
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: leftLoader.right
        active: true
        sourceComponent: serialportPage.rightItemcontrols
    }
}
