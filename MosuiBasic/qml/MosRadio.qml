import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Templates as T
import MosuiBasic

T.RadioButton {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool effectEnabled: true
    property int hoverCursorShape: Qt.PointingHandCursor
    property color colorText: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    property color colorIndicator: enabled ?
                                       checked ? themeSource.colorIndicatorChecked :
                                                 themeSource.colorIndicator : themeSource.colorIndicatorDisabled
    property color colorIndicatorBorder: (enabled && (hovered || checked)) ? themeSource.colorIndicatorBorderChecked :
                                                                             themeSource.colorIndicatorBorder
    property MosRadius radiusIndicator: MosRadius { all: themeSource.radiusIndicator }
    property string contentDescription: ''
    property var themeSource: MosTheme.MosRadio

    objectName: '__MosRadio__'
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(implicitContentHeight, implicitIndicatorHeight) + topPadding + bottomPadding
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize)
    }
    spacing: 8
    indicator: Item {
        x: root.leftPadding
        implicitWidth: __bg.width
        implicitHeight: __bg.height
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: __effect
            width: __bg.width
            height: __bg.height
            radius: width * 0.5
            anchors.centerIn: parent
            visible: root.effectEnabled
            color: 'transparent'
            border.width: 0
            border.color: root.enabled ? root.themeSource.colorEffectBg : 'transparent'
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

        Rectangle {
            id: __bg
            width: root.radiusIndicator.all * 2
            height: width
            anchors.centerIn: parent
            radius: height * 0.5
            color: root.colorIndicator
            border.color: root.colorIndicatorBorder
            border.width: root.checked ? 0 : 1

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
            Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

            Rectangle {
                width: root.checked ? root.radiusIndicator.all - 2 : 0
                height: width
                anchors.centerIn: parent
                radius: width * 0.5

                Behavior on width { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
            }
        }
    }
    contentItem: MosText {
        leftPadding: root.indicator.width + root.spacing
        text: root.text
        font: root.font
        opacity: enabled ? 1.0 : 0.3
        color: root.colorText
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        cursorShape: root.hoverCursorShape
    }

    Accessible.role: Accessible.RadioButton
    Accessible.name: root.text
    Accessible.description: root.contentDescription
    Accessible.onPressAction: root.clicked();
}
