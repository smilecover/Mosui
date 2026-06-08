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
    property real rootOpacity: 1.0
    property color captionbarcolor: "Transparent"
    property string windowIcon: ''

    title: windowAgent.windowTitle? windowAgent.windowTitle : ""
    opacity: rootOpacity

    readonly property bool __isWindows: Qt.platform.os === "windows"
    readonly property bool __isMacOS: Qt.platform.os === "osx"
    readonly property bool __isLinux: !__isWindows && !__isMacOS

    enum Effect {
        Effect_None = 0,
        Effect_dwm_blur,
        Effect_acrylic_material,
        Effect_mica,
        Effect_mica_alt,
        Effect_mac_blur
    }

    property int effect: {
        if (__isWindows) return MosWindow.Effect_acrylic_material;
        if (__isMacOS)  return MosWindow.Effect_mac_blur;
        return MosWindow.Effect_acrylic_material;
    }

    readonly property var __effectNameMap: {
        var m = {};
        m[MosWindow.Effect_None] = "";
        m[MosWindow.Effect_dwm_blur] = "dwm-blur";
        m[MosWindow.Effect_acrylic_material] = "acrylic-material";
        m[MosWindow.Effect_mica] = "mica";
        m[MosWindow.Effect_mica_alt] = "mica-alt";
        m[MosWindow.Effect_mac_blur] = "blur-effect";
        return m;
    }
    property string effectName: __effectNameMap[effect] || ""
    readonly property var __allEffectNames: [
        "dwm-blur", "acrylic-material", "mica", "mica-alt", "blur-effect"
    ]

    // ── Linux 毛玻璃参数 ───────────────────────────────────
    function __tintOpacity(eff) {
        switch (eff) {
            case MosWindow.Effect_dwm_blur:          return 0.55;
            case MosWindow.Effect_acrylic_material:  return 0.40;
            case MosWindow.Effect_mica:              return 0.70;
            case MosWindow.Effect_mica_alt:          return 0.60;
            default: return 0.0;
        }
    }
    function __noiseStrength(eff) {
        switch (eff) {
            case MosWindow.Effect_dwm_blur:          return 0.08;
            case MosWindow.Effect_acrylic_material:  return 0.14;
            case MosWindow.Effect_mica:              return 0.05;
            case MosWindow.Effect_mica_alt:          return 0.07;
            default: return 0.0;
        }
    }

    // ── 切换效果 ──────────────────────────────────────────
    function setEffect(newEffect : int): bool {
        for (var i = 0; i < __allEffectNames.length; i++)
            windowAgent.setWindowAttribute(__allEffectNames[i], false);
        linuxTint.visible = false;
        linuxNoise.visible = false;

        if (newEffect === MosWindow.Effect_None) {
            root.effect = MosWindow.Effect_None;
            root.color = MosTheme.Primary.colorBgBase;
            return true;
        }

        if (__isMacOS && newEffect === MosWindow.Effect_mac_blur) {
            if (windowAgent.setWindowAttribute("blur-effect", "auto")) {
                root.effect = newEffect;
                root.color = "transparent";
                return true;
            }
            root.effect = MosWindow.Effect_None;
            root.color = MosTheme.Primary.colorBgBase;
            return false;
        }

        var name = __effectNameMap[newEffect];
        if (!name) {
            root.effect = MosWindow.Effect_None;
            root.color = MosTheme.Primary.colorBgBase;
            return false;
        }

        if (__isLinux) {
            // KDE best-effort + QML 毛玻璃渲染
            windowAgent.setWindowAttribute(name, true);
            root.effect = newEffect;
            root.color = "transparent";
            linuxTint.opacity = __tintOpacity(newEffect);
            linuxTint.visible = true;
            linuxNoise.opacity = __noiseStrength(newEffect);
            linuxNoise.visible = true;
            return true;
        }

        if (windowAgent.setWindowAttribute(name, true)) {
            root.effect = newEffect;
            root.color = "transparent";
            return true;
        }

        root.effect = MosWindow.Effect_None;
        root.color = MosTheme.Primary.colorBgBase;
        return false;
    }

    function setWindowMode(isDark: bool): bool {
        if (!windowAgent.initialized) return false;
        return windowAgent.setWindowAttribute('dark-mode', isDark);
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

    MosWindowAgent { id: windowAgent }

    // ── Linux 毛玻璃层 ────────────────────────────────────
    Rectangle {
        id: linuxTint
        anchors.fill: parent
        visible: false
        z: -9999
        color: MosTheme.Primary.colorBgBase
        opacity: 0.2
        Behavior on opacity { NumberAnimation { duration: MosTheme.Primary.durationFast } }
    }

    ShaderEffect {
        id: linuxNoise
        anchors.fill: parent
        visible: false
        z: -9998
        blending: true

        property real u_strength: 0.0

        vertexShader: "qrc:/shaders/noise.vert.qsb"
        fragmentShader: "qrc:/shaders/noise.frag.qsb"
    }

    Connections {
        id: __connections
        target: MosTheme
        enabled: root.followThemeSwitch
        function onIsDarkChanged() {
            if (root.effect == MosWindow.Effect_None) {
                root.color = MosTheme.Primary.colorBgBase;
            } else if (__isLinux && linuxTint.visible) {
                linuxTint.color = MosTheme.Primary.colorBgBase;
            }
            if (__isMacOS && root.effect == MosWindow.Effect_mac_blur)
                windowAgent.setWindowAttribute("blur-effect", "auto");
            root.setWindowMode(MosTheme.isDark);
        }
    }

    Component.onCompleted: {
        initialized = true;
        windowAgent.setTitleBar(captionbar);
        setEffect(effect);
        if (followThemeSwitch) __connections.onIsDarkChanged();
        captionbar.windowAgent = windowAgent;
        root.visible = true;
    }
}
