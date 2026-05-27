pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: tpinvControl
    color: "transparent"
    anchors.fill: parent

    property string currentTime: ""
    property int contentCompactBreakpoint: 820
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
                border.color: "#244b87"
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
                            color: "#2f8dff"
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "参数设置"
                            color: "#f4f8ff"
                            font.pixelSize: 20
                            font.bold: true
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: "#263852"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        spacing: 13

                        Repeater {
                            model: [
                                { icon: "▭", label: "直流电压有效值", value: 15, stepper: false },
                                { icon: "", label: "额定频率(Hz)", value: 50, stepper: false },
                                { icon: "", label: "交流电压设定(V)", value: 220, stepper: true },
                                { icon: "▰", label: "交流电压步长(V)", value: 1, stepper: false },
                                { icon: "◒", label: "交流频率给定(Hz)", value: 50, stepper: false }
                            ]

                            delegate: RowLayout {
                                id: parameterRow
                                required property var modelData

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
                                        color: "#cfd8e7"
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    MosText {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        Layout.alignment: Qt.AlignVCenter
                                        text: parameterRow.modelData.label
                                        color: "#cfd8e7"
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }
                                MosInputNumber {
                                    Layout.minimumWidth: 130
                                    Layout.preferredWidth: 130
                                    Layout.maximumWidth: 130
                                    Layout.minimumHeight: 34
                                    Layout.preferredHeight: 34
                                    Layout.maximumHeight: 34
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    value: parameterRow.modelData.value
                                    min: 0
                                    step: 0.1
                                    precision: 1
                                    clip: true
                                    useKeyboard: true
                                    colorBg: 'transparent'
                                    colorBorder: '#244b87'

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
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: "✓  确认"
                                type: MosButton.Type_Primary
                                sizeHint: "normal"
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                            }

                            MosButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: "↻  立即设置"
                                type: MosButton.Type_Outlined
                                sizeHint: "normal"
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
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
                border.color: "#244b87"
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
                            color: "#2f8dff"
                            font.pixelSize: 21
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "串口通信 · 高级调试"
                            color: "#f4f8ff"
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
                            border.color: "#244b87"
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "🔗"
                                    color: "#f4f8ff"
                                    font.pixelSize: 18
                                }

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: "连接状态:"
                                    color: "#f4f8ff"
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                MosText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "● 未连接"
                                    color: "#ff801f"
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
                                model: [
                                    { label: "COM1", value: "COM1" },
                                    { label: "COM2", value: "COM2" },
                                    { label: "COM3", value: "COM3" }
                                ]
                                currentIndex: 0
                                clearEnabled: false
                                colorBg: "transparent"
                                colorBorder: "#244b87"
                                colorText: "#f4f8ff"
                                radiusBg.all: 17
                                font.family: "Consolas"
                                font.pixelSize: 13
                            }

                            MosSelect {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                model: [
                                    { label: "9600", value: 9600 },
                                    { label: "19200", value: 19200 },
                                    { label: "38400", value: 38400 },
                                    { label: "115200", value: 115200 }
                                ]
                                currentIndex: 0
                                clearEnabled: false
                                colorBg: "transparent"
                                colorBorder: "#244b87"
                                colorText: "#f4f8ff"
                                radiusBg.all: 17
                                font.family: "Consolas"
                                font.pixelSize: 13
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            MosButton {

                                Layout.preferredHeight: 40
                                text: "▣  连接"
                                type: MosButton.Type_Primary
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                            }

                            MosButton {
                                Layout.preferredHeight: 40
                                text: "⌘  断开"
                                type: MosButton.Type_Outlined
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                            }

                            MosButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                text: "◢  请求参数"
                                type: MosButton.Type_Outlined
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
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
                border.color: "#244b87"
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
                            color: "#2f8dff"
                            font.pixelSize: 26
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: "运行控制 · 故障诊断"
                            color: "#f4f8ff"
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: "#263852"
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
                                    color: "#f4f8ff"
                                    font.pixelSize: 16
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                MosRectangle {
                                    Layout.preferredWidth: 108
                                    Layout.preferredHeight: 44
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: height / 2
                                    color: "lightblue"
                                    border.width: 0

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        MosText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: "●"
                                            color: "#ff4d57"
                                            font.pixelSize: 19
                                        }

                                        MosText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: "未启动"
                                            color: "#4A90E2"
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
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: "▶  启动"
                                type: MosButton.Type_Primary
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                            }

                            MosButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                text: "■  停机"
                                type: MosButton.Type_Outlined
                                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                                font.bold: true
                            }
                        }

                        MosRectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 62
                            radius: MosTheme.Primary.radiusPrimaryLG
                            color: 'lightblue'
                            border.width: 0

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                anchors.topMargin: 10
                                anchors.bottomMargin: 8
                                spacing: 2

                                MosText {
                                    Layout.fillWidth: true
                                    text: "⚠ 未运行"
                                    color: "#4A90E2"
                                    font.pixelSize: 16
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                MosText {
                                    Layout.fillWidth: true
                                    text: "系统正常，三相平衡"
                                    color: "#4A90E2"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
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
                border.color: "#244b87"
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
                            color: "#2f8dff"
                            font.pixelSize: lnverterStatus.compact ? 30 : 38
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: "逆变器状态监测"
                            color: "#f4f8ff"
                            font.pixelSize: lnverterStatus.compact ? 21 : 26
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: implicitHeight
                            text: "↻ 工作模式: 三相逆变"
                            colorBg: "#123165"
                            colorBorder: "#2f7dff"
                            colorText: "#07101f"
                            radiusBg.all: implicitHeight / 2
                            font.pixelSize: 12
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: "#263852"
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
                                color: "#214d73"
                                border.width: Math.max(2, width * 0.02)
                                border.color: "#3279dc"

                                MosText {
                                    anchors.centerIn: parent
                                    text: "▣"
                                    color: "#4b91ff"
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
                                color: "#07101f"
                                border.width: 0

                                MosText {
                                    anchors.centerIn: parent
                                    text: "运行中"
                                    color: "#1071e7"
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
                                color: "#07101f"
                                border.width: 0

                                MosText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: "⚡ 直流输入 0.0V · 输出 0.0V"
                                    color: '#1071e7'
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
                            border.color: "#244b87"

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
                                    color: "#9ca8ba"
                                    font.pixelSize: 12
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MosText {
                                        text: "0.0"
                                        color: "#05070b"
                                        font.family: "Consolas"
                                        font.pixelSize: lnverterStatus.valueFontSize
                                    }

                                    MosText {
                                        Layout.alignment: Qt.AlignBottom
                                        text: "V"
                                        color: "#2f8dff"
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
                            border.color: "#244b87"

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
                                    color: "#9ca8ba"
                                    font.pixelSize: 12
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MosText {
                                        text: "0.0"
                                        color: "#05070b"
                                        font.family: "Consolas"
                                        font.pixelSize: lnverterStatus.valueFontSize
                                    }

                                    MosText {
                                        Layout.alignment: Qt.AlignBottom
                                        text: "V"
                                        color: "#2f8dff"
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
                            border.color: "#244b87"

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
                                    color: "#9ca8ba"
                                    font.pixelSize: 12
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MosText {
                                        text: "0.00"
                                        color: "#05070b"
                                        font.family: "Consolas"
                                        font.pixelSize: lnverterStatus.valueFontSize
                                    }

                                    MosText {
                                        Layout.alignment: Qt.AlignBottom
                                        text: "Hz"
                                        color: "#2f8dff"
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
                            color: "#352321"
                            border.width: 2
                            border.color: "#ff801f"

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
                                    color: "#9ca8ba"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                MosText {
                                    Layout.fillWidth: true
                                    text: "0x0000   (正常)"
                                    color: "#05070b"
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
                border.color: "#244b87"
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
                            color: "#2f8dff"
                            font.pixelSize: 25
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: "数据监测"
                            color: "#f4f8ff"
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosTag {
                            Layout.alignment: Qt.AlignVCenter
                            text: "实时采样"
                            colorBg: "#10284d"
                            colorBorder: "#244b87"
                            colorText: "#9fc6ff"
                            radiusBg.all: implicitHeight / 2
                        }
                    }

                    MosDivider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        colorSplit: "#263852"
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
                            model: [
                                {
                                    title: "电压监测",
                                    accent: "#2f8dff",
                                    items: [
                                        { name: "直流电压", value: "0.0", unit: "V" },
                                        { name: "半母线电压", value: "0.0", unit: "V" },
                                        { name: "A相电压", value: "0.0", unit: "V" },
                                        { name: "B相电压", value: "0.0", unit: "V" },
                                        { name: "C相电压", value: "0.0", unit: "V" }
                                    ]
                                },
                                {
                                    title: "电流监测",
                                    accent: "#37d6a3",
                                    items: [
                                        { name: "直流电流", value: "0.0", unit: "A" },
                                        { name: "A相电流", value: "0.0", unit: "A" },
                                        { name: "B相电流", value: "0.0", unit: "A" },
                                        { name: "C相电流", value: "0.0", unit: "A" }
                                    ]
                                },
                                {
                                    title: "频率与功率",
                                    accent: "#f7b955",
                                    items: [
                                        { name: "A相频率", value: "0.00", unit: "Hz" },
                                        { name: "B相频率", value: "0.00", unit: "Hz" },
                                        { name: "C相频率", value: "0.00", unit: "Hz" },
                                        { name: "直流侧功率", value: "0.0", unit: "W" },
                                        { name: "交流有功功率", value: "0.0", unit: "W" },
                                        { name: "交流无功功率", value: "0.0", unit: "var" },
                                        { name: "交流视在功率", value: "0.0", unit: "VA" },
                                        { name: "功率因数", value: "0.00", unit: "" },
                                        { name: "效率", value: "0.0", unit: "%" }
                                    ]
                                },
                                {
                                    title: "三相功率",
                                    accent: "#b88cff",
                                    items: [
                                        { name: "A相有功功率", value: "0.0", unit: "W" },
                                        { name: "B相有功功率", value: "0.0", unit: "W" },
                                        { name: "C相有功功率", value: "0.0", unit: "W" },
                                        { name: "A相无功功率", value: "0.0", unit: "var" },
                                        { name: "B相无功功率", value: "0.0", unit: "var" },
                                        { name: "C相无功功率", value: "0.0", unit: "var" },
                                        { name: "A相视在功率", value: "0.0", unit: "VA" },
                                        { name: "B相视在功率", value: "0.0", unit: "VA" },
                                        { name: "C相视在功率", value: "0.0", unit: "VA" }
                                    ]
                                },
                                {
                                    title: "温度与版本",
                                    accent: "#ff8a4c",
                                    items: [
                                        { name: "环境温度", value: "0.0", unit: "℃" },
                                        { name: "辅源温度", value: "0.0", unit: "℃" },
                                        { name: "IGBT温度", value: "0.0", unit: "℃" },
                                        { name: "硬件版本号", value: "--", unit: "" },
                                        { name: "软件版本号", value: "--", unit: "" }
                                    ]
                                },
                                {
                                    title: "诊断状态",
                                    accent: "#ff5f68",
                                    items: [
                                        { name: "故障码", value: "0x0000", unit: "" }
                                    ]
                                }
                            ]

                            delegate: MosRectangle {
                                id: monitorGroup
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: monitorGroupLayout.implicitHeight + 24
                                Layout.preferredHeight: implicitHeight
                                radius: MosTheme.Primary.radiusPrimaryLG
                                color: "#091222"
                                border.width: 1
                                border.color: "#1d3f72"
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
                                            color: "#f4f8ff"
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
                                                color: "#07101f"
                                                border.width: 1
                                                border.color: "#203a63"

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
                                                        color: "#9ca8ba"
                                                        font.pixelSize: 12
                                                        elide: Text.ElideRight
                                                    }

                                                    MosText {
                                                        Layout.alignment: Qt.AlignVCenter
                                                        text: monitorCell.modelData.value
                                                        color: "#f4f8ff"
                                                        font.family: "Consolas"
                                                        font.pixelSize: 15
                                                        font.bold: true
                                                    }

                                                    MosText {
                                                        Layout.alignment: Qt.AlignVCenter
                                                        text: monitorCell.modelData.unit
                                                        color: "#2f8dff"
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

    Component.onCompleted: updateTime()

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: tpinvControl.updateTime()
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
                            color: "#dbe8ff"
                        }
                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "三相逆变智能管理站"
                            color: "#dbe8ff"
                            font.pixelSize: 30
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "·"
                            color: "#38aafc"
                            font.pixelSize: 30
                            font.bold: true
                        }

                        MosText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: "动态能量中枢"
                            color: "#36b2ff"
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
                        color: "#10284d"
                        border.width: 1
                        border.color: "#2d5f9e"

                        RowLayout {
                            id: modeRow
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 14
                            spacing: 8

                            MosText {
                                Layout.alignment: Qt.AlignVCenter
                                text: "↻"
                                color: "#eef6ff"
                                font.pixelSize: 17
                                font.bold: true
                            }

                            MosText {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: true
                                text: "工作模式： 三相逆变 | 空间矢量调制 + 实时能效分析"
                                color: "#f2f7ff"
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
                    color: "#10182a"
                    border.width: 1
                    border.color: "#3b4e70"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "◷"
                            color: "#eef6ff"
                            font.pixelSize: 17
                            font.bold: true
                        }

                        MosText {
                            Layout.alignment: Qt.AlignVCenter
                            text: tpinvControl.currentTime
                            color: "#eef6ff"
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
