import QtQuick
import MosuiBasic
import QtQuick.Templates as T
T.ScrollBar{
    id: root
    objectName: '__MosScrollBar__'

    property bool animationEnabled: MosTheme.animationEnabled

    property int minimumHandleSize: 24
    property color colorBar: root.pressed ? MosTheme.MosScrollBar.colorBarActive :
                                               root.hovered ? MosTheme.MosScrollBar.colorBarHover :
                                                                 MosTheme.MosScrollBar.colorBar
    property color colorBg: root.pressed ? MosTheme.MosScrollBar.colorBgActive :
                                              root.hovered ? MosTheme.MosScrollBar.colorBgHover :
                                                                MosTheme.MosScrollBar.colorBg
    property string contentDescription: ''
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    leftPadding: root.orientation === Qt.Horizontal ? 10 : 2
    rightPadding: root.orientation === Qt.Horizontal ? 10 : 2
    topPadding: root.orientation === Qt.Vertical ? 10 : 2
    bottomPadding: root.orientation === Qt.Vertical ? 10 : 2
    policy: T.ScrollBar.AlwaysOn
    minimumSize: {
        if (root.orientation === Qt.Vertical)
            return size * height < minimumHandleSize ? minimumHandleSize / height : 0;
        else
            return size * width < minimumHandleSize ? minimumHandleSize / width : 0;
    }
    visible: (root.policy != T.ScrollBar.AlwaysOff) && root.size !== 1
    contentItem: Rectangle {
        implicitWidth: root.interactive && __private.visible ? 6 : 2
        implicitHeight: root.interactive && __private.visible ? 6 : 2
        radius: root.orientation === Qt.Vertical ? width * 0.5 : height * 0.5
        color: root.colorBar
        opacity: {
            if (root.policy === T.ScrollBar.AlwaysOn) {
                return 1;
            } else if (root.policy === T.ScrollBar.AsNeeded) {
                return __private.visible ? 1 : 0;
            } else {
                return 0;
            }
        }

        Behavior on implicitWidth { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on implicitHeight { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on opacity { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }
    background: Rectangle {
        color: root.colorBg
        opacity: __private.visible ? 1 : 0

        Behavior on opacity { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }

        Loader {
            active: root.orientation === Qt.Vertical
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            sourceComponent: HoverIcon {
                iconSize: 10
                // iconSource: MosIcon.CaretUpOutlined
                onClicked: root.decrease();
            }
        }

        Loader {
            active: root.orientation === Qt.Vertical
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            sourceComponent: HoverIcon {
                iconSize: 10
                // iconSource: MosIcon.CaretDownOutlined
                onClicked: root.increase();
            }
        }

        Loader {
            active: root.orientation === Qt.Horizontal
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            sourceComponent: HoverIcon {
                iconSize: 10
                // iconSource: MosIcon.CaretLeftOutlined
                onClicked: root.decrease();
            }
        }

        Loader {
            active: root.orientation === Qt.Horizontal
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            sourceComponent: HoverIcon {
                iconSize: 10
                // iconSource: MosIcon.CaretRightOutlined
                onClicked: root.increase();
            }
        }
    }

    onHoveredChanged: {
        if (hovered) {
            __exitTimer.stop();
            __private.exit = false;
        } else {
            __exitTimer.restart();
        }
    }

    component HoverIcon: MosIconText {
        signal clicked()
        property bool hovered: false

        colorIcon: hovered ? MosTheme.MosScrollBar.colorIconHover : MosTheme.MosScrollBar.colorIcon
        opacity: __private.visible ? 1 : 0

        Behavior on opacity { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.hovered = true;
            onExited: parent.hovered = false;
            onClicked: parent.clicked();
        }
    }

    QtObject {
        id: __private
        property bool visible: root.hovered || root.pressed || !exit
        property bool exit: true
    }

    Timer {
        id: __exitTimer
        interval: 800
        onTriggered: __private.exit = true;
    }

    Accessible.role: Accessible.ScrollBar
    Accessible.description: root.contentDescription
}

