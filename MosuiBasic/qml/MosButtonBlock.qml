import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum Size {
        Size_Auto = 0,
        Size_Fixed = 1
    }

    signal pressed(index: int, buttonData: var)
    signal released(index: int, buttonData: var)
    signal clicked(index: int, buttonData: var)
    signal doubleClicked(index: int, buttonData: var)

    property bool animationEnabled: MosTheme.animationEnabled
    property bool effectEnabled: true
    property int hoverCursorShape: Qt.PointingHandCursor
    property var model: []
    property int count: model.length
    property int size: MosButtonBlock.Size_Auto
    property int buttonWidth: 120
    property int buttonHeight: 30
    property int buttonLeftPadding: 10
    property int buttonRightPadding: 10
    property int buttonTopPadding: 8
    property int buttonBottomPadding: 8
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property var themeSource: MosTheme.MosButton

    property Component toolTipDelegate: MosToolTip {
        animationEnabled: root.animationEnabled
        visible: hovered
        font: root.font
        locale: root.locale
        text: toolTip.text ?? ''
        delay: toolTip.delay ?? 500
        timeout: toolTip.timeout ?? -1
    }
    property Component buttonDelegate: MosIconButton {
        id: __rootItem

        required property var modelData
        required property int index

        onPressed: root.pressed(index, modelData);
        onReleased: root.released(index, modelData);
        onDoubleClicked: root.doubleClicked(index, modelData);
        onClicked: root.clicked(index, modelData);

        animationEnabled: root.animationEnabled
        effectEnabled: root.effectEnabled
        autoRepeat: modelData.autoRepeat ?? false
        hoverCursorShape: root.hoverCursorShape
        leftPadding: root.buttonLeftPadding
        rightPadding: root.buttonRightPadding
        topPadding: root.buttonTopPadding
        bottomPadding: root.buttonBottomPadding
        implicitWidth: root.size == MosButtonBlock.Size_Auto ? (implicitContentWidth + leftPadding + rightPadding) :
                                                                 root.buttonWidth
        implicitHeight: root.size == MosButtonBlock.Size_Auto ? (implicitContentHeight + topPadding + bottomPadding) :
                                                                  root.buttonHeight
        z: (hovered || checked) ? 1 : 0
        enabled: root.enabled && (modelData.enabled === undefined ? true : modelData.enabled)
        themeSource: root.themeSource
        locale: root.locale
        font: root.font
        type: modelData.type ?? MosButton.Type_Default
        iconSource: modelData.iconSource ?? 0
        text: modelData.label ?? ''
        background: Item {
            MosRectangleInternal {
                id: __effect
                width: __bg.width
                height: __bg.height
                anchors.centerIn: parent
                visible: __rootItem.effectEnabled
                color: 'transparent'
                radius: __bg.radius
                topLeftRadius: __bg.topLeftRadius
                topRightRadius: __bg.topRightRadius
                bottomLeftRadius: __bg.bottomLeftRadius
                bottomRightRadius: __bg.bottomRightRadius
                border.width: 0
                border.color: __rootItem.enabled ? root.themeSource.colorBorderHover : 'transparent'
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
                    target: __rootItem
                    function onReleased() {
                        if (__rootItem.animationEnabled && __rootItem.effectEnabled) {
                            __effect.border.width = 8;
                            __animation.restart();
                        }
                    }
                }
            }

            MosRectangleInternal {
                id: __bg
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                color: __rootItem.colorBg
                topLeftRadius: index == 0 ? root.radiusBg.topLeft : 0
                topRightRadius: index === (count - 1) ? root.radiusBg.topRight : 0
                bottomLeftRadius: index == 0 ? root.radiusBg.bottomLeft : 0
                bottomRightRadius: index === (count - 1) ? root.radiusBg.bottomRight : 0
                border.width: 1
                border.color: __rootItem.colorBorder

                Behavior on color { enabled: __rootItem.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
                Behavior on border.color { enabled: __rootItem.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            }
        }

        Loader {
            x: (parent.width - width) * 0.5
            active: toolTip !== undefined
            sourceComponent: root.toolTipDelegate
            property bool pressed: __rootItem.pressed
            property bool hovered: __rootItem.hovered
            property var toolTip: modelData.toolTip
        }
    }
    property string contentDescription: ''

    objectName: '__MosButtonBlock__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    contentItem: Loader {
        sourceComponent: Row {
            spacing: -1

            Repeater {
                id: __repeater
                model: root.model
                delegate: buttonDelegate
            }
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: root.contentDescription
    Accessible.description: root.contentDescription
}
