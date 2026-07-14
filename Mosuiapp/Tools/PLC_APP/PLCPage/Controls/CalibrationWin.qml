pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosModal {
    id: root

    title: "节流阀校准"
    confirmText: ""
    cancelText: ""
    closable: true
    maskClosable: true
    implicitWidth: 720
    implicitHeight: 450

    // ── 各阀限值 ──
    property string downLimitA: "5"
    property string upLimitA: "5"
    property string downLimitB: "5"
    property string upLimitB: "5"
    property string downLimitC: "5"
    property string upLimitC: "5"

    // ── 写入 PLC ──
    function writeCalibration(downLimit, upLimit, startIndex) {
        K3Client.dbWriteReal(parseFloat(downLimit), 123, startIndex)
        K3Client.dbWriteReal(parseFloat(upLimit), 123, startIndex + 1)
    }

    // ═══════════════════════════════════════════
    //  内容
    // ═══════════════════════════════════════════
    contentDelegate: Item {
        implicitWidth: root.implicitWidth
        implicitHeight: contentColumn.implicitHeight + 38

        ColumnLayout {
            id: contentColumn
            width: parent.width - 48
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 14
            spacing: 14

            // 校准说明
            MosFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: 66
                padding: 0
                colorBg: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.08)
                colorBorder: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.36)
                borderWidth: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        Layout.alignment: Qt.AlignVCenter
                        radius: 10
                        color: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.16)

                        MosIconText {
                            anchors.centerIn: parent
                            iconSource: MosIcon.SettingsOutlined
                            iconSize: 20
                            color: MosTheme.Primary.colorPrimary
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 3

                        MosLabel {
                            Layout.fillWidth: true
                            text: "设置阀门行程上下限"
                            colorText: MosTheme.Primary.colorTextPrimary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: "分别设置 A、B、C 阀参数，确认后将对应数值写入 PLC"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 12
                        }
                    }
                }
            }

            // ── 三阀校准区域 ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // ── A 阀 ──
                CalibrationPanel {
                    Layout.fillWidth: true
                    valveCode: "A"
                    title: "A 阀校准"
                    downLimit: root.downLimitA
                    upLimit: root.upLimitA
                    onDownLimitEdited: (downLimit) => { root.downLimitA = downLimit }
                    onUpLimitEdited: (upLimit) => { root.upLimitA = upLimit }
                    onConfirm: () => { root.writeCalibration(root.downLimitA, root.upLimitA, 1) }
                }

                // ── B 阀 ──
                CalibrationPanel {
                    Layout.fillWidth: true
                    valveCode: "B"
                    title: "B 阀校准"
                    downLimit: root.downLimitB
                    upLimit: root.upLimitB
                    onDownLimitEdited: (downLimit) => { root.downLimitB = downLimit }
                    onUpLimitEdited: (upLimit) => { root.upLimitB = upLimit }
                    onConfirm: () => { root.writeCalibration(root.downLimitB, root.upLimitB, 3) }
                }

                // ── C 阀 ──
                CalibrationPanel {
                    Layout.fillWidth: true
                    valveCode: "C"
                    title: "C 阀校准"
                    downLimit: root.downLimitC
                    upLimit: root.upLimitC
                    onDownLimitEdited: (downLimit) => { root.downLimitC = downLimit }
                    onUpLimitEdited: (upLimit) => { root.upLimitC = upLimit }
                    onConfirm: () => { root.writeCalibration(root.downLimitC, root.upLimitC, 5) }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: MosTheme.Primary.colorSplit
            }

            // 底部提示与操作
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MosIconText {
                    iconSource: MosIcon.InfoCircleOutlined
                    iconSize: 15
                    color: MosTheme.Primary.colorWarning
                }

                MosLabel {
                    Layout.fillWidth: true
                    text: "执行校准前，请确认阀门处于安全操作状态"
                    colorText: MosTheme.Primary.colorTextSecondary
                    colorBg: "transparent"
                    colorBorder: "transparent"
                    font.pixelSize: 12
                }

                MosIconButton {
                    Layout.preferredWidth: 88
                    Layout.preferredHeight: 36
                    text: "退出"
                    iconSource: MosIcon.IcoMoonExit
                    font.pixelSize: 13
                    type: MosButton.Type_Default
                    onClicked: root.close()
                }
            }
        }
    }

    // ═══════════════════════════════════════════
    //  单个阀校准面板组件
    // ═══════════════════════════════════════════
    component CalibrationPanel: MosFrame {
        id: panel

        property string valveCode: ""
        property string title: ""
        property string downLimit: "5"
        property string upLimit: "5"
        readonly property bool valuesValid: !isNaN(parseFloat(downLimit))
                                            && !isNaN(parseFloat(upLimit))
        signal downLimitEdited(string downLimit)
        signal upLimitEdited(string upLimit)
        signal confirm()

        implicitHeight: 232
        padding: 0
        colorBg: MosTheme.Primary.colorFillQuaternary
        colorBorder: MosTheme.Primary.colorSplit
        borderWidth: 1
        radiusBg: MosRadius { all: 8 }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 标题
            MosFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                padding: 0
                colorBg: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.12)
                colorBorder: "transparent"
                borderWidth: 0
                radiusBg: MosRadius {
                    topLeft: 8
                    topRight: 8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        radius: 16
                        color: MosTheme.Primary.colorPrimary

                        MosText {
                            anchors.centerIn: parent
                            text: panel.valveCode
                            color: "white"
                            font.pixelSize: 15
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        MosLabel {
                            Layout.fillWidth: true
                            text: panel.title
                            colorText: MosTheme.Primary.colorTextPrimary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: "行程限值设置"
                            colorText: MosTheme.Primary.colorTextTertiary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 11
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: MosTheme.Primary.colorSplit
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 9

                    // 低限
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MosLabel {
                            Layout.preferredWidth: 48
                            text: "低限值"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }

                        MosInput {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            text: panel.downLimit
                            colorText: MosTheme.Primary.colorTextPrimary
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            onTextChanged: panel.downLimitEdited(text)
                        }
                    }

                    // 高限
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MosLabel {
                            Layout.preferredWidth: 48
                            text: "高限值"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }

                        MosInput {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            text: panel.upLimit
                            colorText: MosTheme.Primary.colorTextPrimary
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            onTextChanged: panel.upLimitEdited(text)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: panel.valuesValid
                                   ? MosTheme.Primary.colorSuccess
                                   : MosTheme.Primary.colorError
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: panel.valuesValid ? "参数就绪" : "请输入有效数值"
                            colorText: panel.valuesValid
                                       ? MosTheme.Primary.colorTextTertiary
                                       : MosTheme.Primary.colorError
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 11
                        }
                    }

                    MosIconButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        text: "写入校准"
                        iconSource: MosIcon.SaveOutlined
                        font.pixelSize: 13
                        type: MosButton.Type_Primary
                        enabled: panel.valuesValid
                        onClicked: panel.confirm()
                    }
                }
            }
        }
    }
}
··