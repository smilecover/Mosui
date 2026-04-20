import QtQuick
import QtQuick.Shapes
import MosuiBasic

Item {
    id: root
    objectName: '__MosDivider__'

    enum Align
    {
        Align_Left = 0,
        Align_Center = 1,
        Align_Right = 2
    }

    enum Style
    {
        SolidLine = 0,
        DashLine = 1
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property string title: ''
    property font titleFont: Qt.font({
                                         family: themeSource.fontFamily,
                                         pixelSize: parseInt(themeSource.fontSize)
                                     })
    property int titleAlign: MosDivider.Align_Left
    property int titlePadding: 20
    property int lineStyle: MosDivider.SolidLine
    property real lineWidth: 1 / Screen.devicePixelRatio
    property list<real> dashPattern: [4, 2]
    property int orientation: Qt.Horizontal
    property color colorText: themeSource.colorText
    property color colorSplit: themeSource.colorSplit
    property var themeSource: MosTheme.MosDivider

    property Component titleDelegate: MosText {
        text: root.title
        font: root.titleFont
        color: root.colorText
    }
    property Component splitDelegate: Shape {
        id: __shape

        property real lineX: __titleLoader.x + __titleLoader.implicitWidth * 0.5
        property real lineY: __titleLoader.y + __titleLoader.implicitHeight * 0.5

        ShapePath {
            strokeStyle: root.lineStyle === MosDivider.SolidLine ? ShapePath.SolidLine : ShapePath.DashLine
            strokeColor: root.colorSplit
            strokeWidth: root.lineWidth
            dashPattern: root.dashPattern
            fillColor: 'transparent'
            startX: root.orientation === Qt.Horizontal ? 0 : __shape.lineX
            startY: root.orientation === Qt.Horizontal ? __shape.lineY : 0

            PathLine {
                x: {
                    if (root.orientation === Qt.Horizontal) {
                        return root.title === '' ? 0 : __titleLoader.x - 10;
                    } else {
                        return __shape.lineX;
                    }
                }
                y: root.orientation === Qt.Horizontal ? __shape.lineY : __titleLoader.y - 10
            }
        }

        ShapePath {
            strokeStyle: root.lineStyle === MosDivider.SolidLine ? ShapePath.SolidLine : ShapePath.DashLine
            strokeColor: root.colorSplit
            strokeWidth: root.lineWidth
            dashPattern: root.dashPattern
            fillColor: 'transparent'
            startX: {
                if (root.orientation === Qt.Horizontal) {
                    return root.title === '' ? 0 : (__titleLoader.x + __titleLoader.implicitWidth + 10);
                } else {
                    return __shape.lineX;
                }
            }
            startY: {
                if (root.orientation === Qt.Horizontal) {
                    return __shape.lineY;
                } else {
                    return root.title === '' ? 0 : (__titleLoader.y + __titleLoader.implicitHeight + 10);
                }
            }

            PathLine {
                x: root.orientation === Qt.Horizontal ?  root.width : __shape.lineX
                y: root.orientation === Qt.Horizontal ? __shape.lineY : root.height
            }
        }
    }
    property string contentDescription: title



    Behavior on colorSplit { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

    Loader {
        id: __splitLoader
        sourceComponent: root.splitDelegate
    }

    Loader {
        id: __titleLoader
        z: 1
        anchors.top: (root.orientation !== Qt.Horizontal && root.titleAlign === MosDivider.Align_Left) ? parent.top : undefined
        anchors.topMargin: (root.orientation !== Qt.Horizontal && root.titleAlign === MosDivider.Align_Left) ? root.titlePadding : 0
        anchors.bottom: (root.orientation !== Qt.Horizontal && root.titleAlign === MosDivider.Align_Right) ? parent.right : undefined
        anchors.bottomMargin: (root.orientation !== Qt.Horizontal && root.titleAlign === MosDivider.Align_Right) ? root.titlePadding : 0
        anchors.left: (root.orientation === Qt.Horizontal && root.titleAlign === MosDivider.Align_Left) ? parent.left : undefined
        anchors.leftMargin: (root.orientation === Qt.Horizontal && root.titleAlign === MosDivider.Align_Left) ? root.titlePadding : 0
        anchors.right: (root.orientation === Qt.Horizontal && root.titleAlign === MosDivider.Align_Right) ? parent.right : undefined
        anchors.rightMargin: (root.orientation === Qt.Horizontal && root.titleAlign === MosDivider.Align_Right) ? root.titlePadding : 0
        anchors.horizontalCenter: (root.orientation !== Qt.Horizontal || root.titleAlign === MosDivider.Align_Center) ? parent.horizontalCenter : undefined
        anchors.verticalCenter: (root.orientation === Qt.Horizontal || root.titleAlign === MosDivider.Align_Center) ? parent.verticalCenter : undefined
        sourceComponent: root.titleDelegate
    }

    Accessible.role: Accessible.Separator
    Accessible.name: root.title
    Accessible.description: root.contentDescription
}
