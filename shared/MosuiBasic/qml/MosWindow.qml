import QtQuick
// import QtQml
import MosuiBasic

Window{
    id: root
    objectName: '__MosWindow__'
    visible: true
    Component.onCompleted: {
        windowAgent.setup(root)
        windowAgent.setWindowAttribute("dark-mode", MosTheme.isDark)
        if (root.showWhenReady) {
            root.visible = true
        }   
    }
    MosWindowAgent{
        id: windowAgent
    }
    MosCaptionbar{
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
        }
    }
}