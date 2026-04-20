import QtQuick
import QtQuick.Controls
import MosuiBasic
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    // color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    windowIcon: "qrc:/image/image/cangshu.svg"
    MosMenu{
        id: menu
        width: root.width/5
        anchors.top: captionbar.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        showEdge: true

        menuColor: "red"
        initModel: [ {
            key: 'Navigation',
            label: qsTr('导航'),
            menuChildren: [
                {
                    key: 'MosMenu',
                    label: qsTr('MosMenu 菜单'),
                    updateVersion: '0.4.9.1',
                    desc: qsTr('重做 compactMode 模式。\n移除 defaultMenuHeight 属性。\n新增 defaultMenu[Top/Bottom]Padding 默认菜单上/下边距属性。'),
                    menuChildren: [
                        {
                            key: 'MosMenuButton',
                            label: qsTr('MosMenuButton 菜单按钮'),
                        }
                    ]
                }

            ]
        },
        {
            key: 'Button',
            label: qsTr('按钮'),
            menuChildren: [
                {
                    key: 'MosButton',
                    label: qsTr('MosButton 按钮'),
                }
            ]
        },
        {
            key: 'ToolTip',
            label: qsTr('提示'),
            menuChildren: [
                {
                    key: 'MosToolTip',
                    label: qsTr('MosToolTip 提示'),
                }
            ]
        },
        {
            key: 'Input',
            label: qsTr('输入'),
            menuChildren: [
                {
                    key: 'MosInput',
                    label: qsTr('MosInput 输入'),
                }
            ]
        },
        {
            key: 'Select',
            label: qsTr('选择'),
            menuChildren: [
                {
                    key: 'MosSelect',
                    label: qsTr('MosSelect 选择'),
                }
            ]
        },
        {
            key: 'Checkbox',
            label: qsTr('复选框'),
            menuChildren: [
                {
                    key: 'MosCheckbox',
                    label: qsTr('MosCheckbox 复选框'),
                }
            ]
        },
        {
            key: 'Radio',
            label: qsTr('单选框'),
            menuChildren: [
                {
                    key: 'MosRadio',
                    label: qsTr('MosRadio 单选框'),
                }
            ]
        },
        {
            key: 'Slider',
            label: qsTr('滑动条'),
            menuChildren: [
                {
                    key: 'MosSlider',
                    label: qsTr('MosSlider 滑动条'),
                }
            ]
        },
        {
            key: 'ProgressBar',
            label: qsTr('进度条'),
            menuChildren: [
                {
                    key: 'MosProgressBar',
                    label: qsTr('MosProgressBar 进度条'),
                }
            ]
        },
        {
            key: 'Progress',
            label: qsTr('进度'),
            menuChildren: [
                {
                    key: 'MosProgress',
                    label: qsTr('MosProgress 进度'),
                }
            ]
        }
    ]
    }
    Item{
        id: item
        anchors.left: menu.right
        anchors.right: parent.right
        anchors.top: captionbar.bottom
        anchors.bottom: parent.bottom
    }
    MosRouter{
        id: router
    }
}