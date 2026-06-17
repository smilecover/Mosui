import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.AbstractButton {
    id: root

    signal change(color: color)

    property bool animationEnabled: MosTheme.animationEnabled
    property bool active: hovered || visualFocus || open
    readonly property alias value: __colorPickerPanel.value
    property alias defaultValue: __colorPickerPanel.defaultValue
    property alias autoChange: __colorPickerPanel.autoChange
    property alias changeValue: __colorPickerPanel.changeValue
    property bool showText: false
    property var textFormatter:
        color => {
            switch (format.toLowerCase()) {
                case 'hex': return toHexString(color);
                case 'hsv': return toHsvString(color);
                case 'rgb': return toRgbString(color);
            }
        }
    property alias title: __colorPickerPanel.title
    property alias alphaEnabled: __colorPickerPanel.alphaEnabled
    property alias open: __popup.visible
    property alias format: __colorPickerPanel.format
    property alias presets: __colorPickerPanel.presets
    property alias presetsOrientation: __colorPickerPanel.presetsOrientation
    property alias presetsLayoutDirection: __colorPickerPanel.presetsLayoutDirection
    property alias titleFont: __colorPickerPanel.titleFont
    property alias inputFont: __colorPickerPanel.inputFont
    property alias colorBg: __colorPickerPanel.colorBg
    property alias colorBorder: __colorPickerPanel.colorBorder
    property color colorText: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    property alias colorInput: __colorPickerPanel.colorInput
    property alias colorTitle: __colorPickerPanel.colorTitle
    property alias colorPresetIcon: __colorPickerPanel.colorPresetIcon
    property alias colorPresetText: __colorPickerPanel.colorPresetText
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property MosRadius radiusTriggerBg: MosRadius { all: themeSource.radiusTriggerBg }
    property MosRadius radiusPopupBg: MosRadius { all: themeSource.radiusPopupBg }

    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosColorPicker

    property alias popup: __popup
    property alias panel: __colorPickerPanel

    property Component textDelegate: MosText {
        padding: 4
        text: root.textFormatter(root.value)
        color: root.colorText
        font: root.font
        verticalAlignment: Text.AlignVCenter
    }
    property alias titleDelegate: __colorPickerPanel.titleDelegate
    property Component footerDelegate: Item { }

    function toHexString(color: color): string {
        return __colorPickerPanel.toHexString(color);
    }

    function toHsvString(color: color): string {
        return __colorPickerPanel.toHsvString(color);
    }

    function toRgbString(color: color): string {
        return __colorPickerPanel.toRgbString(color);
    }

    objectName: '__MosColorPicker__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 4
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    contentItem: RowLayout {
        spacing: 4

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 22 * root.sizeRatio
            Layout.preferredHeight: 22 * root.sizeRatio

            MosCheckerBoard {
                anchors.fill: parent
                rows: 4
                columns: 4
                radiusBg: root.radiusTriggerBg
            }

            MosRectangleInternal {
                anchors.fill: parent
                radius: root.radiusTriggerBg.all
                topLeftRadius: root.radiusTriggerBg.topLeft
                topRightRadius: root.radiusTriggerBg.topRight
                bottomLeftRadius: root.radiusTriggerBg.bottomLeft
                bottomRightRadius: root.radiusTriggerBg.bottomRight
                color: root.value
                border.color: root.themeSource.colorBorder
            }
        }

        Loader {
            Layout.preferredHeight: 24 * root.sizeRatio
            active: root.showText
            visible: active
            sourceComponent: root.textDelegate
        }
    }
    background: MosRectangleInternal {
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
        color: root.colorBg
        border.color: root.colorBorder
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: __popup.visible = !__popup.visible;
    }

    MosPopup {
        id: __popup
        y: parent.height + 6
        padding: 0
        animationEnabled: root.animationEnabled
        radiusBg: root.radiusPopupBg
        closePolicy: T.Popup.NoAutoClose | T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent
        Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
        transformOrigin: {
            if (isTop)
                return isLeft ? Item.BottomRight : Item.BottomLeft;
            else
                return isLeft ? Item.TopRight : Item.TopLeft;
        }
        enter: Transition {
            NumberAnimation {
                property: 'scale'
                from: 0.5
                to: 1.0
                easing.type: Easing.OutQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
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
                property: 'scale'
                from: 1.0
                to: 0.5
                easing.type: Easing.InQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
            NumberAnimation {
                property: 'opacity'
                from: 1.0
                to: 0.0
                easing.type: Easing.InQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
        }
        contentItem: Column {
            MosColorPickerPanel {
                id: __colorPickerPanel
                animationEnabled: root.animationEnabled
                themeSource: root.themeSource
                active: root.active
                locale: root.locale
                background: Item { }
                onChange: color => root.change(color);
            }
            Loader {
                width: parent.width
                sourceComponent: root.footerDelegate
            }
        }
        property real xCenter: x + width * 0.5
        property real yCenter: y + height * 0.5
        property bool isLeft: xCenter < root.width * 0.5
        property bool isTop: yCenter < root.height * 0.5
    }
}
