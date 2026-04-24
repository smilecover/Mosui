import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MosuiBasic

Flickable {
    // contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { }
    component SettingsItem: Item {
        id: settingsItem
        anchors.fill: parent
        implicitWidth: parent.width
        implicitHeight: column.height

        property string title: value
        property Component itemDelegate: Item { }

        Column{
            id: column
            width: parent.width
            spacing: 10
            MosText {
                text: settingsItem.title
            }
            Rectangle {
                width: parent.width
                height: itemLoader.height + 40
                radius: 6
                color: MosThemeFunctions.alpha(MosTheme.Primary.colorBgBase, 0.6)
                border.color: MosTheme.Primary.colorFillPrimary

                Loader {
                    id: itemLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: settingsItem.itemDelegate
                }
            }
        }
    }
    ColumnLayout {
        id: settingsColumn
        width: parent.width
        spacing: 30
        SettingsItem {
            title: "导航栏设置··"
            itemDelegate: MosRadioBlock {
                id: navMode
                model: [
                    { label: qsTr('宽松'), value: MosMenu.Mode_Relaxed },
                    { label: qsTr('标准'), value: MosMenu.Mode_Standard },
                    { label: qsTr('紧凑'), value: MosMenu.Mode_Compact }
                ]
                onClicked:
                    (index, radioData) => {
                        menu.compactMode = radioData.value;
                    }
                Component.onCompleted: {
                    currentCheckedIndex = menu.compactMode;
                }

                Connections {
                    target: menu
                    function onCompactModeChanged() {
                        navMode.currentCheckedIndex = menu.compactMode;
                    }
                }
            }
        }
    }  
}