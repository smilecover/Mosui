pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: wavePage
    color: "transparent"
    anchors.fill: parent

    readonly property color pageBg: "transparent"
    readonly property color panelBg: "transparent"
    readonly property color chartBg: "transparent"
    readonly property color panelBorder: MosTheme.Primary.colorSplit
    readonly property color controlBg: "transparent"
    readonly property color textStrong: MosTheme.Primary.colorTextPrimary
    readonly property color textMuted: MosTheme.Primary.colorTextSecondary
    readonly property color gridColor: MosTheme.Primary.colorSplit
    readonly property color axisColor: MosTheme.Primary.colorTextTertiary

    MosMessage {
        id: pageMessage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        z: 999
        width: Math.min(480, parent.width - 40)
    }

    // ── MQTT 初始化 ──
    readonly property int _tpInvMqttInit: TpinvMqtt.InitMqtt()

    // ── 通信模式: 0=串口, 1=MQTT，绑定到 C++ ConnectMode 属性 ──
    readonly property var commModeOptions: [
        { label: "串口", value: 0 },
        { label: "MQTT", value: 1 }
    ]

    function commModeIndex() {
        return TpInvcontroldata.ConnectMode
    }

    // ── 串口连接内容组件 ──
    property Component serialWaveConnectionContent: ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        MosRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 7
            color: wavePage.isConnected() ? "#1b2d2e" : "#2a2130"
            border.width: 1
            border.color: wavePage.isConnected() ? "#2ce0a0" : "#ce3f5b"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 9

                MosRectangle {
                    Layout.preferredWidth: 11
                    Layout.preferredHeight: 11
                    Layout.alignment: Qt.AlignVCenter
                    radius: 6
                    color: wavePage.isConnected() ? "#2cff9a" : "#ff5660"
                }

                MosText {
                    Layout.fillWidth: true
                    text: wavePage.isConnected() && wavePage.selectedPortName.length > 0
                          ? "已连接 · " + wavePage.selectedPortName
                          : wavePage.isConnected() ? "已连接" : "未连接"
                    color: wavePage.isConnected() ? "#62ffc4" : "#ff5e73"
                    font.bold: true
                }
            }
        }

        MosText {
            Layout.fillWidth: true
            text: "串口号"
            color: wavePage.textMuted
            font.pixelSize: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MosSelect {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                model: wavePage.portOptions
                enabled: !wavePage.isConnected()
                colorBg: wavePage.controlBg
                colorBorder: MosTheme.Primary.colorBorder
                colorText: wavePage.textStrong
                placeholderText: "请选择串口"
                radiusBg.all: 7
                currentIndex: {
                    for (let i = 0; i < wavePage.portOptions.length; ++i) {
                        if (wavePage.portOptions[i].value === wavePage.selectedPortName)
                            return i
                    }
                    return wavePage.portOptions.length > 0 ? 0 : -1
                }
                onActivated: TpInvDataProcessing.selectedPortName = currentValue
            }

            MosButton {
                Layout.preferredWidth: 66
                Layout.preferredHeight: 38
                text: "刷新"
                enabled: !wavePage.isConnected()
                radiusBg.all: 7
                colorBg: wavePage.controlBg
                colorBorder: MosTheme.Primary.colorBorder
                colorText: wavePage.textStrong
                onClicked: wavePage.refreshSerialPorts()
            }
        }

        MosText {
            Layout.fillWidth: true
            text: "波特率"
            color: wavePage.textMuted
            font.pixelSize: 12
        }

        MosSelect {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            model: wavePage.baudRateOptions
            enabled: !wavePage.isConnected()
            colorBg: wavePage.controlBg
            colorBorder: MosTheme.Primary.colorBorder
            colorText: wavePage.textStrong
            radiusBg.all: 7
            currentIndex: {
                for (let i = 0; i < wavePage.baudRateOptions.length; ++i) {
                    if (wavePage.baudRateOptions[i].value === wavePage.selectedBaudRate)
                        return i
                }
                return wavePage.baudRateOptions.length - 1
            }
            onActivated: TpInvDataProcessing.selectedBaudRate = currentValue
        }

        MosButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            text: wavePage.isConnected() ? "断开串口" : "连接串口"
            enabled: wavePage.isConnected() || wavePage.selectedPortName.length > 0
            type: MosButton.Type_Primary
            radiusBg.all: 8
            colorBg: hovered ? "#62b5ff" : "#4ba7ff"
            colorBorder: colorBg
            font.bold: true
            onClicked: wavePage.toggleSerialPort()
        }
    }

    // ── MQTT 连接内容组件 ──
    property Component mqttWaveConnectionContent: ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        MosRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 7
            color: TpinvMqtt.isConnected ? "#1b2d2e" : "#2a2130"
            border.width: 1
            border.color: TpinvMqtt.isConnected ? "#2ce0a0" : "#ce3f5b"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 9

                MosRectangle {
                    Layout.preferredWidth: 11
                    Layout.preferredHeight: 11
                    Layout.alignment: Qt.AlignVCenter
                    radius: 6
                    color: TpinvMqtt.isConnected ? "#2cff9a" : "#ff5660"
                }

                MosText {
                    Layout.fillWidth: true
                    text: TpinvMqtt.isConnected
                          ? "已连接 · " + TpinvMqtt.host + ":" + TpinvMqtt.port
                          : "未连接"
                    color: TpinvMqtt.isConnected ? "#62ffc4" : "#ff5e73"
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MosInput {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                placeholderText: "MQTT 主机地址"
                text: TpinvMqtt.host
                colorBg: wavePage.controlBg
                colorBorder: MosTheme.Primary.colorBorder
                radiusBg.all: 7
                font.pixelSize: 12
                enabled: !TpinvMqtt.isConnected
                onTextChanged: {
                    if (text !== TpinvMqtt.host)
                        TpinvMqtt.host = text
                }
            }

            MosInput {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 34
                placeholderText: "端口"
                text: String(TpinvMqtt.port)
                colorBg: wavePage.controlBg
                colorBorder: MosTheme.Primary.colorBorder
                radiusBg.all: 7
                font.pixelSize: 12
                enabled: !TpinvMqtt.isConnected
                validator: IntValidator { bottom: 1; top: 65535 }
                onTextChanged: {
                    const p = parseInt(text)
                    if (!isNaN(p) && p !== TpinvMqtt.port)
                        TpinvMqtt.port = p
                }
            }
        }

        MosText {
            Layout.fillWidth: true
            text: "波形数据主题"
            color: wavePage.textMuted
            font.pixelSize: 12
        }

        MosInput {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            placeholderText: "波形数据订阅主题"
            text: TpinvMqtt.waveDataTopic
            colorBg: wavePage.controlBg
            colorBorder: MosTheme.Primary.colorBorder
            radiusBg.all: 7
            font.pixelSize: 12
            enabled: !TpinvMqtt.isConnected
            onTextChanged: {
                if (text !== TpinvMqtt.waveDataTopic)
                    TpinvMqtt.waveDataTopic = text
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MosButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "连接"
                type: MosButton.Type_Primary
                enabled: !TpinvMqtt.isConnected
                radiusBg.all: 8
                colorBg: hovered ? "#62b5ff" : "#4ba7ff"
                colorBorder: colorBg
                font.bold: true
                onClicked: {
                    TpinvMqtt.connectToHost()
                    pageMessage.info("正在连接 MQTT " + TpinvMqtt.host + ":" + TpinvMqtt.port + "…")
                }
            }

            MosButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "断开"
                type: MosButton.Type_Outlined
                enabled: TpinvMqtt.isConnected
                radiusBg.all: 8
                colorBg: wavePage.controlBg
                colorBorder: MosTheme.Primary.colorBorder
                colorText: wavePage.textStrong
                font.bold: true
                onClicked: {
                    TpinvMqtt.disconnectFromHost()
                    pageMessage.info("已断开 MQTT 连接")
                }
            }
        }
    }

    property bool chartModified: false
    property bool waveformPaused: TpInvDataProcessing.waveformPaused
    property var portOptions: TpInvDataProcessing.portOptions
    property string selectedPortName: TpInvDataProcessing.selectedPortName
    property bool wavePortOpen: TpInvDataProcessing.wavePortOpen
    property int selectedBaudRate: TpInvDataProcessing.selectedBaudRate
    property int sampleCount: 400
    property int maxAdaptiveRenderPoints: 1600
    property int receivedByteCount: TpInvDataProcessing.receivedByteCount
    property string lastWaveHex: TpInvDataProcessing.lastWaveHex
    property string lastWaveText: TpInvDataProcessing.lastWaveText
    property string lastWaveRxTime: TpInvDataProcessing.lastWaveRxTime
    property string waveStatusText: TpInvDataProcessing.waveStatusText

    property bool voltageAEnabled: TpInvDataProcessing.voltageAEnabled
    property bool voltageBEnabled: TpInvDataProcessing.voltageBEnabled
    property bool voltageCEnabled: TpInvDataProcessing.voltageCEnabled
    property bool currentAEnabled: TpInvDataProcessing.currentAEnabled
    property bool currentBEnabled: TpInvDataProcessing.currentBEnabled
    property bool currentCEnabled: TpInvDataProcessing.currentCEnabled

    property var voltageSeries: TpInvDataProcessing.voltageSeries
    property var currentSeries: TpInvDataProcessing.currentSeries

    readonly property var baudRateOptions: [
        { value: 9600, label: "9600" },
        { value: 19200, label: "19200" },
        { value: 38400, label: "38400" },
        { value: 57600, label: "57600" },
        { value: 115200, label: "115200" },
        { value: 230400, label: "230400" },
        { value: 460800, label: "460800" },
        { value: 921600, label: "921600" },
        { value: 1000000, label: "1M" },
        { value: 1500000, label: "1.5M" },
        { value: 2000000, label: "2M" },
        { value: 2500000, label: "2.5M" },
        { value: 3000000, label: "3M" }
    ]

    function isConnected() {
        return TpInvDataProcessing.wavePortOpen
    }

    function isAnyConnected() {
        if (TpInvcontroldata.ConnectMode === 1) return TpinvMqtt.isConnected
        return TpInvDataProcessing.wavePortOpen
    }

    function refreshSerialPorts() {
        TpInvDataProcessing.refreshSerialPorts()
    }

    function toggleSerialPort() {
        return TpInvDataProcessing.toggleSerialPort()
    }

    function compactHex(hex) {
        return TpInvDataProcessing.compactHex(hex)
    }

    function clearWaveformData() {
        TpInvDataProcessing.clearWaveformData()
    }

    function updateAdaptiveRenderPoints() {
        const vLimit = Math.max(50, Math.min(Math.round(voltageChart.width), maxAdaptiveRenderPoints))
        const cLimit = Math.max(50, Math.min(Math.round(currentChart.width), maxAdaptiveRenderPoints))
        if (voltageChart.maxRenderPoints !== vLimit)
            voltageChart.maxRenderPoints = vLimit
        if (currentChart.maxRenderPoints !== cLimit)
            currentChart.maxRenderPoints = cLimit
    }

    function scheduleCapacityUpdate() {
        capacityDebounce.restart()
    }

    function updateSampleCapacityFromZoom() {
        const actualCount = TpInvDataProcessing.sampleCount
        if (actualCount <= 0)
            return

        const visibleRange = Math.max(1, voltageChart.xMax - voltageChart.xMin + 1)
        const zoomRatio = visibleRange / Math.max(visibleRange, actualCount)
        const minNeeded = Math.max(400, voltageChart.xMax + 1)
        const targetCapacity = Math.min(1600, Math.max(minNeeded,
            Math.round(400 + 1200 * (1 - zoomRatio))))

        if (TpInvDataProcessing.sampleCapacity !== targetCapacity)
            TpInvDataProcessing.sampleCapacity = targetCapacity
    }

    Timer {
        id: capacityDebounce
        interval: 300
        repeat: false
        onTriggered: wavePage.updateSampleCapacityFromZoom()
    }

    function clampChartRange(chart) {
        const actualCount = TpInvDataProcessing.sampleCount
        const maxIndex = Math.max(0, actualCount - 1)
        if (chart.xMin < 0)
            chart.xMin = 0
        if (chart.xMax > maxIndex)
            chart.xMax = maxIndex
        const maxRange = Math.max(10, maxIndex + 1)
        if (chart.xMax - chart.xMin > maxRange) {
            const mid = (chart.xMin + chart.xMax) / 2
            chart.xMin = Math.max(0, mid - maxRange / 2)
            chart.xMax = Math.min(maxIndex, mid + maxRange / 2)
        }
    }

    Component.onCompleted: {
        TpInvDataProcessing.initializeWavePage(wavePage.sampleCount)
        updateAdaptiveRenderPoints()
    }

    MosRectangle {
        anchors.fill: parent
        color: wavePage.pageBg
        radius: 0
    }

    Flickable {
        id: waveFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, mainRow.height + 20)
        clip: true

        ScrollBar.vertical: MosScrollBar {
            anchors.right: parent.right
        }

        RowLayout {
            id: mainRow
            x: 10
            y: 10
            width: waveFlick.width - 20
            height: Math.max(waveFlick.height - 20, leftColumn.implicitHeight, rightColumn.implicitHeight)
            spacing: 14

            ColumnLayout {
                id: leftColumn
                Layout.preferredWidth: 294
                Layout.minimumWidth: 260
                Layout.maximumWidth: 330
                Layout.alignment: Qt.AlignTop
                spacing: 14

                // ── 通信连接面板 (串口 / MQTT) ──
                MosRectangle {
                    Layout.fillWidth: true
                    implicitHeight: commInnerLayout.implicitHeight + 36
                    Layout.preferredHeight: implicitHeight
                    radius: 10
                    color: wavePage.panelBg
                    border.width: 1
                    border.color: wavePage.panelBorder

                    ColumnLayout {
                        id: commInnerLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 8

                        // ── 标题栏 + 模式选择 ──
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            spacing: 8

                            MosRectangle {
                                Layout.preferredWidth: 5
                                Layout.preferredHeight: 5
                                Layout.alignment: Qt.AlignVCenter
                                radius: 3
                                color: "#56a8ff"
                            }

                            MosText {
                                Layout.fillWidth: true
                                text: "通信连接"
                                color: wavePage.textMuted
                                font.pixelSize: 12
                            }

                            MosSelect {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignRight
                                model: wavePage.commModeOptions
                                currentIndex: wavePage.commModeIndex()
                                colorBg: wavePage.controlBg
                                colorBorder: MosTheme.Primary.colorBorder
                                colorText: wavePage.textStrong
                                radiusBg.all: 7
                                font.pixelSize: 12
                                enabled: !(TpInvcontroldata.ConnectMode === 0 ? wavePage.wavePortOpen : TpinvMqtt.isConnected)
                                onActivated: {
                                    if (currentValue === 1 && wavePage.wavePortOpen) {
                                        wavePage.toggleSerialPort()
                                    }
                                    TpInvcontroldata.ConnectMode = currentValue
                                    pageMessage.info(currentValue === 1
                                        ? "已切换至 MQTT 模式"
                                        : "已切换至串口模式")
                                }
                            }
                        }

                        MosDivider {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            colorSplit: MosTheme.Primary.colorSplit
                        }

                        // ── 内容区域 ──
                        Loader {
                            id: commLoader
                            Layout.fillWidth: true
                            sourceComponent: TpInvcontroldata.ConnectMode === 1
                                ? wavePage.mqttWaveConnectionContent
                                : wavePage.serialWaveConnectionContent
                        }
                    }
                }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: waveformControlColumn.implicitHeight + 36
                Layout.minimumHeight: waveformControlColumn.implicitHeight + 36
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                ColumnLayout {
                    id: waveformControlColumn
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MosRectangle {
                            Layout.preferredWidth: 5
                            Layout.preferredHeight: 5
                            Layout.alignment: Qt.AlignVCenter
                            radius: 3
                            color: "#56a8ff"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "波形显示控制"
                            color: wavePage.textMuted
                            font.pixelSize: 12
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        spacing: 7

                        MosRectangle {
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            Layout.alignment: Qt.AlignVCenter
                            radius: 5
                            color: "#ff4f63"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "三相电压"
                            color: wavePage.textMuted
                            font.pixelSize: 12
                        }
                    }

                    ChannelRow {
                        label: "A相电压"
                        accent: "#FFCC00"
                        propertyName: "voltageAEnabled"
                    }

                    ChannelRow {
                        label: "B相电压"
                        accent: '#01ff45'
                        propertyName: "voltageBEnabled"
                    }

                    ChannelRow {
                        label: "C相电压"
                        accent: '#ff4f63'
                        propertyName: "voltageCEnabled"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        spacing: 7

                        MosRectangle {
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            Layout.alignment: Qt.AlignVCenter
                            radius: 5
                            color: "#43ffd7"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "三相电流"
                            color: wavePage.textMuted
                            font.pixelSize: 12
                        }
                    }

                    ChannelRow {
                        label: "A相电流"
                        accent:'#FFCC00'
                        propertyName: "currentAEnabled"
                    }

                    ChannelRow {
                        label: "B相电流"
                        accent: '#01ff45'
                        propertyName: "currentBEnabled"
                    }

                    ChannelRow {
                        label: "C相电流"
                        accent: '#ff4f63'
                        propertyName: "currentCEnabled"
                    }
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: pauseWaveButton.implicitHeight + 36
                Layout.minimumHeight: pauseWaveButton.implicitHeight + 36
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                MosButton {
                    id: pauseWaveButton
                    anchors.fill: parent
                    anchors.margins: 18
                    text: wavePage.waveformPaused ? "继续波形" : "暂停波形"
                    radiusBg.all: 9
                    colorBg: wavePage.controlBg
                    colorBorder: MosTheme.Primary.colorBorder
                    colorText: wavePage.textStrong
                    font.bold: true
                    onClicked: TpInvDataProcessing.waveformPaused = !TpInvDataProcessing.waveformPaused
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: autoReceiveRow.implicitHeight + 36
                Layout.minimumHeight: autoReceiveRow.implicitHeight + 36
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                ColumnLayout {
                    id: autoReceiveRow
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MosRectangle {
                            Layout.preferredWidth: 5
                            Layout.preferredHeight: 5
                            Layout.alignment: Qt.AlignVCenter
                            radius: 3
                            color: "#56a8ff"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "接收模式"
                            color: wavePage.textMuted
                            font.pixelSize: 12
                        }
                    }

                    MosRectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 7
                        color: wavePage.isAnyConnected() ? "#1a2e2d" : "#2a2130"
                        border.width: 1
                        border.color: wavePage.isAnyConnected() ? "#2ce0a0" : "#ce3f5b"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            MosRectangle {
                                Layout.preferredWidth: 8
                                Layout.preferredHeight: 8
                                Layout.alignment: Qt.AlignVCenter
                                radius: 4
                                color: wavePage.isAnyConnected() && TpInvDataProcessing.parsedFrameCount > 0 ? "#2cff9a" : "#ff5660"
                            }

                            MosText {
                                Layout.fillWidth: true
                                text: wavePage.isAnyConnected()
                                      ? (TpInvDataProcessing.parsedFrameCount > 0
                                         ? "自动接收中"
                                         : "等待数据推送...")
                                      : "未连接"
                                color: wavePage.isAnyConnected() ? "#62ffc4" : "#ff5e73"
                                font.bold: true
                            }
                        }
                    }

                    MosButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: "清空数据"
                        radiusBg.all: 8
                        colorBg: wavePage.controlBg
                        colorBorder: MosTheme.Primary.colorBorder
                        colorText: wavePage.textStrong
                        onClicked: wavePage.clearWaveformData()
                    }

                    // MosButton {
                    //     Layout.fillWidth: true
                    //     Layout.preferredHeight: 36
                    //     text: "模拟波形"
                    //     radiusBg.all: 8
                    //     colorBg: "#1a2e2d"
                    //     colorBorder: "#2ce0a0"
                    //     colorText: "#62ffc4"
                    //     font.bold: true
                    //     onClicked: TpInvDataProcessing.generateMockData(wavePage.sampleCount)
                    // }
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: waveInfoColumn.implicitHeight + 36
                Layout.minimumHeight: waveInfoColumn.implicitHeight + 36
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                ColumnLayout {
                    id: waveInfoColumn
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MosRectangle {
                            Layout.preferredWidth: 5
                            Layout.preferredHeight: 5
                            Layout.alignment: Qt.AlignVCenter
                            radius: 3
                            color: "#56a8ff"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "波形信息"
                            color: wavePage.textMuted
                            font.pixelSize: 12
                        }
                    }

                    InfoRow {
                        label: "状态"
                        value: wavePage.waveStatusText
                        valueColor: TpInvDataProcessing.sampleCount > 0 ? "#62ffc4" : wavePage.textStrong
                    }

                    InfoRow {
                        label: "样本"
                        value: TpInvDataProcessing.sampleCount + " / " + wavePage.sampleCount
                    }

                    InfoRow {
                        label: "解析帧"
                        value: String(TpInvDataProcessing.parsedFrameCount)
                    }

                    InfoRow {
                        label: "丢弃"
                        value: String(TpInvDataProcessing.droppedFrameCount)
                    }

                    InfoRow {
                        label: "接收"
                        value: wavePage.receivedByteCount + " B"
                    }

                    InfoRow {
                        label: "最近"
                        value: wavePage.lastWaveRxTime.length > 0 ? wavePage.lastWaveRxTime : "--"
                    }

                    MosRectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(56, lastHexText.implicitHeight + 24)
                        radius: 7
                        color: wavePage.controlBg
                        border.width: 1
                        border.color: MosTheme.Primary.colorBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            MosText {
                                Layout.fillWidth: true
                                text: "最后HEX"
                                color: wavePage.textMuted
                                font.pixelSize: 11
                            }

                            MosText {
                                id: lastHexText
                                Layout.fillWidth: true
                                text: wavePage.compactHex(wavePage.lastWaveHex)
                                color: wavePage.textStrong
                                font.pixelSize: 11
                                font.family: "Consolas"
                                wrapMode: Text.WrapAnywhere
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: rightColumn
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 14

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: voltageChartColumn.implicitHeight + 40
                Layout.minimumHeight: voltageChartColumn.implicitHeight + 40
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                ColumnLayout {
                    id: voltageChartColumn
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        spacing: 8

                        MosRectangle {
                            Layout.preferredWidth: 7
                            Layout.preferredHeight: 7
                            Layout.alignment: Qt.AlignVCenter
                            radius: 2
                            color: "#52b1ff"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "三相电压波形"
                            color: wavePage.textStrong
                            font.bold: true
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            tagState: MosTag.State_Success
                            text: "实时"
                        }

                        MosButton {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 22
                            text: "重置"
                            visible: wavePage.chartModified
                            radiusBg.all: 6
                            colorBg: wavePage.controlBg
                            colorBorder: MosTheme.Primary.colorBorder
                            colorText: wavePage.textMuted
                            font.pixelSize: 11
                            onClicked: {
                                voltageChart.resetZoom()
                                currentChart.resetZoom()
                                TpInvDataProcessing.sampleCapacity = 400
                                voltageChart.autoXRange = false
                                voltageChart.xMin = 0
                                voltageChart.xMax = wavePage.sampleCount - 1
                                currentChart.autoXRange = false
                                currentChart.xMin = 0
                                currentChart.xMax = wavePage.sampleCount - 1
                                wavePage.chartModified = false
                                wavePage.updateAdaptiveRenderPoints()
                            }
                        }
                    }

                    MosCanvasChart {
                        id: voltageChart
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(280, Math.round((waveFlick.height - 132) / 2))
                        chartType: MosCanvasChart.Type_Line
                        series: wavePage.voltageSeries
                        colors: ["#FFCC00", '#01ff45', '#ff4f63']
                        showTitle: false
                        showLegend: false
                        showValues: false
                        showGrid: true
                        showAxis: true
                        smooth: true
                        hoverable: true
                        animationEnabled: false
                        highPerformance: true
                        fillBackground: false
                        zoomEnabled: true
                        panEnabled: true
                        autoXRange: false
                        autoYRange: true
                        xMin: 0
                        xMax: wavePage.sampleCount - 1
                        xBlockCount: 8
                        yBlockCount: 4
                        unit: "V"
                        lineWidth: 2
                        pointSize: 2
                        pointRenderThreshold: 1
                        maxRenderPoints: 1600
                        maxInteractivePoints: 1600
                        colorBg: wavePage.chartBg
                        colorPlotBg: wavePage.chartBg
                        colorText: wavePage.textStrong
                        colorTextSecondary: wavePage.textMuted
                        colorGrid: wavePage.gridColor
                        colorAxis: wavePage.axisColor
                        radiusBg.all: 7
                        formatter: value => Number(value).toFixed(1)
                        xFormatter: value => String(Math.round(value))

                        onChartZoomed: {
                            wavePage.chartModified = true
                            wavePage.scheduleCapacityUpdate()
                            wavePage.clampChartRange(voltageChart)
                            currentChart.autoXRange = false
                            currentChart.xMin = voltageChart.xMin
                            currentChart.xMax = voltageChart.xMax
                            wavePage.clampChartRange(currentChart)
                            wavePage.updateAdaptiveRenderPoints()
                        }
                        onWidthChanged: wavePage.updateAdaptiveRenderPoints()
                    }
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: currentChartColumn.implicitHeight + 40
                Layout.minimumHeight: currentChartColumn.implicitHeight + 40
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                ColumnLayout {
                    id: currentChartColumn
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        spacing: 8

                        MosRectangle {
                            Layout.preferredWidth: 7
                            Layout.preferredHeight: 7
                            Layout.alignment: Qt.AlignVCenter
                            radius: 2
                            color: "#43ffd7"
                        }

                        MosText {
                            Layout.fillWidth: true
                            text: "三相电流波形"
                            color: wavePage.textStrong
                            font.bold: true
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            tagState: MosTag.State_Success
                            text: "实时"
                        }

                        MosButton {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 22
                            text: "重置"
                            visible: wavePage.chartModified
                            radiusBg.all: 6
                            colorBg: wavePage.controlBg
                            colorBorder: MosTheme.Primary.colorBorder
                            colorText: wavePage.textMuted
                            font.pixelSize: 11
                            onClicked: {
                                voltageChart.resetZoom()
                                currentChart.resetZoom()
                                TpInvDataProcessing.sampleCapacity = 400
                                voltageChart.autoXRange = false
                                voltageChart.xMin = 0
                                voltageChart.xMax = wavePage.sampleCount - 1
                                currentChart.autoXRange = false
                                currentChart.xMin = 0
                                currentChart.xMax = wavePage.sampleCount - 1
                                wavePage.chartModified = false
                                wavePage.updateAdaptiveRenderPoints()
                            }
                        }
                    }

                    MosCanvasChart {
                        id: currentChart
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(280, Math.round((waveFlick.height - 132) / 2))
                        chartType: MosCanvasChart.Type_Line
                        series: wavePage.currentSeries
                        colors: ["#FFCC00", '#01ff45', '#ff4f63']
                        showTitle: false
                        showLegend: false
                        showValues: false
                        showGrid: true
                        showAxis: true
                        smooth: true
                        hoverable: true
                        animationEnabled: false
                        highPerformance: true
                        fillBackground: false
                        zoomEnabled: true
                        panEnabled: true
                        autoXRange: false
                        autoYRange: true

                        xMin: 0
                        xMax: wavePage.sampleCount - 1
                        xBlockCount: 8
                        yBlockCount: 4
                        unit: "A"
                        lineWidth: 2
                        pointSize: 2
                        pointRenderThreshold: 1
                        maxRenderPoints: 1600
                        maxInteractivePoints: 1600
                        colorBg: wavePage.chartBg
                        colorPlotBg: wavePage.chartBg
                        colorText: wavePage.textStrong
                        colorTextSecondary: wavePage.textMuted
                        colorGrid: wavePage.gridColor
                        colorAxis: wavePage.axisColor
                        radiusBg.all: 7
                        formatter: value => Number(value).toFixed(1)
                        xFormatter: value => String(Math.round(value))

                        onChartZoomed: {
                            wavePage.chartModified = true
                            wavePage.scheduleCapacityUpdate()
                            wavePage.clampChartRange(currentChart)
                            voltageChart.autoXRange = false
                            voltageChart.xMin = currentChart.xMin
                            voltageChart.xMax = currentChart.xMax
                            wavePage.clampChartRange(voltageChart)
                            wavePage.updateAdaptiveRenderPoints()
                        }
                        onWidthChanged: wavePage.updateAdaptiveRenderPoints()
                    }
                }
            }
        }
        }
    }

    // ── MQTT 事件连接 ──
    Connections {
        target: TpinvMqtt

        function onIsConnectedChanged() {
            if (TpInvcontroldata.ConnectMode === 1) {
                if (TpinvMqtt.isConnected) {
                    pageMessage.success("MQTT 已连接 " + TpinvMqtt.host + ":" + TpinvMqtt.port)
                } else {
                    pageMessage.info("MQTT 已断开")
                }
            }
        }

        function onErrorOccurred(message) {
            pageMessage.error("MQTT 错误: " + message)
        }

        function onMqttMessageReceived(topic, data) {
            console.log("[TPInv-Wave] MQTT 收到数据 topic=" + topic + " len=" + data.length)
        }
    }

    component InfoRow: RowLayout {
        id: infoRowRoot

        property string label: ""
        property string value: ""
        property color valueColor: wavePage.textStrong

        Layout.fillWidth: true
        Layout.preferredHeight: 24
        spacing: 8

        MosText {
            Layout.preferredWidth: 58
            Layout.alignment: Qt.AlignVCenter
            text: infoRowRoot.label
            color: wavePage.textMuted
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        MosText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: infoRowRoot.value
            color: infoRowRoot.valueColor
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }

    component ChannelRow: MosRectangle {
        id: channelRowRoot

        property string label: ""
        property color accent: "#56a8ff"
        property string propertyName: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 46
        radius: 7
        color: wavePage.controlBg

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            spacing: 10

            MosRectangle {
                Layout.preferredWidth: 15
                Layout.preferredHeight: 15
                Layout.alignment: Qt.AlignVCenter
                radius: 4
                color: channelRowRoot.accent
            }

            MosText {
                Layout.fillWidth: true
                text: channelRowRoot.label
                color: wavePage.textStrong
                font.bold: true
            }

            MosRectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignVCenter
                radius: 13
                color: "transparent"
                border.width: 2
                border.color: wavePage[channelRowRoot.propertyName] ? channelRowRoot.accent : "#576174"

                MosRectangle {
                    width: 18
                    height: 18
                    radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    x: wavePage[channelRowRoot.propertyName] ? parent.width - width - 4 : 4
                    color: wavePage[channelRowRoot.propertyName] ? channelRowRoot.accent : "#637086"

                    Behavior on x { NumberAnimation { duration: MosTheme.Primary.durationFast } }
                    Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const key = channelRowRoot.propertyName
                        TpInvDataProcessing[key] = !TpInvDataProcessing[key]
                    }
                }

                Behavior on border.color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
            }
        }
    }
}
