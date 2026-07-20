import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic
import "./Controls"

Item {
    id: root
    width: 290
    implicitWidth: width
    property real yali_pressure: 6.5
    property real wendu_temperature: 46.9
    property int heatStatus: 0  // 0=停止(灰), 1=加热(绿), 2=故障(红)

    // ── 连接弹窗 ──
    ConnectDialog {
        id: connectDialog
        onConnectRequested: function(host, secondaryHost) {
            K3Client.host = host
            if (secondaryHost !== "") {
                K3Client.secondaryHost = secondaryHost
            }
            connectDeferTimer.start()
        }
    }

    // ── 参数设置弹窗 ──
    ParamSettingsWin { id: paramSettingsWin }

    // ── 硬件监控弹窗 ──
    HardwareMonitorWin { id: hardwareMonitorWin }

    // ── 报告输出弹窗 ──
    ReportOutputWin { id: reportOutputWin }

    // ── 节流阀校准弹窗 ──
    CalibrationWin { id: calibrationWin }

    Timer {
        id: connectDeferTimer
        interval: 1
        repeat: false
        onTriggered: K3Client.safeConnectToHost()
    }

    // ── 监听 K3Client 事件，反馈给弹窗 ──
    Connections {
        target: K3Client

        function onIsConnectedChanged() {
            if (K3Client.isConnected && connectDialog.opened) {
                connectDialog.showSuccess()
            }
        }
        function onErrorOccurred(message) {
            if (connectDialog.opened) {
                connectDialog.showError("连接失败: " + message)
            }
        }
    }

    MosRectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: MosTheme.Primary.colorSplit
        border.width: 1
    }
    MosSpace {
        anchors.fill: parent
        layout: 'ColumnLayout'
        spacing: 0

        // 启动，退出，最大化，最小化
        MosFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            Layout.alignment: Qt.AlignTop
            borderWidth: 1
            MosSpace {
                anchors.fill: parent
                anchors.margins: 6
                layout: 'RowLayout'
                spacing: 4
                MosSpace {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    layout: 'RowLayout'
                    spacing: 5
                    MosIconButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 70
                        iconSource: MosIcon.UserOutlined
                        text: "启动"
                        radiusBg: MosRadius { all: 0 }
                        onClicked: connectDialog.open()
                    }
                    MosIconButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 70
                        iconSource: MosIcon.PowerswitchOutlined
                        text: "退出"
                        radiusBg: MosRadius { all: 0 }
                        onClicked: {
                            if (plcappwindow) plcappwindow.close()
                        }
                    }
                }
                MosSpace {
                    id: column1
                    Layout.fillHeight: true
                    Layout.preferredWidth: 28
                    layout: 'ColumnLayout'
                    spacing: 5
                    MosIconButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        iconSource: MosIcon.WindowMinimizeOutlined
                        // sizeHint: 'small'
                        sizeRatio: 0.5

                        iconSize: 10
                        radiusBg: MosRadius { all: 0 }
                        onClicked:{
                            if (plcappwindow) {
                                MosApi.setWindowState(plcappwindow, Qt.WindowMinimized);
                            }
                        }
                    }
                    MosIconButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        iconSource: plcappwindow.visibility === Window.Maximized ? MosIcon.SmallwindowOutlined : MosIcon.WindowMaximizeOutlined
                        // sizeHint: 'small'
                        sizeRatio: 0.5

                        iconSize: 10
                        radiusBg: MosRadius { all: 0 }
                        onClicked: {
                            if (!plcappwindow) return

                            if (plcappwindow.visibility === Window.Maximized ||
                                    plcappwindow.visibility === Window.FullScreen) {
                                plcappwindow.showNormal()
                            } else {
                                plcappwindow.showMaximized()
                            }
                        }
                    }
                }
            }
        }
        // 时钟
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignTop
            MosLabel {
                id: clockLabel
                anchors.centerIn: parent
                colorBg: "transparent"
                colorBorder: "transparent"
                color: "white"
                font.pixelSize: 16
            }
            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    clockLabel.text = Qt.formatDateTime(new Date(), "yyyy/MM/dd hh:mm:ss")
                }
            }
        }
        // 运行状态
        MosFrame {
            Layout.fillWidth: true
            Layout.minimumHeight: 30
            Layout.preferredHeight: root.height * 0.06
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            Layout.alignment: Qt.AlignTop
            borderWidth: 1
            MosLabel {
                anchors.centerIn: parent
                text: "正常运行"
                colorBg: "transparent"
                colorBorder: "transparent"
                color: "#FFFFC738"
                font.pixelSize: 22
                font.bold: true
            }
        }
        // 各种参数
        MosFrame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 118
            Layout.preferredHeight: root.height * 0.25
            colorBg: "transparent"
            colorBorder: "transparent"
            borderWidth: 0
            leftPadding: 20
            rightPadding: 20
            MosSpace {
                id: column2
                layout: 'ColumnLayout'
                anchors.fill: parent
                topPadding: 10
                bottomPadding: 10
                spacing: 5
                uniformCellSizes: true
                Repeater {
                    model: [
                        { name: "井底压力模式" , value: K3data.flag_model_downhole },
                        { name: "井口压力模式" , value: K3data.flag_model_ground },
                        { name: "回压过高保护" , value: K3data.flag_high_backpressure },
                        { name: "启用A阀" , value: K3data.flag_valve_a },
                        { name: "启用B阀" , value: K3data.flag_valve_b },
                        { name: "启用C阀" , value: K3data.flag_valve_c },
                        { name: "启用板A" , value: K3data.flag_board },
                        { name: "启用板B" , value: !K3data.flag_board }
                    ]
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 12
                        MosCheckBox {
                            Layout.fillWidth: true
                            enabled: false
                            text: modelData.name
                            colorText: "white"
                            checked: modelData.value
                            indicatorSize: 10
                            radiusIndicator: MosRadius { all: 99 }
                        }
                        Item { Layout.fillWidth: true }
                        MosRectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 5
                            color: modelData.value ? 'red' : "gray"
                        }
                    }
                }
            }
        }

        /*
        按键控制
        */
        MosFrame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 88
            Layout.preferredHeight: root.height * 0.18
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            topPadding: 10
            bottomPadding: 10
            leftPadding: 20
            rightPadding: 20
            MosSpace {
                id: column3
                anchors.fill: parent
                layout: 'ColumnLayout'
                spacing: 3
                uniformCellSizes: true
                Repeater {
                    model: [
                        {name: "参数设置"},
                        {name: "硬件监控"},
                        {name: "报告输出"},
                        {name: "节流阀校准"},
                    ]
                    delegate: MosButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 20
                        text: modelData.name
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        radiusBg: MosRadius { all: 0 }
                        onClicked: {
                            switch (index) {
                            case 0: paramSettingsWin.open(); break
                            case 1: hardwareMonitorWin.open(); break
                            case 2: reportOutputWin.open(); break
                            case 3: calibrationWin.open(); break
                            }
                        }
                    }
                }
            }
        }
        /*
        液压站数据
        */

        MosGroupBox{
            title: "液压站数据"
            borderWidth: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 80
            Layout.preferredHeight: root.height * 0.16
            Layout.alignment: Qt.AlignBottom
           
            MosSpace{
                anchors.fill: parent
                layout: 'ColumnLayout'
                topPadding: 4
                bottomPadding: 4
                leftPadding: 5
                rightPadding: 5
                spacing: 4
                MosSpace{
                    id: row1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 34
                    Layout.preferredHeight: 54
                    layout: 'RowLayout'
                    MosLabel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: "压力（MPa）\n" + root.yali_pressure.toFixed(1)
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }
                    MosLabel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: "温度（°C）\n" + root.wendu_temperature.toFixed(1)
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
                MosSpace{
                    layout: 'RowLayout'
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 24
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spacing: 6
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        id: heatLight
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                        radius: 6
                        color: {
                            switch (root.heatStatus) {
                            case 1: return "lime"
                            case 2: return "red"
                            default: return "gray"
                            }
                        }
                    }
                    MosLabel {
                        text: {
                            switch (root.heatStatus) {
                            case 1: return "加热运行"
                            case 2: return "加热故障"
                            default: return "加热停止"
                            }
                        }
                        colorBorder: "transparent"
                        color: "white"
                        font.pixelSize: 16
                        colorBg: "transparent"
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }
        MosFrame{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 80
            Layout.preferredHeight: root.height * 0.17
            Layout.alignment: Qt.AlignBottom
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            topPadding:20
            bottomPadding: 10
            MosSpace {
                id: column4
                anchors.fill: parent
                layout: 'ColumnLayout'
                spacing: 0
                uniformCellSizes: true
                Repeater {
                    model: [
                        {name: "气源压力\n" + "743KPa"},
                        {name: "油箱低液位报警"},
                    ]
                    delegate: MosLabel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 32
                        text: modelData.name
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        radiusBg: MosRadius { all: 0 }
                    }
                }
            }
        }
    }
}