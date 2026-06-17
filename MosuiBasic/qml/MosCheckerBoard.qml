import QtQuick
import QtQuick.Effects
import MosuiBasic

Item {
    id: root

    property alias rows: __checkerGrid.rows
    property alias columns: __checkerGrid.columns
    property color colorWhite: 'transparent'
    property color colorBlack: MosTheme.Primary.colorFillSecondary
    property MosRadius radiusBg: MosRadius { all: 0 }

    MosRectangleInternal {
        id: __mask
        anchors.fill: parent
        radius: parent.radiusBg.all
        topLeftRadius: parent.radiusBg.topLeft
        topRightRadius: parent.radiusBg.topRight
        bottomLeftRadius: parent.radiusBg.bottomLeft
        bottomRightRadius: parent.radiusBg.bottomRight
        layer.enabled: true
        visible: false
    }

    Grid {
        id: __checkerGrid
        anchors.fill: parent
        layer.enabled: true
        visible: false

        property real cellWidth: width / columns
        property real cellHeight: height / rows

        Repeater {
            model: parent.rows * parent.columns

            Rectangle {
                width: __checkerGrid.cellWidth
                height: __checkerGrid.cellHeight
                color: (rowIndex + colIndex) % 2 === 0 ? root.colorWhite : root.colorBlack
                required property int index
                property int rowIndex: Math.floor(index / __checkerGrid.columns)
                property int colIndex: index % __checkerGrid.columns
            }
        }
    }

    MultiEffect {
        anchors.fill: __checkerGrid
        maskEnabled: true
        maskSource: __mask
        source: __checkerGrid
    }
}
