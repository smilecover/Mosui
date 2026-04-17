import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.Control{
    id: root
    objectName: '__MosMenu__'

    enum CompactMode {
        Mode_Relaxed = 0,
        Mode_Standard = 1,
        Mode_Compact = 2
    }
    property var themeSource: MosTheme.MosMenu

    property color menuColor: "red"

    signal clickMenu(deep: int, key: string, keyPath: var, data: var)

    property bool animationEnabled: MosTheme.animationEnabled

    property bool showEdge: false
    property bool showToolTip: false

    property int compactMode: MosMenu.Mode_Relaxed
    property int compactWidth: {
        switch (compactMode) {
        case MosMenu.Mode_Relaxed: return 0;
        case MosMenu.Mode_Standard: return 80;
        case MosMenu.Mode_Compact: return 52;
        }
    }


    property bool popupMode: false
    property int popupWidth: 200
    property int popupOffset: 4
    property int popupMaxHeight: height
    property int defaultMenuIconSize: font.pixelSize + 2
    property int defaultMenuIconSpacing: 8
    property int defaultMenuWidth: 300
    property int defaultMenuTopPadding: 10
    property int defaultMenuBottomPadding: 10
    property int defaultMenuSpacing: 4
    property var defaultSelectedKeys: []
    property string selectedKey: ''
    property var initModel: []
    property MosRadius radiusMenuBg:  MosRadius { all: root.themeSource.radiusMenuBg }
    property MosRadius radiusPopupBg:  MosRadius { all: root.themeSource.radiusPopupBg }
    property string contentDescription: ''  
 

    // property alias scrollBar: __menuScrollBar
    MosRectangleInternal{
        id: menuBg
        anchors.fill: parent
        color: menuColor
        radius: radiusMenuBg.all
    }
    
    

}

