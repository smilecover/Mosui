import QtQuick
import QtQuick.Templates as T
import QtQuick.Shapes
import MosuiBasic

T.GroupBox {
    id: root

    property real borderWidth: 1 / Screen.devicePixelRatio
    property color colorTitle: enabled ? themeSource.colorTitle :
                                         themeSource.colorTitleDisabled
    property color colorBg: 'transparent'
    property color colorBorder: enabled ? themeSource.colorBorder :
                                          themeSource.colorBorderDisabled
    property MosRadius radiusBg: MosRadius { all: MosTheme.Primary.radiusPrimary }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosGroupBox

    objectName: '__MosGroupBox__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            implicitLabelWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12 * sizeRatio
    topPadding: padding + (implicitLabelWidth > 0 ? implicitLabelHeight * 0.5 : 0)
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    label: MosText {
        x: root.leftPadding
        width: root.availableWidth
        text: root.title
        font: root.font
        color: root.colorTitle
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
    background: Item {
        y: root.topPadding - root.bottomPadding
        // width: parent.width
        // height: parent.height - root.topPadding + root.bottomPadding

        Shape {
            id: __shape
            anchors.fill: parent
            
            ShapePath {
                id: __path
                strokeColor: root.colorBorder
                strokeWidth: root.borderWidth
                fillColor: root.colorBg
                
                property real inset: root.borderWidth * 0.5
                property real w: __shape.width - inset
                property real h: __shape.height - inset
                
                property real rTL: Math.max(0.001, root.radiusBg.topLeft)
                property real rTR: Math.max(0.001, root.radiusBg.topRight)
                property real rBR: Math.max(0.001, root.radiusBg.bottomRight)
                property real rBL: Math.max(0.001, root.radiusBg.bottomLeft)
                
                property real labelWidth: root.implicitLabelWidth
                property real gapStartX: root.leftPadding - 4 * root.sizeRatio
                property real gapEndX: root.leftPadding + labelWidth + 4 * root.sizeRatio
                
                property real safeGapStartX: labelWidth <= 0 ? inset + rTL : Math.min(w - rTR, Math.max(inset + rTL, gapStartX))
                property real safeGapEndX: labelWidth <= 0 ? inset + rTL : Math.min(w - rTR, Math.max(inset + rTL, gapEndX))

                startX: safeGapEndX
                startY: inset
                
                PathLine { x: __path.w - __path.rTR; y: __path.inset }
                PathArc {
                    x: __path.w; y: __path.inset + __path.rTR
                    radiusX: __path.rTR; radiusY: __path.rTR
                    useLargeArc: false
                }
                PathLine { x: __path.w; y: __path.h - __path.rBR }
                PathArc {
                    x: __path.w - __path.rBR; y: __path.h
                    radiusX: __path.rBR; radiusY: __path.rBR
                    useLargeArc: false
                }
                PathLine { x: __path.inset + __path.rBL; y: __path.h }
                PathArc {
                    x: __path.inset; y: __path.h - __path.rBL
                    radiusX: __path.rBL; radiusY: __path.rBL
                    useLargeArc: false
                }
                PathLine { x: __path.inset; y: __path.inset + __path.rTL }
                PathArc {
                    x: __path.inset + __path.rTL; y: __path.inset
                    radiusX: __path.rTL; radiusY: __path.rTL
                    useLargeArc: false
                }
                PathLine { x: __path.safeGapStartX; y: __path.inset }
            }
        }
    }

    QtObject {
        id: __private
        property real implicitLabelHeight: root.title === '' ? 0 : root.implicitLabelHeight
    }
}
