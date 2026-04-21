import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    signal click(index: int, data: var)
    signal clickMenu(deep: int, key: string, keyPath: var, data: var)

    property bool animationEnabled: MosTheme.animationEnabled
    property var initModel: []
    readonly property int count: __listModel.count
    property string separator: '/'
    property alias titleFont: root.font
    property int defaultIconSize: themeSource.fontSize + 2
    property int defaultMenuWidth: 120
    property MosRadius radiusItemBg: MosRadius { all: themeSource.radiusItemBg }
    property var themeSource: MosTheme.MosBreadcrumb

    property Component itemDelegate: MosRectangleInternal {
        id: __itemDelegate

        implicitWidth: __itemRow.implicitWidth + 8
        implicitHeight: Math.max(__icon.implicitHeight, __text.implicitHeight) + 4
        radius: root.radiusItemBg.all
        topLeftRadius: root.radiusItemBg.topLeft
        topRightRadius: root.radiusItemBg.topRight
        bottomLeftRadius: root.radiusItemBg.bottomLeft
        bottomRightRadius: root.radiusItemBg.bottomRight

        color: isCurrent || !__hoverHandler.hovered ? root.themeSource.colorBgLast :
                                                      root.themeSource.colorBg;

        property int __index: index
        property var menu: model.menu ?? {}
        property var menuItem: menu.items ?? []

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

        Row {
            id: __itemRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            MosIconText {
                id: __icon
                anchors.verticalCenter: parent.verticalCenter
                color: isCurrent || __hoverHandler.hovered ? root.themeSource.colorIconLast :
                                                             root.themeSource.colorIcon;
                iconSize: model.iconSize
                iconSource: model.loading ? MosIcon.LoadingOutlined : model.iconSource
                verticalAlignment: Text.AlignVCenter

                NumberAnimation on rotation {
                    running: model.loading
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 1000
                }

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
            }

            MosCopyableText {
                id: __text
                anchors.verticalCenter: parent.verticalCenter
                text: model.title
                font: root.titleFont
                enabled: isCurrent
                color: __icon.color

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
            }

            Loader {
                anchors.verticalCenter: parent.verticalCenter
                active: __itemDelegate.menuItem.length > 0
                sourceComponent: MosIconText {
                    color: isCurrent || __hoverHandler.hovered ? root.themeSource.colorIconLast :
                                                                 root.themeSource.colorIcon;
                    iconSource: MosIcon.DownOutlined
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
                }
            }
        }

        HoverHandler {
            id: __hoverHandler
            cursorShape: !isCurrent ? Qt.PointingHandCursor : Qt.ArrowCursor
            onHoveredChanged: {
                if (hovered) __private.hover(index);
            }
        }

        TapHandler {
            id: __tapHandler
            enabled: !isCurrent
            onTapped: root.click(index, model);
        }

        Loader {
            active: __itemDelegate.menuItem.length > 0
            sourceComponent: MosContextMenu {
                id: __menu
                parent: __itemDelegate
                showToolTip: true
                initModel: __itemDelegate.menuItem
                defaultMenuWidth: __itemDelegate.menu.width ?? root.defaultMenuWidth
                closePolicy: MosPopup.NoAutoClose | MosPopup.CloseOnPressOutsideParent | MosPopup.CloseOnEscape
                onHoveredChanged: {
                    if (hovered) {
                        x = (parent.width - implicitWidth) * 0.5;
                        y = parent.height + 2;
                        open();
                    }
                }
                onClickMenu: (deep, key, keyPath, data) => root.clickMenu(deep, key, keyPath, data);
                Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
                property bool hovered: __hoverHandler.hovered

                Connections {
                    target: __private
                    function onHover(index) {
                        if (__itemDelegate.__index !== index && __menu.opened) {
                            __menu.close();
                        }
                    }
                }
            }
        }
    }
    property Component separatorDelegate: MosText {
        text: model.separator ?? ''
        color: root.themeSource.colorIcon
    }

    function get(index: int) {
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

    function append(object: var) {
        __listModel.append(__private.initObject(object));
    }

    function remove(index: int, count = 1) {
        __listModel.remove(index, count);
    }

    function clear() {
        __listModel.clear();
    }

    function reset() {
        clear();
        for (const object of initModel) {
            append(object);
        }
    }

    function getPath() {
        let path = '';
        for (let i = 0; i < __listModel.count; i++) {
            path += __listModel.get(i).title + ((i + 1 != count) ? __listModel.get(i).separator : '');
        }
        return path;
    }

    onInitModelChanged: reset();

    objectName: '__MosBreadcrumb__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 0
    spacing: 4
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    contentItem: ListView {
        id: __listView
        implicitHeight: 30
        orientation: ListView.Horizontal
        model: ListModel { id: __listModel }
        clip: true
        spacing: root.spacing
        boundsBehavior: ListView.StopAtBounds
        add: Transition {
            NumberAnimation {
                properties: 'opacity'
                from: 0
                to: 1
                duration: root.animationEnabled ? MosTheme.Primary.durationFast : 0
            }
        }
        remove: Transition {
            NumberAnimation {
                properties: 'opacity'
                from: 1
                to: 0
                duration: root.animationEnabled ? MosTheme.Primary.durationFast : 0
            }
        }
        delegate: Item {
            id: __rootItem
            width: __row.implicitWidth
            height: __listView.height

            required property int index
            required property var model
            property bool isCurrent: (index + 1) === __listModel.count

            Row {
                id: __row
                height: parent.height
                spacing: root.spacing

                Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: model.itemDelegate
                    property alias index: __rootItem.index
                    property alias model: __rootItem.model
                    property alias isCurrent: __rootItem.isCurrent
                }

                Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    active: index + 1 !== __listModel.count
                    sourceComponent: model.separatorDelegate
                    property alias index: __rootItem.index
                    property alias model: __rootItem.model
                    property alias isCurrent: __rootItem.isCurrent
                }
            }
        }
    }

    QtObject {
        id: __private

        signal hover(index: int)

        function initObject(object: var): var {
            if (!object.hasOwnProperty('title')) object.title = '';

            if (!object.hasOwnProperty('iconSource')) object.iconSource = 0;
            if (!object.hasOwnProperty('iconUrl')) object.iconUrl = '';
            if (!object.hasOwnProperty('iconSize')) object.iconSize = root.defaultIconSize;
            if (!object.hasOwnProperty('loading')) object.loading = false;

            if (!object.hasOwnProperty('separator')) object.separator = root.separator;
            if (!object.hasOwnProperty('itemDelegate')) object.itemDelegate = root.itemDelegate;
            if (!object.hasOwnProperty('separatorDelegate')) object.separatorDelegate = root.separatorDelegate;

            if (!object.hasOwnProperty('menu')) object.menu = {};

            return object;
        }
    }
}
