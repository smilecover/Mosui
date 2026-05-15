import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle{
    id: homePage
    color: "black"



    enum Background {
        Hyperkart,
        FractalLand,
        Boykisser
    }

    property int currentBackground: appData.currentBackground

    property real shaderTime: 0
    Timer {
        running: true
        repeat: true
        interval: 16
        onTriggered: homePage.shaderTime += 0.01
    }

    property Component hyperkart: ShaderEffect {
        anchors.fill: parent
        vertexShader: "qrc:/shaders/Hyperkart.vert.qsb"
        fragmentShader: "qrc:/shaders/Hyperkart.frag.qsb"

        property vector3d iResolution: Qt.vector3d(width, height, 0)
        property real iTime: homePage.shaderTime
        property vector4d iMouse: Qt.vector4d(0, 0, 0, 0)
    }

    property Component fractalLand: ShaderEffect {
        anchors.fill: parent
        vertexShader: "qrc:/shaders/Fractal_Land.vert.qsb"
        fragmentShader: "qrc:/shaders/Fractal_Land.frag.qsb"

        property vector3d iResolution: Qt.vector3d(width, height, 0)
        property real iTime: homePage.shaderTime
        property vector4d iMouse: Qt.vector4d(0, 0, 0, 0)
    }

    property Component boykisser: ShaderEffect {
        anchors.fill: parent
        vertexShader: "qrc:/shaders/boykisser.vert.qsb"
        fragmentShader: "qrc:/shaders/boykisser.frag.qsb"

        property vector3d iResolution: Qt.vector3d(width, height, 0)
        property real iTime: homePage.shaderTime
        property vector4d iMouse: Qt.vector4d(0, 0, 0, 0)
    }

    Loader {
        id: bgLoader
        anchors.fill: parent
        active: true
        asynchronous: true
        sourceComponent: {
            switch(homePage.currentBackground) {
                case HomePage.Hyperkart: return homePage.hyperkart;
                case HomePage.FractalLand: return homePage.fractalLand;
                case HomePage.Boykisser: return homePage.boykisser;
                default: return null;
            }
        }
    }
    ColumnLayout {
    id: settingsColumn
    anchors.top: parent.top
    anchors.topMargin: 30
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: backgroundSelector.implicitWidth
    spacing: 30
        MosRectangle {
            id: backgroundSelector
            width: 200
            height: 50
            color: "white"
            radius: MosTheme.Primary.radiusPrimaryLG
        }
    }
    
}