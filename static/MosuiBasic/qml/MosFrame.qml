import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Frame {
    id: root

    property real borderWidth: 1
    property color colorBg: 'transparent'
    property color colorBorder: MosTheme.Primary.colorSplit
    property MosRadius radiusBg: MosRadius { all: MosTheme.Primary.radiusPrimary }

    objectName: '__MosFrame__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)
    padding: 5
    font {
        family: MosTheme.Primary.fontPrimaryFamily
        pixelSize: parseInt(MosTheme.Primary.fontPrimarySize)
    }
    background: MosRectangleInternal {
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
        color: root.colorBg
        border.color: root.colorBorder
        border.width: root.borderWidth
    }
}
