import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Button {
    id: root
    property var themeSource: MosTheme.MosButton
    property color buttoncolor: MosTheme.MosButton.ButtonBgColor
    property real buttonradius: MosTheme.MosButton.ButtonRadius
    property bool active: down || checked
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]


    enum Type{
        Type_Default = 0, // 默认按钮类型
        Type_Outlined = 1, // 线框按钮类型
        Type_Dashed = 2, // 虚线按钮类型
        Type_Primary = 3, // 主要按钮类型
        Type_Filled = 4, // 填充按钮类型
        Type_Text = 5, // 文本按钮类型
        Type_Link = 6 // 链接按钮类型
    }
    enum Shape{
        Shape_Default = 0,// 默认形状（矩形）
        Shape_Circle = 1 // 圆形形状
    }
    property int type: MosButton.Type_Default
    property int shape: MosButton.Shape_Default
    property color colorText: {
        if (enabled) {
            switch(root.type)
            {
            case MosButton.Type_Default:
                return root.active ? themeSource.colorTextActive :
                                        root.hovered ? themeSource.colorTextHover :
                                                          themeSource.colorTextDefault;
            case MosButton.Type_Outlined:
            case MosButton.Type_Dashed:
                return root.active ? themeSource.colorTextActive :
                                        root.hovered ? themeSource.colorTextHover :
                                                          themeSource.colorText;
            case MosButton.Type_Primary: return 'white';
            case MosButton.Type_Filled:
            case MosButton.Type_Text:
            case MosButton.Type_Link:
                return root.active ? themeSource.colorTextActive :
                                        root.hovered ? themeSource.colorTextHover :
                                                          themeSource.colorText;
            default: return themeSource.colorText;
            }
        } else {
            return themeSource.colorTextDisabled;
        }
    }
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    padding: 15 * root.sizeRatio
    topPadding: 6 * root.sizeRatio
    bottomPadding: 6 * root.sizeRatio


    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
    }
    contentItem: Text {
        text: root.text
        font: root.font
        lineHeight: root.themeSource.fontLineHeight
        color: root.colorText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }

}