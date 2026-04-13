import QtQuick
import QtQuick.Layouts
import MosuiBasic

Item {
    id: root
    objectName: '__MosCaptionBar__'

    // 高度固定 32px（Windows 桌面标题栏标准高度）
    implicitHeight: 32

    enum CaptionbarColor {
        CaptionbarColorDefault = 0,
        CaptionbarColorTransparent = 1
    }
    property int captionbarcolor: MosCaptionbar.CaptionbarColorTransparent

    property color backgroundcolor:{

        if (enabled) {
            switch (root.captionbarcolor){
            case MosCaptionbar.CaptionbarColorDefault:
                return MosTheme.MosCaptionbar.DefaultColor
            case MosCaptionbar.CaptionbarColorTransparent:
                return MosTheme.MosCaptionbar.Transparent
            default:
                return MosTheme.MosCaptionbar.DefaultColor 
        }

        }
        
    }
        

    MosRectangle {
        id: background
        anchors.fill: parent
        color: backgroundcolor
    }
    

}
