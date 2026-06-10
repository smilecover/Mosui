import QtQuick
import QtQuick.Templates as T
import QtQuick.Effects
import MosuiBasic

T.Control {
    id: root

    enum TextSize {
        Size_Fixed = 0,
        Size_Auto = 1
    }

    property int size: 30
    property var iconSource: 0 ?? ''

    property string imageSource: ''
    property bool imageMipmap: false

    property string textSource: ''
    property alias textFont: root.font
    property int textSize: MosAvatar.Size_Fixed
    property int textGap: 4

    property color colorBg: MosTheme.Primary.colorTextQuaternary
    property color colorIcon: 'white'
    property color colorText: 'white'
    property MosRadius radiusBg: MosRadius { all: root.width * 0.5 }

    objectName: '__MosAvatar__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: MosTheme.Primary.fontPrimaryFamily
        pixelSize: root.size * 0.5
    }
    contentItem: Loader {
        sourceComponent: {
            if (root.iconSource !== 0 && root.iconSource !== '')
                return __iconImpl;
            else if (root.imageSource != '')
                return __imageImpl;
            else
                return __textImpl;
        }
    }

    Component {
        id: __iconImpl

        MosRectangleInternal {
            implicitWidth: root.size
            implicitHeight: root.size
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
            color: root.colorBg

            MosIconText {
                id: __iconSource
                anchors.centerIn: parent
                iconSource: root.iconSource
                iconSize: root.size * 0.7
                colorIcon: root.colorIcon
            }
        }
    }

    Component {
        id: __imageImpl

        MosRectangleInternal {
            implicitWidth: root.size
            implicitHeight: root.size
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
            color: root.colorBg

            MosRectangleInternal {
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
                mipmap: root.imageMipmap
                source: root.imageSource
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

        MosRectangleInternal {
            id: __bg
            implicitWidth: Math.max(root.size, __textSource.implicitWidth + root.textGap * 2);
            implicitHeight: implicitWidth
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
            color: root.colorBg
            Component.onCompleted: calcBestSize();

            function calcBestSize() {
                if (root.textSize == MosAvatar.Size_Fixed) {
                    __textSource.font.pixelSize = root.size * 0.5;
                } else {
                    let bestSize = root.size * 0.5;
                    __fontMetrics.font.pixelSize = bestSize;
                    while ((__fontMetrics.advanceWidth(root.textSource) + root.textGap * 2 > root.size)) {
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
                color: root.colorText
                text: root.textSource
                smooth: true
                font: root.textFont

                Connections {
                    target: root
                    function onTextSourceChanged() {
                        __bg.calcBestSize();
                    }
                }
            }
        }
    }
}
