import QtQuick
import QtQuick.Templates as T

T.Button {
    id: root
    width: 120
    height: 40
    text: "自定义按钮"
    background: Rectangle {
        color: root.pressed ? "#2c3e50" : "#3498db"  // 按下/正常 两种颜色
        radius: 6  // 圆角
        border.color: "#2980b9"
        border.width: 1
    }
    contentItem: Text {
        text: root.text
        color: "white"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    onClicked: {
        console.log("按钮被点击了！")
    }
}