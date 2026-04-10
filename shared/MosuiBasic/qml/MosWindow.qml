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
            // dark-mode 已由 classBegin() 初始化，此处仅做动态切换
            windowAgent.setWindowAttribute("dark-mode", MosTheme.isDark)
            // 同步窗口背景
            root.color = MosTheme.isDark ? "#181818" : "#f5f5f5"
        }
    }
}
