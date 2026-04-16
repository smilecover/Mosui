import QtQuick
import MosuiBasic

Window {
    id: root
    objectName: '__MosWindow__'
    visible: false
    color: "Transparent"

    property alias windowAgent: windowAgent

    property color captionbarcolor: "Transparent"

    property string windowIcon: ''

    title: windowAgent.windowTitle

    flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint

    MosCaptionbar {
        id: captionbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.width
        color: captionbarcolor
        z: 9999
        winIcon: root.windowIcon
        targetWindow: root
        windowAgent: root.windowAgent
    }

    MosWindowAgent {
        id: windowAgent

        Component.onCompleted: {
            setup(root)
            setTitleBar(captionbar)

            setWindowAttribute("acrylic-material", true)
            
            captionbar.windowAgent = windowAgent
            root.visible = true

        }
    }



}
