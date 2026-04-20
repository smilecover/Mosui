import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.ToolTip {
    id: root
    objectName: '__MosToolTip__'

    enum Position
    {
        Position_Top = 0,
        Position_Bottom = 1,
        Position_Left = 2,
        Position_Right = 3
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property bool showArrow: false
    property int position: MosToolTip.Position_Top
    property color colorShadow: MosTheme.MosToolTip.colorShadow
    property color colorText: MosTheme.MosToolTip.colorText
    property color colorBg: MosTheme.isDark ? MosTheme.MosToolTip.colorBgDark : MosTheme.MosToolTip.colorBg
    property MosRadius radiusBg: MosRadius { all: MosTheme.MosToolTip.radiusBg }

    component Arrow: Canvas {
        onWidthChanged: requestPaint();
        onHeightChanged: requestPaint();
        onColorBgChanged: requestPaint();
        onPaint: {
            const ctx = getContext('2d');
            ctx.fillStyle = colorBg;
            ctx.beginPath();
            switch (position) {
            case MosToolTip.Position_Top: {
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width * 0.5, height);
            } break;
            case MosToolTip.Position_Bottom: {
                ctx.moveTo(0, height);
                ctx.lineTo(width, height);
                ctx.lineTo(width * 0.5, 0);
            } break;
            case MosToolTip.Position_Left: {
                ctx.moveTo(0, 0);
                ctx.lineTo(0, height);
                ctx.lineTo(width, height * 0.5);
            } break;
            case MosToolTip.Position_Right: {
                ctx.moveTo(width, 0);
                ctx.lineTo(width, height);
                ctx.lineTo(0, height * 0.5);
            } break;
            }
            ctx.closePath();
            ctx.fill();
        }
        property color colorBg: root.colorBg
    }

    x: {
        switch (position) {
        case MosToolTip.Position_Top:
        case MosToolTip.Position_Bottom:
            return (__private.rootParentWidth - implicitWidth) * 0.5;
        case MosToolTip.Position_Left:
            return -implicitWidth - 4;
        case MosToolTip.Position_Right:
            return __private.rootParentWidth + 4;
        }
    }
    y: {
        switch (position) {
        case MosToolTip.Position_Top:
            return -implicitHeight - 4;
        case MosToolTip.Position_Bottom:
            return __private.rootParentHeight + 4;
        case MosToolTip.Position_Left:
        case MosToolTip.Position_Right:
            return (__private.rootParentHeight - implicitHeight) * 0.5;
        }
    }


    implicitWidth: implicitContentWidth
    implicitHeight: implicitContentHeight
    delay: 500
    padding: 0
    font {
        family: MosTheme.MosToolTip.fontFamily
        pixelSize: parseInt(MosTheme.MosToolTip.fontSize)
    }
    enter: Transition {
        NumberAnimation { property: 'opacity'; from: 0.0; to: 1.0; duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0 }
    }
    exit: Transition {
        NumberAnimation { property: 'opacity'; from: 1.0; to: 0.0; duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0 }
    }
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent
    contentItem: Item {
        implicitWidth: __bg.width + (__private.isHorizontal ? 0 : __arrow.width)
        implicitHeight: __bg.height + (__private.isHorizontal ? __arrow.height : 0)

        MosShadow {
            anchors.fill: __item
            source: __item
            shadowColor: root.colorShadow
        }

        Item {
            id: __item
            anchors.fill: parent

            Arrow {
                id: __arrow
                x: __private.isHorizontal ? (-root.x + (__private.rootParentWidth - width) * 0.5) : 0
                y: __private.isHorizontal ? 0 : (-root.y + (__private.rootParentHeight - height)) * 0.5
                width: __private.arrowSize.width
                height: __private.arrowSize.height
                anchors.top: root.position == MosToolTip.Position_Bottom ? parent.top : undefined
                anchors.bottom: root.position == MosToolTip.Position_Top ? parent.bottom : undefined
                anchors.left: root.position == MosToolTip.Position_Right ? parent.left : undefined
                anchors.right: root.position == MosToolTip.Position_Left ? parent.right : undefined

                Connections {
                    target: root
                    function onPositionChanged() {
                        __arrow.requestPaint();
                    }
                }
            }

            MosRectangleInternal {
                id: __bg
                width: __text.implicitWidth + 14
                height: __text.implicitHeight + 12
                anchors.top: root.position == MosToolTip.Position_Top ? parent.top : undefined
                anchors.bottom: root.position == MosToolTip.Position_Bottom ? parent.bottom : undefined
                anchors.left: root.position == MosToolTip.Position_Left ? parent.left : undefined
                anchors.right: root.position == MosToolTip.Position_Right ? parent.right : undefined
                anchors.margins: 1
                radius: root.radiusBg.all
                topLeftRadius: root.radiusBg.topLeft
                topRightRadius: root.radiusBg.topRight
                bottomLeftRadius: root.radiusBg.bottomLeft
                bottomRightRadius: root.radiusBg.bottomRight
                color: root.colorBg

                MosText {
                    id: __text
                    text: root.text
                    font: root.font
                    color: root.colorText
                    wrapMode: Text.Wrap
                    anchors.centerIn: parent
                }
            }
        }
    }
    background: Item { }

    QtObject {
        id: __private
        property bool isHorizontal: root.position == MosToolTip.Position_Top || root.position == MosToolTip.Position_Bottom
        property size arrowSize: root.showArrow ? (isHorizontal ? Qt.size(12, 6) : Qt.size(6, 12)) : Qt.size(0, 0)
        property real rootParentWidth: root.parent ? root.parent.width : 0
        property real rootParentHeight: root.parent ? root.parent.height : 0
    }
}
