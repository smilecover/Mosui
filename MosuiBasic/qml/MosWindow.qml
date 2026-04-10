import QtQuick
import MosuiBasic

Window {
    id: root
    objectName: '__MosWindow__'
    visible: true

    property alias windowAgent: windowAgent

    title: windowAgent.windowTitle

    MosWindowAgent {
        id: windowAgent
    }

    MosCaptionbar {
        id: captionbar
        width: root.width
        height: 32
        Component.onCompleted: windowAgent.setTitleBar(captionbar)
    }

    // 跟随主题系统同步标题栏暗色模式
    Connections {
        target: MosTheme
        function onIsDarkChanged() {
            windowAgent.setWindowAttribute("dark-mode", MosTheme.isDark)
            root.color = MosTheme.isDark ? "#181818" : "#f5f5f5"
        }
    }
}
