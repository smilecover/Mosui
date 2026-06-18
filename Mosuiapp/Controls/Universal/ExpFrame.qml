import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
# MosFrame 框架\n
逻辑控件组的视觉框架。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Frame }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
borderWidth | real | 1 | 边框宽度
colorBg | color | - | 背景颜色
colorBorder | color | - | 边框颜色
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当需要在视觉框架内将一组逻辑控件布局在一起时使用。
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法等同于 \`Frame\`
                       `)
            code: `
                import QtQuick
                import QtQuick.Layouts
                import MosuiBasic

                Column {
                    spacing: 15

                    MosFrame {
                        padding: 20

                        MosSpace {
                            anchors.fill: parent
                            layout: 'ColumnLayout'
                            spacing: 10

                            MosCheckBox { text: 'E-mail '}
                            MosCheckBox { text: 'Calendar' }
                            MosCheckBox { text: 'Contacts' }
                        }
                    }

                    MosFrame {
                        padding: 20

                        MosSpace {
                            anchors.fill: parent
                            layout: 'ColumnLayout'

                            MosCard {
                                Layout.fillWidth: true
                                title: 'Card title'
                                extraDelegate: MosButton { type: MosButton.Type_Link; text: 'More' }
                                bodyDescription: 'Card content\nCard content\nCard content'
                            }
                            MosSpace {
                                Layout.fillWidth: true
                                layout: 'RowLayout'

                                MosButton { Layout.preferredWidth: 80; type: MosButton.Type_Primary; text: 'Submit' }
                            }
                            MosSpace {
                                Layout.fillWidth: true
                                layout: 'RowLayout'

                                MosIconButton { Layout.preferredWidth: 80; iconSource: MosIcon.CopyOutlined }
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 15

                MosFrame {
                    padding: 20

                    MosSpace {
                        layout: 'ColumnLayout'
                        spacing: 10

                        MosCheckBox { text: 'E-mail '}
                        MosCheckBox { text: 'Calendar' }
                        MosCheckBox { text: 'Contacts' }
                    }
                }

                MosFrame {
                    padding: 20

                    MosSpace {
                        layout: 'ColumnLayout'

                        MosCard {
                            Layout.fillWidth: true
                            title: 'Card title'
                            extraDelegate: MosButton { type: MosButton.Type_Link; text: 'More' }
                            bodyDescription: 'Card content\nCard content\nCard content'
                        }
                        MosSpace {
                            Layout.fillWidth: true
                            layout: 'RowLayout'

                            MosButton { Layout.preferredWidth: 80; type: MosButton.Type_Primary; text: 'Submit' }
                        }
                        MosSpace {
                            Layout.fillWidth: true
                            layout: 'RowLayout'
                            MosIconButton { Layout.preferredWidth: 80; iconSource: MosIcon.CopyOutlined }
                        }
                    }
                }
            }
        }
    }
}
