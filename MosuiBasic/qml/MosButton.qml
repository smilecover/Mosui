import QtQuick
import QtQuick.Templates as T

T.Button {
    id: root
    enum Type{
        Type_Default = 0 // 默认按钮类型
    }
    enum Shape{
        Shape_Default = 0,// 默认形状（矩形）
        Shape_Circle = 1
    }
    flat: true
}