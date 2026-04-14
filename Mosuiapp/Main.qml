import QtQuick
import QtQuick.Controls
import MosuiBasic
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    captionbarcolor: MosCaptionbar.CaptionbarColorTransparent
    MosButton{
        id: button1
        anchors.centerIn: parent
        height: 50
        text: "按钮"
        type: MosButton.Type_Default
        shape: MosButton.Shape_Circle


        onClicked: {
            // 输出

            button1.buttonradius=MosTheme.MosButton.ButtonRadius2
            button1.buttoncolor=MosTheme.MosButton.ButtonBgColor2
            console.log("按钮点击事件触发"+button1.buttonradius)
            // 关闭软件
            root.close()
        }
    }

}