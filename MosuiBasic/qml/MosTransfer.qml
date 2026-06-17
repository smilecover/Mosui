import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import MosuiBasic

T.Control {
    id: root

    signal change(nextTargetKeys: var, direction: string, moveKeys: var)

    property bool animationEnabled: MosTheme.animationEnabled
    property var dataSource: []
    readonly property alias sourceKeys: __private.sourceKeys
    property var targetKeys: []
    property alias sourceCheckedKeys: __sourceList.checkedKeys
    property alias targetCheckedKeys: __targetList.checkedKeys
    property alias defaultSourceCheckedKeys: __sourceList.defaultCheckedKeys
    property alias defaultTargetCheckedKeys: __targetList.defaultCheckedKeys
    readonly property alias sourceCount: __sourceList.totalCount
    readonly property alias targetCount: __targetList.totalCount
    readonly property int sourceCheckedCount: sourceCheckedKeys.length
    readonly property int targetCheckedCount: targetCheckedKeys.length
    property var titles: ['Source', 'Target']
    property var operations: ['>', '<']
    property bool showSearch: false
    property var filterOption: (value, record) => String(record.title).includes(value)
    property string searchPlaceholder: 'Search here'
    property var pagination: false ?? {}
    property bool oneWay: false
    property font titleFont: Qt.font({
                                         family: themeSource.fontFamilyTitle,
                                         pixelSize: parseInt(themeSource.fontSizeTitle)
                                     })
    property color colorTitle: themeSource.colorColumnTitle
    property color colorText: themeSource.colorText
    property color colorBg: themeSource.colorBg
    property color colorBorder: themeSource.colorBorder
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property var themeSource: MosTheme.MosTransfer

    property alias sourceTableView: __sourceList.view
    property alias targetTableView: __targetList.view

    property Component titleDelegate: RowLayout {
        MosText {
            Layout.alignment: Qt.AlignLeft
            leftPadding: 8
            font: root.titleFont
            text: numberText + qsTr('项')
            color: root.colorTitle
            verticalAlignment: Text.AlignVCenter
            property string numberText: onLeft ? `${root.sourceCheckedCount}/${root.sourceCount} ` :
                                                 `${root.targetCheckedCount}/${root.targetCount} `
        }

        MosText {
            Layout.alignment: Qt.AlignRight
            rightPadding: 8
            font: root.titleFont
            text: title
            color: root.colorTitle
            verticalAlignment: Text.AlignVCenter
        }
    }
    property Component searchInputDelegate: MosInput {
        animationEnabled: root.animationEnabled
        iconSource: MosIcon.SearchOutlined
        placeholderText: root.searchPlaceholder
        clearEnabled: true
        onTextChanged: root.filter(text, onLeft ? 'left' : 'right');
    }
    property Component rightActionDelegate: MosButton {
        padding: 8 * sizeRatio
        topPadding: 4 * sizeRatio
        bottomPadding: 4 * sizeRatio
        animationEnabled: root.animationEnabled
        text: root.operations[0]
        type: MosButton.Type_Primary
        enabled: root.sourceCheckedKeys.length > 0 && root.enabled
        onClicked: {
            targetKeys = [...sourceCheckedKeys, ...targetKeys];
            root.clearAllCheckedKeys('left');
            root.change(targetKeys, 'right', [...sourceCheckedKeys]);
        }
    }
    property Component leftActionDelegate: MosButton {
        padding: 8 * sizeRatio
        topPadding: 4 * sizeRatio
        bottomPadding: 4 * sizeRatio
        animationEnabled: root.animationEnabled
        text: root.operations[1]
        type: MosButton.Type_Primary
        enabled: root.targetCheckedKeys.length > 0 && root.enabled && !root.oneWay
        visible: !root.oneWay
        onClicked: {
            const targetKeysSet = new Set;
            targetCheckedKeys.forEach(key => targetKeysSet.add(key));
            targetKeys = targetKeys.filter(key => !targetKeysSet.has(key));
            root.clearAllCheckedKeys('right');
            root.change(targetKeys, 'left', targetKeysSet.keys());
        }
    }
    property Component emptyDelegate: MosEmpty { description: qsTr('暂无数据') }

    function clearAllCheckedKeys(direction = 'left') {
        if (direction === 'left') {
            sourceTableView.clearAllCheckedKeys();
        } else {
            targetTableView.clearAllCheckedKeys();
        }
    }

    function filter(text: string, direction = 'left') {
        if (direction === 'left') {
            __sourceList.filterString = text;
            __sourceList.filter();
        } else {
            __targetList.filterString = text;
            __targetList.filter();
        }
    }

    onTargetKeysChanged: __private.resetData();

    objectName: '__MosTransfer__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    spacing: 4
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize)
    }
    contentItem: RowLayout {
        spacing: root.spacing

        TransferList {
            id: __sourceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.titles[0]
            onLeft: true
        }

        Column {
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            Loader {
                sourceComponent: root.rightActionDelegate
            }

            Loader {
                sourceComponent: root.leftActionDelegate
            }
        }

        TransferList {
            id: __targetList
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.titles[1]
            onLeft: false
        }
    }

    QtObject {
        id: __private

        property alias sourceData: __sourceList.initData
        property var sourceKeys: []
        property alias targetData: __targetList.initData

        function resetData() {
            const targetKeysSet = new Set;
            const __sourceData = [], __sourceKeys = [], __targetData = [];
            targetKeys.forEach(key => targetKeysSet.add(key));
            root.dataSource.forEach(
                        object => {
                            if (object.hasOwnProperty('key')) {
                                if (targetKeysSet.has(object.key)) {
                                    __targetData.push(object);
                                } else {
                                    __sourceData.push(object);
                                    __sourceKeys.push(object.key);
                                }
                            }
                        });
            sourceData = __sourceData;
            sourceKeys = __sourceKeys;
            targetData = __targetData;

            __sourceList.filter();
            __targetList.filter();
        }
    }

    component TransferList: T.Control {
        id: __transferListRoot

        property var initData: []
        property var filteredData: []
        property string filterString: ''

        property alias totalCount: __pagination.total
        property alias view: __transferView
        property alias onLeft: __transferView.onLeft
        property alias title: __transferView.title
        property alias rowCount: __transferView.rowCount
        property alias checkedKeys: __transferView.checkedKeys
        property alias defaultCheckedKeys: __transferView.defaultCheckedKeys
        property alias initModel: __transferView.initModel

        function filter() {
            let data = initData;
            if (root.showSearch && filterString !== '') {
                data = data.filter(item => root.filterOption(filterString, item));
            }
            filteredData = data;
            refreshData();
        }

        function refreshData() {
            if (typeof root.pagination === 'object') {
                const start = __pagination.currentPageIndex * __pagination.pageSize;
                const end = start + __pagination.pageSize;
                __transferView.initModel = filteredData.slice(start, end);
            } else {
                __transferView.initModel = filteredData;
            }
        }

        padding: background.border.width
        topPadding: Math.max(8, root.radiusBg.topLeft, root.radiusBg.topRight)
        bottomPadding: Math.max(8, root.radiusBg.bottomLeft, root.radiusBg.bottomRight)
        contentItem: ColumnLayout {
            spacing: 0

            Loader {
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.fillWidth: true
                active: root.showSearch
                visible: active
                sourceComponent: root.searchInputDelegate
                property bool onLeft: __transferView.onLeft
            }

            MosTableView {
                id: __transferView
                Layout.fillWidth: true
                Layout.fillHeight: true
                animationEnabled: root.animationEnabled
                themeSource: root.themeSource
                color: root.colorBg
                colorColumnHeaderBg: 'transparent'
                columnResizable: false
                showRowHeader: false
                defaultColumnHeaderHeight: 32
                minimumRowHeight: 32
                topLeftRadius: 0
                topRightRadius: 0
                columnHeaderFilterIconDelegate: null
                columnHeaderTitleDelegate: Loader{
                    sourceComponent: root.titleDelegate
                    property bool onLeft: __transferView.onLeft
                    property string title: __transferView.title
                }
                columns: [
                    {
                        width: __transferView.width,
                        title: __transferView.title,
                        delegate: __textDelegate,
                        dataIndex: 'title',
                        selectionType: 'checkbox',
                    }
                ]

                property bool onLeft: true
                property string title: ''

                Component {
                    id: __textDelegate

                    MosText {
                        leftPadding: 8
                        font: root.font
                        text: cellData
                        color: enabled ? root.colorText : root.themeSource.colorTextDisabled
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: {
                                __transferView.toggleForRows([row]);
                            }
                        }
                    }
                }

                Loader {
                    anchors.top: parent.top
                    anchors.topMargin: parent.defaultColumnHeaderHeight
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: parent.rowCount === 0
                    sourceComponent: root.emptyDelegate
                }
            }

            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                active: typeof root.pagination === 'object'
                visible: active
                sourceComponent: MosDivider { }
            }

            MosPagination {
                id: __pagination
                Layout.topMargin: 8
                Layout.alignment: Qt.AlignHCenter
                clip: true
                visible: typeof root.pagination === 'object'
                sizeHint: 'small'
                animationEnabled: root.animationEnabled
                total: __transferListRoot.filteredData.length
                pageSize: root.pagination?.pageSize ?? 10
                pageButtonMaxCount: root.pagination?.pageButtonMaxCount ?? 7
                showQuickJumper: root.pagination?.showQuickJumper ?? false
                defaultButtonSpacing: root.pagination?.defaultButtonSpacing ?? 8 * sizeRatio
                onCurrentPageIndexChanged: __transferListRoot.refreshData();
            }
        }
        background: MosRectangleInternal {
            color: root.colorBg
            border.color: root.colorBorder
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        }
    }
}
