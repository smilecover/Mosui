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
# MosPage 页面\n
一个容器控件，可以方便地向页面添加页眉和页脚项。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Page }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
colorBg | color | - | 背景颜色
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
当需要一个自带页眉和页脚的页面时使用。
                       `)
        }

        ThemeToken {
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosPage.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法等同于 \`Page\`。
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 15

                    MosTabView {
                        width: parent.width
                        height: 200
                        contentDelegate: MosPage {
                            header: MosText {
                                width: parent.width
                                padding: 5
                                font.pixelSize: MosTheme.Primary.fontPrimarySizeHeading4
                                horizontalAlignment: Text.AlignHCenter
                                text: 'Title - Page ' + (index + 1)
                            }
                            contentItem: Item {
                                width: parent.width

                                MosDivider {
                                    anchors.top: parent.top
                                    width: parent.width
                                }

                                MosText {
                                    anchors.centerIn: parent
                                    text: model.content + (index + 1)
                                }

                                MosDivider {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                }
                            }
                            footer: MosText {
                                width: parent.width
                                padding: 5
                                horizontalAlignment: Text.AlignHCenter
                                text: '(' + (index + 1) + ')'
                            }
                        }
                        initModel: [
                            {
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 1',
                                content: 'Content of page ',
                            },
                            {
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 2',
                                content: 'Content of page ',
                            },
                            {
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 3',
                                content: 'Content of page ',
                            }
                        ]
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 15

                MosTabView {
                    width: parent.width
                    height: 200
                    contentDelegate: MosPage {
                        header: MosText {
                            width: parent.width
                            padding: 5
                            font.pixelSize: MosTheme.Primary.fontPrimarySizeHeading4
                            horizontalAlignment: Text.AlignHCenter
                            text: 'Title - Page ' + (index + 1)
                        }
                        contentItem: Item {
                            width: parent.width

                            MosDivider {
                                anchors.top: parent.top
                                width: parent.width
                            }

                            MosText {
                                anchors.centerIn: parent
                                text: model.content + (index + 1)
                            }

                            MosDivider {
                                anchors.bottom: parent.bottom
                                width: parent.width
                            }
                        }
                        footer: MosText {
                            width: parent.width
                            padding: 5
                            horizontalAlignment: Text.AlignHCenter
                            text: '(' + (index + 1) + ')'
                        }
                    }
                    initModel: [
                        {
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 1',
                            content: 'Content of page ',
                        },
                        {
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 2',
                            content: 'Content of page ',
                        },
                        {
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 3',
                            content: 'Content of page ',
                        }
                    ]
                }
            }
        }
    }
}
