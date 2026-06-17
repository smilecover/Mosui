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
# MosText 文本\n
提供统一字体和颜色的文本(替代Text)。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Text }**\n
* **继承自 { [MosIconText](internal://MosIconText) }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
需要统一字体和颜色的文本时建议使用。
                       `)
        }

        ThemeToken {
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosText.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法等同于 \`Text\`
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 15

                    MosText {
                        text: qsTr('HusText文本')
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 15

                MosText {
                    text: qsTr('HusText文本')
                }
            }
        }
    }
}
