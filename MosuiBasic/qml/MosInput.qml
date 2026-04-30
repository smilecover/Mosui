import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.TextField {
    id: root

    enum IconPosition {
        Position_Left = 0,
        Position_Right = 1
    }

    enum Type {
        Type_Outlined = 1,
        Type_Dashed = 2,
        Type_Borderless = 3,
        Type_Underlined = 4,
        Type_Filled = 5
    }

    signal clickClear()

    property bool animationEnabled: MosTheme.animationEnabled
    property bool darkMode: MosTheme.isDark
    property bool active: hovered || activeFocus
    property int type: MosInput.Type_Outlined
    property bool showShadow: false
    property var iconSource: 0 ?? ''
    property int iconSize: parseInt(themeSource.fontSizeIcon) * sizeRatio
    property int iconPosition: MosInput.Position_Left
    property var clearEnabled: false ?? ''
    property var clearIconSource: MosIcon.CloseCircleFilled ?? ''
    property int clearIconSize: parseInt(themeSource.fontSizeClearIcon) * sizeRatio
    property int clearIconPosition: MosInput.Position_Right
    readonly property int leftIconPadding: iconPosition === MosInput.Position_Left ? __private.iconSize : 0
    readonly property int rightIconPadding: iconPosition === MosInput.Position_Right ? __private.iconSize : 0
    readonly property int leftClearIconPadding: clearIconPosition === MosInput.Position_Left ? __private.clearIconSize : 0
    readonly property int rightClearIconPadding: clearIconPosition === MosInput.Position_Right ? __private.clearIconSize : 0
    property color colorIcon: enabled ? themeSource.colorIcon : themeSource.colorIconDisabled
    property alias colorText: root.color
    property color colorBorder: enabled ?
                                    active ? themeSource.colorBorderHover :
                                             themeSource.colorBorder : themeSource.colorBorderDisabled
    property color colorBg: {
        if (enabled) {
            if (type === MosInput.Type_Borderless || type === MosInput.Type_Underlined) {
                return 'transparent';
            } else if (type === MosInput.Type_Filled) {
                return themeSource.colorBgFilled;
            } else {
                return themeSource.colorBg;
            }
        } else {
            return themeSource.colorBgDisabled;
        }
    }
    property color colorShadow: enabled ? themeSource.colorShadow : 'transparent'
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property string contentDescription: ''
    property var themeSource: MosTheme.MosInput

    property Component iconDelegate: MosIconText {
        leftPadding: root.iconPosition === MosInput.Position_Left ? 10 * sizeRatio: 0
        rightPadding: root.iconPosition === MosInput.Position_Right ? 10 * sizeRatio: 0
        iconSource: root.iconSource
        iconSize: root.iconSize
        colorIcon: root.colorIcon
    }
    property Component clearIconDelegate: MosIconText {
        leftPadding: root.clearIconPosition === MosInput.Position_Left ? (root.leftIconPadding > 0 ? 5 : 10) * sizeRatio : 0
        rightPadding: root.clearIconPosition === MosInput.Position_Right ? (root.rightIconPadding > 0 ? 5 : 10) * sizeRatio : 0
        iconSource: root.length > 0 ? root.clearIconSource : 0
        iconSize: root.clearIconSize
        colorIcon: {
            if (root.enabled) {
                return __tapHandler.pressed ? root.themeSource.colorClearIconActive :
                                              __hoverHandler.hovered ? root.themeSource.colorClearIconHover :
                                                                       root.themeSource.colorClearIcon;
            } else {
                return root.themeSource.colorClearIconDisabled;
            }
        }

        Behavior on colorIcon { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

        HoverHandler {
            id: __hoverHandler
            enabled: (root.clearEnabled === 'active' || root.clearEnabled === true) && !root.readOnly
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: __tapHandler
            enabled: (root.clearEnabled === 'active' || root.clearEnabled === true) && !root.readOnly
            onTapped: {
                root.clear();
                root.clickClear();
            }
        }
    }
    property Component bgDelegate: Item {
        Loader {
            anchors.fill: parent
            visible: active
            active: root.type === MosInput.Type_Outlined || root.type === MosInput.Type_Filled
            sourceComponent: MosRectangleInternal {
                color: root.colorBg
                border.color: root.colorBorder
                radius: root.radiusBg.all
                topLeftRadius: root.radiusBg.topLeft
                topRightRadius: root.radiusBg.topRight
                bottomLeftRadius: root.radiusBg.bottomLeft
                bottomRightRadius: root.radiusBg.bottomRight
            }
        }

        Loader {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            visible: active
            active: root.type === MosInput.Type_Underlined
            sourceComponent: MosRectangleInternal {
                color: root.colorBorder
            }
        }

        Loader {
            anchors.fill: parent
            visible: active
            active: root.type === MosInput.Type_Dashed
            sourceComponent: MosRectangle {
                color: root.colorBg
                border.color: root.colorBorder
                border.style: Qt.DashLine
                radius: root.radiusBg.all
                topLeftRadius: root.radiusBg.topLeft
                topRightRadius: root.radiusBg.topRight
                bottomLeftRadius: root.radiusBg.bottomLeft
                bottomRightRadius: root.radiusBg.bottomRight
            }
        }
    }

    objectName: '__MosInput__'
    focus: true
    padding: 6 * sizeRatio
    leftPadding: (__private.leftHasIcons ? 5 : 10) * sizeRatio + leftIconPadding + leftClearIconPadding
    rightPadding: (__private.rightHasIcons ? 5 : 10) * sizeRatio + rightIconPadding + rightClearIconPadding
    color: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    placeholderTextColor: enabled ? themeSource.colorPlaceholderText : themeSource.colorPlaceholderTextDisabled
    selectedTextColor: themeSource.colorTextSelected
    selectionColor: themeSource.colorSelection
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    background: Item {
        Loader {
            anchors.fill: parent
            active: root.showShadow
            sourceComponent: MosShadow {
                source: __bgLoader
                shadowColor: root.colorShadow
                shadowOpacity: root.enabled && root.active ? 0.2 : 0
                shadowBlur: 0.3
            }
        }

        Loader {
            id: __bgLoader
            anchors.fill: parent
            visible: !root.showShadow
            sourceComponent: root.bgDelegate
        }
    }

    Behavior on colorText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorBorder { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

    QtObject {
        id: __private
        property bool leftHasIcons: root.leftIconPadding + root.leftClearIconPadding > 0
        property bool rightHasIcons: root.rightIconPadding + root.rightClearIconPadding > 0
        property int iconSize: __iconLoader.active ? __iconLoader.width : 0
        property int clearIconSize: __clearIconLoader.active ? __clearIconLoader.width : 0
    }

    Loader {
        id: __iconLoader
        active: root.iconSource !== 0 && root.iconSource !== ''
        anchors.left: root.iconPosition === MosInput.Position_Left ? parent.left : undefined
        anchors.right: root.iconPosition === MosInput.Position_Right ? parent.right : undefined
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: root.iconDelegate
    }

    Loader {
        id: __clearIconLoader
        active: root.enabled && !root.readOnly && root.clearIconSource !== 0 && root.clearIconSource !== ''
                && (root.clearEnabled === true || (root.clearEnabled === 'active' && root.active))
        anchors.left: {
            if (root.clearIconPosition === MosInput.Position_Left) {
                return __iconLoader.active && root.iconPosition === MosInput.Position_Left ? __iconLoader.right : parent.left;
            } else {
                return undefined;
            }
        }
        anchors.right: {
            if (root.clearIconPosition === MosInput.Position_Right) {
                return __iconLoader.active && root.iconPosition === MosInput.Position_Right ? __iconLoader.left : parent.right;
            } else {
                return undefined;
            }
        }
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: root.clearIconDelegate
    }

    Accessible.role: Accessible.EditableText
    Accessible.editable: !root.readOnly
    Accessible.description: root.contentDescription
}
