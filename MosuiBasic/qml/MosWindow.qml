import QtQuick
import MosuiBasic

Window {
    id: root
    objectName: '__MosWindow__'
    visible: false

    property alias windowAgent: windowAgent

    property color captionbarcolor: "transparent"

    title: windowAgent.windowTitle


    

    MosWindowAgent {
        id: windowAgent
        Component.onCompleted:{
            windowAgent.setup(root);
            windowAgent.setTitleBar(captionbar);
            captionbar.windowAgent = windowAgent
            Window.visible = true
        }
    }

    MosCaptionbar {
        id: captionbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.width
        color: "red"
        z: 65535
        targetWindow: root
        windowAgent: root.windowAgent
    }

}
