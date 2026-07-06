import QtQuick
import QtQuick.Layouts
import MosuiBasic

Item {
    id: root
    implicitHeight: 100

    MosRectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: MosTheme.Primary.colorSplit
        border.width: 1
    }

    MosSpace {
        anchors.fill: parent
        layout: 'RowLayout'
        spacing: 0
        // Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        // 节流阀区域
        MosFrame{
            Layout.horizontalStretchFactor: 0
            Layout.fillWidth: true
            Layout.minimumWidth: 410
            Layout.preferredWidth: 430
            Layout.fillHeight: true
            Layout.preferredHeight: root.height
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            padding: 10
            MosSpace{
                layout: 'RowLayout'
                spacing: 10
                anchors.fill: parent
                Repeater{
                    model: [
                        {name: "节流阀A", value: "45.0"},
                        {name: "节流阀B", value: "45.0"},
                        {name: "节流阀C", value: "45.0"}
                    ]
                    delegate: MosLabel{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 120
                        Layout.preferredWidth: 130
                        text: modelData.name + "\n" + modelData.value
                        font.pixelSize: 16
                        colorText: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        MosFrame{
            Layout.horizontalStretchFactor: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: root.height
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            padding: 10
            MosSpace{
                layout: 'RowLayout'
                spacing: 4
                anchors.fill: parent
                Repeater{
                    model: [
                        {name: "手动模式", color: "#FFFFC738"},
                        {name: "井底压力模式", color: "white"},
                        {name: "井口压力模式", color: "white"},
                        {name: "主备阀模式切换", color: "white"},
                        {name: "专家模式", color: "white"},
                        {name: "停车", color: "white"},
                        {name: "切换控制板", color: "white"}
                    ]
                    delegate: MosButton{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: modelData.name
                        colorText: modelData.color
                    }
                }
            }
        }
    }
}
