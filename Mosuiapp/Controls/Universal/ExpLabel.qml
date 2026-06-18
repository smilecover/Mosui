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

        MosDescription {
            desc: qsTr(`
# MosLabel 文本标签\n
扩展了HusText(文本)的功能, 并自带背景和圆角。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Label }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
borderWidth | real | 1 | 边框宽度
colorText | color | - | 文本颜色
colorBg | color | - | 背景颜色
colorBorder | color | - | 边框颜色
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
sizeHint | string | 'normal' | 尺寸提示
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
需要统一字体和颜色的并带自背景和圆角的文本时建议使用。
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法等同于 \`Label\`
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 15

                    Row {
                        MosText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'Radius:   '
                        }
                        MosSlider {
                            id: radiusSlider
                            width: 150
                            height: 30
                            min: 0
                            max: 30
                            value: 0
                        }
                    }

                    MosSwitch {
                        id: enabledSwitch
                        checked: true
                        text: 'Enabeld: '
                    }

                    MosLabel {
                        enabled: enabledSwitch.checked
                        text: qsTr('MosLabel文本')
                        radiusBg.all: radiusSlider.currentValue
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 15

                Row {
                    MosText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'Radius:   '
                    }
                    MosSlider {
                        id: radiusSlider
                        width: 150
                        height: 30
                        min: 0
                        max: 30
                        value: 0
                    }
                }

                MosSwitch {
                    id: enabledSwitch
                    checked: true
                    text: 'Enabeld: '
                }

                MosLabel {
                    enabled: enabledSwitch.checked
                    text: qsTr('MosLabel文本')
                    radiusBg.all: radiusSlider.currentValue
                }
            }
        }
    }
}
