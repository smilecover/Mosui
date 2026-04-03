import QtQuick
// import QtQml
import MosuiBasic

Window{
    id: root
    objectName: '__MosWindow__'
    visible: true
    Component.onCompleted: {
        windowAgent.setup(root)
        windowAgent.setWindowAttribute("dark-mode", true)
        if (root.showWhenReady) {
            root.visible = true
        }   
    }
    MosWindowAgent{
        id: windowAgent
    }
    MosCaptionbar{
        id: captionbar
        // targetWindow: root
        // windowAgent: windowAgent
        width: root.width
        height: 32
        Component.onCompleted: windowAgent.setTitleBar(captionbar)
    }

}