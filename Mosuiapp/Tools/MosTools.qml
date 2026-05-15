import QtQuick
import QtQuick.Controls
import MosuiBasic

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }
    Column {
        id: column
        anchors.top: parent.top
        
        MosDescription {
        desc: qsTr(`
# Mos工具\n
各种工具的集合\n
\n### 支持的属性：\n
工具名字 | 工具 | 描述
------ | --- | ---
TPInv | [逆变器](internal://TPInv) | 逆变器上位机工具

                    `)
        }
    }

}

