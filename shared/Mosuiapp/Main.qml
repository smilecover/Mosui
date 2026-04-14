import QtQuick
import QtQuick.Controls
import MosuiBasic
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    captionbarcolor: MosCaptionbar.CaptionbarColorTransparent
    MosIconButton{
        id: iconbutton1
        anchors.centerIn: parent
        height: 50
        iconSize: 30
        iconSource: 0xe78f
        type: MosButton.Type_Default
        shape: MosButton.Shape_Circle
    }

}