import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum Type {
        Type_Filled = 0,
        Type_Outlined = 1
    }

    enum Size {
        Size_Auto = 0,
        Size_Fixed = 1
    }

    signal clicked(index: int, radioData: var)

    property bool animationEnabled: MosTheme.animationEnabled
    property bool effectEnabled: true
    property int hoverCursorShape: Qt.PointingHandCursor
    property var model: []
    readonly property int count: model.length
    property int initCheckedIndex: -1
    property int currentCheckedIndex: -1
    property var currentCheckedValue: undefined
    property int type: MosRadioBlock.Type_Filled
    property int size: MosRadioBlock.Size_Auto
    property int radioWidth: 120
    property int radioHeight: 30
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string contentDescription: ''
    property var themeSource: MosTheme.MosRadioBlock

    property Component toolTipDelegate: MosToolTip {
        animationEnabled: root.animationEnabled
        visible: hovered
        font: root.font
        locale: root.locale
        text: toolTip.text ?? ''
        delay: toolTip.delay ?? 500
        timeout: toolTip.timeout ?? -1
    }
    property Component radioDelegate: MosIconButton {
        id: __rootItem

        required property var modelData
        required property int index

        T.ButtonGroup.group: __buttonGroup
        Component.onCompleted: {
            if (root.initCheckedIndex == index) {
                checked = true;
                __buttonGroup.clicked(__rootItem);
            }
        }

        implicitWidth: root.size == MosRadioBlock.Size_Auto ? (implicitContentWidth + leftPadding + rightPadding) :
                                                                 root.radioWidth
        implicitHeight: root.size == MosRadioBlock.Size_Auto ? (implicitContentHeight + topPadding + bottomPadding) :
                                                                  root.radioHeight
        z: (hovered || checked) ? 1 : 0
        animationEnabled: root.animationEnabled
        effectEnabled: root.effectEnabled
        hoverCursorShape: root.hoverCursorShape
        enabled: root.enabled && (modelData.enabled === undefined ? true : modelData.enabled)
        themeSource: root.themeSource
        locale: root.locale
        font: root.font
        type: MosButton.Type_Default
        iconSource: modelData.iconSource ?? 0
        text: modelData.label ?? ''
        colorBorder: (enabled && checked) ? root.themeSource.colorBorderChecked :
                                            root.themeSource.colorBorder;
        colorText: {
            if (enabled) {
                if (root.type == MosRadioBlock.Type_Filled) {
                    return checked ? root.themeSource.colorTextFilledChecked :
                                     hovered ? root.themeSource.colorTextChecked :
                                               root.themeSource.colorText;
                } else {
                    return (checked || hovered) ? root.themeSource.colorTextChecked :
                                                  root.themeSource.colorText;
                }
            } else {
                return root.themeSource.colorTextDisabled;
            }
        }
        colorBg: {
            if (enabled) {
                if (root.type == MosRadioBlock.Type_Filled) {
                    return down ? (checked ? root.themeSource.colorBgActive : root.themeSource.colorBg) :
                                  hovered ? (checked ? root.themeSource.colorBgHover : root.themeSource.colorBg) :
                                            checked ? root.themeSource.colorBgChecked :
                                                      root.themeSource.colorBg;
                } else {
                    return root.themeSource.colorBg;
                }
            } else {
                return checked ? root.themeSource.colorBgCheckedDisabled : root.themeSource.colorBgDisabled;
            }
        }
        checkable: true
        background: Item {
            MosRippleEffect {
                id: __ripple
                animationEnabled: __rootItem.animationEnabled
                effectEnabled: __rootItem.effectEnabled
                effectColor: root.themeSource.colorEffectBg
                targetWidth: __bg.width
                targetHeight: __bg.height
                topLeftRadius: __bg.topLeftRadius
                topRightRadius: __bg.topRightRadius
                bottomLeftRadius: __bg.bottomLeftRadius
                bottomRightRadius: __bg.bottomRightRadius
            }
            Connections {
                target: __rootItem
                function onReleased() { __ripple.trigger(); }
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
            property bool checked: __rootItem.released
            property bool pressed: __rootItem.pressed
            property bool hovered: __rootItem.hovered
            property var toolTip: modelData.toolTip
        }

        Connections {
            target: root
            function onCurrentCheckedIndexChanged() {
                if (__rootItem.index == root.currentCheckedIndex) {
                    __rootItem.checked = true;
                }
            }
        }
    }

    objectName: '__MosRadioBlock__'
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
                delegate: radioDelegate
            }
        }

        T.ButtonGroup {
            id: __buttonGroup
            onClicked:
                button => {
                    root.currentCheckedIndex = button.index;
                    root.currentCheckedValue = button.modelData.value;
                    root.clicked(button.index, button.modelData);
                }
        }
    }

    Accessible.role: Accessible.RadioButton
    Accessible.name: root.contentDescription
    Accessible.description: root.contentDescription
}
