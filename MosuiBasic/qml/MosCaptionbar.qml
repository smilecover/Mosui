import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosRectangle{
    id: root

    property bool mirrored: false

    property var targetWindow: null
    property MosWindowAgent windowAgent: null

    property int fontIconSize: 14
    property string winIcon: ''
    property string winTitle: targetWindow?.title ?? ''

    property font winTitleFont: Qt.font({
        family: MosTheme.Primary.fontPrimaryFamily,
        pixelSize: fontIconSize
    })
    property color winTitleColor: MosTheme.Primary.colorTextBase

    property Component winIconComponent: Image{
        source: winIcon
        width: fontIconSize
        height: fontIconSize
        sourceSize.width: fontIconSize
        sourceSize.height: fontIconSize
        mipmap: true
        fillMode: Image.PreserveAspectFit 
        verticalAlignment: Image.AlignVCenter
    }

    property Component winTitleComponent: MosText{
        text: winTitle
        font: winTitleFont
        color: winTitleColor
        verticalAlignment: Text.AlignVCenter
        topPadding: 0
        bottomPadding: 0
    }

    property Component winButtonComponent: RowLayout{
        spacing: 0
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        MosCaptionButton{
            id: __minimizeButton
            iconSource: 0xe624
            contentDescription : "最小化"
            onClicked: {
                if (targetWindow) targetWindow.showMinimized();
            }
        }
        MosCaptionButton{
            id: __maximizeButton
            iconSource: targetWindow && (targetWindow.visibility === Window.Maximized || targetWindow.visibility === Window.FullScreen) ? 0xe665 : 0xeb49
            contentDescription: "最大化"
            onClicked: {
                if (!targetWindow) return;

                if (targetWindow.visibility === Window.Maximized ||
                    targetWindow.visibility === Window.FullScreen) {
                    targetWindow.showNormal();
                } else {
                    targetWindow.showMaximized();
                }
            }
        }
        MosCaptionButton{
            id: __closeButton
            iconSource: 0xeb1b
            contentDescription: "关闭"
            onClicked: {
                if (targetWindow) targetWindow.close();
            }
        }

        Component.onCompleted: {
            if (root.windowAgent) {
                root.windowAgent.setSystemButton(MosWindowAgent.Minimize, __minimizeButton);
                root.windowAgent.setSystemButton(MosWindowAgent.Maximize, __maximizeButton);
                root.windowAgent.setSystemButton(MosWindowAgent.Close, __closeButton);
            }
        }

        Connections{
            target: root
            function onWindowAgentChanged(){
                if(windowAgent){
                    windowAgent.setSystemButton(MosWindowAgent.Minimize, __minimizeButton);
                    windowAgent.setSystemButton(MosWindowAgent.Maximize, __maximizeButton);
                    windowAgent.setSystemButton(MosWindowAgent.Close, __closeButton);
                }
            }
        }
    }

    objectName: '__MosCaptionBar__'
    implicitHeight: 32
    implicitWidth: targetWindow.width
    color: "Transparent"


    Loader{
        id: __winIcon
        asynchronous: true
        active: winIcon !== ''
        width: fontIconSize
        height: fontIconSize
        anchors.verticalCenter: root.verticalCenter
        anchors.left: root.left
        anchors.leftMargin: 10
        sourceComponent: root.winIconComponent
    }

    Loader{
        id: __winTitle
        asynchronous: true
        active: winTitle !== ''
        width: implicitWidth
        height: root.implicitHeight
        anchors.verticalCenter: root.verticalCenter
        anchors.left: __winIcon.right
        anchors.leftMargin: 6 
        sourceComponent: root.winTitleComponent
    }
    Loader{
        id: __DeButton
        asynchronous: true
        active: winButtonComponent !== null
        width: implicitWidth
        height: root.implicitHeight
        anchors.verticalCenter: root.verticalCenter
        anchors.right: root.right
        anchors.rightMargin: 0
        z: 1000
        sourceComponent: root.winButtonComponent
    }

}