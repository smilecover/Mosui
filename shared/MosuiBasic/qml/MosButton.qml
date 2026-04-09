import QtQuick
import QtQuick.Templates as T

T.Button {
    id: root
    width: 100
    height: 30
    // 背景
    property color buttoncolor: MosTheme.MosButton.MosButtonBgColor
    // 圆角
    property real buttonradius: 5
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