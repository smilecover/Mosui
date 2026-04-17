import QtQuick
import QtQuick.Controls
import MosuiBasic
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    // color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    windowIcon: "qrc:/image/image/cangshu.svg"
    MosMenu{
        id: menu
        width: root.width/5
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        menuColor: "red"
    }
    Item{
        id: item
        anchors.left: menu.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    MosRouter{
        id: router
    }
}