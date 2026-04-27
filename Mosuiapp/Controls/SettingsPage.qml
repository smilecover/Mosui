import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MosuiBasic

Flickable {
    id:root
    contentHeight: settingsColumn.height
    ScrollBar.vertical: MosScrollBar {
        anchors.right: parent.right
        anchors.rightMargin: 5
        
    }
    property var hostWindow: Window.window
    component SettingsItem: Item {
        id: settingsItem
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
                implicitWidth: itemLoader.width
                implicitHeight: itemLoader.height + 40
                radius: 6
                color: MosThemeFunctions.alpha(MosTheme.Primary.colorBgBase, 0)
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
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width
        spacing: 30
        SettingsItem {
            title: "导航栏设置"

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

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
        SettingsItem {
            title: "页面主题效果"

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            itemDelegate: Column{
                id: pageEffectColumn
                spacing: 2

                Component.onCompleted: {
                    pageEffectButtonGroup.checkedButton = pageEffectColumn.children[root.hostWindow.effect]
                }
                ButtonGroup{
                    id: pageEffectButtonGroup
                    onClicked: function(button) {
                        var oldEffectName = root.hostWindow.effectName
                        if (oldEffectName !== "") {
                            console.log(oldEffectName)
                            root.hostWindow.windowAgent.setWindowAttribute(oldEffectName, false)
                        }

                        switch (button.index) {
                        case 0: root.hostWindow.effect = MosWindow.Effect_None; break
                        case 1: root.hostWindow.effect = MosWindow.Effect_dwm_blur; break
                        case 2: root.hostWindow.effect = MosWindow.Effect_acrylic_material; break
                        case 3: root.hostWindow.effect = MosWindow.Effect_mica; break
                        case 4: root.hostWindow.effect = MosWindow.Effect_mica_alt; break
                        }
                    }

                }
                MosRadio{
                    text: qsTr('无')
                    ButtonGroup.group: pageEffectButtonGroup
                }
                MosRadio{
                    text: qsTr('DWM模糊')
                    ButtonGroup.group: pageEffectButtonGroup
                }
                MosRadio{
                    text: qsTr('亚克力')
                    ButtonGroup.group: pageEffectButtonGroup
                }
                MosRadio{
                    text: qsTr('云母')
                    ButtonGroup.group: pageEffectButtonGroup
                }
                MosRadio{
                    text: qsTr('云母Alt')
                    ButtonGroup.group: pageEffectButtonGroup
                }
            }
            Connections {
                target: root.hostWindow
                function onEffectChanged() {
                    console.log("000000000000000000000")
                    
                }
            }
        }
    }
}