pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosModal {
    id: root

    // ── 窗口 ──
    title: "参数设置"
    confirmText: ""
    cancelText: ""
    closable: true
    maskClosable: true
    implicitWidth: 430
    implicitHeight: 570

    // ═══════════════════════════════════════════
    //  基础参数
    // ═══════════════════════════════════════════
    property string presY: "5"
    property string flowY: "60"

    // ═══════════════════════════════════════════
    //  高级参数（PLC 只读）
    // ═══════════════════════════════════════════
    property string k1: "0.00"; property string k2: "0.00"
    property string k3: "0.00"; property string k4: "0.00"
    property string k5: "0.00"; property string k6: "0.00"
    property string k7: "0.00"

    property string p1: "0.00";        property string p2: "0.00"
    property string prUp: "0.00";      property string prDown: "0.00"
    property string presLimit: "0.00"; property string openLimit: "0.00"

    // ── 信号 ──
    signal confirmed()
    signal resetToDefaults()
    signal hmiSwitchClicked()

    // ═══════════════════════════════════════════
    //  内容
    // ═══════════════════════════════════════════
    contentDelegate: Item {
        implicitWidth: root.implicitWidth
        implicitHeight: column.implicitHeight + 60 + footerLoader.implicitHeight

        Column {
            id: column
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 16
            spacing: 14

            // ───────────────────────────────────
            //  基础参数设置
            // ───────────────────────────────────
            MosGroupBox {
                width: parent.width
                title: "基础参数设置"
                colorBg: "transparent"
                colorBorder: MosTheme.Primary.colorSplit
                borderWidth: 1

                Column {
                    anchors.fill: parent
                    spacing: 10

                    Row {
                        width: parent.width
                        spacing: 12
                        MosLabel {
                            width: 130
                            anchors.verticalCenter: parent.verticalCenter
                            text: "压力显示Y轴"
                            colorText: "white"
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 16
                        }
                        MosInput {
                            width: 80; height: 34
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.presY
                            colorText: "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            onTextChanged: root.presY = text
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12
                        MosLabel {
                            width: 130
                            anchors.verticalCenter: parent.verticalCenter
                            text: "流量显示Y轴"
                            colorText: "white"
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 16
                        }
                        MosInput {
                            width: 80; height: 34
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.flowY
                            colorText: "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            onTextChanged: root.flowY = text
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12
                        MosLabel {
                            width: 130
                            anchors.verticalCenter: parent.verticalCenter
                            text: "HMI画面切换"
                            colorText: "white"
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 16
                        }
                        MosButton {
                            width: 80; height: 34
                            anchors.verticalCenter: parent.verticalCenter
                            text: "切换"
                            font.pixelSize: 14
                            type: MosButton.Type_Default
                            onClicked: root.hmiSwitchClicked()
                        }
                    }
                }
            }

            // ───────────────────────────────────
            //  高级参数设置
            // ───────────────────────────────────
            MosGroupBox {
                width: parent.width
                title: "高级参数设置"
                colorBg: "transparent"
                colorBorder: MosTheme.Primary.colorSplit
                borderWidth: 1

                Row {
                    anchors.fill: parent
                    spacing: 8

                    // 第一列：K标签
                    Column {
                        width: 36
                        spacing: 6
                        Repeater {
                            model: ["K1","K2","K3","K4","K5","K6","K7"]
                            delegate: MosLabel {
                                required property string modelData
                                height: 34
                                text: modelData
                                colorText: "white"
                                colorBg: "transparent"
                                colorBorder: "transparent"
                                font.pixelSize: 16
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // 第二列：K值
                    Column {
                        width: 80
                        spacing: 6
                        Repeater {
                            model: [root.k1,root.k2,root.k3,root.k4,root.k5,root.k6,root.k7]
                            delegate: MosInput {
                                required property string modelData
                                required property int index
                                width: 80; height: 34
                                text: modelData
                                colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                enabled: K3data.flag_model_profession
                                onTextChanged: {
                                    switch (index) {
                                    case 0: root.k1 = text; break
                                    case 1: root.k2 = text; break
                                    case 2: root.k3 = text; break
                                    case 3: root.k4 = text; break
                                    case 4: root.k5 = text; break
                                    case 5: root.k6 = text; break
                                    case 6: root.k7 = text; break
                                    }
                                }
                            }
                        }
                    }

                    // 第三列：P标签
                    Column {
                        width: 150
                        spacing: 6
                        Repeater {
                            model: ["P1","P2","追压精度","降压精度","高压限","最低节流阀开度值","返回上一执行参数"]
                            delegate: MosLabel {
                                required property string modelData
                                height: 34
                                text: modelData
                                colorText: "white"
                                colorBg: "transparent"
                                colorBorder: "transparent"
                                font.pixelSize: 16
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // 第四列：P值 + 还原按钮
                    Column {
                        width: 80
                        spacing: 6

                        MosInput {
                            width: 80; height: 34
                            text: root.p1
                            colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            enabled: K3data.flag_model_profession
                            onTextChanged: root.p1 = text
                        }
                        MosInput {
                            width: 80; height: 34
                            text: root.p2
                            colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            enabled: K3data.flag_model_profession
                            onTextChanged: root.p2 = text
                        }
                        MosInput {
                            width: 80; height: 34
                            text: root.prUp
                            colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            enabled: K3data.flag_model_profession
                            onTextChanged: root.prUp = text
                        }
                        MosInput {
                            width: 80; height: 34
                            text: root.prDown
                            colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            enabled: K3data.flag_model_profession
                            onTextChanged: root.prDown = text
                        }
                        MosInput {
                            width: 80; height: 34
                            text: root.presLimit
                            colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            enabled: K3data.flag_model_profession
                            onTextChanged: root.presLimit = text
                        }
                        MosInput {
                            width: 80; height: 34
                            text: root.openLimit
                            colorText: K3data.flag_model_profession ? "white" : "#aaaaaa"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            enabled: K3data.flag_model_profession
                            onTextChanged: root.openLimit = text
                        }
                        MosButton {
                            width: 80; height: 34
                            text: "还原"
                            font.pixelSize: 14
                            type: MosButton.Type_Default
                            enabled: K3data.flag_model_profession
                        }
                    }
                }
            }
        }

        // ── 底部按钮区域 ──
        Loader {
            id: footerLoader
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 12
            sourceComponent: root.footerDelegate
        }
    }

    // ═══════════════════════════════════════════
    //  底部按钮
    // ═══════════════════════════════════════════
    footerDelegate: RowLayout {
        spacing: 12
        anchors.centerIn: parent

        MosButton {
            Layout.preferredWidth: 100; Layout.preferredHeight: 40
            text: "确定"
            type: MosButton.Type_Primary
            onClicked: { root.confirmed(); root.close() }
        }
        MosButton {
            Layout.preferredWidth: 100; Layout.preferredHeight: 40
            text: "一键还原"
            type: MosButton.Type_Default
        }
        MosButton {
            Layout.preferredWidth: 100; Layout.preferredHeight: 40
            text: "取消"
            type: MosButton.Type_Default
            onClicked: root.close()
        }
    }
}
