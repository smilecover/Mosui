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
# MosCopyableText 可复制文本\n
在需要可复制的文本时使用(替代Text)。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { TextEdit }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
Qml中普通文本(Text)无法复制，因此在需要可复制的文本时建议使用。
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法等同于 \`TextEdit\`
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 15

                    MosCopyableText {
                        text: qsTr('可以复制我')
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 15

                MosCopyableText {
                    text: qsTr('可以复制我')
                }
            }
        }
    }
}
