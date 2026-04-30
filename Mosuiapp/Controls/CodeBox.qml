import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MosuiBasic

Rectangle {
    id: root

    width: parent.width
    height: column.height + 40
    radius: 5
    color: 'transparent'
    border.color: MosTheme.Primary.colorFillPrimary
    clip: true

    property alias expTitle: expDivider.title
    property alias descTitle: descDivider.title
    property alias desc: descTextLoader.text
    property bool async: true
    property Component exampleDelegate: Item { }
    property alias code: codeText.text

    Component {
        id: codeRunnerComponent
        MosCodeRunner { }
    }

    MosMessage {
        id: message
        z: 999
        parent: rootWindow.captionbar
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        showCloseButton: true
    }

    Column {
        id: column
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 10

        MosDivider {
            id: expDivider
            width: parent.width
            height: 25
            visible: false
            title: qsTr('示例')
        }

        Loader {
            width: parent.width
            asynchronous: root.async
            sourceComponent: exampleDelegate
        }

        MosDivider {
            id: descDivider
            width: parent.width
            height: 25
            title: qsTr('说明')
        }

        MouseArea {
            id: descMouseArea
            width: parent.width
            height: descTextLoader.height
            hoverEnabled: true

            Loader{
                id: descTextLoader
                width: parent.width
                asynchronous: true
                sourceComponent: MosCopyableText {
                    textFormat: Text.MarkdownText
                    wrapMode: Text.WordWrap
                    text: descTextLoader.text
                    onLinkActivated:
                        (link) => {
                            if (link.startsWith('internal://'))
                                galleryMenu.gotoMenu(link.slice(11));
                            else
                                Qt.openUrlExternally(link);
                        }
                    onHoveredLinkChanged: {
                        if (hoveredLink === '') {
                            linkTooltip.visible = false;
                        } else {
                            linkTooltip.text = hoveredLink;
                            linkTooltip.x = descMouseArea.mouseX;
                            linkTooltip.y = descMouseArea.mouseY;
                            linkTooltip.visible = true;
                        }
                    }
                }
                property string text: ''
            }

            MosToolTip {
                id: linkTooltip
            }
        }

        MosDivider {
            width: parent.width
            height: 30
            title: qsTr('代码')
            titleAlign: MosDivider.Align_Center
            titleDelegate: Row {
                spacing: 10

                MosIconButton {
                    padding: 4
                    topPadding: 4
                    bottomPadding: 4
                    onClicked: {
                        codeText.expanded = !codeText.expanded;
                    }
                    iconDelegate: Item {
                        implicitWidth: MosTheme.Primary.fontPrimarySizeHeading4
                        implicitHeight: implicitWidth

                        Row {
                            height: parent.implicitHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            MosIconText {
                                anchors.verticalCenter: parent.verticalCenter
                                iconSize: MosTheme.Primary.fontPrimarySize - 4
                                iconSource: MosIcon.LeftOutlined
                            }
                            MosIconText {
                                anchors.verticalCenter: parent.verticalCenter
                                iconSize: MosTheme.Primary.fontPrimarySize - 4
                                iconSource: MosIcon.RightOutlined
                            }
                        }

                        MosIconText {
                            anchors.centerIn: parent
                            iconSize: MosTheme.Primary.fontPrimarySize - 2
                            iconSource: MosIcon.MinusOutlined
                            rotation: -80
                            opacity: codeText.expanded ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: MosTheme.Primary.durationMid } }
                        }
                    }

                    MosToolTip {
                        showArrow: false
                        visible: parent ? parent.hovered : false
                        text: codeText.expanded ? qsTr('收起代码') : qsTr('展开代码')
                    }
                }

                MosIconButton {
                    padding: 4
                    topPadding: 4
                    bottomPadding: 4
                    iconSize: MosTheme.Primary.fontPrimarySizeHeading4
                    iconSource: MosIcon.CodeOutlined
                    onClicked: {
                        let win = codeRunnerComponent.createObject(null);
                        if (win) {
                            win.createQmlObject(code);
                            win.show();
                        }
                    }

                    MosToolTip {
                        visible: parent ? parent.hovered : false
                        text: qsTr('运行代码')
                    }
                }

                MosIconButton {
                    padding: 4
                    topPadding: 4
                    bottomPadding: 4
                    iconSize: MosTheme.Primary.fontPrimarySizeHeading4
                    iconSource: MosIcon.CopyOutlined
                    onClicked: {
                        MosApi.setClipboardText(codeText.text);
                        message.success(qsTr('代码复制成功'))
                    }

                    MosToolTip {
                        visible: parent ? parent.hovered : false
                        text: qsTr('复制代码')
                    }
                }
            }
        }

        MosCopyableText {
            id: codeText
            clip: true
            width: parent.width
            height: expanded ? implicitHeight : 0
            wrapMode: Text.WordWrap
            property bool expanded: false

            Behavior on height { NumberAnimation { duration: MosTheme.Primary.durationMid } }
        }
    }
}
