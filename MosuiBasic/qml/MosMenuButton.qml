import QtQuick
import MosuiBasic

MosButton{
    id: root
    objectName: '__MosMenuButton__'

    property var iconSource: 0 ?? ''
    property bool animationEnabled: MosTheme.animationEnabled
    property int iconSize: parseInt(control.themeSource.fontSize)
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
                return (isCurrent && control.compactMode !== HusMenu.Mode_Relaxed) ? control.themeSource.colorTextActive :
                                                                    control.themeSource.colorTextDisabled;
            } else {
                return isCurrent ? control.themeSource.colorTextActive : control.themeSource.colorText;
            }
        } else {
            return control.themeSource.colorTextDisabled;
        }
    }
    colorBg: {
        if (enabled) {
            if (isGroup)
                return (isCurrent && control.compactMode !== HusMenu.Mode_Relaxed) ? control.themeSource.colorBgActive :
                                                                                        control.themeSource.colorBgDisabled;
            else if (isCurrent)
                return control.themeSource.colorBgActive;
            else if (hovered) {
                return control.themeSource.colorBgHover;
            } else {
                return control.themeSource.colorBg;
            }
        } else {
            return control.themeSource.colorBgDisabled;
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