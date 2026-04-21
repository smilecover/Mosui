import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MosuiBasic
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    windowIcon: "qrc:/image/image/cangshu.svg"
    MenuModel{id: menumodel}
    MosRouter {id: galleryRouter}

    MosMenu{
        id: menu
        width: root.width/5
        anchors.top: captionbar.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        showEdge: true
        initModel: menumodel.galleryModel
        defaultSelectedKeys: ['HomePage']
        onClickMenu: function(deep, key, keyPath, data) 
        {
            if (data.source) 
            {
                galleryRouter.push(data.source)
            }
        }
        

    }

    Item{
        id: item
        anchors.left: menu.right
        anchors.right: parent.right
        anchors.top: captionbar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 5
        clip: true

        Loader{
            id: nextpage
            visible: false
        }
        Loader {
            id: containerLoader
            source: galleryRouter.currentUrl
        }
    }


}