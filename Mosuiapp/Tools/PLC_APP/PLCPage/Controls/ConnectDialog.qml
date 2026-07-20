import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosModal {
    id: root

    closable: true
    maskClosable: true
    title: "连接 PLC 服务器"
    confirmText: ""
    cancelText: ""
    iconSource: 0
    implicitWidth: 500
    implicitHeight: 400

    // ── 当前输入的 IP ──
    property string mainIp: "192.168.1.6"
    property string secondaryIp: "192.168.1.7"
    property string statusText: ""
    property bool isConnecting: false

    // ── 外部处理连接 ──
    signal connectRequested(string host, string secondaryHost)

    // ── 外部调用来反馈结果 ──
    function showSuccess() {
        root.isConnecting = false
        root.statusText = "连接成功！"
        closeTimer.start()
    }
    function showError(msg) {
        root.isConnecting = false
        root.statusText = msg
    }

    Timer {
        id: closeTimer
        interval: 800
        repeat: false
        onTriggered: root.close()
    }

    contentDelegate: Item {
        implicitWidth: root.implicitWidth
        implicitHeight: column.implicitHeight + 60 + footerLoader.implicitHeight

        Column {
            id: column
            width: parent.width - 60
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 16

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                MosImage {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    source: "qrc:/logo_plc.png"
                    fillMode: Image.PreserveAspectFit
                    previewEnabled: false
                }
                MosLabel {
                    text: "精细控压钻井自动控制系统"
                    colorText: "white"
                    font.pixelSize: 22
                    font.bold: true
                    colorBg: "transparent"
                    colorBorder: "transparent"
                }
            }

            MosRectangle {
                width: parent.width
                height: 1
                color: MosTheme.Primary.colorSplit
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                spacing: 12

                RowLayout {
                    width: parent.width
                    spacing: 20
                    MosLabel {
                        Layout.preferredWidth: 80
                        text: "主通道 IP"
                        colorText: "white"
                        font.pixelSize: 16
                        colorBg: "transparent"
                        colorBorder: "transparent"
                    }
                    MosInput {
                        id: mainIpInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        text: root.mainIp
                        colorText: "white"
                        font.pixelSize: 16
                        placeholderText: "输入主通道 IP 地址"
                        onTextChanged: root.mainIp = text
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: 20
                    MosLabel {
                        Layout.preferredWidth: 80
                        text: "辅助通道 IP"
                        colorText: "white"
                        font.pixelSize: 16
                        colorBg: "transparent"
                        colorBorder: "transparent"
                    }
                    MosInput {
                        id: secondaryIpInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        text: root.secondaryIp
                        colorText: "white"
                        font.pixelSize: 16
                        placeholderText: "输入辅助通道 IP 地址"
                        onTextChanged: root.secondaryIp = text
                    }
                }
            }

            MosLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                text: root.statusText
                colorText: root.isConnecting ? "#FFFFC738"
                         : root.statusText.indexOf("成功") >= 0 ? "#52c41a"
                         : root.statusText.indexOf("失败") >= 0 ? "#ff4d4f"
                         : "white"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                colorBg: "transparent"
                colorBorder: "transparent"
                visible: root.statusText !== ""
            }

            MosButton {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 160
                height: 44
                text: root.isConnecting ? "连接中..." : "连接"
                enabled: !root.isConnecting && mainIpInput.text.trim() !== ""
                type: MosButton.Type_Primary
                font.pixelSize: 18
                onClicked: {
                    root.isConnecting = true
                    root.statusText = "正在连接 " + mainIpInput.text.trim() + " ..."
                    root.connectRequested(mainIpInput.text.trim(), secondaryIpInput.text.trim())
                }
            }
        }

        MosIconButton {
            id: closeBtn
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 8
            anchors.topMargin: 8
            iconSource: MosIcon.CloseOutlined
            iconSize: 22
            type: MosButton.Type_Link
            colorBg: "transparent"
            colorText: closeBtn.active ? '#f50707' : closeBtn.hovered ? '#2075e4' : "white"
            leftPadding: 6
            rightPadding: 6
            topPadding: 6
            bottomPadding: 6
            hoverCursorShape: Qt.ArrowCursor
            onClicked: root.close()
        }

        Loader {
            id: footerLoader
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.bottomMargin: 8
            sourceComponent: root.footerDelegate
        }
    }

    footerDelegate: Item {
        implicitWidth: infoLabel.implicitWidth
        implicitHeight: 30
        MosLabel {
            id: infoLabel
            anchors.centerIn: parent
            text: "© 中国海洋石油集团有限公司"
            colorText: "#888888"
            font.pixelSize: 12
            colorBg: "transparent"
            colorBorder: "transparent"
        }
    }

    onOpened: {
        root.statusText = ""
        root.isConnecting = false
        root.mainIp = K3Client.host
        root.secondaryIp = K3Client.secondaryHost
    }
}
