pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: tpinvControl
    color: "transparent"
    anchors.fill: parent

    MosMessage {
        id: pageMessage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        z: 999
        width: Math.min(480, parent.width - 40)
    }

    property string currentTime: ""
    property int contentCompactBreakpoint: 820
    property bool parametersWriting: false
    property bool applyingNow: false
    property real voltageStep: 1.0
    readonly property color textStrong: MosTheme.Primary.colorTextPrimary
    readonly property color textMuted: MosTheme.Primary.colorTextSecondary
    readonly property color textSubtle: MosTheme.Primary.colorTextTertiary
    readonly property color accent: MosTheme.Primary.colorPrimary
    readonly property color panelBorder: MosTheme.Primary.colorSplit
    readonly property color panelBg: MosTheme.Primary.colorFillQuaternary
    readonly property color fieldBg: MosTheme.Primary.colorFillQuaternary

    readonly property int _tpInvProcessInit: TpinvControlProcess.Initprocess()
    readonly property int _tpInvSerialInit: TpinvSerial.InitTpinvSerial()

    // 逆变器状态信息映射
    // 0=INV_STOP 1=INV_INIT 2=INV_SELF_CHECK 3=INV_SOFT_START 4=INV_RUNNING 5=INV_FAULT
    function inverterStateInfo() {
        const s = TpInvcontroldata.inverterState
        switch (s) {
        case 0: return { text: "已停机",   icon: "◉",  coreBg: "#E8F0F8", coreBorder: "#7FA8C8", accent: "#5B8DAD", textColor: "#4A7088" }
        case 1: return { text: "初始化中", icon: "⟳",  coreBg: "#D6EAF8", coreBorder: "#3498DB", accent: "#2980B9", textColor: "#2471A3" }
        case 2: return { text: "自检中",   icon: "⚡", coreBg: "#FDEBD0", coreBorder: "#E67E22", accent: "#D35400", textColor: "#A04000" }
        case 3: return { text: "软启动",   icon: "↻",  coreBg: "#FCF3CF", coreBorder: "#F1C40F", accent: "#D4AC0D", textColor: "#7D6608" }
        case 4: return { text: "运行中",   icon: "▣",  coreBg: "#D5F5E3", coreBorder: "#27AE60", accent: "#1E8449", textColor: "#145A32" }
        case 5: return { text: "故障",     icon: "⚠", coreBg: "#FADBD8", coreBorder: "#E74C3C", accent: "#CB4335", textColor: "#922B21" }
        default:return { text: "未知",     icon: "?",  coreBg: "#E8E8E8", coreBorder: "#999999", accent: "#888888", textColor: MosTheme.Primary.colorTextSecondary }
        }
    }

    // 格式化数值显示精度
    function fmt(value, decimals) {
        const num = Number(value)
        if (isNaN(num)) return String(value)
        return num.toFixed(decimals)
    }

    // 根据单位自动选择精度
    function fmtByUnit(value, unit) {
        const str = String(value)
        // hex 字符串（如故障码 "0x00000000"）原样显示
        if (str.startsWith("0x") || str.startsWith("0X"))
            return str
        const u = String(unit || "")
        // 无单位的项（故障码、版本号等）原样显示
        if (u === "") return str
        const num = Number(value)
        if (isNaN(num)) return str
        if (u === "Hz")      return num.toFixed(2)
        if (u === "A")       return num.toFixed(2)
        if (u === "V")       return num.toFixed(1)
        if (u === "W" || u === "var" || u === "VA") return num.toFixed(1)
        if (u === "C")       return num.toFixed(1)
        if (u === "%")       return num.toFixed(1)
        return num.toFixed(1)
    }

    readonly property var baudRateOptions: [
        { label: "9600", value: 9600 },
        { label: "19200", value: 19200 },
        { label: "38400", value: 38400 },
        { label: "115200", value: 115200 }
    ]

    function optionIndex(options, value) {
        for (let i = 0; i < options.length; ++i) {
            if (options[i].value === value)
                return i
        }
        return options.length > 0 ? 0 : -1
    }

    function refreshControlSerialPorts() {
        appTplnvData.refreshSerialPorts("control")
    }

    function startDataTimer() {
        dataTimer.start()
    }

    function stopDataTimer() {
        dataTimer.stop()
    }

    property Component leftloaderComponent: Item {
        id: leftContentRoot
        implicitWidth: leftContentLayout.implicitWidth + leftContentLayout.anchors.margins * 2
        implicitHeight: leftContentLayout.implicitHeight + leftContentLayout.anchors.margins * 2

        ColumnLayout {
            id: leftContentLayout
            anchors.fill: parent
            anchors.margins: 2
            spacing: 10

            MosRectangle {
                id: parameterPanel
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                implicitHeight: parameterPanelLayout.implicitHeight + 10
                Layout.preferredHeight: implicitHeight

                color: 'transparent'
                border.width: 1
                border.color: tpinvControl.panelBorder
                radius: MosTheme.Primary.radiusPrimaryLG
                clip: true

                ColumnLayout {
                    id: parameterPanelLayout
                    anchors.fill: parent
                    spacing: 0
                    anchors.bottomMargin: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 54
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        spacing: 12

                        MosIconText {
                            Layout.alignment: Qt.AlignVCenter
                            iconSource: MosIcon.SettingsOutlined
                            iconSize: 24
                            color: tpinvControl.accent
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "参数设置"
                            color: tpinvControl.textStrong
                            font.pixelSize: 20
                            font.bold: true
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: MosTheme.Primary.colorSplit
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        spacing: 13
                        RowLayout { 
                            Layout.fillWidth: true
                            Layout.minimumHeight: 34
                            Layout.preferredHeight: 34
                            Layout.maximumHeight: 34
                            spacing: 12
                            MosText {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.alignment: Qt.AlignVCenter
                                    text: '工作模式'
                                    color: tpinvControl.textMuted
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                            }
                            MosSelect {
                                Layout.minimumWidth: 130
                                Layout.preferredWidth: 130
                                Layout.maximumWidth: 130
                                Layout.minimumHeight: 34
                                Layout.preferredHeight: 34
                                Layout.maximumHeight: 34
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                showToolTip: true
                                currentIndex: TpInvcontroldata.parameterSelectIndex
                                model:TpInvcontroldata.parametermodelItems
                                colorText: tpinvControl.textMuted
                                colorBg: 'transparent'
                                colorBorder: tpinvControl.panelBorder
                                onActivated: {
                                    TpInvcontroldata.parameterSelectIndex = currentIndex
                                }
                            }
                        }

                        Repeater {
                            id: parameterRepeater
                            model:TpInvcontroldata.parameterItems

                            delegate: RowLayout {
                                id: parameterRow
                                required property var modelData
                                required property int index
                                property real currentValue: parameterInput.value
                                property real dynamicStep: {
                                    if (parameterRow.index === 0) {
                                        const items = TpInvcontroldata.parameterItems
                                        const stepVal = (items && items.length > 2) ? Number(items[2].value) : 1.0
                                        return stepVal > 0 ? stepVal : 1.0
                                    }
                                    return parameterRow.modelData.step
                                }
                                Layout.fillWidth: true
                                Layout.minimumHeight: 34
                                Layout.preferredHeight: 34
                                Layout.maximumHeight: 34
                                spacing: 12

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.minimumHeight: 34
                                    Layout.preferredHeight: 34
                                    Layout.maximumHeight: 34
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    spacing: 4

                                    MosText {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: 18
                                        text: parameterRow.modelData.icon
                                        color: tpinvControl.textMuted
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    MosText {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        Layout.alignment: Qt.AlignVCenter
                                        text: parameterRow.modelData.label
                                        color: tpinvControl.textMuted
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }
                                MosInputNumber {
                                    id: parameterInput
                                    Layout.minimumWidth: 130
                                    Layout.preferredWidth: 130
                                    Layout.maximumWidth: 130
                                    Layout.minimumHeight: 34
                                    Layout.preferredHeight: 34
                                    Layout.maximumHeight: 34
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    value: parameterRow.modelData.value
                                    min: parameterRow.modelData.minimum
                                    max: parameterRow.modelData.maximum
                                    step: parameterRow.dynamicStep
                                    precision: 1
                                    clip: true
                                    useKeyboard: true
                                    colorBg: 'transparent'
                                    colorBorder: tpinvControl.panelBorder

                                    radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                    inputFont.family: "Consolas"
                                    inputFont.pixelSize: 13
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            spacing: 12

                            MosButton {
                                id: confirmButton
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: parametersWriting ? "✓  已写入" : "✓  确认"
                                type: parametersWriting ? MosButton.Type_Filled : MosButton.Type_Primary
                                sizeHint: "normal"
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                                onClicked: {
                                    if (parametersWriting) return
                                    let parameterdata = [];
                                    for (let i = 0; i < parameterRepeater.count; i++) {
                                        let item = parameterRepeater.itemAt(i)
                                        if (item) {
                                            parameterdata.push(item.currentValue)
                                        }
                                    }
                                    TpInvcontroldata.setallParameters(parameterdata)
                                    if (parameterdata.length > 2) {
                                        const newStep = Math.max(0.1, Number(parameterdata[2]))
                                        const voltItem = parameterRepeater.itemAt(0)
                                        if (voltItem) voltItem.dynamicStep = newStep
                                    }
                                    parametersWriting = true
                                    paramWriteTimer.restart()
                                    pageMessage.success("参数已写入，请点击 [立即设置] 下发到设备")
                                }
                            }

                            MosButton {
                                id: applyButton
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: appTplnvData.controlSerialOpen ? "↻  立即设置" : "↻  立即设置（未连接）"
                                type: MosButton.Type_Outlined
                                sizeHint: "normal"
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                                enabled: appTplnvData.controlSerialOpen && !applyingNow
                                onClicked: {
                                    applyingNow = true
                                    applyCooldownTimer.restart()
                                    TpInvcontroldata.sendCommand(appTplnvData.controlSerialPortName, TpinvControlProcess.txBuffer[0]);
                                    pageMessage.success("指令已下发至串口 " + appTplnvData.controlSerialPortName)
                                }
                            }

                        }
                    }
                }
            }
            
            MosRectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                Layout.minimumHeight: 200
                color: "transparent"
                border.width: 1
                border.color: tpinvControl.panelBorder
                radius: MosTheme.Primary.radiusPrimaryLG
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    Layout.topMargin: 5
                    anchors.bottomMargin: 10
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 54
                        Layout.bottomMargin: 5
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        spacing: 12

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "▣"
                            color: tpinvControl.accent
                            font.pixelSize: 21
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "串口通信 · 高级调试"
                            color: tpinvControl.textStrong
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        spacing: 12

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            radius: height / 2
                            color: "transparent"
                            border.width: 1
                            border.color: tpinvControl.panelBorder
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "🔗"
                                    color: tpinvControl.textStrong
                                    font.pixelSize: 18
                                }

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: "连接状态:"
                                    color: tpinvControl.textStrong
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: appTplnvData.controlSerialOpen
                                          ? "● 已连接 · " + appTplnvData.controlSerialPortName
                                          : "● 未连接"
                                    color: appTplnvData.controlSerialOpen
                                           ? MosTheme.Primary.colorSuccessText
                                           : MosTheme.Primary.colorWarningText
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            MosSelect {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                model: appTplnvData.serialPortOptions
                                currentIndex: tpinvControl.optionIndex(appTplnvData.serialPortOptions,
                                                                        appTplnvData.controlSerialPortName)
                                clearEnabled: false
                                colorBg: "transparent"
                                colorBorder: tpinvControl.panelBorder
                                colorText: tpinvControl.textStrong
                                radiusBg.all: 17
                                font.family: "Consolas"
                                font.pixelSize: 13
                                onActivated: {
                                    appTplnvData.controlSerialPortName = currentValue
                                    TpinvSerial.controlPortName = currentValue
                                    appTplnvData.updateSerialConnectionStates()
                                }
                            }

                            MosSelect {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                model: tpinvControl.baudRateOptions
                                currentIndex: tpinvControl.optionIndex(tpinvControl.baudRateOptions,
                                                                        appTplnvData.controlSerialBaudRate)
                                clearEnabled: false
                                colorBg: "transparent"
                                colorBorder: tpinvControl.panelBorder
                                colorText: tpinvControl.textStrong
                                radiusBg.all: 17
                                font.family: "Consolas"
                                font.pixelSize: 13
                                onActivated: appTplnvData.controlSerialBaudRate = currentValue
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            MosButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                text: "连接"
                                type: MosButton.Type_Primary
                                enabled: !appTplnvData.controlSerialOpen
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                                onClicked: {
                                    appTplnvData.openControlSerialPort()
                                    pageMessage.info("正在连接 " + appTplnvData.controlSerialPortName + "…")
                                }
                            }

                            MosButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                text: "断开"
                                type: MosButton.Type_Outlined
                                enabled: appTplnvData.controlSerialOpen
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                                onClicked: {
                                    appTplnvData.closeControlSerialPort()
                                    pageMessage.info("已断开串口连接")
                                }
                            }
                        }
                    }
                }
            }
            MosRectangle {
                id: runControlPanel
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                implicitHeight: runControlPanelLayout.implicitHeight
                Layout.preferredHeight: implicitHeight
                color: "transparent"
                border.width: 1
                border.color: tpinvControl.panelBorder
                radius: MosTheme.Primary.radiusPrimaryLG
                clip: true

                ColumnLayout {
                    id: runControlPanelLayout
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 54
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        spacing: 12

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "⏻"
                            color: tpinvControl.accent
                            font.pixelSize: 26
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: "运行控制 · 故障诊断"
                            color: tpinvControl.textStrong
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: MosTheme.Primary.colorSplit
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        Layout.topMargin: 20
                        Layout.bottomMargin: 20
                        spacing: 16

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: MosTheme.Primary.radiusPrimaryLG
                            color: "transparent"
                            border.width: 0

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 12

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: "逆变器主状态"
                                    color: tpinvControl.textStrong
                                    font.pixelSize: 16
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                MosRectangle {
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 44
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: height / 2
                                    color: tpinvControl.inverterStateInfo().coreBg
                                    border.width: 1
                                    border.color: tpinvControl.inverterStateInfo().coreBorder

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        MosText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: tpinvControl.inverterStateInfo().icon
                                            color: tpinvControl.inverterStateInfo().accent
                                            font.pixelSize: 19
                                        }

                                        MosText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: tpinvControl.inverterStateInfo().text
                                            color: tpinvControl.inverterStateInfo().textColor
                                            font.pixelSize: 18
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            MosButton {
                                enabled: TpInvcontroldata.inverterState === 0 || TpInvcontroldata.inverterState === 5
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: "▶  启动"
                                type: MosButton.Type_Primary
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                                onClicked:
                                {
                                     tpinvControl.startDataTimer();
                                     TpInvcontroldata.startInverter(appTplnvData.controlSerialPortName)
                                     pageMessage.info("启动指令已发送，等待逆变器响应…")
                                }
                            }

                            MosButton {
                                enabled: TpInvcontroldata.inverterState === 4
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: "■  停机"
                                type: MosButton.Type_Outlined
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                                onClicked:
                                {
                                     tpinvControl.stopDataTimer();
                                     TpInvcontroldata.stopInverter(appTplnvData.controlSerialPortName)
                                     pageMessage.warning("停机指令已发送")
                                }
                            }
                        }
                    }
                }
            }
        }
    }









    property Component rightloaderComponent: Item {
        implicitWidth: rightContentLayout.implicitWidth + rightContentLayout.anchors.margins * 2
        implicitHeight: rightContentLayout.implicitHeight + rightContentLayout.anchors.margins * 2

        ColumnLayout {
            id: rightContentLayout
            anchors.fill: parent
            anchors.margins: 2
            spacing: 10
            MosRectangle {
                id: lnverterStatus
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                implicitHeight: inverterStatusLayout.implicitHeight
                Layout.preferredHeight: lnverterStatus.implicitHeight

                color: 'transparent'
                border.width: 1
                border.color: tpinvControl.panelBorder
                radius: MosTheme.Primary.radiusPrimaryLG
                clip: true

                readonly property bool compact: width < 520
                readonly property real contentMargin: Math.max(12, Math.min(48, width * 0.06))
                readonly property real gridGap: compact ? 14 : 28
                readonly property real availableGridWidth: Math.max(0, width - contentMargin * 2)
                readonly property int gridColumns: availableGridWidth < 320 ? 1 : 2
                readonly property real gridColumnWidth: gridColumns === 1 ? availableGridWidth : (availableGridWidth - gridGap) / 2
                readonly property real headerHeight: Math.max(56, Math.min(80, width * 0.11))
                readonly property real coreSize: Math.max(112, Math.min(188, gridColumnWidth * (gridColumns === 1 ? 0.48 : 0.86)))
                readonly property real statusTagHeight: 26
                readonly property real summaryTagHeight: 34
                readonly property real coreBlockHeight: coreSize + statusTagHeight + summaryTagHeight + 14
                readonly property real metricHeight: Math.max(76, Math.min(92, width * 0.15))
                readonly property int valueFontSize: compact ? 24 : 28

                ColumnLayout {
                    id: inverterStatusLayout
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: lnverterStatus.headerHeight
                        Layout.leftMargin: lnverterStatus.contentMargin
                        Layout.rightMargin: lnverterStatus.contentMargin
                        spacing: 12

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "↯"
                            color: tpinvControl.accent
                            font.pixelSize: lnverterStatus.compact ? 30 : 38
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: "逆变器状态监测"
                            color: tpinvControl.textStrong
                            font.pixelSize: lnverterStatus.compact ? 21 : 26
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: implicitHeight
                            text: {
                                const idx = TpInvcontroldata.parameterSelectIndex
                                const models = TpInvcontroldata.parametermodelItems
                                const label = (idx >= 0 && idx < models.length) ? models[idx].label : "三相逆变"
                                return "↻ 工作模式: " + label
                            }
                            colorBg: MosTheme.Primary.colorPrimaryBg
                            colorBorder: MosTheme.Primary.colorPrimaryBorder
                            colorText: MosTheme.Primary.colorPrimaryText
                            radiusBg.all: implicitHeight / 2
                            font.pixelSize: 12
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: MosTheme.Primary.colorSplit
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: lnverterStatus.contentMargin
                        Layout.rightMargin: lnverterStatus.contentMargin
                        Layout.topMargin: lnverterStatus.compact ? 18 : 28
                        Layout.bottomMargin: lnverterStatus.compact ? 20 : 32
                        columns: lnverterStatus.gridColumns
                        columnSpacing: lnverterStatus.gridGap
                        rowSpacing: lnverterStatus.compact ? 14 : 18

                        Item {
                            Layout.rowSpan: lnverterStatus.gridColumns === 1 ? 1 : 3
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                            Layout.preferredWidth: lnverterStatus.gridColumns === 1
                                                   ? Math.min(lnverterStatus.availableGridWidth, lnverterStatus.coreSize * 1.3)
                                                   : lnverterStatus.gridColumnWidth
                            Layout.preferredHeight: lnverterStatus.coreBlockHeight

                            MosRectangle {
                                id: inverterCore
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                width: lnverterStatus.coreSize
                                height: width
                                radius: width / 2
                                color: tpinvControl.inverterStateInfo().coreBg
                                border.width: Math.max(2, width * 0.02)
                                border.color: tpinvControl.inverterStateInfo().coreBorder

                                MosText {
                                    anchors.centerIn: parent
                                    text: tpinvControl.inverterStateInfo().icon
                                    color: tpinvControl.inverterStateInfo().accent
                                    font.pixelSize: inverterCore.width * 0.38
                                    font.bold: true
                                }
                            }

                            MosRectangle {
                                anchors.horizontalCenter: inverterCore.horizontalCenter
                                anchors.top: inverterCore.bottom
                                anchors.topMargin: 2
                                width: Math.max(58, inverterCore.width * 0.34)
                                height: lnverterStatus.statusTagHeight
                                radius: height / 2
                                color: tpinvControl.inverterStateInfo().coreBg
                                border.width: 1
                                border.color: tpinvControl.inverterStateInfo().coreBorder

                                MosText {
                                    anchors.centerIn: parent
                                    text: tpinvControl.inverterStateInfo().text
                                    color: tpinvControl.inverterStateInfo().textColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }

                            MosRectangle {
                                anchors.horizontalCenter: inverterCore.horizontalCenter
                                anchors.top: inverterCore.bottom
                                anchors.topMargin: lnverterStatus.statusTagHeight + 8
                                width: Math.min(parent.width, inverterCore.width * 1.18)
                                height: lnverterStatus.summaryTagHeight
                                radius: height / 2
                                color: tpinvControl.fieldBg
                                border.width: 0

                                MosText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: "⚡ 直流输入 " + tpinvControl.fmt(TpInvcontroldata.dcVoltage, 1) + "V · 输出 " + tpinvControl.fmt(TpInvcontroldata.acVoltage, 1) + "V"
                                    color: tpinvControl.accent
                                    font.pixelSize: 12
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredHeight: lnverterStatus.metricHeight
                            radius: MosTheme.Primary.radiusPrimaryLG
                            color: "transparent"
                            border.width: 1
                            border.color: tpinvControl.panelBorder

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 8

                                MosText {
                                    Layout.fillWidth: true
                                    text: "▭  直流电压"
                                    color: tpinvControl.textMuted
                                    font.pixelSize: 12
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MosText {
                                        text: tpinvControl.fmt(TpInvcontroldata.dcVoltage, 1)
                                        color: tpinvControl.textStrong
                                        font.family: "Consolas"
                                        font.pixelSize: lnverterStatus.valueFontSize
                                    }

                                    MosText {
                                        Layout.alignment: Qt.AlignBottom
                                        text: "V"
                                        color: tpinvControl.accent
                                        font.family: "Consolas"
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredHeight: lnverterStatus.metricHeight
                            radius: MosTheme.Primary.radiusPrimaryLG
                            color: "transparent"
                            border.width: 1
                            border.color: tpinvControl.panelBorder

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 8

                                MosText {
                                    Layout.fillWidth: true
                                    text: "交流电压"
                                    color: tpinvControl.textMuted
                                    font.pixelSize: 12
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MosText {
                                        text: tpinvControl.fmt(TpInvcontroldata.acVoltage, 1)
                                        color: tpinvControl.textStrong
                                        font.family: "Consolas"
                                        font.pixelSize: lnverterStatus.valueFontSize
                                    }

                                    MosText {
                                        Layout.alignment: Qt.AlignBottom
                                        text: "V"
                                        color: tpinvControl.accent
                                        font.family: "Consolas"
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredHeight: lnverterStatus.metricHeight
                            radius: MosTheme.Primary.radiusPrimaryLG
                            color: "transparent"
                            border.width: 1
                            border.color: tpinvControl.panelBorder

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 8

                                MosText {
                                    Layout.fillWidth: true
                                    text: "交流频率"
                                    color: tpinvControl.textMuted
                                    font.pixelSize: 12
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MosText {
                                        text: tpinvControl.fmt(TpInvcontroldata.acFrequency, 2)
                                        color: tpinvControl.textStrong
                                        font.family: "Consolas"
                                        font.pixelSize: lnverterStatus.valueFontSize
                                    }

                                    MosText {
                                        Layout.alignment: Qt.AlignBottom
                                        text: "Hz"
                                        color: tpinvControl.accent
                                        font.family: "Consolas"
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: lnverterStatus.gridColumns
                            Layout.preferredHeight: lnverterStatus.compact ? 68 : 78
                            radius: MosTheme.Primary.radiusPrimaryLG
                            color: MosTheme.Primary.colorWarningBg
                            border.width: 2
                            border.color: MosTheme.Primary.colorWarningBorder

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                anchors.topMargin: 12
                                anchors.bottomMargin: 10
                                spacing: 8

                                MosText {
                                    Layout.fillWidth: true
                                    text: "⚠ 故障码"
                                    color: tpinvControl.textMuted
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                MosText {
                                    Layout.fillWidth: true
                                    text: {
                                        const code = TpInvcontroldata.faultCode
                                        const normal = code === "0x00000000" || code === "0x0000"
                                        return code + "   (" + (normal ? "正常" : "故障") + ")"
                                    }
                                    color: MosTheme.Primary.colorWarningText
                                    font.family: "Consolas"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                        }
                    }

                }
            }

            MosRectangle {
                id: dataMonitorPanel
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                implicitHeight: dataMonitorLayout.implicitHeight
                Layout.preferredHeight: dataMonitorPanel.implicitHeight

                color: "transparent"
                border.width: 1
                border.color: tpinvControl.panelBorder
                radius: MosTheme.Primary.radiusPrimaryLG
                clip: true

                readonly property bool compact: width < 680
                readonly property real contentMargin: Math.max(12, Math.min(28, width * 0.04))

                ColumnLayout {
                    id: dataMonitorLayout
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        Layout.leftMargin: dataMonitorPanel.contentMargin
                        Layout.rightMargin: dataMonitorPanel.contentMargin
                        spacing: 10

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "▦"
                            color: tpinvControl.accent
                            font.pixelSize: 25
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: "数据监测"
                            color: tpinvControl.textStrong
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            text: "实时采样"
                            colorBg: MosTheme.Primary.colorPrimaryBg
                            colorBorder: MosTheme.Primary.colorPrimaryBorder
                            colorText: MosTheme.Primary.colorPrimaryText
                            radiusBg.all: implicitHeight / 2
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: MosTheme.Primary.colorSplit
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: dataMonitorPanel.contentMargin
                        Layout.rightMargin: dataMonitorPanel.contentMargin
                        Layout.topMargin: 16
                        Layout.bottomMargin: 18
                        columns: dataMonitorPanel.compact ? 1 : 2
                        columnSpacing: 12
                        rowSpacing: 12

                        Repeater {
                            model: TpInvcontroldata.monitorGroups

                            delegate: MosRectangle {
                                id: monitorGroup
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: monitorGroupLayout.implicitHeight + 24
                                Layout.preferredHeight: implicitHeight
                                radius: MosTheme.Primary.radiusPrimaryLG
                                color: tpinvControl.panelBg
                                border.width: 1
                                border.color: tpinvControl.panelBorder
                                clip: true

                                ColumnLayout {
                                    id: monitorGroupLayout
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        MosRectangle {
                                            Layout.preferredWidth: 4
                                            Layout.preferredHeight: 16
                                            radius: 2
                                            color: monitorGroup.modelData.accent
                                            border.width: 0
                                        }

                                        MosText {
                                            Layout.fillWidth: true
                                            text: monitorGroup.modelData.title
                                            color: tpinvControl.textStrong
                                            font.pixelSize: 15
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: monitorGroup.width < 360 ? 1 : 2
                                        columnSpacing: 8
                                        rowSpacing: 8

                                        Repeater {
                                            model: monitorGroup.modelData.items

                                            delegate: MosRectangle {
                                                id: monitorCell
                                                required property var modelData

                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 38
                                                radius: MosTheme.Primary.radiusPrimaryLG
                                                color: tpinvControl.fieldBg
                                                border.width: 1
                                                border.color: tpinvControl.panelBorder

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 10
                                                    anchors.rightMargin: 10
                                                    spacing: 8

                                                    MosText {
                                                        Layout.alignment: Qt.AlignVCenter
                                                        Layout.fillWidth: true
                                                        Layout.minimumWidth: 0
                                                        text: monitorCell.modelData.name
                                                        color: tpinvControl.textMuted
                                                        font.pixelSize: 12
                                                        elide: Text.ElideRight
                                                    }

                                                    MosText {
                                                        Layout.alignment: Qt.AlignVCenter
                                                        text: tpinvControl.fmtByUnit(monitorCell.modelData.value, monitorCell.modelData.unit)
                                                        color: tpinvControl.textStrong
                                                        font.family: "Consolas"
                                                        font.pixelSize: 15
                                                        font.bold: true
                                                    }

                                                    MosText {
                                                        Layout.alignment: Qt.AlignVCenter
                                                        text: monitorCell.modelData.unit
                                                        color: tpinvControl.accent
                                                        font.pixelSize: 11
                                                        visible: text !== ""
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    function updateTime() {
        var date = new Date();
        currentTime = Qt.formatTime(date, "hh:mm:ss");
    }

    Component.onCompleted: {
        updateTime()
        refreshControlSerialPorts()
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: tpinvControl.updateTime()
    }

    Timer {
        id: dataTimer
        interval: 1000
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            TpinvControlProcess.controntroldataProcess()
        }
    }

    Timer {
        id: paramWriteTimer
        interval: 800
        repeat: false
        onTriggered: {
            tpinvControl.parametersWriting = false
        }
    }

    Timer {
        id: applyCooldownTimer
        interval: 300
        repeat: false
        onTriggered: {
            tpinvControl.applyingNow = false
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true

        ScrollBar.vertical: MosScrollBar {
            anchors.right: parent.right
        }
        ColumnLayout {
            id: contentColumn
            width: flickable.width
            GridLayout {
                id: controlGridtop
                Layout.fillWidth: true
                columns: flickable.width < 650 ? 1 : 2
                columnSpacing: 0
                rowSpacing: 0
                flow: GridLayout.LeftToRight

                ColumnLayout {
                    Layout.fillWidth: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        spacing: 8
                        MosIconText {
                            Layout.alignment: Qt.AlignVCenter
                            iconSource: MosIcon.SettingsOutlined
                            iconSize: 31
                            color: tpinvControl.textStrong
                        }
                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "三相逆变智能管理站"
                            color: tpinvControl.textStrong
                            font.pixelSize: 30
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "·"
                            color: tpinvControl.accent
                            font.pixelSize: 30
                            font.bold: true
                        }

                        MosText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: "动态能量中枢"
                            color: tpinvControl.accent
                            font.pixelSize: 30
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }
                    MosRectangle {
                        Layout.rightMargin: 20
                        Layout.leftMargin: 20
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: 350
                        Layout.maximumWidth: 400
                        Layout.preferredHeight: 34
                        radius: MosTheme.Primary.radiusPrimaryLG
                        color: MosTheme.Primary.colorPrimaryBg
                        border.width: 1
                        border.color: MosTheme.Primary.colorPrimaryBorder

                        RowLayout {
                            id: modeRow
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 14
                            spacing: 8

                            MosText {
                                Layout.alignment: Qt.AlignVCenter
                                text: "↻"
                                color: MosTheme.Primary.colorPrimaryText
                                font.pixelSize: 17
                                font.bold: true
                            }

                            MosText {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: true
                                text: "工作模式： 三相逆变 | 空间矢量调制 + 实时能效分析"
                                color: MosTheme.Primary.colorPrimaryText
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
                

                MosRectangle {
                    Layout.preferredWidth: 118
                    Layout.preferredHeight: 34
                    Layout.alignment: controlGridtop.columns === 1 ? Qt.AlignLeft : Qt.AlignRight
                    Layout.leftMargin: controlGridtop.columns === 1 ? 20 : 0

                    
                    radius: MosTheme.Primary.radiusPrimaryLG
                    color: tpinvControl.panelBg
                    border.width: 1
                    border.color: tpinvControl.panelBorder

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "◷"
                            color: tpinvControl.textStrong
                            font.pixelSize: 17
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: tpinvControl.currentTime
                            color: tpinvControl.textStrong
                            font.family: "Consolas"
                            font.pixelSize: 13
                        }
                    }
                }
            }

            GridLayout {
                id: controlGrid
                Layout.fillWidth: true
                columns: flickable.width < tpinvControl.contentCompactBreakpoint ? 1 : 2
                columnSpacing: 0
                rowSpacing: 0
                flow: GridLayout.LeftToRight

                Loader {
                    id: leftloader
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.preferredWidth: controlGrid.columns === 1 ? controlGrid.width : 380
                    Layout.maximumWidth: controlGrid.columns === 1 ? controlGrid.width : 390
                    Layout.minimumWidth: controlGrid.columns === 1 ? 0 : 360
                    Layout.preferredHeight: item && item.implicitHeight > 0 ? item.implicitHeight : 240
                    active: true
                    sourceComponent: tpinvControl.leftloaderComponent
                }

                Loader {
                    id: rightloader
                    Layout.alignment: Qt.AlignTop
                    Layout.minimumWidth: controlGrid.columns === 1 ? 200 : 400
                    Layout.fillWidth: true
                    Layout.preferredHeight: item && item.implicitHeight > 0 ? item.implicitHeight : 240
                    active: true
                    sourceComponent: tpinvControl.rightloaderComponent
                }
            }
        }
    }
}
