import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Popup {
    id: root
    objectName: '__MosPopup__'

    property bool animationEnabled: MosTheme.animationEnabled
    property bool movable: false
    property bool resizable: false
    property real minimumX: Number.NaN
    property real maximumX: Number.NaN
    property real minimumY: Number.NaN
    property real maximumY: Number.NaN
    property real minimumWidth: 0
    property real maximumWidth: Number.NaN
    property real minimumHeight: 0
    property real maximumHeight: Number.NaN
    property color colorShadow: themeSource.colorShadow
    property color colorBg: MosTheme.isDark ? themeSource.colorBgDark : themeSource.colorBg
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property var themeSource: MosTheme.MosPopup


    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    enter: Transition {
        NumberAnimation {
            property: 'opacity'
            from: 0.0
            to: 1.0
            easing.type: Easing.OutQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
    }
    exit: Transition {
        NumberAnimation {
            property: 'opacity'
            from: 1.0
            to: 0
            easing.type: Easing.InQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
    }
    background: Item {
        MosShadow {
            anchors.fill: __popupRect
            source: __popupRect
            shadowColor: root.colorShadow
        }
        MosRectangleInternal {
            id: __popupRect
            anchors.fill: parent
            color: root.colorBg
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
        }
        Loader {
            active: root.movable || root.resizable
            sourceComponent: MosResizeMouseArea {
                anchors.fill: parent
                target: root
                movable: root.movable
                resizable: root.resizable
                minimumX: root.minimumX
                maximumX: root.maximumX
                minimumY: root.minimumY
                maximumY: root.maximumY
                minimumWidth: root.minimumWidth
                maximumWidth: root.maximumWidth
                minimumHeight: root.minimumHeight
                maximumHeight: root.maximumHeight
            }
        }
    }

    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
}
