import QtQuick
import QtQuick.Controls
import MosuiBasic

Flickable {
    id: root
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }
    property bool toolsvisible: true
    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        MosDescription {
            desc: qsTr("# 石油精细压控")
        }
        MosButton {
            text: qsTr('打开')
            onClicked: {
                root.toolsvisible = !root.toolsvisible
            }
        }
        Loader {
            id: loader
            source: './PLC_APP.qml'
            active: root.toolsvisible

            onLoaded: {
                item.visibleChanged.connect(function() {
                    if (!item.visible) {
                        root.toolsvisible = false
                    }
                })
            }
        }
    }
}

