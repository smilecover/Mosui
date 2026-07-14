pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosModal {
    id: root

    readonly property color statusColor: ReportOutput.recording
                                         ? MosTheme.Primary.colorSuccess
                                         : MosTheme.Primary.colorTextTertiary

    title: "报告输出"
    confirmText: ""
    cancelText: ""
    closable: true
    maskClosable: true
    implicitWidth: 520
    implicitHeight: 346

    contentDelegate: Item {
        implicitWidth: root.implicitWidth
        implicitHeight: contentColumn.implicitHeight + 40

        ColumnLayout {
            id: contentColumn
            width: parent.width - 48
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 14
            spacing: 14

            MosLabel {
                Layout.fillWidth: true
                text: "实时查看数据记录进度与文件输出位置"
                colorText: MosTheme.Primary.colorTextSecondary
                colorBg: "transparent"
                colorBorder: "transparent"
                font.pixelSize: 13
            }

            // 记录状态与数据量
            MosFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: 112
                padding: 0
                colorBg: MosThemeFunctions.alpha(root.statusColor, 0.08)
                colorBorder: MosThemeFunctions.alpha(root.statusColor, 0.45)
                borderWidth: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        Layout.alignment: Qt.AlignVCenter
                        radius: 26
                        color: MosThemeFunctions.alpha(root.statusColor, 0.16)

                        MosIconText {
                            anchors.centerIn: parent
                            iconSource: ReportOutput.recording
                                        ? MosIcon.SyncOutlined
                                        : MosIcon.MinusCircleOutlined
                            iconSize: 25
                            color: root.statusColor

                            RotationAnimation on rotation {
                                running: ReportOutput.recording
                                from: 0
                                to: 360
                                duration: 1800
                                loops: Animation.Infinite
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 5

                        MosLabel {
                            Layout.fillWidth: true
                            text: ReportOutput.recording ? "正在记录数据" : "记录已停止"
                            colorText: root.statusColor
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 17
                            font.bold: true
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: ReportOutput.recording
                                  ? "数据正在持续写入输出文件"
                                  : "点击“开始记录”创建新的数据记录"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 13
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 54
                        Layout.alignment: Qt.AlignVCenter
                        color: MosTheme.Primary.colorSplit
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 94
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        MosLabel {
                            Layout.fillWidth: true
                            text: String(ReportOutput.totalRows)
                            colorText: MosTheme.Primary.colorTextPrimary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 24
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: "已记录行数"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // 文件输出位置
            MosFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                padding: 0
                colorBg: MosTheme.Primary.colorFillQuaternary
                colorBorder: MosTheme.Primary.colorSplit
                borderWidth: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        Layout.alignment: Qt.AlignVCenter
                        radius: 8
                        color: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.14)

                        MosIconText {
                            anchors.centerIn: parent
                            iconSource: MosIcon.SaveOutlined
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
                            text: "文件输出位置"
                            colorText: MosTheme.Primary.colorTextPrimary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: ReportOutput.outputDir || "尚未设置输出目录"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 12
                            elide: Text.ElideMiddle
                        }
                    }

                    MosIconButton {
                        Layout.preferredWidth: 102
                        Layout.preferredHeight: 36
                        text: "打开目录"
                        iconSource: MosIcon.FileOutlined
                        font.pixelSize: 13
                        type: MosButton.Type_Default
                        enabled: String(ReportOutput.outputDir).length > 0
                        onClicked: ReportOutput.openOutputFolder()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 2
                color: MosTheme.Primary.colorSplit
            }

            // 页面操作
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MosButton {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 38
                    text: "关闭"
                    font.pixelSize: 14
                    type: MosButton.Type_Text
                    onClicked: root.close()
                }

                Item {
                    Layout.fillWidth: true
                }

                MosIconButton {
                    Layout.preferredWidth: 126
                    Layout.preferredHeight: 38
                    text: ReportOutput.recording ? "停止记录" : "开始记录"
                    iconSource: ReportOutput.recording
                                ? MosIcon.MinusCircleOutlined
                                : MosIcon.PlayCircleOutlined
                    font.pixelSize: 14
                    type: MosButton.Type_Primary
                    onClicked: {
                        if (ReportOutput.recording)
                            ReportOutput.stopRecording()
                        else
                            ReportOutput.startRecording()
                    }
                }
            }
        }
    }
}
