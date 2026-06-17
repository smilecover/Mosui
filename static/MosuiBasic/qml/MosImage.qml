import QtQuick
import MosuiBasic

Image {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool previewEnabled: true
    readonly property alias hovered: __hoverHandler.hovered
    property int hoverCursorShape: Qt.PointingHandCursor
    property string fallback: ''
    property string placeholder: ''
    property var items: []

    objectName: '__MosImage__'
    onSourceChanged: {
        if (items.length == 0) {
            __private.previewItems = [{ url: String(source) }];
        }
    }
    onItemsChanged: {
        if (items.length > 0) {
            __private.previewItems = [...items];
        }
    }

    QtObject {
        id: __private
        property var previewItems: []
    }

    Loader {
        anchors.centerIn: parent
        active: root.status === Image.Error && root.fallback !== ''
        sourceComponent: Image {
            source: root.fallback
            Component.onCompleted: {
                __private.previewItems = [{ url: root.fallback }]
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        active: root.status === Image.Loading && root.placeholder !== ''
        sourceComponent: Image {
            source: root.placeholder
        }
    }

    Loader {
        anchors.fill: parent
        active: root.previewEnabled
        sourceComponent: Rectangle {
            color: MosTheme.Primary.colorTextTertiary
            opacity: root.hovered ? 1.0 : 0.0

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            Behavior on opacity { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }

            Row {
                anchors.centerIn: parent
                spacing: 5

                MosIconText {
                    anchors.verticalCenter: parent.verticalCenter
                    colorIcon: MosTheme.MosImage.colorText
                    iconSource: MosIcon.EyeOutlined
                    iconSize: parseInt(MosTheme.MosImage.fontSize) + 2
                }

                MosText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('预览')
                    color: MosTheme.MosImage.colorText
                }
            }

            MosImagePreview {
                id: __preview
                animationEnabled: root.animationEnabled
                items: __private.previewItems
            }

            TapHandler {
                onTapped: {
                    if (!__preview.opened) {
                        __preview.open();
                    }
                }
            }
        }
    }

    HoverHandler {
        id: __hoverHandler
        cursorShape: root.hoverCursorShape
    }
}
