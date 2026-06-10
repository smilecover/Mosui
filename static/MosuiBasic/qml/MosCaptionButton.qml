import QtQuick
import MosuiBasic

MosIconButton{
    id: root
    property bool isError: false
    property bool noDisabledState: true
    
    themeSource: MosTheme.MosCaptionButton
    objectName: '__MosCaptionButton__'
    leftPadding: 12 * sizeRatio
    rightPadding: 12 * sizeRatio
    active: down
    radiusBg.all: 0
    hoverCursorShape: Qt.ArrowCursor
    type: MosButton.Type_Text
    iconSize: parseInt(themeSource.fontSize)
    effectEnabled: false
    colorIcon: {
        if (enabled || noDisabledState) {
            return checked ? themeSource.colorIconChecked :
                             themeSource.colorIcon;
        } else {
            return themeSource.colorIconDisabled;
        }
    }
    colorBg: {
        if (enabled || noDisabledState) {
            if (isError) {
                return active ? themeSource.colorErrorBgActive:
                                hovered ? themeSource.colorErrorBgHover :
                                          themeSource.colorErrorBg;
            } else {
                return active ? themeSource.colorBgActive:
                                hovered ? themeSource.colorBgHover :
                                          themeSource.colorBg;
            }
        } else {
            return themeSource.colorBgDisabled;
        }
    }
}
