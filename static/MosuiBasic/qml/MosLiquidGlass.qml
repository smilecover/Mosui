import QtQuick
import MosuiBasic

Item {
    id: root

    property alias sourceItem: __source.sourceItem
    property alias sourceRect: __source.sourceRect
    property real refraction: 0.026
    property real bevelDepth: 0.119
    property real bevelWidth: 0.057
    property real frost: 0.0
    property bool animated: true
    property real specularIntensity: 1.0
    property real tiltX: 0.0
    property real tiltY: 0.0
    property real magnify: 1.0
    property MosRadius radiusBg: MosRadius { all: 0 }

    objectName: '__MosLiquidGlass__'

    readonly property real __srcScale: {
        const magnifyPad = Math.max(1.0 / Math.max(root.magnify, 0.001), 1.0);
        const refrPad = 1.0 + 2.0 * (root.refraction + root.bevelDepth);
        return Math.max(magnifyPad, refrPad, 1.1);
    }

    ShaderEffectSource {
        id: __source
        anchors.fill: parent
        visible: false
        sourceRect: Qt.rect(
            root.x - root.width * (root.__srcScale - 1.0) * 0.5,
            root.y - root.height * (root.__srcScale - 1.0) * 0.5,
            root.width * root.__srcScale,
            root.height * root.__srcScale
        )
    }

    ShaderEffect {
        id: __shaderEffect
        anchors.fill: parent

        property variant source: __source
        property vector2d resolution: Qt.vector2d(root.width, root.height)
        property real refraction: root.refraction
        property real bevelDepth: root.bevelDepth
        property real bevelWidth: root.bevelWidth
        property real frost: root.frost
        property real radius: root.radiusBg.all
        property real specularIntensity: root.specularIntensity
        property real tiltX: root.tiltX
        property real tiltY: root.tiltY
        property real magnify: root.magnify
        property real iTime: 0.0

        NumberAnimation on iTime {
            running: root.animated && root.specularIntensity > 0.0
            loops: Animation.Infinite
            from: 0
            to: 360000      // 360000 seconds = 100 hours
            duration: 360000000  // real-time: 1 unit = 1 second
        }

        vertexShader: 'qrc:/shaders/mosliquidglass.vert.qsb'
        fragmentShader: 'qrc:/shaders/mosliquidglass.frag.qsb'
    }
}
