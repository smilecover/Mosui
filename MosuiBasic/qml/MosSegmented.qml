import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property var options: []
    property alias currentIndex: __listView.currentIndex
    readonly property var currentValue: get(currentIndex)?.value
    readonly property int count: __listModel.count
    property bool block: false
    property int orientation: Qt.Horizontal
    property real defaultItemHeight: 26 * sizeRatio
    property int iconSpacing: 5
    property font iconFont: Qt.font({
                                        family: 'MOSUI',
                                        pixelSize: root.font.pixelSize
                                    })
    property color colorBg: MosTheme.isDark ? themeSource.colorBgDark : themeSource.colorBg
    property color colorIndicatorBg: themeSource.colorIndicatorBg
    property color colorBorder: themeSource.colorBorder
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosSegmented

    property Component indicatorDelegate: MosRectangleInternal {
        id: __indicator
        color: root.colorIndicatorBg
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }
    property Component itemDelegate: Item {
        id: __itemDelegate
        width: __row.implicitWidth + (root.orientation === Qt.Horizontal ? 20 * root.sizeRatio : 0)
        height: __row.implicitHeight + (root.orientation === Qt.Horizontal ? 0 : 8 * root.sizeRatio)

        property bool hasIcon: model.iconSource !== 0 && model.iconSource !== ''

        Row {
            id: __row
            anchors.centerIn: parent
            spacing: root.iconSpacing

            Loader {
                id: __icon
                height: Math.max(__icon.implicitHeight, __label.implicitHeight)
                anchors.verticalCenter: parent.verticalCenter
                active: __itemDelegate.hasIcon
                sourceComponent: root.iconDelegate
                property int index: __itemDelegate.parent.index
                property var model: __itemDelegate.parent.model
                property bool hovered: __itemDelegate.parent.hovered
                property bool pressed: __itemDelegate.parent.pressed
                property bool isCurrent: __itemDelegate.parent.isCurrent
            }

            MosText {
                id: __label
                anchors.verticalCenter: parent.verticalCenter
                text: model.label
                font: root.font
                color: {
                    if (enabled ) {
                        return (hovered || isCurrent) ? root.themeSource.colorTextSelected :
                                                        root.themeSource.colorText;
                    } else {
                        return root.themeSource.colorTextDisabled;
                    }
                }
            }
        }
    }
    property Component iconDelegate: MosIconText {
        font: root.iconFont
        colorIcon: {
            if (enabled ) {
                return (hovered || isCurrent) ? root.themeSource.colorTextSelected :
                                                root.themeSource.colorText;
            } else {
                return root.themeSource.colorTextDisabled;
            }
        }
        iconSource: model ? model.iconSource : 0
        verticalAlignment: Text.AlignVCenter

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }
    property Component toolTipDelegate: MosToolTip {
        text: model.toolTip
        visible: hovered
    }

    function get(index: int): var {
        return __listModel.get(index);
    }

    function set(index: int, object: var) {
        __listModel.set(index, __private.initObject(object));
    }

    function setProperty(index: int, propertyName: string, value: var) {
        __listModel.setProperty(index, propertyName, value);
    }

    function move(from: int, to: int, count = 1) {
        __listModel.move(from, to, count);
    }

    function insert(index: int, object: var) {
        __listModel.insert(index, __private.initObject(object));
    }

    /*! [QtBug] Can't assign to existing role 'value' of different type [String -> VariantMap] */
    function append(object: var) {
        __listModel.append(__private.initObject(object));
    }

    function remove(index: int, count = 1) {
        __listModel.remove(index, count);
    }

    function clear() {
        __listModel.clear();
    }

    onOptionsChanged: {
        clear();
        for (let object of options) {
            append(object);
        }
    }

    objectName: '__MosSegmented__'
    implicitWidth: block ? parent.width : Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                                   implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 2 * sizeRatio
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    background: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }
    contentItem: Item {
        id: __contentItem
        implicitWidth: __listView.orientation === ListView.Horizontal ? __listView.width : 120 * sizeRatio
        implicitHeight: __listView.orientation === ListView.Horizontal ? root.defaultItemHeight : __listView.height

        ListView {
            id: __listView
            width: orientation === ListView.Horizontal ? (block ? parent.width : contentWidth) : parent.width
            height: orientation === ListView.Horizontal ? parent.height : (block ? parent.height : contentHeight)
            orientation: root.orientation === Qt.Horizontal ? ListView.Horizontal : ListView.Vertical
            highlightMoveDuration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
            highlightResizeDuration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
            boundsBehavior: Flickable.StopAtBounds
            spacing: root.spacing
            onContentWidthChanged: if (orientation === ListView.Horizontal) cacheBuffer = contentWidth;
            onContentHeightChanged: if (orientation === ListView.Vertical) cacheBuffer = contentHeight;
            currentIndex: 0
            model: ListModel { id: __listModel }
            highlight: root.indicatorDelegate
            delegate: MosRectangleInternal {
                id: __rootItem
                implicitWidth: {
                    if (__listView.orientation === ListView.Horizontal) {
                        if (root.block) {
                            return ((__contentItem.width - __listModel.count * __listView.spacing) / __listModel.count );
                        } else {
                            return __itemLoader.implicitWidth;
                        }
                    } else {
                        return __listView.width;
                    }
                }
                implicitHeight: {
                    if (__listView.orientation === ListView.Horizontal) {
                        return __listView.height;
                    } else {
                        if (root.block) {
                            return ((__contentItem.height - __listModel.count * __listView.spacing) / __listModel.count );
                        } else {
                            return __itemLoader.implicitHeight;
                        }
                    }
                }
                topLeftRadius: index === 0 ? root.radiusBg.topLeft : root.radiusBg.all
                topRightRadius: index === (__listModel.count - 1) ? root.radiusBg.topRight : root.radiusBg.all
                bottomLeftRadius: index === 0 ? root.radiusBg.bottomLeft : root.radiusBg.all
                bottomRightRadius: index === (__listModel.count - 1) ? root.radiusBg.bottomRight : root.radiusBg.all
                color: {
                    if (enabled && !isCurrent) {
                        return pressed ? root.themeSource.colorItemBgActive :
                                         hovered ? root.themeSource.colorItemBgHover :
                                                   root.themeSource.colorItemBg;
                    } else {
                        return 'transparent';
                    }
                }
                enabled: model.enabled

                required property int index
                required property var model
                readonly property bool pressed: __tapHandler.pressed
                readonly property bool hovered: __hoverHandler.hovered
                readonly property bool isCurrent: root.currentIndex === index

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

                HoverHandler {
                    id: __hoverHandler
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: __tapHandler
                    cursorShape: Qt.PointingHandCursor
                    onTapped: {
                        __listView.currentIndex = index;
                    }
                }

                Loader {
                    id: __itemLoader
                    anchors.centerIn: parent
                    sourceComponent: root.itemDelegate
                    property alias index: __rootItem.index
                    property alias model: __rootItem.model
                    property alias hovered: __rootItem.hovered
                    property alias pressed: __rootItem.pressed
                    property alias isCurrent: __rootItem.isCurrent
                }

                Loader {
                    anchors.fill: parent
                    active: model.toolTip !== ''
                    sourceComponent: root.toolTipDelegate
                    property alias index: __rootItem.index
                    property alias model: __rootItem.model
                    property alias hovered: __rootItem.hovered
                    property alias pressed: __rootItem.pressed
                    property alias isCurrent: __rootItem.isCurrent
                }
            }
        }
    }

    QtObject {
        id: __private

        function initObject(object: var): var {
            if (typeof object !== 'object') {
                return initObject({ label: String(object) });
            } else {
                if (!object.hasOwnProperty('label')) object.label = '';
                if (!object.hasOwnProperty('value')) object.value = object.label;
                if (!object.hasOwnProperty('enabled')) object.enabled = true;
                if (!object.hasOwnProperty('toolTip')) object.toolTip = '';
                if (!object.hasOwnProperty('iconSource') || object.iconSource == null || object.iconSource === undefined) object.iconSource = 0;

                return object;
            }
        }
    }
}
