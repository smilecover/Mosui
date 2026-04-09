import QtQuick
import QtQuick.Templates as T
import QtQuick.Effects
import MosuiBasic

T.Control {
    id: control

    enum TextSize {
        Size_Fixed = 0,
        Size_Auto = 1
    }

    property int size: 30
    property var iconSource: 0 ?? ''

    property string imageSource: ''
    property bool imageMipmap: false

    property string textSource: ''
    property alias textFont: control.font
    property int textSize: MosAvatar.TextSize.Size_Fixed
    property int textGap: 4

    property color colorBg: MosTheme.Primary.colorTextQuaternary
    property color colorIcon: 'white'
    property color colorText: 'white'
    // property MosRadius radiusBg: MosRadius { all: control.width * 0.5 }

    objectName: '__MosAvatar__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: MosTheme.Primary.fontPrimaryFamily
        pixelSize: control.size * 0.5
    }
    contentItem: Loader {
        sourceComponent: {
            if (control.iconSource !== 0 && control.iconSource !== '')
                return __iconImpl;
            else if (control.imageSource != '')
                return __imageImpl;
            else
                return __textImpl;
        }
    }

    Component {
        id: __iconImpl

        MosRectangle{
            implicitWidth: control.size
            implicitHeight: control.size
            // radius: control.radiusBg.all
            // topLeftRadius: control.radiusBg.topLeft
            // topRightRadius: control.radiusBg.topRight
            // bottomLeftRadius: control.radiusBg.bottomLeft
            // bottomRightRadius: control.radiusBg.bottomRight
            radius: 8
            color: control.colorBg

            MosIconText {
                id: __iconSource
                anchors.centerIn: parent
                iconSource: control.iconSource
                iconSize: control.size * 0.7
                colorIcon: control.colorIcon
            }
        }
    }

    Component {
        id: __imageImpl

        MosRectangle{
            implicitWidth: control.size
            implicitHeight: control.size
            radius: control.radiusBg.all
            topLeftRadius: control.radiusBg.topLeft
            topRightRadius: control.radiusBg.topRight
            bottomLeftRadius: control.radiusBg.bottomLeft
            bottomRightRadius: control.radiusBg.bottomRight
            color: control.colorBg

            MosRectangle{
                id: __mask
                anchors.fill: parent
                radius: parent.radius
                topLeftRadius: parent.topLeftRadius
                topRightRadius: parent.topRightRadius
                bottomLeftRadius: parent.bottomLeftRadius
                bottomRightRadius: parent.bottomRightRadius
                layer.enabled: true
                visible: false
            }

            Image {
                id: __imageSource
                anchors.fill: parent
                mipmap: control.imageMipmap
                source: control.imageSource
                sourceSize: Qt.size(width, height)
                layer.enabled: true
                visible: false
            }

            MultiEffect {
                anchors.fill: __imageSource
                maskEnabled: true
                maskSource: __mask
                source: __imageSource
            }
        }
    }

    Component {
        id: __textImpl

        MosRectangle{
            id: __bg
            implicitWidth: Math.max(control.size, __textSource.implicitWidth + control.textGap * 2);
            implicitHeight: implicitWidth
            radius: control.radiusBg.all
            topLeftRadius: control.radiusBg.topLeft
            topRightRadius: control.radiusBg.topRight
            bottomLeftRadius: control.radiusBg.bottomLeft
            bottomRightRadius: control.radiusBg.bottomRight
            color: control.colorBg
            Component.onCompleted: calcBestSize();

            function calcBestSize() {
                if (control.textSize == MosAvatar.Size_Fixed) {
                    __textSource.font.pixelSize = control.size * 0.5;
                } else {
                    let bestSize = control.size * 0.5;
                    __fontMetrics.font.pixelSize = bestSize;
                    while ((__fontMetrics.advanceWidth(control.textSource) + control.textGap * 2 > control.size)) {
                        bestSize -= 1;
                        __fontMetrics.font.pixelSize = bestSize;
                        if (bestSize <= 1) break;
                    }
                    __textSource.font.pixelSize = bestSize;
                }
            }

            FontMetrics {
                id: __fontMetrics
                font.family: __textSource.font.family
            }

            MosText {
                id: __textSource
                anchors.centerIn: parent
                color: control.colorText
                text: control.textSource
                smooth: true
                font: control.textFont

                Connections {
                    target: control
                    function onTextSourceChanged() {
                        __bg.calcBestSize();
                    }
                }
            }
        }
    }
}
