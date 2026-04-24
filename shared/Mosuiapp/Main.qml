import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MosuiBasic
import "./Controls" as C
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    // color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    windowIcon: "qrc:/image/image/cangshu.svg"
    MenuModel{id: menumodel}
    MosRouter {id: galleryRouter}
    C.Data{id: appData
    onMenuTypeChanged: {
        console.log("menuType: "+appData.menuType)
        }
    }

    MosMenu{
        id: menu
        width: root.width/5>200?200:root.width/5
        anchors.top: captionbar.bottom
        anchors.left: parent.left
        anchors.bottom: linemenutosetting.top
        showEdge: true
        compactMode: appData.menuType
        // popupMode: true

        initModel: menumodel.menus
        defaultSelectedKeys: ['HomePage']
        onClickMenu: function(deep, key, keyPath, data) 
        {
            if (data.source) 
            {
                galleryRouter.push(data.source)
            }
        }
        onCompactModeChanged: {
            if (compactMode == 0) {
                menu.width = root.width/5>200?200:root.width/5
            } else if (compactMode == 1) {
                menu.width = root.width/5>100?100:root.width/5
            } else {
                menu.width = root.width/10>50?50:root.width/10
            }
        }
    }
    MosDivider{
        id: linemenutosetting
        anchors.bottom: settingItem.top
        anchors.left: menu.left
        anchors.leftMargin: 2
        anchors.right: menu.right
        anchors.bottomMargin: 0
    }
    Item{
        id: settingItem
        anchors.left: menu.left
        anchors.right: menu.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        height: 30
        property Component settingButtonComponent: MosRotateIconButton {
            iconSource: MosIcon.SettingsOutlined
            iconSize: 30
            onClicked: {
                galleryRouter.push('./Controls/SettingsPage.qml')
                menu.clearSelection()
            }
        }
        Loader{
            anchors.fill: parent
            id: settingsButtonLoader
            sourceComponent: settingItem.settingButtonComponent
            visible: settingItem.settingButtonComponent !== null && root.visible
        }
    }



    Item{
        id: item
        anchors.left: menu.right
        anchors.right: parent.right
        anchors.top: captionbar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 5
        // clip: true

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