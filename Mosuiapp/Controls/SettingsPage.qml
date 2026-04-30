import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MosuiBasic

Flickable {
    id:root
    contentHeight: settingsColumn.height
    // 在item中居中
    anchors.fill: parent
    ScrollBar.vertical: MosScrollBar {
        anchors.right: parent.right
        anchors.rightMargin: 5
        
    }
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
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(root.width, 500)
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
            title: qsTr('窗口效果')
            itemDelegate: Column {
                spacing: 10

                ButtonGroup { id: specialEffectGroup }

                Repeater {
                    delegate: MosRadio {
                        property int effectValue: modelData.value
                        text: modelData.label
                        ButtonGroup.group: specialEffectGroup
                        onClicked: {
                            if (!rootWindow.setEffect(modelData.value)) {
                                for (let i = 0; i < specialEffectGroup.buttons.length; i++) {
                                    specialEffectGroup.buttons[i].checked =
                                        specialEffectGroup.buttons[i].effectValue === rootWindow.effect;
                                }
                            }
                        }
                        Component.onCompleted: {
                            checked = rootWindow.effect === modelData.value;
                        }
                    }
                    Component.onCompleted: {
                        if (Qt.platform.os === 'windows'){
                            model = [
                                        { 'label': qsTr('无'), 'value': MosWindow.Effect_None },
                                        { 'label': qsTr('模糊'), 'value': MosWindow.Effect_dwm_blur },
                                        { 'label': qsTr('亚克力'), 'value': MosWindow.Effect_acrylic_material },
                                        { 'label': qsTr('云母'), 'value': MosWindow.Effect_mica },
                                        { 'label': qsTr('云母变体'), 'value': MosWindow.Effect_mica_alt }
                                    ];
                        }
                    }
                }
            }
        }

        SettingsItem {
            title: qsTr('应用主题')
            itemDelegate: Column {
                spacing: 10

                ButtonGroup { id: themeGroup }

                Repeater {
                    model: [
                        { 'label': qsTr('浅色'), 'value': MosTheme.Light },
                        { 'label': qsTr('深色'), 'value': MosTheme.Dark },
                        { 'label': qsTr('跟随系统'), 'value': MosTheme.System }
                    ]
                    delegate: MosRadio {
                        id: darkModeRadio
                        text: modelData.label
                        ButtonGroup.group: themeGroup
                        onClicked: {
                            MosTheme.darkMode = modelData.value;
                        }
                        Component.onCompleted: {
                            checked = MosTheme.darkMode === modelData.value;
                        }

                        Connections {
                            target: MosTheme
                            function onDarkModeChanged() {
                                darkModeRadio.checked = MosTheme.darkMode === modelData.value;
                            }
                        }
                    }
                }
            }
        }
    }
}
