import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }

    Column {
        id: column
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 15
        spacing: 30

        MosDescription {
            desc: qsTr(`
# MosButton 按钮\n
按钮用于开始一个即时操作。\n
* **模块 { MosuiBasic }**\n
* **继承自 { Button }**\n
* **继承此 { [MosIconButton](internal://MosIconButton) }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
effectEnabled | bool | true | 是否开启点击效果
active | bool | down丨checked | 是否处于激活状态
hoverCursorShape | int | Qt.PointingHandCursor | 悬浮时鼠标形状
type | enum | MosButton.Type_Default | 按钮类型
shape | enum | MosButton.Shape_Default | 按钮形状
colorText | color | - | 文本颜色
colorBg | color | - | 背景颜色
colorBorder | color | - | 边框颜色
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
sizeHint | string | 'normal' | 尺寸提示
contentDescription | string | '' | 内容描述
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
标记了一个（或封装一组）操作命令，响应用户点击行为，触发相应的业务逻辑。\n
在 MoskarUI 中我们提供了七种按钮。\n
- 默认按钮：用于没有主次之分的一组行动点。\n
- 主要按钮：用于主行动点，一个操作区域只能有一个主按钮。\n
- 虚线按钮：常用于添加操作。\n
- 线框按钮：等同于默认按钮，但线框使用了主要颜色。\n
- 填充按钮：用于次级的行动点。\n
- 文本按钮：用于最次级的行动点。\n
- 链接按钮：一般用于链接，即导航至某位置。\n
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`sizeHint\` 属性设置尺寸。\n
通过 \`type\` 属性改变按钮类型，支持的类型：\n
- 默认按钮{ MosButton.Type_Default }\n
- 线框按钮{ MosButton.Type_Outlined }\n
- 虚线按钮{ MosButton.Type_Dashed }\n
- 主要按钮{ MosButton.Type_Primary }\n
- 填充按钮{ MosButton.Type_Filled }\n
- 文本按钮{ MosButton.Type_Text }\n
- 链接按钮{ MosButton.Type_Link }\n
                       `)
            code: `
            import QtQuick
            import MosuiBasic

            Column {
            spacing: 10

            MosRadioBlock {
            id: sizeHintRadio
            initCheckedIndex: 1
            model: [
            { label: 'Small', value: 'small' },
            { label: 'Normal', value: 'normal' },
            { label: 'Large', value: 'large' },
            ]
            }

            Row {
            spacing: 15

            MosButton {
            text: qsTr('默认')
            sizeHint: sizeHintRadio.currentCheckedValue
            }

            MosButton {
            text: qsTr('线框')
            type: MosButton.Type_Outlined
            sizeHint: sizeHintRadio.currentCheckedValue
            }

            MosButton {
            text: qsTr('虚线')
            type: MosButton.Type_Dashed
            sizeHint: sizeHintRadio.currentCheckedValue
            }

            MosButton {
            text: qsTr('主要')
            type: MosButton.Type_Primary
            sizeHint: sizeHintRadio.currentCheckedValue
            }

            MosButton {
            text: qsTr('填充')
            type: MosButton.Type_Filled
            sizeHint: sizeHintRadio.currentCheckedValue
            }

            MosButton {
            text: qsTr('文本')
            type: MosButton.Type_Text
            sizeHint: sizeHintRadio.currentCheckedValue
            }

            MosButton {
            text: qsTr('链接')
            type: MosButton.Type_Link
            sizeHint: sizeHintRadio.currentCheckedValue
            }
            }
            }
            `
            exampleDelegate: Column {
                spacing: 10

                MosRadioBlock {
                    id: sizeHintRadio
                    initCheckedIndex: 1
                    model: [
                        { label: 'Small', value: 'small' },
                        { label: 'Normal', value: 'normal' },
                        { label: 'Large', value: 'large' },
                    ]
                }

                Row {
                    spacing: 15

                    MosButton {
                        text: qsTr('默认')
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosButton {
                        text: qsTr('线框')
                        type: MosButton.Type_Outlined
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosButton {
                        text: qsTr('虚线')
                        type: MosButton.Type_Dashed
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosButton {
                        text: qsTr('主要')
                        type: MosButton.Type_Primary
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosButton {
                        text: qsTr('填充')
                        type: MosButton.Type_Filled
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosButton {
                        text: qsTr('文本')
                        type: MosButton.Type_Text
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosButton {
                        text: qsTr('链接')
                        type: MosButton.Type_Link
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
                       通过 \`enabled\` 属性启用或禁用按钮，禁用的按钮不会响应任何交互。\n
                       `)
            code: `
            import QtQuick
            import MosuiBasic

            Row {
            spacing: 15

            MosButton {
            text: qsTr('默认')
            enabled: false
            }

            MosButton {
            text: qsTr('线框')
            type: MosButton.Type_Outlined
            enabled: false
            }

            MosButton {
            text: qsTr('主要')
            type: MosButton.Type_Primary
            enabled: false
            }

            MosButton {
            text: qsTr('填充')
            type: MosButton.Type_Filled
            enabled: false
            }

            MosButton {
            text: qsTr('文本')
            type: MosButton.Type_Text
            enabled: false
            }

            MosButton {
            text: qsTr('链接')
            type: MosButton.Type_Link
            enabled: false
            }
            }
            `
            exampleDelegate: Row {
                spacing: 15

                MosButton {
                    text: qsTr('默认')
                    enabled: false
                }

                MosButton {
                    text: qsTr('线框')
                    type: MosButton.Type_Outlined
                    enabled: false
                }

                MosButton {
                    text: qsTr('主要')
                    type: MosButton.Type_Primary
                    enabled: false
                }

                MosButton {
                    text: qsTr('填充')
                    type: MosButton.Type_Filled
                    enabled: false
                }

                MosButton {
                    text: qsTr('文本')
                    type: MosButton.Type_Text
                    enabled: false
                }

                MosButton {
                    text: qsTr('链接')
                    type: MosButton.Type_Link
                    enabled: false
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
                       通过 \`shape\` 属性改变按钮形状，支持的形状：\n
                       - 默认形状{ MosButton.Shape_Default }\n
                       - 圆形{ MosButton.Shape_Circle }
                       `)
            code: `
            import QtQuick
            import MosuiBasic

            Row {
            spacing: 15

            MosButton {
            text: qsTr('A')
            shape: MosButton.Shape_Circle
            }

            MosButton {
            text: qsTr('A')
            type: MosButton.Type_Outlined
            shape: MosButton.Shape_Circle
            }

            MosButton {
            text: qsTr('A')
            type: MosButton.Type_Primary
            shape: MosButton.Shape_Circle
            }

            MosButton {
            text: qsTr('A')
            type: MosButton.Type_Filled
            shape: MosButton.Shape_Circle
            }

            MosButton {
            text: qsTr('A')
            type: MosButton.Type_Text
            shape: MosButton.Shape_Circle
            }
            }
            `
            exampleDelegate: Row {
                spacing: 15

                MosButton {
                    text: qsTr('A')
                    shape: MosButton.Shape_Circle
                }

                MosButton {
                    text: qsTr('A')
                    type: MosButton.Type_Outlined
                    shape: MosButton.Shape_Circle
                }

                MosButton {
                    text: qsTr('A')
                    type: MosButton.Type_Primary
                    shape: MosButton.Shape_Circle
                }

                MosButton {
                    text: qsTr('A')
                    type: MosButton.Type_Filled
                    shape: MosButton.Shape_Circle
                }

                MosButton {
                    text: qsTr('A')
                    type: MosButton.Type_Text
                    shape: MosButton.Shape_Circle
                }
            }
        }
        MosDescription {
            title: qsTr('按键样式生成')
            desc: qsTr('通过 \`各种属性\` 属性改变按钮形状，支持的形状：\n- 默认形状{ MosButton.Shape_Default }\n- 圆形{ MosButton.Shape_Circle }')
        }
        MosRectangle{
            width: parent.width + 20
            height: rowLayout.height + 30
            color: rootWindow.color
            border{
                width: 1
                color: MosTheme.Primary.colorFillPrimary
            }
            RowLayout{
                id: rowLayout
                spacing: 15
                width: parent.width-30
                anchors.centerIn: parent
                height: styleColumn.height + 30

                MosRectangle{
                    width: parent.width/2
                    height: styleColumn.height + 30
                    color: rootWindow.color
                    Column{
                        id: styleColumn
                        spacing: 15
                        MosRadioBlock{
                            model: [
                                { label: qsTr('默认'), value: MosButton.Shape_Default},
                                { label: qsTr('圆形'), value: MosButton.Shape_Circle }
                            ]
                            onClicked:
                                (index, radioData) => {
                                    expBtn.shape = radioData.value;
                                }
                            Component.onCompleted: {
                                // 初始化选中第一个选项
                                currentCheckedIndex = expBtn.shape;
                            }
                        }
                        MosRadioBlock{
                            model:[
                                { label: qsTr('默认'), value: MosButton.Type_Default},
                                { label: qsTr('轮廓'), value: MosButton.Type_Outlined},
                                { label: qsTr('主要'), value: MosButton.Type_Primary},
                                { label: qsTr('填充'), value: MosButton.Type_Filled},
                                { label: qsTr('文本'), value: MosButton.Type_Text},
                                { label: qsTr('链接'), value: MosButton.Type_Link}
                            ]
                            onClicked:
                                (index, radioData) => {
                                    expBtn.type = radioData.value;
                                }
                            Component.onCompleted: {
                                // 初始化选中第一个选项
                                currentCheckedIndex = expBtn.type;
                            }
                        }
                        MosRadioBlock{
                            model: [
                                { label: 'Small', value: 'small' },
                                { label: 'Normal', value: 'normal' },
                                { label: 'Large', value: 'large' },
                            ]
                            onClicked:
                                (index, radioData) => {
                                    expBtn.sizeHint = radioData.value;
                                }
                            Component.onCompleted: {
                                switch(expBtn.sizeHint){
                                    case 'small':
                                        currentCheckedIndex = 0;
                                        break;
                                    case 'normal':
                                        currentCheckedIndex = 1;
                                        break;
                                    case 'large':
                                        currentCheckedIndex = 2;
                                        break;
                                }
                            }
                        }

                       MosInput{
                            id: expInputText
                            Layout.fillWidth: true         
                            placeholderText: qsTr("请输入按键文本")
                            implicitHeight: 30
                            implicitWidth: parent.width/2
                            onTextChanged: {
                                expBtn.text = text;
                            }

                            Component.onCompleted: {
                                text = expBtn.text
                            }
                        } 
                    }
                }
                MosDivider{
                    orientation: Qt.Vertical
                    height: parent.height
                    width: 15
                }
                MosRectangle{
                    id: expWidget
                    width: parent.width/2
                    color: rootWindow.color
                    
                    MosButton{
                        id: expBtn
                        anchors.centerIn: parent
                        shape: MosButton.Shape_Default
                        text: "测试按键"
                    }
                }
            }
        }
    }
}

