import QtQuick
import QtQuick.Controls
import MosuiBasic

Item {
    height: 100

    // 背景
    MosRectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: MosTheme.Primary.colorSplit
        border.width: 2
    }

    Row {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 0

        Rectangle {
            width: 100
            height: parent.height
            color: "transparent"
            MosImage {
                anchors.centerIn: parent
                source: "qrc:/logo_plc.png"
                previewEnabled : false
                width: 80
                height: 80
                fillMode: Image.PreserveAspectFit
            }
        }
        Column {
            width: 180
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 10
            Label {
                text: "中国海洋石油"
                color: "white"
                font.pixelSize: 26
                font.bold: true
            }
            Label {
                text: "集团有限公司"
                color: "white"
                font.pixelSize: 26
                font.bold: true
            }
        }
        Item {
            width: parent.width
            height: parent.height
            Label {
                anchors.centerIn: parent
                text: "精细控压钻井自动控制系统"
                color: "white"
                font.pixelSize: 32
                font.bold: true
            }
        }
    }
}
