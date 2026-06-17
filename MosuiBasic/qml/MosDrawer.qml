import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.Drawer {
    id: root

    enum ClosePosition {
        Position_Start = 0,
        Position_End = 1
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property bool maskClosable: true
    property int closePosition: MosDrawer.Position_Start
    property int drawerSize: 378
    property string title: ''
    property font titleFont: Qt.font({
                                         family: MosTheme.MosDrawer.fontFamily,
                                         pixelSize: parseInt(MosTheme.MosDrawer.fontSizeTitle)
                                     })
    property color colorTitle: MosTheme.MosDrawer.colorTitle
    property color colorBg: MosTheme.MosDrawer.colorBg
    property color colorOverlay: MosTheme.MosDrawer.colorOverlay

    property Component closeDelegate: Component {
        MosCaptionButton {
            topPadding: 2
            bottomPadding: 2
            leftPadding: 4
            rightPadding: 4
            anchors.verticalCenter: parent.verticalCenter
            animationEnabled: root.animationEnabled
            radiusBg.all: MosTheme.MosDrawer.radiusButtonBg
            iconSource: MosIcon.CloseOutlined
            hoverCursorShape: Qt.PointingHandCursor
            onClicked: {
                root.close();
            }
        }
    }

    property Component titleDelegate: Item {
        implicitHeight: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 5

            Loader {
                id: __closeStartLoader
                sourceComponent: closeDelegate
                Layout.alignment: Qt.AlignVCenter
                active: root.closePosition === MosDrawer.Position_Start
                visible: root.closePosition === MosDrawer.Position_Start
            }

            MosText {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: root.title
                font: root.titleFont
                color: root.colorTitle
            }

            Loader {
                id: __closeEndLoader
                sourceComponent: closeDelegate
                Layout.alignment: Qt.AlignVCenter
                active: root.closePosition === MosDrawer.Position_End
                visible: root.closePosition === MosDrawer.Position_End
            }
        }

        MosDivider {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            animationEnabled: root.animationEnabled
        }
    }

    property Component contentDelegate: Item { }

    objectName: '__MosDrawer__'
    width: edge == Qt.LeftEdge || edge == Qt.RightEdge ? drawerSize : parent.width
    height: edge == Qt.LeftEdge || edge == Qt.RightEdge ? parent.height : drawerSize
    edge: Qt.RightEdge
    parent: T.Overlay.overlay
    modal: true
    closePolicy: maskClosable ? T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside : T.Popup.NoAutoClose
    enter: Transition { NumberAnimation { duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0 } }
    exit: Transition { NumberAnimation { duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0 } }
    background: Item {
        MosShadow {
            anchors.fill: __rect
            source: __rect
            shadowColor: MosTheme.MosDrawer.colorShadow
        }

        Rectangle {
            id: __rect
            anchors.fill: parent
            color: root.colorBg
        }
    }
    contentItem: ColumnLayout {
        spacing: 0
        Loader {
            Layout.fillWidth: true
            sourceComponent: root.titleDelegate
            onLoaded: {
                /*! 无边框窗口的标题栏会阻止事件传递, 需要调这个 */
                if (typeof captionBar !== 'undefined')
                    captionBar.addInteractionItem(item);
            }
        }
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: root.contentDelegate
        }
    }
    onAboutToShow: {
        if (typeof captionBar !== 'undefined' && modal)
            captionBar.enabled = false;
    }
    onAboutToHide: {
        if (typeof captionBar !== 'undefined' && modal)    
            captionBar.enabled = true;
    }

    T.Overlay.modal: Rectangle {
        color: root.colorOverlay
    }
}
