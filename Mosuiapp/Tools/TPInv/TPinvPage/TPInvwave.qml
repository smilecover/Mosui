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

    property bool waveformPaused: TpInvDataProcessing.waveformPaused
    property var portOptions: TpInvDataProcessing.portOptions
    property string selectedPortName: TpInvDataProcessing.selectedPortName
    property bool wavePortOpen: TpInvDataProcessing.wavePortOpen
    property int selectedBaudRate: TpInvDataProcessing.selectedBaudRate
    property int sampleCount: 352
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
        { value: 921600, label: "921600" }
    ]

    function isConnected() {
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

    Component.onCompleted: {
        TpInvDataProcessing.initializeWavePage(wavePage.sampleCount)
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
                            return 0
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
                        color: wavePage.isConnected() ? "#1a2e2d" : "#2a2130"
                        border.width: 1
                        border.color: wavePage.isConnected() ? "#2ce0a0" : "#ce3f5b"

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
                                color: wavePage.isConnected() && TpInvDataProcessing.parsedFrameCount > 0 ? "#2cff9a" : "#ff5660"
                            }

                            MosText {
                                Layout.fillWidth: true
                                text: wavePage.isConnected()
                                      ? (TpInvDataProcessing.parsedFrameCount > 0
                                         ? "自动接收中"
                                         : "等待数据推送...")
                                      : "未连接"
                                color: wavePage.isConnected() ? "#62ffc4" : "#ff5e73"
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

                        RealtimeBadge {}
                    }

                    MosCanvasChart {
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
                        // autoXRange: true
                        // autoYRange: true
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
                        // autoXRange: true
                        // autoYRange: true
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
