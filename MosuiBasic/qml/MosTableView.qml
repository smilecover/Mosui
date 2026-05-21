pragma ComponentBehavior: Unbound

import QtQuick
import QtQuick.Templates as T
import Qt.labs.qmlmodels
import MosuiBasic

MosRectangleInternal {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property alias reuseItems: __cellView.reuseItems
    property bool propagateWheelEvent: false
    property bool alternatingRow: false
    property int defaultColumnHeaderHeight: 40
    property int defaultRowHeaderWidth: 40
    property var rowHeightProvider: (row, key) => minimumRowHeight
    property bool showColumnGrid: false
    property bool showRowGrid: false
    property real minimumRowHeight: 40
    property real maximumRowHeight: Number.MAX_VALUE
    property bool columnResizable: true
    property bool rowResizable: true
    property var initModel: []
    readonly property int rowCount: __cellModel.rowCount
    property var columns: []
    property var defaultCheckedKeys: []
    property var checkedKeys: []

    property bool showColumnHeader: true
    property font columnHeaderTitleFont: Qt.font({
                                                     family: themeSource.fontFamily,
                                                     pixelSize: parseInt(themeSource.fontSize)
                                                 })
    property color colorColumnHeaderTitle: themeSource.colorColumnTitle
    property color colorColumnHeaderBg: themeSource.colorColumnHeaderBg

    property bool showRowHeader: true
    property font rowHeaderTitleFont: Qt.font({
                                                  family: themeSource.fontFamily,
                                                  pixelSize: parseInt(themeSource.fontSize)
                                              })
    property color colorRowHeaderTitle: themeSource.colorRowTitle
    property color colorRowHeaderBg: themeSource.colorRowHeaderBg

    property color colorGridLine: themeSource.colorGridLine
    property color colorResizeBlockBg: themeSource.colorResizeBlockBg
    property MosRadius radiusBg: MosRadius {
        topLeft: themeSource.radiusBg
        topRight: themeSource.radiusBg
    }
    property var themeSource: MosTheme.MosTableView

    property alias verScrollBar: __vScrollBar
    property alias horScrollBar: __hScrollBar
    property alias tableView: __cellView
    property alias tableModel: __cellModel

    property Component columnHeaderDelegate: Item {
        id: __columnHeaderDelegate

        property var model: parent.model
        property var headerData: parent.headerData
        property int column: parent?.model?.column ?? -1
        property bool editable: headerData?.editable ?? false
        property string align: headerData?.align ?? 'center'
        property string selectionType: headerData?.selectionType ?? ''
        property var sorter: headerData?.sorter
        property var sortDirections: headerData?.sortDirections ?? []
        property var onFilter: headerData?.onFilter

        Loader {
            anchors {
                left: __checkBoxLoader.active ? __checkBoxLoader.right : parent.left
                leftMargin: __checkBoxLoader.active ? 0 : 10
                right: parent.right
                rightMargin: 10
                top: parent.top
                topMargin: 4
                bottom: parent.bottom
                bottomMargin: 4
            }
            sourceComponent: root.columnHeaderTitleDelegate
            property alias column: __columnHeaderDelegate.column
            property alias headerData: __columnHeaderDelegate.headerData
            property alias align: __columnHeaderDelegate.align
        }

        MouseArea {
            height: parent.height
            anchors.left: __columnHeaderDelegate.editable ? __sorterLoader.left : __checkBoxLoader.right
            anchors.right: __filterLoader.active ? __filterLoader.left : parent.right
            enabled: __sorterLoader.active
            hoverEnabled: true
            onEntered: cursorShape = Qt.PointingHandCursor;
            onExited: cursorShape = Qt.ArrowCursor;
            onClicked: {
                root.sort(column);
                __sorterLoader.sortMode = columns[column].sortMode ?? 'false';
            }
        }

        Loader {
            id: __checkBoxLoader
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            active: __columnHeaderDelegate.selectionType === 'checkbox'
            sourceComponent: MosCheckBox {
                id: __parentBox
                animationEnabled: root.animationEnabled
                checkState: __private.parentCheckState
                onToggled: {
                    if (checkState == Qt.Unchecked) {
                        __private.model.forEach(
                            object => {
                                if (object?.enabled ?? true) {
                                    __private.checkedKeysSet.delete(object.key);
                                }
                            });
                        __private.checkedKeysSetChanged();
                    } else {
                        __private.model.forEach(
                            object => {
                                if (object?.enabled ?? true) {
                                    __private.checkedKeysSet.add(object.key);
                                }
                            });
                        __private.checkedKeysSetChanged();
                    }
                    __private.updateParentCheckBox();
                }

                Connections {
                    target: __private
                    function onParentCheckStateChanged() {
                        __parentBox.checkState = Qt.binding(() => __private.parentCheckState);
                    }
                }
            }
        }

        Loader {
            id: __sorterLoader
            anchors.right: __filterLoader.active ? __filterLoader.left : parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            active: sorter !== undefined
            sourceComponent: root.columnHeaderSorterIconDelegate
            onLoaded: {
                if (sortDirections.length === 0) return;

                let ref = root.columns[column];
                if (!ref.hasOwnProperty('activeSorter')) {
                    ref.activeSorter = false;
                }
                if (!ref.hasOwnProperty('sortIndex')) {
                    ref.sortIndex = -1;
                }
                if (!ref.hasOwnProperty('sortMode')) {
                    ref.sortMode = 'false';
                }
                sortMode = ref.sortMode;
            }
            property alias column: __columnHeaderDelegate.column
            property alias sorter: __columnHeaderDelegate.sorter
            property alias sortDirections: __columnHeaderDelegate.sortDirections
            property string sortMode: 'false'
        }

        Loader {
            id: __filterLoader
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            active: onFilter !== undefined
            sourceComponent: root.columnHeaderFilterIconDelegate
            property alias column: __columnHeaderDelegate.column
            property alias onFilter: __columnHeaderDelegate.onFilter
        }
    }
    property Component rowHeaderDelegate: Item {
        MosText {
            anchors {
                left: parent.left
                leftMargin: 8
                right: parent.right
                rightMargin: 8
                top: parent.top
                topMargin: 4
                bottom: parent.bottom
                bottomMargin: 4
            }
            font: root.rowHeaderTitleFont
            text: (row + 1)
            color: root.colorRowHeaderTitle
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
    property Component columnHeaderTitleDelegate: MosText {
        font: root.columnHeaderTitleFont
        text: headerData?.title ?? ''
        color: root.colorColumnHeaderTitle
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: {
            if (align === 'left')
            return Text.AlignLeft;
            else if (align === 'right')
            return Text.AlignRight;
            else
            return Text.AlignHCenter;
        }
    }
    property Component columnHeaderSorterIconDelegate: Item {
        id: __sorterIconDelegate
        width: __sorterIconColumn.width
        height: __sorterIconColumn.height + 12

        Column {
            id: __sorterIconColumn
            anchors.verticalCenter: parent.verticalCenter
            spacing: -2

            MosIconText {
                visible: sortDirections.indexOf('ascend') !== -1
                colorIcon: sortMode === 'ascend' ? root.themeSource.colorIconHover :
                                                   root.themeSource.colorIcon
                iconSource: MosIcon.CaretUpOutlined
                iconSize: parseInt(root.themeSource.fontSize) - 2
            }

            MosIconText {
                visible: sortDirections.indexOf('descend') !== -1
                colorIcon: sortMode === 'descend' ? root.themeSource.colorIconHover :
                                                    root.themeSource.colorIcon
                iconSource: MosIcon.CaretDownOutlined
                iconSize: parseInt(root.themeSource.fontSize) - 2
            }
        }
    }
    property Component columnHeaderFilterIconDelegate: Item {
        width: __headerFilterIcon.width
        height: __headerFilterIcon.height + 12

        HoverIcon {
            id: __headerFilterIcon
            anchors.centerIn: parent
            iconSource: MosIcon.SearchOutlined
            colorIcon: hovered ? root.themeSource.colorIconHover : root.themeSource.colorIcon
            onClicked: {
                __filterPopup.open();
            }
        }

        MosPopup {
            id: __filterPopup
            x: -width * 0.5
            y: parent.height
            padding: 5
            animationEnabled: root.animationEnabled
            contentItem: Column {
                spacing: 5

                MosInput {
                    id: __searchInput
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholderText: qsTr('Search ') + root.columns[column]?.dataIndex ?? ''
                    onEditingFinished: __searchButton.clicked();
                    Component.onCompleted: {
                        let ref = root.columns[column];
                        if (ref.hasOwnProperty('filterInput')) {
                            text = ref.filterInput;
                        } else {
                            ref.filterInput = '';
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 5

                    MosIconButton {
                        id: __searchButton
                        animationEnabled: root.animationEnabled
                        text: qsTr('Search')
                        iconSource: MosIcon.SearchOutlined
                        type: MosButton.Type_Primary
                        onClicked: {
                            if (__searchInput.text.length === 0)
                            __filterPopup.close();
                            root.columns[column].filterInput = __searchInput.text;
                            root.filter();
                        }
                    }

                    MosButton {
                        animationEnabled: root.animationEnabled
                        text: qsTr('Reset')
                        onClicked: {
                            if (__searchInput.text.length === 0)
                            __filterPopup.close();
                            __searchInput.clear();
                            root.columns[column].filterInput = '';
                            root.filter();
                        }
                    }

                    MosButton {
                        animationEnabled: root.animationEnabled
                        text: qsTr('Close')
                        type: MosButton.Type_Link
                        onClicked: {
                            __filterPopup.close();
                        }
                    }
                }
            }
            Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
        }
    }

    function setColumnVisible(dataIndex: string, visible: bool) {
        const filter = (item, column) => {
            if (item.dataIndex === dataIndex) {
                columns[column].visible = visible;
                __private.columnVisibleChanged(dataIndex, visible);
                return true;
            }
        }
        columns.some(filter);
    }

    function checkForRows(rows: var) {
        if (rows.length <= 0) return;

        if (__private.selectionType === 'radio') {
            const key = __private.model[rows[rows.length - 1]].key;
            __private.checkedKeysSet.add(key);
        } else {
            rows.forEach(
                        row => {
                            if (row >= 0 && row < __private.model.length) {
                                const key = __private.model[row].key;
                                __private.checkedKeysSet.add(key);
                            }
                        });
        }
        __private.checkedKeysSetChanged();
    }

    function checkForKeys(keys: var) {
        if (keys.length <= 0) return;

        if (__private.selectionType === 'radio') {
            __private.checkedKeysSet.add(keys[keys.length - 1]);
        } else {
            keys.forEach(key => __private.checkedKeysSet.add(key));
        }
        __private.checkedKeysSetChanged();
    }

    function toggleForRows(rows: var) {
        if (rows.length <= 0) return;

        if (__private.selectionType === 'radio') {
            const key = __private.model[rows[rows.length - 1]].key;
            __private.checkedKeysSet.add(key);
        } else {
            rows.forEach(row => {
                             if (row >= 0 && row < __private.model.length) {
                                 const key = __private.model[row].key;
                                 if (__private.checkedKeysSet.has(key)) {
                                     __private.checkedKeysSet.delete(key);
                                 } else {
                                     __private.checkedKeysSet.add(key);
                                 }
                             }
                         });
        }
        __private.checkedKeysSetChanged();
    }

    function toggleForKeys(keys: var) {
        if (keys.length <= 0) return;

        if (__private.selectionType === 'radio') {
            __private.checkedKeysSet.add(keys[keys.length - 1]);
        } else {
            keys.forEach(key => {
                             if (__private.checkedKeysSet.has(key)) {
                                 __private.checkedKeysSet.delete(key);
                             } else {
                                 __private.checkedKeysSet.add(key);
                             }
                         });
        }
        __private.checkedKeysSetChanged();
    }

    function getCheckedKeys(): var {
        return [...__private.checkedKeysSet.keys()];
    }

    function clearAllCheckedKeys() {
        __private.checkedKeysSet.clear();
        __private.checkedKeysSetChanged();
        __private.parentCheckState = Qt.Unchecked;
        __private.parentCheckStateChanged();
    }

    function scrollToRow(row: int, mode = TableView.AlignVCenter) {
        __cellView.positionViewAtRow(row, mode);
        __private.updateParentCheckBox();
    }

    function sort(column: int) {
        /*! 仅需设置排序相关属性, 真正的排序在 filter() 中完成 */
        if (columns[column].hasOwnProperty('sorter')) {
            columns.forEach(
                        (object, index) => {
                            if (object.hasOwnProperty('sorter')) {
                                if (column === index) {
                                    object.activeSorter = true;
                                    object.sortIndex = (object.sortIndex + 1) % object.sortDirections.length;
                                    object.sortMode = object.sortDirections[object.sortIndex];
                                } else {
                                    object.activeSorter = false;
                                    object.sortIndex = -1;
                                    object.sortMode = 'false';
                                }
                            }
                        });
        }

        filter();
    }

    function clearSort() {
        columns.forEach(
                    object => {
                        if (object.sortDirections && object.sortDirections.length !== 0) {
                            object.activeSorter = false;
                            object.sortIndex = -1;
                            object.sortMode = 'false';
                        }
                    });
        __private.model = [...initModel];
    }

    function filter() {
        /*! 先过滤 */
        let change = false;
        let model = [...initModel];
        columns.forEach(
                    object => {
                        if (object.hasOwnProperty('onFilter') && object.hasOwnProperty('filterInput')) {
                            model = model.filter((record, index) => object.onFilter(object.filterInput, record));
                            change = true;
                        }
                    });
        if (change)
            __private.model = model;

        /*! 根据 activeSorter 列排序 */
        columns.forEach(
                    object => {
                        if (object.activeSorter === true) {
                            if (object.sortMode === 'ascend') {
                                /*! sorter 作为上升处理 */
                                __private.model.sort(object.sorter);
                                __private.modelChanged();
                            } else if (object.sortMode === 'descend') {
                                /*! 返回 ascend 相反结果即可 */
                                __private.model.sort((a, b) => object.sorter(b, a));
                                __private.modelChanged();
                            } else {
                                /*! 还原 */
                                __private.model = model;
                            }
                        }
                    });
    }

    function clearFilter() {
        columns.forEach(
                    object => {
                        if (object.hasOwnProperty('onFilter') || object.hasOwnProperty('filterInput')) {
                            object.filterInput = '';
                        }
                    });
        __private.model = [...initModel];
    }

    function clear() {
        clearAllCheckedKeys();
        initModel = [];
        __private.model = [];
        __cellModel.clear();
        columns.forEach(
                    object => {
                        if (object.sortDirections && object.sortDirections.length !== 0) {
                            object.activeSorter = false;
                            object.sortIndex = -1;
                            object.sortMode = 'false';
                        }
                        if (object.hasOwnProperty('onFilter') || object.hasOwnProperty('filterInput')) {
                            object.filterInput = '';
                        }
                    });
    }

    function getTableModel(): var {
        return [...__private.model];
    }

    function rowCount(): int {
        return __cellModel.rowCount;
    }

    function columnCount(): int {
        return __cellModel.columnCount;
    }

    function appendRow(object: var) {
        __cellModel.appendRow(__private.toCellObject(object));
        __private.model.push(object);
        __private.updateRowHeader();
    }

    function getRow(rowIndex: int): var {
        if (rowIndex >= 0 && rowIndex < __cellModel.rowCount) {
            const row = __cellModel.getRow(rowIndex);
            const newRow = {};
            for (const key in row) {
                if (__private.dataIndexMap.has(key)) {
                    newRow[__private.dataIndexMap.get(key)] = row[key];
                }
            }
            return newRow;
        }
        return undefined;
    }

    function setRow(rowIndex: int, object: var) {
        if (rowIndex >= 0 && rowIndex < __cellModel.rowCount) {
            __cellModel.setRow(rowIndex, __private.toCellObject(object));
            __private.model[rowIndex] = object;
            __private.updateRowHeader();
        }
    }

    function insertRow(rowIndex: int, object: var) {
        __cellModel.insertRow(rowIndex, __private.toCellObject(object));
        __private.model.splice(rowIndex, 0, object);
        __private.updateRowHeader();
    }

    function moveRow(fromRowIndex: int, toRowIndex: int, count = 1) {
        if (fromRowIndex >= 0 && fromRowIndex < __cellModel.rowCount &&
                toRowIndex >= 0 && toRowIndex < __cellModel.rowCount) {
            __cellModel.moveRow(fromRowIndex, toRowIndex, count);
            const objects = __private.model.splice(from, count);
            __private.model.splice(to, 0, ...objects);
            __private.updateRowHeader();
        }
    }

    function removeRow(rowIndex: int, count = 1) {
        if (rowIndex >= 0 && rowIndex < __cellModel.rowCount) {
            __cellModel.removeRow(rowIndex, count);
            __private.model.splice(rowIndex, count);
            __private.updateRowHeader();
        }
    }

    function getCellData(rowIndex: int, columnIndex: int): var {
        if (rowIndex >= 0 && rowIndex < __cellModel.rowCount
                && columnIndex >= 0 && columnIndex < columns.length) {
            return __cellModel.data(__cellModel.index(rowIndex, columnIndex), 'display');
        }
        return undefined;
    }

    function setCellData(rowIndex: int, columnIndex: int, data: var) {
        if (rowIndex >= 0 && rowIndex < __cellModel.rowCount
                && columnIndex >= 0 && columnIndex < columns.length) {
            __cellModel.setData(__cellModel.index(rowIndex, columnIndex), 'display', data);
        }
    }

    onColumnsChanged: {
        let headerColumns = [];
        let headerRow = {};
        for (const object of columns) {
            __private.selectionType = object?.selectionType ?? 'none';
            let column = Qt.createQmlObject('import Qt.labs.qmlmodels; TableModelColumn {}', __columnHeaderModel);
            column.display = object.dataIndex;
            headerColumns.push(column);
            headerRow[object.dataIndex] = object;
        }

        if (showColumnHeader) {
            __columnHeaderModel.clear();
            __columnHeaderModel.columns = headerColumns;
            __columnHeaderModel.rows = [headerRow];
        }

        let cellColumns = [];
        __private.dataIndexMap.clear();
        for (let i = 0; i < columns.length; i++) {
            let column = Qt.createQmlObject('import Qt.labs.qmlmodels; TableModelColumn {}', __cellModel);
            column.display = `__data${i}`;
            cellColumns.push(column);
            __private.dataIndexMap.set(`__data${i}`, columns[i].dataIndex);
        }
        __cellModel.columns = cellColumns;
    }
    onInitModelChanged: {
        clearSort();
        filter();
    }
    Component.onCompleted: {
        checkForKeys(defaultCheckedKeys);
    }

    objectName: '__MosTableView__'
    clip: true
    color: themeSource.colorBg
    topLeftRadius: radiusBg.topLeft
    topRightRadius: radiusBg.topRight

    component HoverIcon: MosIconText {
        signal clicked()
        property alias hovered: __hoverHandler.hovered

        HoverHandler {
            id: __hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: parent.clicked();
        }
    }

    component ResizeArea: MouseArea {
        property bool isHorizontal: true
        property var target: __columnHeaderItem
        property point startPos: Qt.point(0, 0)
        property real minimumWidth: 0
        property real maximumWidth: Number.NaN
        property real minimumHeight: 0
        property real maximumHeight: Number.NaN
        property var resizeCallback: (result) => { }

        preventStealing: true
        hoverEnabled: true
        onEntered: cursorShape = isHorizontal ? Qt.SplitHCursor : Qt.SplitVCursor;
        onPressed:
            (mouse) => {
            if (target) {
                startPos = Qt.point(mouseX, mouseY);
            }
        }
        onPositionChanged:
            (mouse) => {
            if (pressed && target) {
                if (isHorizontal) {
                    let resultWidth = 0;
                    let offsetX = mouse.x - startPos.x;
                    if (maximumWidth != Number.NaN && (target.width + offsetX) > maximumWidth) {
                        resultWidth = maximumWidth;
                    } else if ((target.width + offsetX) < minimumWidth) {
                        resultWidth = minimumWidth;
                    } else {
                        resultWidth = target.width + offsetX;
                    }
                    resizeCallback(resultWidth);
                } else {
                    let resultHeight = 0;
                    let offsetY = mouse.y - startPos.y;
                    if (maximumHeight != Number.NaN && (target.height + offsetY) > maximumHeight) {
                        resultHeight = maximumHeight;
                    } else if ((target.height + offsetY) < minimumHeight) {
                        resultHeight = minimumHeight;
                    } else {
                        resultHeight = target.height + offsetY;
                    }
                    resizeCallback(resultHeight);
                }
                mouse.accepted = true;
            }
        }
    }

    Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorGridLine { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

    QtObject {
        id: __private

        signal columnVisibleChanged(dataIndex: string, visible: bool)

        property var model: []
        property int parentCheckState: Qt.Unchecked
        property var checkedKeysSet: new Set
        property var dataIndexMap: new Map
        property string selectionType: 'none'

        function updateParentCheckBox() {
            let checkCount = 0;
            let checkableCount = 0;
            model.forEach(
                        object => {
                            if (object?.enabled ?? true) {
                                checkableCount++;
                                if (checkedKeysSet.has(object.key)) {
                                    checkCount++;
                                }
                            }
                        });
            parentCheckState = checkCount === 0 ? Qt.Unchecked : checkCount === checkableCount ? Qt.Checked : Qt.PartiallyChecked;
        }

        function updateCheckedKeys() {
            root.checkedKeys = [...checkedKeysSet.keys()];
        }

        function updateRowHeader() {
            __rowHeaderModel.rows = model;
        }

        function toCellObject(object) {
            let dataObject = new Object;
            for (let i = 0; i < root.columns.length; i++) {
                const dataIndex = root.columns[i].dataIndex ?? '';
                if (object.hasOwnProperty(dataIndex)) {
                    dataObject[`__data${i}`] = object[dataIndex];
                } else {
                    dataObject[`__data${i}`] = null;
                }
            }
            return dataObject;
        }

        onModelChanged: {
            root.scrollToRow(0);
            __cellModel.clear();

            let cellRows = [];
            model.forEach(
                (object, index) => {
                    let data = {};
                    for (let i = 0; i < columns.length; i++) {
                        const dataIndex = columns[i].dataIndex ?? '';
                        if (object.hasOwnProperty(dataIndex)) {
                            data[`__data${i}`] = object[dataIndex];
                        } else {
                            data[`__data${i}`] = null;
                        }
                    }
                    cellRows.push(data);
                });
            __cellModel.rows = cellRows;

            __rowHeaderModel.rows = model;

            updateParentCheckBox();
        }
        onParentCheckStateChanged: updateCheckedKeys();
        onCheckedKeysSetChanged: {
            updateCheckedKeys();
            updateParentCheckBox();
        }
    }

    MosRectangleInternal {
        id: __columnHeaderViewBg
        height: root.defaultColumnHeaderHeight
        anchors.left: root.showRowHeader ? __rowHeaderViewBg.right : parent.left
        anchors.right: parent.right
        topLeftRadius: root.showRowHeader ? 0 : root.themeSource.radiusBg
        topRightRadius: root.radiusBg.topRight
        color: root.colorColumnHeaderBg
        visible: root.showColumnHeader

        TableView {
            id: __columnHeaderView
            anchors.fill: parent
            syncDirection: Qt.Horizontal
            syncView: __cellView
            reuseItems: false
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            model: TableModel {
                id: __columnHeaderModel
            }
            columnWidthProvider: (column) => root.columns[column].width
            delegate: Item {
                id: __columnHeaderItem
                implicitWidth: display.width ?? 100
                implicitHeight: __columnHeaderView.height
                clip: true

                required property var model
                required property var display
                property bool isVisible: true
                property int row: model.row
                property int column: model.column
                property string selectionType: display.selectionType ?? ''
                property bool editable: display.editable ?? false
                property var sorter: display.sorter
                property real lastWidth: implicitWidth
                property real minimumWidth: display.minimumWidth ?? 40
                property real maximumWidth: display.maximumWidth ?? Number.MAX_VALUE

                TableView.onReused: {
                    if (selectionType == 'checkbox') {
                        __private.updateParentCheckBox();
                    }
                }

                TableView.editDelegate: MosInput {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: sorter !== undefined ? 50 : 20
                    anchors.verticalCenter: parent.verticalCenter
                    animationEnabled: root.animationEnabled
                    text: display.title
                    visible: activeFocus && __columnHeaderItem.editable
                    TableView.onCommit: {
                        root.columns[__columnHeaderItem.column].title = text;
                        root.columnsChanged();
                    }
                }

                Connections{
                    target: __private

                    function onColumnVisibleChanged(dataIndex, visible) {
                        if (__columnHeaderItem.display.dataIndex === dataIndex) {
                            __columnHeaderItem.isVisible = visible;
                            if (visible) {
                                __columnHeaderView.setColumnWidth(__columnHeaderItem.column, __columnHeaderItem.lastWidth);
                            } else {
                                __columnHeaderItem.lastWidth = __columnHeaderView.columnWidth(__columnHeaderItem.column);
                                __columnHeaderView.setColumnWidth(__columnHeaderItem.column, 0.01);
                            }
                        }
                    }
                }

                Loader {
                    active: __columnHeaderItem.isVisible
                    anchors.fill: parent
                    sourceComponent: root.columnHeaderDelegate
                    property alias model: __columnHeaderItem.model
                    property alias headerData: __columnHeaderItem.display
                    property alias column: __columnHeaderItem.column
                }

                Rectangle {
                    z: 2
                    width: 1
                    height: parent.height * 0.5
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.colorGridLine
                    visible: __columnHeaderItem.isVisible && root.columnResizable
                }

                ResizeArea {
                    width: 8
                    height: parent.height
                    minimumWidth: __columnHeaderItem.minimumWidth
                    maximumWidth: __columnHeaderItem.maximumWidth
                    anchors.right: parent.right
                    anchors.rightMargin: -width * 0.5
                    visible: __columnHeaderItem.isVisible && root.columnResizable
                    enabled: visible
                    target: __columnHeaderItem
                    isHorizontal: true
                    resizeCallback: result => __columnHeaderView.setColumnWidth(__columnHeaderItem.column, result);
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: root.colorGridLine
        }
    }

    Rectangle {
        id: __rowHeaderViewBg
        width: root.defaultRowHeaderWidth
        anchors.top: root.showColumnHeader ? __columnHeaderViewBg.bottom : __cellMouseArea.top
        anchors.bottom: __cellMouseArea.bottom
        color: root.colorRowHeaderBg
        visible: root.showRowHeader

        TableView {
            id: __rowHeaderView
            anchors.fill: parent
            syncDirection: Qt.Vertical
            syncView: __cellView
            rowSpacing: __cellView.rowSpacing
            columnSpacing: __cellView.columnSpacing
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            model: TableModel {
                id: __rowHeaderModel
                TableModelColumn { }
            }
            delegate: Item {
                id: __rowHeaderItem
                implicitWidth: __rowHeaderView.width
                implicitHeight: root.minimumRowHeight
                clip: true

                required property var model
                property int row: model.row

                Loader {
                    anchors.fill: parent
                    sourceComponent: root.rowHeaderDelegate
                    property alias model: __rowHeaderItem.model
                    property alias row: __rowHeaderItem.row
                }

                Rectangle {
                    z: 2
                    width: parent.width * 0.5
                    height: 1
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.colorGridLine
                    visible: root.rowResizable
                }

                ResizeArea {
                    width: parent.width
                    height: 8
                    minimumHeight: root.minimumRowHeight
                    maximumHeight: root.maximumRowHeight
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -height * 0.5
                    visible: root.rowResizable
                    enabled: visible
                    target: __rowHeaderItem
                    isHorizontal: false
                    resizeCallback: result => __rowHeaderView.setRowHeight(__rowHeaderItem.row, result);
                }
            }
        }

        Rectangle {
            width: 1
            height: parent.height
            anchors.right: parent.right
            color: root.colorGridLine
        }
    }

    MouseArea {
        id: __cellMouseArea
        anchors.top: root.showColumnHeader ? __columnHeaderViewBg.bottom : parent.top
        anchors.bottom: parent.bottom
        anchors.left: __columnHeaderViewBg.left
        anchors.right: __columnHeaderViewBg.right
        hoverEnabled: true
        onExited: __cellView.currentHoverRow = -1;
        onWheel: wheel => wheel.accepted = !root.propagateWheelEvent;

        TableView {
            id: __cellView
            property int currentHoverRow: -1
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            selectionModel: ItemSelectionModel { }
            T.ScrollBar.horizontal: __hScrollBar
            T.ScrollBar.vertical: __vScrollBar
            clip: true
            reuseItems: false
            model: TableModel { id: __cellModel }
            delegate: Rectangle {
                id: __rootItem
                implicitWidth: root.columns[column].width
                implicitHeight: Math.max(root.minimumRowHeight, Math.min(root.rowHeightProvider(row, key), root.maximumRowHeight))
                visible: isHide ? false : implicitHeight >= 0
                enabled: isEnabled
                clip: true
                color: {
                    if (!enabled) return root.themeSource.colorBgDisabled;
                    if (__private.checkedKeysSet.has(key)) {
                        if (row == __cellView.currentHoverRow) {
                            return MosTheme.isDark ? root.themeSource.colorCellBgDarkHoverChecked :
                                                     root.themeSource.colorCellBgHoverChecked;
                        } else {
                            return MosTheme.isDark ? root.themeSource.colorCellBgDarkChecked :
                                                     root.themeSource.colorCellBgChecked;
                        }
                    } else {
                        return row == __cellView.currentHoverRow ? root.themeSource.colorCellBgHover :
                                                                   root.alternatingRow && __rootItem.row % 2 !== 0 ?
                                                                       root.themeSource.colorCellOddBg : root.themeSource.colorCellBg;
                    }
                }

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

                TableView.onReused: {
                    checked = __private.checkedKeysSet.has(key);
                    if (__childCheckBoxLoader.item) {
                        __childCheckBoxLoader.item.checked = checked;
                    }
                }

                required property int row
                required property int column
                required property var model
                required property var index
                required property var display
                required property bool current
                required property bool selected

                property bool isEnabled: __private.model[row]?.enabled ?? true
                property bool isHide: width === 1 && (root.columns[column].visible ?? true) === false
                property string key: __private.model[row]?.key ?? ''
                property string selectionType: root.columns[column].selectionType ?? ''
                property string dataIndex: root.columns[column].dataIndex ?? ''
                property string filterInput: root.columns[column].filterInput ?? ''
                property alias cellData: __rootItem.display
                property bool checked: __private.checkedKeysSet.has(key)

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: __cellView.currentHoverRow = __rootItem.row;

                    Loader {
                        id: __childCheckBoxLoader
                        active: __rootItem.selectionType === 'checkbox'
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: MosCheckBox {
                            id: __childCheckBox
                            animationEnabled: root.animationEnabled
                            checked: __rootItem.checked
                            onToggled: {
                                if (checkState === Qt.Checked) {
                                    __private.checkedKeysSet.add(__rootItem.key);
                                    __rootItem.checked = true;
                                } else {
                                    __private.checkedKeysSet.delete(__rootItem.key);
                                    __rootItem.checked = false;
                                }
                                __private.updateCheckedKeys();
                                __private.updateParentCheckBox();
                                __cellView.currentHoverRowChanged();
                            }

                            Connections {
                                target: __private
                                function onCheckedKeysSetChanged() {
                                    __childCheckBox.checked = __rootItem.checked = __private.checkedKeysSet.has(__rootItem.key);
                                }
                            }
                        }
                    }

                    Loader {
                        id: __childRadioLoader
                        active: __rootItem.selectionType === 'radio'
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: MosRadio {
                            id: __childRadio
                            animationEnabled: root.animationEnabled
                            checked: __rootItem.checked
                            onToggled: {
                                __private.checkedKeysSet.clear();
                                __private.checkedKeysSet.add(__rootItem.key);
                                __private.checkedKeysSetChanged();
                                __cellView.currentHoverRowChanged();
                            }

                            Connections {
                                target: __private
                                function onCheckedKeysSetChanged() {
                                    __childRadio.checked = __private.checkedKeysSet.has(__rootItem.key);
                                }
                            }
                        }
                    }

                    Loader {
                        anchors.left: __childCheckBoxLoader.active ? __childCheckBoxLoader.right : parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        sourceComponent: {
                            if (root.columns[__rootItem.column]?.delegate) {
                                return root.columns[__rootItem.column].delegate;
                            } else {
                                return null;
                            }
                        }
                        property alias row: __rootItem.row
                        property alias column: __rootItem.column
                        property alias cellData: __rootItem.cellData
                        property alias cellIndex: __rootItem.index
                        property alias dataIndex: __rootItem.dataIndex
                        property alias filterInput: __rootItem.filterInput
                        property alias current: __rootItem.current
                    }
                }

                Loader {
                    active: root.showRowGrid
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    sourceComponent: Rectangle { color: root.colorGridLine }
                }

                Loader {
                    active: root.showColumnGrid
                    width: 1
                    height: parent.height
                    anchors.right: parent.right
                    sourceComponent: Rectangle { color: root.colorGridLine }
                }
            }
        }
    }

    Loader {
        id: __resizeRectLoader
        z: 10
        width: __rowHeaderViewBg.width
        height: __columnHeaderViewBg.height
        active: root.showRowHeader && root.showColumnHeader
        sourceComponent: MosRectangleInternal {
            color: root.colorResizeBlockBg
            topLeftRadius: root.radiusBg.topLeft

            ResizeArea {
                width: parent.width
                height: 8
                minimumHeight: root.defaultColumnHeaderHeight
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -height * 0.5
                target: __columnHeaderViewBg
                isHorizontal: false
                resizeCallback: result => __columnHeaderViewBg.height = result;
            }

            ResizeArea {
                width: 8
                height: parent.height
                minimumWidth: root.defaultRowHeaderWidth
                anchors.right: parent.right
                anchors.rightMargin: -width * 0.5
                target: __rowHeaderViewBg
                isHorizontal: true
                resizeCallback: result => __rowHeaderViewBg.width = result;
            }
        }
    }

    MosScrollBar {
        id: __hScrollBar
        z: 11
        anchors.left: root.showRowHeader ? __rowHeaderViewBg.right : __cellMouseArea.left
        anchors.right: __cellMouseArea.right
        anchors.bottom: __cellMouseArea.bottom
        animationEnabled: root.animationEnabled
    }

    MosScrollBar {
        id: __vScrollBar
        z: 12
        anchors.right: __cellMouseArea.right
        anchors.top: root.showColumnHeader ? __columnHeaderViewBg.bottom : __cellMouseArea.top
        anchors.bottom: __cellMouseArea.bottom
        animationEnabled: root.animationEnabled
    }
}
