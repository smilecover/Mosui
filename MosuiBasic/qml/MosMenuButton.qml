import QtQuick
import MosuiBasic

MosButton{
    id: root
    objectName: '__MosMenuButton__'

    property var iconSource: 0 ?? ''
    property bool animationEnabled: MosTheme.animationEnabled
    property int iconSize: parseInt(root.themeSource.fontSize)
    property int iconSpacing: 5
    property bool expanded: false
    property bool showExpanded: false
    property bool isCurrent: false  
    property bool isGroup: false
    property var model: undefined
    property int menuDeep: -1
    property var iconDelegate: null
    property var labelDelegate: null
    property var contentDelegate: null
    property var bgDelegate: null
    property var themeSource: MosTheme.MosMenuButton

    onClicked: {
        if (showExpanded)
            expanded = !expanded;
    }

    effectEnabled: false
    colorBorder: 'transparent'
    colorText: {
        if (enabled) {
            if (isGroup) {
                return (isCurrent && root.compactMode !== MosMenu.Mode_Relaxed) ? root.themeSource.colorTextActive :
                                                                    root.themeSource.colorTextDisabled;
            } else {
                return isCurrent ? root.themeSource.colorTextActive : root.themeSource.colorText;
            }
        } else {
            return root.themeSource.colorTextDisabled;
        }
    }
    colorBg: {
        if (enabled) {
            if (isGroup)
                return (isCurrent && root.compactMode !== MosMenu.Mode_Relaxed) ? root.themeSource.colorBgActive :
                                                                                        root.themeSource.colorBgDisabled;
            else if (isCurrent)
                return root.themeSource.colorBgActive;
            else if (hovered) {
                return root.themeSource.colorBgHover;
            } else {
                return root.themeSource.colorBg;
            }
        } else {
            return root.themeSource.colorBgDisabled;
        }
    }
    contentItem: Loader {
        sourceComponent: root.contentDelegate
        property alias model: root.model
        property alias menuButton: root
    }
    background: Loader {
        sourceComponent: root.bgDelegate
        property alias model: root.model
        property alias menuButton: root
    }
}   