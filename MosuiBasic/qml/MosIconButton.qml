import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosButton {
    id: root
    objectName: '__MosIconButton__'
    enum IconPosition {
        Position_Start = 0,
        Position_End = 1
    }

    property bool loading: false
    property var iconSource: 0 ?? ''
    property int iconSize: parseInt(themeSource.fontSize)
    property int iconSpacing: 5 * sizeRatio
    property int iconPosition: MosIconButton.Position_Start
    property int orientation: Qt.Horizontal
    property alias textFont: root.font
    property font iconFont: Qt.font({
                                        family: 'iconfont',
                                        pixelSize: iconSize
                                    })
    property color colorIcon: colorText

    property Component iconDelegate: MosIconText {
        font: root.iconFont
        color: root.colorIcon
        iconSize: root.iconSize
        iconSource: root.loading ? MosIcon.LoadingOutlined : root.iconSource
        verticalAlignment: Text.AlignVCenter
        visible: root.loading || (root.iconSource !== 0 && root.iconSource !== "")

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

        NumberAnimation on rotation {
            running: root.loading
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1000
        }
    }


    contentItem: Item {
        implicitWidth: root.orientation === Qt.Horizontal ? __horLoader.implicitWidth : __verLoader.implicitWidth
        implicitHeight: root.orientation === Qt.Horizontal ? __horLoader.implicitHeight : __verLoader.implicitHeight

        Behavior on implicitWidth { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
        Behavior on implicitHeight { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }

        Loader {
            id: __horLoader
            anchors.centerIn: parent
            active: root.orientation === Qt.Horizontal
            sourceComponent: Row {
                spacing: root.iconSpacing
                layoutDirection: root.iconPosition === MosIconButton.Position_Start ? Qt.LeftToRight : Qt.RightToLeft

                Loader {
                    id: __hIcon
                    height: Math.max(__hIcon.implicitHeight, __hText.implicitHeight)
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: root.iconDelegate
                }

                MosText {
                    id: __hText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.text
                    font: root.font
                    lineHeight: root.themeSource.fontLineHeight
                    color: root.colorText
                    elide: Text.ElideRight
                    visible: text !== ''

                    Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
                }
            }
        }

        Loader {
            id: __verLoader
            active: root.orientation === Qt.Vertical
            anchors.centerIn: parent
            sourceComponent: Column {
                spacing: root.iconSpacing
                Component.onCompleted: relayout();

                function relayout() {
                    if (root.iconPosition === MosIconButton.Position_Start) {
                        children = [__vIcon, __vText];
                    } else {
                        children = [__vText, __vIcon];
                    }
                }

                Loader {
                    id: __vIcon
                    height: Math.max(__vIcon.implicitHeight, __vText.implicitHeight)
                    anchors.horizontalCenter: parent.horizontalCenter
                    sourceComponent: root.iconDelegate
                }

                MosText {
                    id: __vText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.text
                    font: root.font
                    lineHeight: root.themeSource.fontLineHeight
                    color: root.colorText
                    elide: Text.ElideRight
                    visible: text !== ''

                    Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
                }
            }
        }
    }
}
