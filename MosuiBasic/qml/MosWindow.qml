import QtQuick
import MosuiBasic

Window {
    id: root
    objectName: '__MosWindow__'
    visible: false
    color: "Transparent"

    property alias windowAgent: windowAgent
    property alias captionbar: captionbar
    property bool initialized: false
    property bool followThemeSwitch: true
    

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
    readonly property var __effectNameMap: {
        var m = {};
        m[MosWindow.Effect_None] = "";
        m[MosWindow.Effect_dwm_blur] = "dwm-blur";
        m[MosWindow.Effect_acrylic_material] = "acrylic-material";
        m[MosWindow.Effect_mica] = "mica";
        m[MosWindow.Effect_mica_alt] = "mica-alt";
        return m;
    }
    property string effectName: __effectNameMap[effect] || ""
    readonly property var __allEffectNames: ["dwm-blur", "acrylic-material", "mica", "mica-alt"]
    function setEffect(newEffect : int): bool {
        // 先关闭所有 DWM 效果
        for (var i = 0; i < __allEffectNames.length; i++)
            windowAgent.setWindowAttribute(__allEffectNames[i], false);

        if (newEffect === MosWindow.Effect_None) {
            root.effect = MosWindow.Effect_None;
            root.color = MosTheme.Primary.colorBgBase;
            return true;
        }

        var name = __effectNameMap[newEffect];
        if (!name) return false;

        if (windowAgent.setWindowAttribute(name, true)) {
            root.effect = newEffect;
            root.color = 'transparent';
            return true;
        }
        return false;
    }
    function setWindowMode(isDark: bool): bool {
        if (windowAgent.initialized)
            return windowAgent.setWindowAttribute('dark-mode', isDark);
        return false;
    }


    MosCaptionbar {
        id: captionbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 32
        color: captionbarcolor
        z: 9999
        winIcon: root.windowIcon
        targetWindow: root
        windowAgent: root.windowAgent
    }

    MosWindowAgent {
        id: windowAgent
    }
    Connections {
        id: __connections
        target: MosTheme
        enabled: root.followThemeSwitch
        function onIsDarkChanged() {
            if (root.effect == MosWindow.Effect_None){
                root.color = MosTheme.Primary.colorBgBase;
            }
            root.setWindowMode(MosTheme.isDark);
        }
    }

    Component.onCompleted: {
        initialized = true;
        windowAgent.setTitleBar(captionbar)
        if(effect != MosWindow.Effect_None) {
            windowAgent.setWindowAttribute(root.effectName, true)
        }   
        if (followThemeSwitch)
            __connections.onIsDarkChanged();
        
        captionbar.windowAgent = windowAgent
        root.visible = true
    }
    
}
