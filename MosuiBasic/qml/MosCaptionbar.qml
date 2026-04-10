import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: root
    objectName: '__MosCaptionBar__'

    // 高度固定 32px（Windows 桌面标题栏标准高度）
    implicitHeight: 32

    // 背景跟随主题
    color: MosTheme.isDark ? "#202020" : "#f5f5f5"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        // ── 右侧：窗口控制按钮 ──
        RowLayout {
            id: buttonRow
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            // 最小化
            ControlButton {
                onClicked: root.windowAgent.showMinimized()
            }

            // 最大化 / 还原
            ControlButton {
                id: btnMaximize
                onClicked: {
                    if (root.windowAgent.window) {
                        isMaximized
                            ? root.windowAgent.window.showNormal()
                            : root.windowAgent.window.showMaximized()
                    }
                }
            }

            // 关闭
            ControlButton {
                onClicked: root.windowAgent.close()
            }
        }
    }
}
