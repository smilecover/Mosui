import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic
import QtWebEngine
import QtQuick.Effects

MosRectangle{
    id: homePage
    color: "transparent"



    enum Background {
        None = 0,
        FractalLand = 1,
        GlassRain = 2
    }

    property int currentBackground: appTplnvData.currentBackground

    property real shaderTime: 0
    Timer {
        running: true
        repeat: true
        interval: 16
        onTriggered: homePage.shaderTime += 0.01
    }

    property Component fractalLand: ShaderEffect {
        anchors.fill: parent
        vertexShader: "qrc:/shaders/Fractal_Land.vert.qsb"
        fragmentShader: "qrc:/shaders/Fractal_Land.frag.qsb"

        property vector3d iResolution: Qt.vector3d(width, height, 0)
        property real iTime: homePage.shaderTime
        property vector4d iMouse: Qt.vector4d(0, 0, 0, 0)
    }

    property Component glassRain: Item{
        anchors.fill: parent
        WebEngineView {
            id: webEngine
            anchors.fill: parent
            url: "qrc:/html/rain-on-glass.html"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton                
        }
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
    // Flickable {
    //     id:root
    //     contentHeight: column.height
    //     // 在item中居中
    //     anchors.fill: parent
    //     ScrollBar.vertical: MosScrollBar {
    //         anchors.right: parent.right
    //         anchors.rightMargin: 5

    //     }
    Column {
        id: column
        anchors.centerIn: parent
        spacing: 30

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Item {
                width: MosTheme.Primary.fontPrimarySize * 30
                height: MosTheme.Primary.fontPrimarySize + 32
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: huskaruiIcon
                    width: parent.width
                    height: width
                    anchors.centerIn: parent
                    source: 'qrc:/logo.png'
                    MosShadow {
                        source: huskaruiIcon
                        anchors.fill: huskaruiIcon
                        shadowHorizontalOffset: 6
                        shadowVerticalOffset: 6
                        shadowBlur: 1.0
                        opacity: 1.0
                        Behavior on opacity { NumberAnimation { duration: MosTheme.Primary.durationMid } }
                    }
                }
            }

            Item {
                width: huskaruiTitle.width
                height: huskaruiTitle.height
                anchors.horizontalCenter: parent.horizontalCenter

                MosText {
                    id: huskaruiTitle
                    text: 'TPInv - 逆变器工具箱'
                    color: '#000000'
                    font.pixelSize: MosTheme.Primary.fontPrimarySize + 32
                    font.bold: true
                }
                MosShadow {
                    source: huskaruiTitle
                    anchors.fill: huskaruiTitle
                    shadowHorizontalOffset: 6
                    shadowVerticalOffset: 6
                    shadowColor: huskaruiTitle.color
                    shadowBlur: 1.0
                    opacity: 1.0

                    Behavior on shadowColor { ColorAnimation { duration: MosTheme.Primary.durationMid } }
                    Behavior on opacity { NumberAnimation { duration: MosTheme.Primary.durationMid } }
                }
            } 
        }
    }
}