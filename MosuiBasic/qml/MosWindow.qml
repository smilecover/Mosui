import QtQuick
import MosuiBasic

Window {
    id: root
    objectName: '__MosWindow__'
    visible: false
    color: "Transparent"

    property alias windowAgent: windowAgent
    property alias captionbar: captionbar
    

    property color captionbarcolor: "Transparent"

    property string windowIcon: ''

    title: windowAgent.windowTitle
    // 页面效果
    enum Effect {
        Effect_None = 0,
        Effect_dwm_blur,
        Effect_acrylic_material,
        Effect_mica,
        Effect_mica_alt
    }
    property int effect: MosWindow.Effect_acrylic_material
    property string effectName: {
        switch (effect) {
            case MosWindow.Effect_None: return "";
            case MosWindow.Effect_dwm_blur: return "dwm-blur";
            case MosWindow.Effect_acrylic_material: return "acrylic-material";
            case MosWindow.Effect_mica: return "mica";
            case MosWindow.Effect_mica_alt: return "mica-alt";
            default: return "";
        }
    }


    MosCaptionbar {
        id: captionbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.width
        height: 32
        color: captionbarcolor
        z: 9999
        winIcon: root.windowIcon
        targetWindow: root
        windowAgent: root.windowAgent
    }

    MosWindowAgent {
        id: windowAgent

        Component.onCompleted: {
            setTitleBar(captionbar)
            if(effect != MosWindow.Effect_None) {
                setWindowAttribute(root.effectName, true)
            }
            
            captionbar.windowAgent = windowAgent
            root.visible = true
        }
    }
}
