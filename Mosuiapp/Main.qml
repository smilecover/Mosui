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
    MosCaptionButton{
        id: exitButton
        anchors.centerIn: parent
        height: 32
        iconSource: 0xeb1b
        onClicked: {
            if(root){
                root.close()
            }
        }
    }
}