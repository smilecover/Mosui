import QtQuick
import QtQuick.Layouts
import MosuiBasic

Loader {
    id: root

    enum Type {
        Type_Compact = 0
    }

    property int type: MosSpace.Type_Compact
    property string layout: ''
    property bool autoCombineRadius: true
    property MosRadius radiusBg: MosRadius { all: MosTheme.Primary.radiusPrimary }

    /*! Row Column Grid */
    property Transition add: null
    property Transition populate: null
    property Transition move: null
    property real padding: 0
    property real leftPadding: 0
    property real rightPadding: 0
    property real topPadding: 0
    property real bottomPadding: 0

    /*! Row Column RowLayout ColunmLayout */
    property real spacing: -1

    /*! Row RowLayout ColunmLayout Grid GridLayout */
    property int layoutDirection: Qt.LeftToRight

    /*! RowLayout ColunmLayout */
    property bool uniformCellSizes: false

    /* Grid */
    property int horizontalItemAlignment: Qt.AlignHCenter
    property int verticalItemAlignment: Qt.AlignVCenter

    /* Grid GridLayout */
    property real rows: 0
    property real columns: 0
    property real rowSpacing: spacing
    property real columnSpacing: spacing
    property int flow: GridLayout.LeftToRight

    /*! GridLayout */
    property bool uniformCellWidths: false
    property bool uniformCellHeights: false

    default property list<QtObject> layoutData

    function __setItemRadiusBinding(instance: var, edge: string, hasDirection: bool) {
        if (instance.hasOwnProperty('radiusBg')) {
            instance.radiusBg.all = 0;
            switch (edge) {
            case 'left': {
                instance.radiusBg.topLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.topLeft : 0) :
                            Qt.binding(() => root.radiusBg.topLeft);
                instance.radiusBg.bottomLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.bottomLeft : 0) :
                            Qt.binding(() => root.radiusBg.bottomLeft);
                instance.radiusBg.topRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.topRight : 0) :
                            Qt.binding(() => root.radiusBg.topRight);
                instance.radiusBg.bottomRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.bottomRight : 0) :
                            Qt.binding(() => root.radiusBg.bottomRight);
            } break;
            case 'right': {
                instance.radiusBg.topRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.topRight : 0) :
                            Qt.binding(() => root.radiusBg.topRight);
                instance.radiusBg.bottomRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.bottomRight : 0) :
                            Qt.binding(() => root.radiusBg.bottomRight);
                instance.radiusBg.topLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.topLeft : 0) :
                            Qt.binding(() => root.radiusBg.topLeft);
                instance.radiusBg.bottomLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.bottomLeft : 0) :
                            Qt.binding(() => root.radiusBg.bottomLeft);
            } break;
            case 'top': {
                instance.radiusBg.topLeft = Qt.binding(() => root.radiusBg.topLeft);
                instance.radiusBg.topRight = Qt.binding(() => root.radiusBg.topRight);
            } break;
            case 'bottom': {
                instance.radiusBg.bottomLeft = Qt.binding(() => root.radiusBg.bottomLeft);
                instance.radiusBg.bottomRight = Qt.binding(() => root.radiusBg.bottomRight);
            } break;
            case 'topLeft': {
                instance.radiusBg.topLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.topLeft : 0) :
                            Qt.binding(() => root.radiusBg.topLeft);
                instance.radiusBg.topRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.topRight : 0) :
                            Qt.binding(() => root.radiusBg.topRight);
            } break;
            case 'topRight': {
                instance.radiusBg.topRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.topRight : 0) :
                            Qt.binding(() => root.radiusBg.topRight);
                instance.radiusBg.topLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.topLeft : 0) :
                            Qt.binding(() => root.radiusBg.topLeft);
            } break;
            case 'bottomLeft': {
                instance.radiusBg.bottomLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.bottomLeft : 0) :
                            Qt.binding(() => root.radiusBg.bottomLeft);
                instance.radiusBg.bottomRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.bottomRight : 0) :
                            Qt.binding(() => root.radiusBg.bottomRight);
            } break;
            case 'bottomRight': {
                instance.radiusBg.bottomRight = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.LeftToRight ? root.radiusBg.bottomRight : 0) :
                            Qt.binding(() => root.radiusBg.bottomRight);
                instance.radiusBg.bottomLeft = hasDirection ?
                            Qt.binding(() => root.layoutDirection === Qt.RightToLeft ? root.radiusBg.bottomLeft : 0) :
                            Qt.binding(() => root.radiusBg.bottomLeft);
            } break;
            default: break;
            }
        }
    }

    function __createBindings(itemChildren: var) {
        if (!autoCombineRadius) return;

        const length = itemChildren.length;
        const createRowBinding = () => {
            itemChildren.forEach(
                (item, i) => {
                    if (i === 0) {
                        __setItemRadiusBinding(item, 'left', true);
                    } else if (i === length - 1) {
                        __setItemRadiusBinding(item, 'right', true);
                    } else {
                        __setItemRadiusBinding(item, '');
                    }
                });
        };
        const createColumnBinding = () => {
            itemChildren.forEach(
                (item, i) => {
                    if (i === 0) {
                        __setItemRadiusBinding(item, 'top');
                    } else if (i === length - 1) {
                        __setItemRadiusBinding(item, 'bottom');
                    } else {
                        __setItemRadiusBinding(item, '');
                    }
                });
        };
        const createGridBinding = () => {
            if (columns > 1 && rows > 1) {
                itemChildren.forEach(
                    (item, i) => {
                        if (i === 0) {
                            __setItemRadiusBinding(item, 'topLeft');
                        } else if (i === (columns - 1)) {
                            __setItemRadiusBinding(item, 'topRight');
                        } else if (i === columns * (rows - 1)) {
                            __setItemRadiusBinding(item, 'bottomLeft');
                        } else if (i === length - 1) {
                            __setItemRadiusBinding(item, 'bottomRight');
                        } else {
                            __setItemRadiusBinding(item, '');
                        }
                    });
            } else {
                if (rows === 1) {
                    createRowBinding();
                } else if (columns === 1) {
                    createColumnBinding();
                }
            }
        }
        const createGridLayoutBinding = () => {
            if (columns > 1 && rows > 1) {
                /* 统一清空radius */
                itemChildren.forEach(item => __setItemRadiusBinding(item, ''));
                /*! 第一行的第一个和最后一个 */
                let columnIndex = 0;
                for (let i = 0; i < length; i++) {
                    const item1 = itemChildren[i];
                    if (i === 0) {
                        __setItemRadiusBinding(item1, 'topLeft', true);
                    }
                     if (columnIndex < columns) {
                        columnIndex += item1.Layout.columnSpan;
                        if (columnIndex >= columns) {
                            __setItemRadiusBinding(item1, 'topRight', true);
                            break;
                        }
                    }
                }
                /*! 最后一行的最后一个和第一个 */
                columnIndex = 0;
                for (let j = length - 1; j > 0; j--) {
                    const item2 = itemChildren[j];
                    if (j === length - 1) {
                        __setItemRadiusBinding(item2, 'bottomRight', true);
                    }
                    if (columnIndex < columns) {
                        columnIndex += item2.Layout.columnSpan;
                        if (columnIndex >= columns) {
                            __setItemRadiusBinding(item2, 'bottomLeft', true);
                            break;
                        }
                    }
                }
            } else {
                if (rows === 1) {
                    createRowBinding();
                } else if (columns === 1) {
                    createColumnBinding();
                }
            }
        }
        if (length > 0) {
            switch (layout) {
            case 'Row':
            case 'RowLayout':
                createRowBinding();
                break;
            case 'Column':
            case 'ColumnLayout':
                createColumnBinding();
                break;
            case 'Grid':
                createGridBinding();
                break;
            case 'GridLayout':
                createGridLayoutBinding();
                break;
            }
        }
    }

    objectName: '__MosSpace__'
    sourceComponent: {
        switch (layout) {
        case 'Row': return __row;
        case 'RowLayout': return __rowLayout;
        case 'Column': return __column;
        case 'ColumnLayout': return __columnLayout;
        case 'Grid': return __grid;
        case 'GridLayout': return __gridLayout;
        }
    }

    Component {
        id: __row

        Row {
            add: root.add
            populate: root.add
            move: root.add
            padding: root.padding
            leftPadding: root.leftPadding
            rightPadding: root.rightPadding
            topPadding: root.topPadding
            bottomPadding: root.bottomPadding
            spacing: root.spacing
            layoutDirection: root.layoutDirection
            data: root.layoutData
            Component.onCompleted: root.__createBindings(children);
        }
    }

    Component {
        id: __rowLayout

        Item {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.leftPadding
            anchors.rightMargin: root.rightPadding
            anchors.topMargin: root.topPadding
            anchors.bottomMargin: root.bottomPadding
            spacing: root.spacing
            layoutDirection: root.layoutDirection
            uniformCellSizes: root.uniformCellSizes
            data: root.layoutData
            Component.onCompleted: root.__createBindings(children);
        }
        }
    }

    Component {
        id: __column

        Column {
            add: root.add
            populate: root.add
            move: root.add
            padding: root.padding
            leftPadding: root.leftPadding
            rightPadding: root.rightPadding
            topPadding: root.topPadding
            bottomPadding: root.bottomPadding
            spacing: root.spacing
            data: root.layoutData
            Component.onCompleted: root.__createBindings(children);
        }
    }

    Component {
        id: __columnLayout

        Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: root.leftPadding
            anchors.rightMargin: root.rightPadding
            anchors.topMargin: root.topPadding
            anchors.bottomMargin: root.bottomPadding
            spacing: root.spacing
            layoutDirection: root.layoutDirection
            uniformCellSizes: root.uniformCellSizes
            data: root.layoutData
            Component.onCompleted: root.__createBindings(children);
        }
        }
    }

    Component {
        id: __grid

        Grid {
            add: root.add
            populate: root.add
            move: root.add
            padding: root.padding
            leftPadding: root.leftPadding
            rightPadding: root.rightPadding
            topPadding: root.topPadding
            bottomPadding: root.bottomPadding
            rows: root.rows
            columns: root.columns
            spacing: root.spacing
            rowSpacing: root.rowSpacing
            columnSpacing: root.columnSpacing
            layoutDirection: root.layoutDirection
            horizontalItemAlignment: root.horizontalItemAlignment
            verticalItemAlignment: root.verticalItemAlignment
            data: root.layoutData
            Component.onCompleted: root.__createBindings(children);
        }
    }

    Component {
        id: __gridLayout

        Item {
        GridLayout {
            anchors.fill: parent
            anchors.leftMargin: root.leftPadding
            anchors.rightMargin: root.rightPadding
            anchors.topMargin: root.topPadding
            anchors.bottomMargin: root.bottomPadding
            flow: root.flow
            rows: root.rows
            columns: root.columns
            rowSpacing: root.rowSpacing
            columnSpacing: root.columnSpacing
            layoutDirection: root.layoutDirection
            uniformCellWidths: root.uniformCellWidths
            uniformCellHeights: root.uniformCellHeights
            data: root.layoutData
            Component.onCompleted: root.__createBindings(children);
        }
        }
    }
}
