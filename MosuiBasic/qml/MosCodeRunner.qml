import QtQuick
import QtQuick.Controls
import MosuiBasic

MosWindow {
    id: root

    width: 900
    height: 600
    title: qsTr('代码运行器')
    effect: MosWindow.Effect_dwm_blur
    visible: true

    captionbar.closeCallback:
        () => {
            root.destroy();
        }
    captionbar.winIconDelegate: Item {
        Image {
            width: 16
            height: 16
            anchors.centerIn: parent
        }
    }
    onInitializedChanged: {
        if (initialized)
            MosApi.setWindowStaysOnTopHint(root, true);
    }

    property var created: undefined

    function createQmlObject(code) {
        codeEdit.text = code;
        updateCode();
    }

    function updateCode() {
        try {
            errorEdit.clear();
            if (created)
                created.destroy();
            created = Qt.createQmlObject(codeEdit.text, runnerBlock);
            created.parent = runnerBlock;
            created.width = Qt.binding(() => runnerBlock.width);
        } catch (error) {
            errorEdit.text = error.message;
        }
    }

    MosDivider {
        id: divider
        width: parent.width
        height: 1
        anchors.top: captionbar.bottom
    }

    Item {
        id: content
        width: parent.width
        anchors.top: divider.bottom
        anchors.bottom: parent.bottom

        Item {
            id: codeBlock
            width: parent.width * 0.4
            height: parent.height

            ScrollView {
                width: parent.width
                anchors.top: parent.top
                anchors.bottom: divider1.top
                ScrollBar.vertical: MosScrollBar { }
                ScrollBar.horizontal: MosScrollBar { }

                MosCopyableText {
                    id: codeEdit
                    readOnly: false
                    wrapMode: Text.WrapAnywhere
                }
            }

            MosDivider {
                id: divider1
                width: parent.width
                height: 10
                anchors.bottom: errorView.top
                title: qsTr('错误')
            }

            ScrollView {
                id: errorView
                width: parent.width
                height: 100
                anchors.bottom: parent.bottom
                clip: true
                background: Item {}

                TextArea {
                    id: errorEdit
                    readOnly: true
                    selectByKeyboard: true
                    selectByMouse: true
                    font {
                        family: MosTheme.Primary.fontPrimaryFamily
                        pixelSize: MosTheme.Primary.fontPrimarySize
                    }
                    color: MosTheme.Primary.colorError
                    wrapMode: Text.WordWrap
                    background: Item {}
                }
            }
        }

        MosDivider {
            id: divider2
            width: 10
            height: parent.height
            anchors.left: codeBlock.right
            orientation: Qt.Vertical
            titleAlign: MosDivider.Align_Center
            titleDelegate: MosIconButton {
                padding: 5
                iconSize: MosTheme.Primary.fontPrimarySizeHeading4
                iconSource: MosIcon.PlayCircleOutlined
                onClicked: {
                    root.updateCode();
                }
                MosToolTip {
                    visible: parent.hovered
                    text: qsTr('运行')
                }
            }
        }

        Item {
            id: runnerBlock
            anchors.left: divider2.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 5
            clip: true
        }
    }
}
