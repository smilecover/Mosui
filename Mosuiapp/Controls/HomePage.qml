import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle{
    id: homePage
    color: "transparent"



    enum Background {
        None = 0,
        FractalLand = 1,
        GlassRain = 2
    }

    property int currentBackground: appData.currentBackground

    property real shaderTime: 0
    Timer {
        running: homePage.currentBackground === HomePage.FractalLand
        repeat: true
        interval: 16
        onTriggered: homePage.shaderTime += 0.01
    }

    // property Component hyperkart: ShaderEffect {
    //     anchors.fill: parent
    //     vertexShader: "qrc:/shaders/Hyperkart.vert.qsb"
    //     fragmentShader: "qrc:/shaders/Hyperkart.frag.qsb"

    //     property vector3d iResolution: Qt.vector3d(width, height, 0)
    //     property real iTime: homePage.shaderTime
    //     property vector4d iMouse: Qt.vector4d(0, 0, 0, 0)
    // }

    property Component fractalLand: ShaderEffect {
        anchors.fill: parent
        vertexShader: "qrc:/shaders/Fractal_Land.vert.qsb"
        fragmentShader: "qrc:/shaders/Fractal_Land.frag.qsb"

        property vector3d iResolution: Qt.vector3d(width, height, 0)
        property real iTime: homePage.shaderTime
        property vector4d iMouse: Qt.vector4d(0, 0, 0, 0)
    }

    property Component glassRain: Loader {
        anchors.fill: parent
        asynchronous: true
        source: Qt.resolvedUrl("./GlassRainBg.qml")
    }
    

    Loader {
        id: bgLoader
        anchors.fill: parent
        active: true
        asynchronous: true
        sourceComponent: {
            switch(homePage.currentBackground) {
                case HomePage.None: return null;
                case HomePage.FractalLand: return homePage.fractalLand;
                case HomePage.GlassRain: return homePage.glassRain;
                default: return null;
            }
        }
    }
}