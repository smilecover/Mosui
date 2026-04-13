import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Button {
    id: root
    width: 100
    height: 30
    text: "按钮"

    property color buttoncolor: MosTheme.MosButton.ButtonBgColor
    property real buttonradius: MosTheme.MosButton.ButtonRadius

    enum Type{
        Type_Default = 0 // 默认按钮类型
    }
    enum Shape{
        Shape_Default = 0,// 默认形状（矩形）
        Shape_Circle = 1
    }
    flat: true
    background: MosRectangle{
        color: buttoncolor
        radius: buttonradius
    }

}