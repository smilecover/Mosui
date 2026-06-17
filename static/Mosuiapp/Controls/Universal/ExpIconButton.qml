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
# MosIconButton 图标按钮\n
带图标的按钮。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { [MosButton](internal://MosButton) }**\n
* **继承此 { [MosCaptionButton](internal://MosCaptionButton) }**\n
\n<br/>
\n### 支持的代理：\n
- **iconDelegate: Component** 图标代理\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
iconSource | int丨string | 0丨'' | 图标源(来自 MosIcon)或图标链接
iconSize | int | - | 图标大小
iconSpacing | int | 5 | 图标间隔
iconPosition | enum | MosIconButton.Position_Start | 图标位置(来自 MosIconButton)
loading | bool | false | 是否在加载中
orientation | enum | Qt.Horizontal | 方向(Qt.Horizontal 或 Qt.Vertical)
textFont | font | - | 文本字体
iconFont | font | 'MosuiBasic-Icons' | 图标字体
colorIcon | color | - | 图标颜色
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
等同于 [MosButton](internal://MosButton)，但提供一个前/后/上/下的可选图标。
                       `)
        }

        ThemeToken {
            source: 'MosButton'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosIconButton.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`iconSource\` 属性设置图标源{ MosIcon中定义 }\n
通过 \`iconSize\` 属性设置图标大小\n
通过 \`iconPosition\` 属性设置图标位置，支持的位置有：\n
- 图标处于开始位置(默认){ MosIconButton.Position_Start }\n
- 图标处于结束位置{ MosIconButton.Position_End }\n
通过 \`orientation\` 属性改变方向，支持的方向：\n
- 水平排布(默认){ Qt.Horizontal }\n
- 垂直排布{ Qt.Vertical }\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosRadioBlock {
                        id: orientationRadio
                        initCheckedIndex: 0
                        model: [
                            { label: 'Horizontal', value: Qt.Horizontal },
                            { label: 'Vertical', value: Qt.Vertical },
                        ]
                    }

                    Row {
                        spacing: 15

                        MosIconButton {
                            text: qsTr('搜索')
                            iconSource: MosIcon.SearchOutlined
                            orientation: orientationRadio.currentCheckedValue
                        }

                        MosIconButton {
                            text: qsTr('搜索')
                            type: MosButton.Type_Outlined
                            iconSource: MosIcon.SearchOutlined
                            orientation: orientationRadio.currentCheckedValue
                        }

                        MosIconButton {
                            type: MosButton.Type_Primary
                            iconSource: MosIcon.SearchOutlined
                            orientation: orientationRadio.currentCheckedValue
                        }

                        MosIconButton {
                            text: qsTr('搜索')
                            type: MosButton.Type_Primary
                            iconSource: MosIcon.SearchOutlined
                            orientation: orientationRadio.currentCheckedValue
                        }

                        MosIconButton {
                            text: qsTr('搜索')
                            type: MosButton.Type_Primary
                            iconSource: MosIcon.SearchOutlined
                            iconPosition: MosIconButton.Position_End
                            orientation: orientationRadio.currentCheckedValue
                        }

                        MosIconButton {
                            text: qsTr('搜索')
                            type: MosButton.Type_Filled
                            iconSource: MosIcon.SearchOutlined
                            orientation: orientationRadio.currentCheckedValue
                        }

                        MosIconButton {
                            text: qsTr('搜索')
                            type: MosButton.Type_Text
                            iconSource: MosIcon.SearchOutlined
                            orientation: orientationRadio.currentCheckedValue
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosRadioBlock {
                    id: orientationRadio
                    initCheckedIndex: 0
                    model: [
                        { label: 'Horizontal', value: Qt.Horizontal },
                        { label: 'Vertical', value: Qt.Vertical },
                    ]
                }

                Row {
                    spacing: 15

                    MosIconButton {
                        text: qsTr('搜索')
                        iconSource: MosIcon.SearchOutlined
                        orientation: orientationRadio.currentCheckedValue
                    }

                    MosIconButton {
                        text: qsTr('搜索')
                        type: MosButton.Type_Outlined
                        iconSource: MosIcon.SearchOutlined
                        orientation: orientationRadio.currentCheckedValue
                    }

                    MosIconButton {
                        type: MosButton.Type_Primary
                        iconSource: MosIcon.SearchOutlined
                        orientation: orientationRadio.currentCheckedValue
                    }

                    MosIconButton {
                        text: qsTr('搜索')
                        type: MosButton.Type_Primary
                        iconSource: MosIcon.SearchOutlined
                        orientation: orientationRadio.currentCheckedValue
                    }

                    MosIconButton {
                        text: qsTr('搜索')
                        type: MosButton.Type_Primary
                        iconSource: MosIcon.SearchOutlined
                        iconPosition: MosIconButton.Position_End
                        orientation: orientationRadio.currentCheckedValue
                    }

                    MosIconButton {
                        text: qsTr('搜索')
                        type: MosButton.Type_Filled
                        iconSource: MosIcon.SearchOutlined
                        orientation: orientationRadio.currentCheckedValue
                    }

                    MosIconButton {
                        text: qsTr('搜索')
                        type: MosButton.Type_Text
                        iconSource: MosIcon.SearchOutlined
                        orientation: orientationRadio.currentCheckedValue
                    }
                }
            }
        }
    }
}
