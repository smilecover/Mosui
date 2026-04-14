import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Button {
    id: root
    property bool animationEnabled: MosTheme.animationEnabled
    property bool effectEnabled: true
    property var themeSource: MosTheme.MosButton
    property color buttoncolor: MosTheme.MosButton.ButtonBgColor
    property real buttonradius: MosTheme.MosButton.ButtonRadius
    property int hoverCursorShape: Qt.PointingHandCursor
    property bool active: down || checked
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property string contentDescription: text
    property MosRadius radiusBg: MosRadius { all: root.themeSource.ButtonRadius }


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
    property color colorBg: {
        if (type == MosButton.Type_Link) return 'transparent';
        if (enabled) {
            switch(root.type)
            {
            case MosButton.Type_Default:
            case MosButton.Type_Outlined:
            case MosButton.Type_Dashed:
                return root.active ? themeSource.colorBgActive :
                                        root.hovered ? themeSource.colorBgHover :
                                                          themeSource.colorBg;
            case MosButton.Type_Primary:
                return root.active ? root.themeSource.colorPrimaryBgActive:
                                        root.hovered ? themeSource.colorPrimaryBgHover :
                                                          themeSource.colorPrimaryBg;
            case MosButton.Type_Filled:
                if (MosTheme.isDark) {
                    return root.active ? themeSource.colorFillBgDarkActive:
                                            root.hovered ? themeSource.colorFillBgDarkHover :
                                                              themeSource.colorFillBgDark;
                } else {
                    return root.active ? themeSource.colorFillBgActive:
                                            root.hovered ? themeSource.colorFillBgHover :
                                                              themeSource.colorFillBg;
                }
            case MosButton.Type_Text:
                if (MosTheme.isDark) {
                    return root.active ? themeSource.colorFillBgDarkActive:
                                            root.hovered ? themeSource.colorFillBgDarkHover :
                                                              themeSource.colorTextBg;
                } else {
                    return root.active ? themeSource.colorTextBgActive:
                                            root.hovered ? themeSource.colorTextBgHover :
                                                              themeSource.colorTextBg;
                }
            default: return themeSource.colorBg;
            }
        } else {
            return themeSource.colorBgDisabled;
        }
    }
    property color colorBorder: {
        if (type == MosButton.Type_Link) return 'transparent';
        if (enabled) {
            switch(root.type)
            {
            case MosButton.Type_Default:    
                return (root.active || root.visualFocus) ? themeSource.colorBorderActive :
                                                                 root.hovered ? themeSource.colorBorderHover :
                                                                                   themeSource.colorDefaultBorder;
            default:
                return (root.active || root.visualFocus) ? themeSource.colorBorderActive :
                                                                 root.hovered ? themeSource.colorBorderHover :
                                                                                   themeSource.colorBorder;
            }
        } else {
            return themeSource.colorBorderDisabled;
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
    background: Item {
        MosRectangleInternal {
            id: __effect
            width: __bg.width
            height: __bg.height
            radius: __bg.r
            topLeftRadius: __bg.tl
            topRightRadius: __bg.tr
            bottomLeftRadius: __bg.bl
            bottomRightRadius: __bg.br
            anchors.centerIn: parent
            visible: root.effectEnabled && root.type != MosButton.Type_Link
            color: 'transparent'
            border.width: 0
            border.color: root.enabled ? root.themeSource.colorBorderHover : 'transparent'
            opacity: 0.2

            ParallelAnimation {
                id: __animation
                onFinished: __effect.border.width = 0;
                NumberAnimation {
                    target: __effect; property: 'width'; from: __bg.width + 3; to: __bg.width + 8;
                    duration: MosTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'height'; from: __bg.height + 3; to: __bg.height + 8;
                    duration: MosTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'opacity'; from:0.2 ; to: 0;
                    duration: MosTheme.Primary.durationSlow
                }
            }
            Connections {
                target: root
                function onReleased() {
                    if (root.animationEnabled && root.effectEnabled) {
                        __effect.border.width = 8;
                        __animation.restart();
                    }
                }
            }
        }

        Loader {
            id: __bg
            width: realWidth
            height: realHeight
            anchors.centerIn: parent
            sourceComponent: root.type === MosButton.Type_Dashed ? __dashedBgComponent : __bgComponent
            property real r: root.radiusBg?.all ?? 0
            property real tl: root.shape == MosButton.Shape_Default ? root.radiusBg?.topLeft ?? 0 : height * 0.5
            property real tr: root.shape == MosButton.Shape_Default ? root.radiusBg?.topRight ?? 0 : height * 0.5
            property real bl: root.shape == MosButton.Shape_Default ? root.radiusBg?.bottomLeft ?? 0 : height * 0.5
            property real br: root.shape == MosButton.Shape_Default ? root.radiusBg?.bottomRight ?? 0 : height * 0.5
            property real realWidth: root.shape == MosButton.Shape_Default ? parent.width : parent.height
            property real realHeight: root.shape == MosButton.Shape_Default ? parent.height : parent.height
        }

        Component {
            id: __bgComponent

            MosRectangleInternal {
                color: root.colorBg
                border.width: (root.type == MosButton.Type_Filled || root.type == MosButton.Type_Text) ? 0 : 1
                border.color: root.enabled ? root.colorBorder : 'transparent'
                radius: r
                topLeftRadius: tl
                topRightRadius: tr
                bottomLeftRadius: bl
                bottomRightRadius: br

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
                Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            }
        }

        Component {
            id: __dashedBgComponent

            MosRectangle {
                color: root.colorBg
                border.width: (root.type == MosButton.Type_Filled || root.type == MosButton.Type_Text) ? 0 : 1
                border.color: root.enabled ? root.colorBorder : 'transparent'
                border.style: Qt.DashLine
                radius: r
                topLeftRadius: tl
                topRightRadius: tr
                bottomLeftRadius: bl
                bottomRightRadius: br

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
                Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            }
        }
    }

    HoverHandler {
        cursorShape: root.hoverCursorShape
    }

    Accessible.role: Accessible.Button
    Accessible.name: root.text
    Accessible.description: root.contentDescription
    Accessible.onPressAction: root.clicked();

}