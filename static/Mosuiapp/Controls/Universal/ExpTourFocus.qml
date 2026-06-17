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
            desc: qsTr(`
# MosTourFocus 漫游焦点\n
聚焦于某个功能的焦点。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Popup }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
penetrationEvent | bool | false | 是否可穿透事件
maskClosable | bool | true | 点击蒙层是否允许关闭
target | Item | - | 焦点目标
overlayColor | color | - | 覆盖层颜色
focusMargin | int | 5 | 焦点边距
focusRadius | int | 2 | 焦点圆角
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
用户需要聚焦于某个功能的焦点时使用。\n
本组件将通过高亮 \`target\` 项的方式来吸引注意力。\n
                       `)
        }

        ThemeToken {
            source: 'HusTour'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosTourFocus.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('基本')
            desc: qsTr(`
通过 \`target\` 属性设置焦点目标。\n
通过 \`overlayColor\` 属性设置覆盖层颜色。\n
通过 \`focusMargin\` 属性设置焦点边距。\n
通过 \`focusRadius\` 属性设置焦点圆角。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosButton {
                        text: qsTr('漫游焦点')
                        type: MosButton.Type_Primary
                        onClicked: {
                            tourFocus.open();
                        }

                        MosTourFocus {
                            id: tourFocus
                            target: tourFocus1
                        }
                    }

                    Row {
                        spacing: 10

                        MosButton {
                            id: tourFocus1
                            text: qsTr('漫游焦点1')
                            type: MosButton.Type_Outlined
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosButton {
                    text: qsTr('漫游焦点')
                    type: MosButton.Type_Primary
                    onClicked: {
                        tourFocus.open();
                    }

                    MosTourFocus {
                        id: tourFocus
                        target: tourFocusButton
                    }
                }

                Row {
                    spacing: 10

                    MosButton {
                        id: tourFocusButton
                        text: qsTr('漫游焦点1')
                        type: MosButton.Type_Outlined
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('聚焦组件可交互')
            desc: qsTr(`
通过 \`penetrationEvent\` 属性设置是否可穿透事件。\n
                       `)
            code: `
                import QtQuick
                
                import MosuiBasic

                Column {
                    spacing: 10

                    MosButton {
                        text: qsTr('穿透焦点')
                        type: MosButton.Type_Primary
                        onClicked: {
                            tourFocus2.open();
                        }

                        MosTourFocus {
                            id: tourFocus2
                            target: tourFocusGrid
                            penetrationEvent: true
                            focusMargin: marginSlider.currentValue
                            focusRadius: radiusSlider.currentValue
                            closePolicy: Popup.CloseOnEscape
                        }
                    }

                    Grid {
                        id: tourFocusGrid
                        spacing: 10
                        columns: 2
                        verticalItemAlignment: Grid.AlignVCenter

                        MosText {
                            text: 'Margin: '
                        }

                        MosSlider {
                            id: marginSlider
                            width: 200
                            height: 30
                            min: 0
                            max: 20
                            value: 5
                            handleToolTipDelegate: MosToolTip {
                                visible: handleHovered || handlePressed
                                text: marginSlider.currentValue.toFixed(0)
                            }
                        }

                        MosText {
                            text: 'Radius: '
                        }

                        MosSlider {
                            id: radiusSlider
                            width: 200
                            height: 30
                            min: 0
                            max: 20
                            handleToolTipDelegate: MosToolTip {
                                visible: handleHovered || handlePressed
                                text: radiusSlider.currentValue.toFixed(0)
                            }
                        }

                        MosButton {
                            text: qsTr('漫游焦点1')
                            type: MosButton.Type_Outlined
                        }

                        MosButton {
                            text: qsTr('关闭')
                            type: MosButton.Type_Outlined
                            onClicked: tourFocus2.close();
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosButton {
                    text: qsTr('穿透焦点')
                    type: MosButton.Type_Primary
                    onClicked: {
                        tourFocus2.open();
                    }

                    MosTourFocus {
                        id: tourFocus2
                        target: tourFocusGrid
                        penetrationEvent: true
                        focusMargin: marginSlider.currentValue
                        focusRadius: radiusSlider.currentValue
                        closePolicy: Popup.CloseOnEscape
                    }
                }

                Grid {
                    id: tourFocusGrid
                    spacing: 10
                    columns: 2
                    verticalItemAlignment: Grid.AlignVCenter

                    MosText {
                        text: 'Margin: '
                    }

                    MosSlider {
                        id: marginSlider
                        width: 200
                        height: 30
                        min: 0
                        max: 20
                        value: 5
                        handleToolTipDelegate: MosToolTip {
                            visible: handleHovered || handlePressed
                            text: marginSlider.currentValue.toFixed(0)
                        }
                    }

                    MosText {
                        text: 'Radius: '
                    }

                    MosSlider {
                        id: radiusSlider
                        width: 200
                        height: 30
                        min: 0
                        max: 20
                        handleToolTipDelegate: MosToolTip {
                            visible: handleHovered || handlePressed
                            text: radiusSlider.currentValue.toFixed(0)
                        }
                    }

                    MosButton {
                        text: qsTr('漫游焦点1')
                        type: MosButton.Type_Outlined
                    }

                    MosButton {
                        text: qsTr('关闭')
                        type: MosButton.Type_Outlined
                        onClicked: tourFocus2.close();
                    }
                }
            }
        }
    }
}
