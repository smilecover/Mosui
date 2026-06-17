import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    signal activated(key: string, index: int)

    property bool animationEnabled: MosTheme.animationEnabled
    property int hoverCursorShape: Qt.PointingHandCursor
    property var initModel: []
    property alias count: __listModel.count
    property bool accordion: false
    property var activeKey: accordion ? '' : []
    property var defaultActiveKey: []
    property var expandIcon: MosIcon.RightOutlined || ''
    property font titleFont: Qt.font({
                                         family: themeSource.fontFamily,
                                         pixelSize: parseInt(themeSource.fontSizeTitle)
                                     })
    property font contentFont: Qt.font({
                                           family: themeSource.fontFamily,
                                           pixelSize: parseInt(themeSource.fontSizeContent)
                                       })
    property color colorBg: themeSource.colorBg
    property color colorIcon: themeSource.colorIcon
    property color colorTitle: themeSource.colorTitle
    property color colorTitleBg: themeSource.colorTitleBg
    property color colorContent: themeSource.colorContent
    property color colorContentBg: themeSource.colorContentBg
    property color colorBorder: themeSource.colorBorder
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property var themeSource: MosTheme.MosCollapse

    property Component titleDelegate: Row {
        leftPadding: 16
        rightPadding: 16
        height: Math.max(40, __icon.height, __title.height)
        spacing: 8

        MosIconText {
            id: __icon
            anchors.verticalCenter: parent.verticalCenter
            iconSource: root.expandIcon
            colorIcon: root.colorIcon
            rotation: isActive ? 90 : 0

            Behavior on rotation { enabled: root.animationEnabled; RotationAnimation { duration: MosTheme.Primary.durationFast } }
        }

        MosText {
            id: __title
            anchors.verticalCenter: parent.verticalCenter
            text: model.title
            elide: Text.ElideRight
            font: root.titleFont
            color: root.colorTitle
        }

        HoverHandler {
            cursorShape: root.hoverCursorShape
        }
    }
    property Component contentDelegate: MosCopyableText {
        padding: 16
        topPadding: 8
        bottomPadding: 8
        text: model.content
        font: root.contentFont
        wrapMode: Text.WordWrap
        color: root.colorContent
    }

    function get(index) {
        return __listModel.get(index);
    }

    function set(index, object) {
        __listModel.set(index, object);
    }

    function setProperty(index, propertyName, value) {
        __listModel.setProperty(index, propertyName, value);
    }

    function move(from, to, count = 1) {
        __listModel.move(from, to, count);
    }

    function insert(index, object) {
        __listModel.insert(index, object);
    }

    function append(object) {
        __listModel.append(object);
    }

    function remove(index, count = 1) {
        __listModel.remove(index, count);
    }

    function clear() {
        __listModel.clear();
    }

    onInitModelChanged: {
        clear();
        /**
         * [Warning]
         * ListModel 的静态角色类型下, 如果某一条数据了单独的内容代理, 就必须同时为其他数据设置默认代理,
         * 所以我们这里需要进行两遍遍历, (另一种方式是设置 dynamicRoles, 但会大幅降低性能)
         */
        const hasContentDelegate = initModel.some(item => 'contentDelegate' in item);
        for (const object of initModel) {
            if (hasContentDelegate && !object.hasOwnProperty('contentDelegate')) {
                object.contentDelegate = root.contentDelegate;
            }
            append(object);
        }
    }

    objectName: '__MosCollapse__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    spacing: -1
    contentItem: ListView {
        id: __listView
        property real realHeight: 0
        implicitHeight: contentHeight
        interactive: false
        spacing: root.spacing
        model: ListModel { id: __listModel }
        onContentHeightChanged: realHeight = Math.max(contentHeight, 0);
        onRealHeightChanged: cacheBuffer = realHeight;
        delegate: MosRectangleInternal {
            id: __rootItem
            width: __listView.width
            height: __column.height + ((detached && active) ? 1 : 0)
            topLeftRadius: (isStart || detached) ? root.radiusBg.topLeft : 0
            topRightRadius: (isStart || detached) ? root.radiusBg.topRight : 0
            bottomLeftRadius: (isEnd || detached) ? root.radiusBg.bottomLeft : 0
            bottomRightRadius: (isEnd || detached) ? root.radiusBg.bottomRight : 0
            color: root.colorBg
            border.color: root.colorBorder
            border.width: detached ? 1 : 0
            clip: true

            required property var model
            required property int index
            property bool isStart: index == 0
            property bool isEnd: (index + 1) === root.count
            property bool active: false
            property bool detached: __listView.spacing !== -1

            Component.onCompleted: {
                if (root.defaultActiveKey.indexOf(model.key) != -1)
                    active = true;
            }

            Column {
                id: __column
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                MosRectangleInternal {
                    width: parent.width
                    height: __titleLoader.height
                    topLeftRadius: (isStart || detached) ? root.radiusBg.topLeft : 0
                    topRightRadius: (isStart || detached) ? root.radiusBg.topRight : 0
                    bottomLeftRadius: (isEnd && !active) || (detached && !active) ? root.radiusBg.bottomLeft : 0
                    bottomRightRadius: (isEnd && !active) || (detached && !active) ? root.radiusBg.bottomRight : 0
                    color: root.colorTitleBg
                    border.color: root.colorBorder

                    Loader {
                        id: __titleLoader
                        width: parent.width
                        sourceComponent: titleDelegate
                        property alias model: __rootItem.model
                        property alias index: __rootItem.index
                        property alias isActive: __rootItem.active

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: {
                                if (root.accordion) {
                                    for (let i = 0; i < __listView.count; i++) {
                                        const item = __listView.itemAtIndex(i);
                                        if (item && item !== __rootItem) {
                                            item.active = false;
                                        }
                                    }
                                    __rootItem.active = !__rootItem.active;
                                } else {
                                    __rootItem.active = !__rootItem.active;
                                }
                                if (__rootItem.active) {
                                    root.activated(__rootItem.model.key, __rootItem.index);
                                }
                                __private.calcActiveKey();
                            }
                        }
                    }
                }

                MosRectangleInternal {
                    width: parent.width - __rootItem.border.width * 2
                    height: active ? __contentLoader.height : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    bottomLeftRadius: root.radiusBg.bottomLeft
                    bottomRightRadius: root.radiusBg.bottomRight
                    color: root.colorContentBg
                    clip: true

                    Behavior on height { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }

                    Loader {
                        id: __contentLoader
                        width: parent.width
                        anchors.centerIn: parent
                        sourceComponent: model?.contentDelegate ?? root.contentDelegate
                        property alias model: __rootItem.model
                        property alias index: __rootItem.index
                        property alias isActive: __rootItem.active
                    }
                }
            }
        }
    }
    background: Loader {
        z: 1
        active: root.spacing === -1
        sourceComponent: Rectangle {
            color: 'transparent'
            border.color: root.colorBorder
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
        }
    }

    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorTitle { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorTitleBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorContent { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorContentBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

    QtObject {
        id: __private
        function calcActiveKey() {
            if (root.accordion) {
                for (let i = 0; i < __listView.count; i++) {
                    const item = __listView.itemAtIndex(i);
                    if (item && item.active) {
                        root.activeKey = item.model.key;
                        break;
                    }
                }
            } else {
                let keys = [];
                for (let i = 0; i < __listView.count; i++) {
                    const item = __listView.itemAtIndex(i);
                    if (item && item.active) {
                        keys.push(item.model.key);
                    }
                }
                root.activeKey = keys;
            }
        }
    }
}
