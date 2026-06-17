import QtQuick
import MosuiBasic

Item {
    id: root

    width: parent.width
    height: column.height + 10

    property string source: ''
    property string historySource: ''

    Column {
        id: column
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        MosText {
            width: parent.width
            visible: root.source !== ''
            text: qsTr('主题变量（Design Token）')
            font {
                pixelSize: MosTheme.Primary.fontPrimarySizeHeading3
                weight: Font.DemiBold
            }
        }

        MosText {
            width: parent.width
            visible: root.source !== ''
            text: qsTr('查看主题文件: ') + root.source + '.json'
            font.pixelSize: MosTheme.Primary.fontPrimarySize
            color: MosTheme.Primary.colorTextSecondary
        }
    }
}
