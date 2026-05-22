import QtQuick
import QtQuick.Controls
import MosuiBasic
import QtWebEngine
import "../../Controls" as C
MosWindow{
    id: tpinvwindow
    visible: true
    width: 1200
    height: 800


    TplnvMenuModel{id: menumodel}
    MosRouter{id: tplnvRouter}
    TplnvData{id: appTplnvData
        // onRainAmountChanged: {
        //     webView.updateWebParams()
        // }
        // onRefractionChanged: {
        //     webView.updateWebParams()
        // }
    }
    // Item{
    //     anchors.fill: parent
    //     WebEngineView {
    //         id: webView
    //         anchors.fill: parent
    //         url: "qrc:/html/rain-on-glass.html"
    //         settings {
    //             localContentCanAccessRemoteUrls: true
    //             localContentCanAccessFileUrls: true
    //             javascriptEnabled: true
    //         }
    //         function updateWebParams() {
    //             runJavaScript("updateRainvalue(" + appTplnvData.rainAmount + "," + appTplnvData.refraction + ")");
    //         }
    //         onLoadingChanged: function(loadRequest) {
    //             if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
    //                 updateWebParams()
    //             }
    //         }
    //     }
    //     MouseArea {
    //         anchors.fill: parent
    //         acceptedButtons: Qt.RightButton                
    //     }
    // }

    MosMenu{
        id: menu
        anchors.top: captionbar.bottom
        anchors.left: parent.left
        anchors.bottom: linemenutosetting.top
        showEdge: true
        compactMode: appTplnvData.menuType

        initModel: menumodel.menus
        defaultSelectedKeys: ['HomePage']
        onClickMenu: function(deep, key, keyPath, data) 
        {
            if (data.source) 
            {
                tplnvRouter.push(data.source)
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
                tplnvRouter.push('./Tplnvsetting.qml')
                menu.clearSelection()
            }
        }
        Loader{
            anchors.fill: parent
            id: settingsButtonLoader
            sourceComponent: settingItem.settingButtonComponent
            visible: settingItem.settingButtonComponent !== null && tpinvwindow.visible
        }
    }

    Item{
        id: item
        anchors.left: menu.right
        anchors.right: parent.right
        anchors.top: captionbar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 0
        clip: true

        Loader{
            id: nextpage
            visible: false
        }
        Loader {
            id: containerLoader
            anchors.fill: parent
            source: tplnvRouter.currentUrl
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}