import QtQuick
import MosuiBasic
Rectangle {
    id: root
    color: '#80000000'
    

    property Component shaderEffect: ShaderEffect {
        anchors.fill: parent
        vertexShader: 'qrc:/shaders/Fractal_Land.vert.qsb'
        fragmentShader: 'qrc:/shaders/Fractal_Land.frag.qsb'
        opacity: 0.5
        property vector3d iResolution: Qt.vector3d(width, height, 0)
        property real iTime: 0
        property variant iChannel1: ""
        property variant iChannel0: ""
        property vector4d iMouse: "0 0 0 0" 

        Timer {
            running: true
            repeat: true
            interval: 16
            onTriggered: {
                parent.iTime += 0.005;
            }
        }
    }
    Loader {
        id: loader
        anchors.fill: parent
        visible: root.visible && loader.status === Component.Ready && shaderEffect !== undefined
        sourceComponent: shaderEffect
    }
}