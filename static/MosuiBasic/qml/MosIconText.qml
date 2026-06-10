import QtQuick
import MosuiBasic

MosText {
    id: root
    objectName: '__MosIconText__'

    readonly property bool isIcon: iconSource === 0 || iconSource === ""
    property var iconSource: 0 ?? ""
    font {
        family: 'MOSUI'
        pixelSize: parseInt(MosTheme.MosIconText.fontSize)
    }
    
    property alias iconSize:root.font.pixelSize
    color: enabled ? MosTheme.MosIconText.colorText : MosTheme.MosIconText.colorTextDisabled
    property alias colorIcon: root.color
    property string contentDescription: text
    width: __iconLoader.active ? (__iconLoader.implicitWidth + leftPadding + rightPadding) : implicitWidth
    height: __iconLoader.active ? (__iconLoader.implicitHeight + topPadding + bottomPadding) : implicitHeight
    text: __iconLoader.active ? '' : String.fromCharCode(iconSource)

    Loader {
        id: __iconLoader
        anchors.centerIn: parent
        active: typeof iconSource == 'string' && iconSource !== ''
        sourceComponent: Image {
            source: root.iconSource
            width: root.iconSize
            height: root.iconSize
            sourceSize: Qt.size(width, height)
        }
    }

    Accessible.role: Accessible.Graphic
    Accessible.name: root.text
    Accessible.description: root.contentDescription
    
}
