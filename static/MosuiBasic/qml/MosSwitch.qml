import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Switch {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool effectEnabled: true
    property int hoverCursorShape: Qt.PointingHandCursor
    property bool loading: false
    property string checkedText: ''
    property string uncheckedText: ''
    property var checkedIconSource: 0 ?? ''
    property var uncheckedIconSource: 0 ?? ''
    property int iconSize: parseInt(themeSource.fontSize) - 2
    property alias textFont: root.font
    property color colorText: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    property color colorHandle: themeSource.colorHandle
    property color colorBg: {
        if (!enabled)
            return checked ? themeSource.colorBgCheckedDisabled : themeSource.colorBgDisabled;

        if (checked)
            return root.down ? themeSource.colorBgCheckedActive :
                                  root.hovered ? themeSource.colorBgCheckedHover :
                                                    themeSource.colorBgChecked;
        else
            return root.down ? themeSource.colorBgActive :
                                  root.hovered ? themeSource.colorBgHover :
                                                    themeSource.colorBg;
    }
    property MosRadius radiusBg: MosRadius { all: root.implicitIndicatorHeight * 0.5 }
    property string contentDescription: ''
    property var themeSource: MosTheme.MosSwitch

    property Component handleDelegate: Rectangle {
        radius: height * 0.5
        color: root.colorHandle

        MosIconText {
            anchors.centerIn: parent
            iconSize: parent.height - 4
            iconSource: MosIcon.LoadingOutlined
            colorIcon: root.colorBg
            visible: root.loading
            transformOrigin: Item.Center

            NumberAnimation on rotation {
                running: root.loading
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1000
            }
        }
    }

    objectName: '__MosSwitch__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize)
    }
    spacing: 5
    indicator: Item {
        x: root.text ? (!root.mirrored ? root.width - width - root.rightPadding : root.leftPadding) :
                          root.leftPadding + (root.availableWidth - width) / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: __bg.width
        implicitHeight: __bg.height

        MosRectangleInternal {
            id: __effect
            width: __bg.width
            height: __bg.height
            radius: __bg.radius
            topLeftRadius: __bg.topLeftRadius
            topRightRadius: __bg.topRightRadius
            bottomLeftRadius: __bg.bottomLeftRadius
            bottomRightRadius: __bg.bottomRightRadius
            anchors.centerIn: parent
            visible: root.effectEnabled
            color: 'transparent'
            border.width: 0
            border.color: root.enabled ? root.themeSource.colorBgHover : 'transparent'
            opacity: 0.2

            ParallelAnimation {
                id: __animation
                onFinished: __effect.border.width = 0;
                NumberAnimation {
                    target: __effect; property: 'width'; from: __bg.width + 3; to: __bg.width + 8;
                    duration: MosTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'height'; from: __bg.height + 3; to: __bg.height + 8;
                    duration: MosTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'opacity'; from: 0.2; to: 0;
                    duration: MosTheme.Primary.durationSlow
                }
            }

            Connections {
                target: root
                function onReleased() {
                    if (root.animationEnabled && root.effectEnabled) {
                        __effect.border.width = 8;
                        __animation.restart();
                    }
                }
            }
        }

        MosRectangleInternal {
            id: __bg
            width: Math.max(Math.max(checkedWidth, uncheckedWidth) + __handle.height, height * 2)
            height: hasContent ? Math.max(checkedHeight, uncheckedHeight, 22) : 22
            anchors.centerIn: parent
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
            color: root.colorBg
            clip: true

            property bool hasCheckedIcon: root.checkedIconSource !== 0 && root.checkedIconSource !== ''
            property bool hasUncheckedIcon: root.uncheckedIconSource !== 0 && root.uncheckedIconSource !== ''
            property bool hasContent: hasCheckedIcon || hasUncheckedIcon ||
                                      root.checkedText.length !== 0 || root.uncheckedText.length !== 0
            property real checkedWidth: !hasCheckedIcon ? __checkedText.width + 6 :  __checkedIcon.width + 6
            property real uncheckedWidth: !hasUncheckedIcon ? __uncheckedText.width + 6 : __uncheckedIcon.width + 6
            property real checkedHeight: !hasCheckedIcon ? __checkedText.height + 4 : __checkedIcon.height + 4
            property real uncheckedHeight: !hasUncheckedIcon ? __uncheckedText.height + 4 : __uncheckedIcon.height + 4

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

            MosText {
                id: __checkedText
                width: text.length === 0 ? 0 : Math.max(implicitWidth + 8, __uncheckedText.implicitWidth + 8)
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: __handle.left
                font {
                    family: root.font.family
                    pixelSize: root.iconSize
                }
                text: root.checkedText
                color: root.colorHandle
                horizontalAlignment: Text.AlignHCenter
                visible: !__checkedIcon.visible
            }

            MosText {
                id: __uncheckedText
                width: text.length === 0 ? 0 : Math.max(implicitWidth + 8, __checkedText.implicitWidth + 8)
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: __handle.right
                font {
                    family: root.font.family
                    pixelSize: root.iconSize
                }
                text: root.uncheckedText
                color: root.colorHandle
                horizontalAlignment: Text.AlignHCenter
                visible: !__uncheckedIcon.visible
            }

            MosIconText {
                id: __checkedIcon
                leftPadding: 4
                rightPadding: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: __handle.left
                iconSize: root.iconSize
                iconSource: root.checkedIconSource
                colorIcon: root.colorHandle
                horizontalAlignment: Text.AlignHCenter
                visible: !isIcon
            }

            MosIconText {
                id: __uncheckedIcon
                leftPadding: 4
                rightPadding: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: __handle.right
                iconSize: root.iconSize
                iconSource: root.uncheckedIconSource
                colorIcon: root.colorHandle
                horizontalAlignment: Text.AlignHCenter
                visible: !isIcon
            }

            Loader {
                id: __handle
                x: root.checked ? (parent.width - (root.pressed ? height + 6 : height) - 2) : 2
                width: root.pressed ? height + 6 : height
                height: parent.height - 4
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: root.handleDelegate

                Behavior on width { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
                Behavior on x { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
            }
        }
    }
    contentItem: MosText {
        leftPadding: root.indicator && root.mirrored ? root.indicator.width + root.spacing : 0
        rightPadding: root.indicator && !root.mirrored ? root.indicator.width + root.spacing : 0
        text: root.text
        font: root.font
        color: root.colorText
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        cursorShape: root.hoverCursorShape
    }

    Accessible.role: Accessible.CheckBox
    Accessible.name: root.checked ? root.checkedText : root.uncheckedText
    Accessible.description: root.contentDescription
    Accessible.onToggleAction: root.toggle();
}
