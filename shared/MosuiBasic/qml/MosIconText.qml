import QtQuick
import MosuiBasic

MosText {
    id: control

    readonly property bool empty: iconSource === 0 || iconSource === ''
    property var iconSource: 0 ?? ''
    property alias iconSize: control.font.pixelSize
    property alias colorIcon: control.color
    property string contentDescription: text

    objectName: '__MosIconText__'
    width: __iconLoader.active ? (__iconLoader.implicitWidth + leftPadding + rightPadding) : implicitWidth
    height: __iconLoader.active ? (__iconLoader.implicitHeight + topPadding + bottomPadding) : implicitHeight
    text: __iconLoader.active ? '' : String.fromCharCode(iconSource)
    font {
        family: 'MosUI-Icons'
        pixelSize: parseInt(MosTheme.MosIconText.fontSize)
    }
    // color: enabled ? MosTheme.MosIconText.colorText : MosTheme.MosIconText.colorTextDisabled

    Loader {
        id: __iconLoader
        anchors.centerIn: parent
        active: typeof iconSource == 'string' && iconSource !== ''
        sourceComponent: Image {
            source: control.iconSource
            width: control.iconSize
            height: control.iconSize
            sourceSize: Qt.size(width, height)
        }
    }

    Accessible.role: Accessible.Graphic
    Accessible.name: control.text
    Accessible.description: control.contentDescription
}
