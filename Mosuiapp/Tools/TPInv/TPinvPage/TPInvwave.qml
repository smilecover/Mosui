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

    property bool waveformPaused: false
    property var portOptions: []
    property string selectedPortName: ""
    property bool wavePortOpen: false
    property int selectedBaudRate: 115200
    property int sampleCount: 352
    property bool autoRequestEnabled: true
    property bool waveformRefreshPending: false

    property bool voltageAEnabled: true
    property bool voltageBEnabled: true
    property bool voltageCEnabled: true
    property bool currentAEnabled: true
    property bool currentBEnabled: true
    property bool currentCEnabled: true

    property var voltageSeries: []
    property var currentSeries: []
    property var voltageAValues: []
    property var voltageBValues: []
    property var voltageCValues: []
    property var currentAValues: []
    property var currentBValues: []
    property var currentCValues: []

    readonly property var baudRateOptions: [
        { value: 9600, label: "9600" },
        { value: 19200, label: "19200" },
        { value: 38400, label: "38400" },
        { value: 57600, label: "57600" },
        { value: 115200, label: "115200" },
        { value: 230400, label: "230400" }
    ]

    function isConnected() {
        return wavePortOpen
    }

    function syncFromSerialGroup() {
        portOptions = appTplnvData.serialPortOptions
        selectedPortName = appTplnvData.waveSerialPortName
        selectedBaudRate = appTplnvData.waveSerialBaudRate
        wavePortOpen = appTplnvData.waveSerialOpen
    }

    function syncToSerialGroup() {
        appTplnvData.waveSerialPortName = selectedPortName
        appTplnvData.waveSerialBaudRate = selectedBaudRate
        appTplnvData.updateSerialConnectionStates()
        syncFromSerialGroup()
    }

    function refreshSerialPorts() {
        appTplnvData.refreshSerialPorts("wave")
        syncFromSerialGroup()
    }

    function toggleSerialPort() {
        if (selectedPortName.length === 0)
            refreshSerialPorts()
        if (selectedPortName.length === 0)
            return false

        syncToSerialGroup()
        const ok = appTplnvData.toggleWaveSerialPort()
        syncFromSerialGroup()
        return ok
    }

    function requestWaveformData() {
        if (!wavePage.isConnected())
            return false

        return MosSerialPortManager.SendHexToPort(selectedPortName, "FF CC 01 00 01 CC")
    }

    function updateWavePortOpen() {
        appTplnvData.updateSerialConnectionStates()
        syncFromSerialGroup()
    }

    function refreshWaveformValues() {
        if (wavePage.waveformPaused)
            return

        voltageAValues = TpInvDataProcessing.voltageAValues
        voltageBValues = TpInvDataProcessing.voltageBValues
        voltageCValues = TpInvDataProcessing.voltageCValues
        currentAValues = TpInvDataProcessing.currentAValues
        currentBValues = TpInvDataProcessing.currentBValues
        currentCValues = TpInvDataProcessing.currentCValues
    }

    function updateVoltageSeries() {
        const result = []
        if (voltageAEnabled)
            result.push({ name: "A相电压", color: "#ff4f63", values: voltageAValues })
        if (voltageBEnabled)
            result.push({ name: "B相电压", color: "#48ff79", values: voltageBValues })
        if (voltageCEnabled)
            result.push({ name: "C相电压", color: "#4da8ff", values: voltageCValues })
        voltageSeries = result
    }

    function updateCurrentSeries() {
        const result = []
        if (currentAEnabled)
            result.push({ name: "A相电流", color: "#ff8b3d", values: currentAValues })
        if (currentBEnabled)
            result.push({ name: "B相电流", color: "#3fffe0", values: currentBValues })
        if (currentCEnabled)
            result.push({ name: "C相电流", color: "#c57bff", values: currentCValues })
        currentSeries = result
    }

    function updateAllSeries() {
        updateVoltageSeries()
        updateCurrentSeries()
    }

    Component.onCompleted: {
        TpInvDataProcessing.sampleCapacity = wavePage.sampleCount
        TpInvDataProcessing.clear()
        refreshSerialPorts()
        updateWavePortOpen()
        refreshWaveformValues()
        updateAllSeries()
    }
    onSelectedPortNameChanged: if (appTplnvData.waveSerialPortName !== selectedPortName) syncToSerialGroup()
    onSelectedBaudRateChanged: if (appTplnvData.waveSerialBaudRate !== selectedBaudRate) syncToSerialGroup()
    onSampleCountChanged: TpInvDataProcessing.sampleCapacity = wavePage.sampleCount
    onWaveformPausedChanged: if (!waveformPaused) refreshWaveformValues()
    onVoltageAEnabledChanged: updateVoltageSeries()
    onVoltageBEnabledChanged: updateVoltageSeries()
    onVoltageCEnabledChanged: updateVoltageSeries()
    onCurrentAEnabledChanged: updateCurrentSeries()
    onCurrentBEnabledChanged: updateCurrentSeries()
    onCurrentCEnabledChanged: updateCurrentSeries()
    onVoltageAValuesChanged: updateVoltageSeries()
    onVoltageBValuesChanged: updateVoltageSeries()
    onVoltageCValuesChanged: updateVoltageSeries()
    onCurrentAValuesChanged: updateCurrentSeries()
    onCurrentBValuesChanged: updateCurrentSeries()
    onCurrentCValuesChanged: updateCurrentSeries()

    Connections {
        target: MosSerialPortManager

        function onReceiveDataFromPort(portName, data, text, hex) {
            if (portName !== wavePage.selectedPortName)
                return
            TpInvDataProcessing.appendSerialData(data)
        }

        function onOpenPortsChanged() {
            wavePage.updateWavePortOpen()
        }
    }

    Connections {
        target: appTplnvData

        function onSerialPortOptionsChanged() {
            wavePage.syncFromSerialGroup()
        }

        function onWaveSerialPortNameChanged() {
            wavePage.syncFromSerialGroup()
        }

        function onWaveSerialBaudRateChanged() {
            wavePage.syncFromSerialGroup()
        }

        function onWaveSerialOpenChanged() {
            wavePage.syncFromSerialGroup()
        }
    }

    Connections {
        target: TpInvDataProcessing

        function onSamplesChanged() {
            wavePage.waveformRefreshPending = true
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: wavePage.autoRequestEnabled && wavePage.isConnected() && !wavePage.waveformPaused
        triggeredOnStart: true
        onTriggered: wavePage.requestWaveformData()
    }

    Timer {
        interval: 33
        repeat: true
        running: !wavePage.waveformPaused
        onTriggered: {
            if (!wavePage.waveformRefreshPending)
                return

            wavePage.waveformRefreshPending = false
            wavePage.refreshWaveformValues()
        }
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

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: serialConnectionColumn.implicitHeight + 36
                    Layout.minimumHeight: serialConnectionColumn.implicitHeight + 36
                    radius: 10
                    color: wavePage.panelBg
                    border.width: 1
                    border.color: wavePage.panelBorder

                    ColumnLayout {
                        id: serialConnectionColumn
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
                            text: "串口连接"
                            color: wavePage.textMuted
                            font.pixelSize: 12
                        }
                    }

                    MosRectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        Layout.topMargin: 8
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
                        Layout.topMargin: 3
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
                            onActivated: wavePage.selectedPortName = currentValue
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
                            return 0
                        }
                        onActivated: wavePage.selectedBaudRate = currentValue
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
                        accent: "#ff4f63"
                        propertyName: "voltageAEnabled"
                    }

                    ChannelRow {
                        label: "B相电压"
                        accent: "#48ff79"
                        propertyName: "voltageBEnabled"
                    }

                    ChannelRow {
                        label: "C相电压"
                        accent: "#4da8ff"
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
                            color: "#f5bd36"
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
                        accent: "#ff8b3d"
                        propertyName: "currentAEnabled"
                    }

                    ChannelRow {
                        label: "B相电流"
                        accent: "#3fffe0"
                        propertyName: "currentBEnabled"
                    }

                    ChannelRow {
                        label: "C相电流"
                        accent: "#c57bff"
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
                    onClicked: wavePage.waveformPaused = !wavePage.waveformPaused
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: requestWaveRow.implicitHeight + 36
                Layout.minimumHeight: requestWaveRow.implicitHeight + 36
                radius: 10
                color: wavePage.panelBg
                border.width: 1
                border.color: wavePage.panelBorder

                RowLayout {
                    id: requestWaveRow
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    MosButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        text: "请求波形"
                        enabled: wavePage.isConnected()
                        radiusBg.all: 8
                        type: MosButton.Type_Primary
                        onClicked: wavePage.requestWaveformData()
                    }

                    MosButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        text: "清空"
                        radiusBg.all: 8
                        colorBg: wavePage.controlBg
                        colorBorder: MosTheme.Primary.colorBorder
                        colorText: wavePage.textStrong
                        onClicked: {
                            TpInvDataProcessing.clear()
                            wavePage.refreshWaveformValues()
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

                        RealtimeBadge {}
                    }

                    MosCanvasChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(280, Math.round((waveFlick.height - 132) / 2))
                        chartType: MosCanvasChart.Type_Line
                        series: wavePage.voltageSeries
                        colors: ["#ff4f63", "#48ff79", "#4da8ff"]
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
                        autoXRange: false
                        autoYRange: false
                        xMin: 0
                        xMax: wavePage.sampleCount - 1
                        yMin: -50
                        yMax: 50
                        xBlockCount: 8
                        yBlockCount: 4
                        unit: "V"
                        lineWidth: 2
                        pointSize: 0
                        pointRenderThreshold: 0
                        maxRenderPoints: 900
                        maxInteractivePoints: 900
                        colorBg: wavePage.chartBg
                        colorPlotBg: wavePage.chartBg
                        colorText: wavePage.textStrong
                        colorTextSecondary: wavePage.textMuted
                        colorGrid: wavePage.gridColor
                        colorAxis: wavePage.axisColor
                        radiusBg.all: 7
                        formatter: value => Number(value).toFixed(1)
                        xFormatter: value => String(Math.round(value))
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

                        RealtimeBadge {}
                    }

                    MosCanvasChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(280, Math.round((waveFlick.height - 132) / 2))
                        chartType: MosCanvasChart.Type_Line
                        series: wavePage.currentSeries
                        colors: ["#ff8b3d", "#3fffe0", "#c57bff"]
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
                        autoXRange: false
                        autoYRange: false
                        xMin: 0
                        xMax: wavePage.sampleCount - 1
                        yMin: -1
                        yMax: 1
                        xBlockCount: 8
                        yBlockCount: 4
                        unit: "A"
                        lineWidth: 2
                        pointSize: 0
                        pointRenderThreshold: 0
                        maxRenderPoints: 900
                        maxInteractivePoints: 900
                        colorBg: wavePage.chartBg
                        colorPlotBg: wavePage.chartBg
                        colorText: wavePage.textStrong
                        colorTextSecondary: wavePage.textMuted
                        colorGrid: wavePage.gridColor
                        colorAxis: wavePage.axisColor
                        radiusBg.all: 7
                        formatter: value => Number(value).toFixed(1)
                        xFormatter: value => String(Math.round(value))
                    }
                }
            }
        }
        }
    }

    component RealtimeBadge: MosRectangle {
        Layout.preferredWidth: 54
        Layout.preferredHeight: 22
        Layout.alignment: Qt.AlignVCenter
        radius: 11
        color: MosTheme.Primary.colorSuccessBg
        border.width: 1
        border.color: MosTheme.Primary.colorSuccessBorder

        RowLayout {
            anchors.centerIn: parent
            spacing: 5

            MosRectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: 4
                Layout.alignment: Qt.AlignVCenter
                radius: 2
                color: "#23ffc2"
            }

            MosText {
                Layout.alignment: Qt.AlignVCenter
                text: "实时"
                color: MosTheme.Primary.colorSuccessText
                font.pixelSize: 11
                font.bold: true
            }
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
                        wavePage[key] = !wavePage[key]
                    }
                }

                Behavior on border.color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
            }
        }
    }
}
