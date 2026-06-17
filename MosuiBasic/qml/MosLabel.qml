import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Label {
    id: root

    property real borderWidth: 1
    property alias colorText: root.color
    property color colorBg: enabled ? themeSource.colorBg : themeSource.colorBgDisabled
    property color colorBorder: themeSource.colorBorder
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosLabel

    objectName: '__MosLabel__'
    padding: 5 * sizeRatio
    leftPadding: 8 * sizeRatio
    rightPadding: 8 * sizeRatio
    renderType: MosTheme.textRenderType
    color: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    linkColor: enabled ? themeSource.colorLinkText : themeSource.colorTextDisabled
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    background: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        border.width: root.borderWidth
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
    }
}
