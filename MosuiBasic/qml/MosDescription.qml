import QtQuick
import MosuiBasic

Item {
    id: root

    width: parent.width
    height: column.height

    // 对外属性
    property alias title: titleText.text
    property alias desc: descText.text
    property alias titleVisible: titleText.visible
    property alias descVisible: descText.visible

    // 新增：文本格式控制（自动/纯文本/富文本/Markdown）
    property int descTextFormat: Text.MarkdownText

    Column {
        id: column
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        // 标题文本
        MosText {
            id: titleText
            width: parent.width
            visible: text.trim().length > 0
            font {
                pixelSize: MosTheme.Primary.fontPrimarySizeHeading3
                weight: Font.DemiBold
            }
        }

        // 描述文本（支持多种格式 + 链接交互）
        MosText {
            id: descText
            width: parent.width
            lineHeight: 1.2
            visible: text.trim().length > 0
            textFormat: root.descTextFormat // 绑定外部可配置属性
            wrapMode: Text.Wrap // 强制自动换行
            // 正确：文字颜色平滑动画
            Behavior on color {
                ColorAnimation { duration: 300 }
            }
            // 链接点击
            onLinkActivated: link => {
                if (!link) return
                if (link.startsWith('internal://')) {
                    galleryMenu.gotoMenu(link.slice(11))
                } else {
                    Qt.openUrlExternally(link)
                }
            }

            // 链接悬停鼠标样式
            onLinkHovered: link => {
                shapeMouse.cursorShape = link ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            // 鼠标穿透 + 光标控制
            MouseArea {
                id: shapeMouse
                anchors.fill: parent
                z: -1
                hoverEnabled: true // 必须开启才能监听 hover
                propagateComposedEvents: true
                onClicked: mouse => mouse.accepted = false
            }
        }
    }
}