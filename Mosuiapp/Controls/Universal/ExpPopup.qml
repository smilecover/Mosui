import QtQuick
import QtQuick.Controls

import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { }

    Column {
        id: column
        width: parent.width - 15
        spacing: 30

        DocDescription {
            id: description
            desc: qsTr(`
# MosPopup 弹窗\n
自带跟随主题切换的背景和阴影, 用来替代内置 Popup。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Popup }**\n
* **继承此 { [MosImagePreview](internal://MosImagePreview), [MosModal](internal://MosModal), [MosPopover](internal://MosPopover), [MosContextMenu](internal://MosContextMenu) }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
movable | bool | false | 是否可移动
resizable | bool | false | 是否可改变大小
minimumX | int | Number.NaN | 可移动的最小X坐标(movable为true生效)
maximumX | int | Number.NaN | 可移动的最大X坐标(movable为true生效)
minimumY | int | Number.NaN | 可移动的最小Y坐标(movable为true生效)
maximumY | int | Number.NaN | 可移动的最大Y坐标(movable为true生效)
minimumWidth | int | 0 | 可改变的最小宽度(resizable为true生效)
maximumWidth | int | Number.NaN | 可改变的最小宽度(resizable为true生效)
minimumHeight | int | 0 | 可改变的最小高度(resizable为true生效)
maximumHeight | int | Number.NaN | 可改变的最小高度(resizable为true生效)
colorShadow | color | - | 阴影颜色
colorBg | color | - | 背景颜色
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角半径
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
需要一个弹出式窗口时使用。
                       `)
        }

        ThemeToken {
            source: 'MosPopup'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosPopup.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法等同于 \`Popup\` \n
通过 \`movable\` 设置为可移动 \n
通过 \`resizable\` 设置为可改变大小 \n
                       `)
            code: `
                import QtQuick
                
                import MosuiBasic

                Item {
                    height: 50

                    MosButton {
                        text: (popup.opened ? qsTr('隐藏') : qsTr('显示'))
                        type: MosButton.Type_Primary
                        onClicked: {
                            if (popup.opened)
                                popup.close();
                            else
                                popup.open();
                        }
                    }

                    MosPopup {
                        id: popup
                        x: (parent.width - width) * 0.5
                        y: (parent.height - height) * 0.5
                        width: 400
                        height: 300
                        parent: Overlay.overlay
                        closePolicy: MosPopup.NoAutoClose
                        movable: true
                        resizable: true
                        minimumX: 0
                        maximumX: parent.width - width
                        minimumY: 0
                        maximumY: parent.height - height
                        minimumWidth: 400
                        minimumHeight: 300
                        radiusBg.topLeft: 100
                        radiusBg.bottomRight: 100
                        contentItem: Item {
                            MosCaptionButton {
                                anchors.right: parent.right
                                radiusBg.topRight: popup.radiusBg.topRight
                                colorText: colorIcon
                                iconSource: MosIcon.CloseOutlined
                                onClicked: popup.close();
                            }
                        }
                    }
                }
            `
            exampleDelegate: Item {
                height: 50

                MosButton {
                    text: (popup.opened ? qsTr('隐藏') : qsTr('显示'))
                    type: MosButton.Type_Primary
                    onClicked: {
                        if (popup.opened)
                            popup.close();
                        else
                            popup.open();
                    }
                }

                MosPopup {
                    id: popup
                    x: (parent.width - width) * 0.5
                    y: (parent.height - height) * 0.5
                    width: 400
                    height: 300
                    parent: Overlay.overlay
                    closePolicy: MosPopup.NoAutoClose
                    movable: true
                    resizable: true
                    minimumX: 0
                    maximumX: parent.width - width
                    minimumY: 0
                    maximumY: parent.height - height
                    minimumWidth: 400
                    minimumHeight: 300
                    radiusBg.topLeft: 100
                    radiusBg.bottomRight: 100
                    contentItem: Item {
                        MosCaptionButton {
                            anchors.right: parent.right
                            radiusBg.topRight: popup.radiusBg.topRight
                            colorText: colorIcon
                            iconSource: MosIcon.CloseOutlined
                            onClicked: popup.close();
                        }
                    }
                }
            }
        }
    }
}
