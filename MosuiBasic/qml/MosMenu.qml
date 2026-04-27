import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.Control{
    id: root
    objectName: '__MosMenu__'

    enum CompactMode {
        Mode_Relaxed = 0,
        Mode_Standard = 1,
        Mode_Compact = 2
    }
    property var themeSource: MosTheme.MosMenu

    property color menuColor: "red"

    signal clickMenu(deep: int, key: string, keyPath: var, data: var)

    property bool animationEnabled: MosTheme.animationEnabled

    property bool showEdge: false
    property bool showToolTip: false

    property int compactMode: MosMenu.Mode_Relaxed
    property int compactWidth: {
        switch (compactMode) {
        case MosMenu.Mode_Relaxed: return 0;
        case MosMenu.Mode_Standard: return 80;
        case MosMenu.Mode_Compact: return 52;
        }
    }

    property bool popupMode: false
    property int popupWidth: 200
    property int popupOffset: 4
    property int popupMaxHeight: height
    property int defaultMenuIconSize: font.pixelSize + 2
    property int defaultMenuIconSpacing: 8
    property int defaultMenuWidth: 200
    property int defaultMenuTopPadding: 10
    property int defaultMenuBottomPadding: 10
    property int defaultMenuSpacing: 4
    property var defaultSelectedKeys: []
    property string selectedKey: ''
    property var initModel: []
    property MosRadius radiusMenuBg:  MosRadius { all: root.themeSource.radiusMenuBg }
    property MosRadius radiusPopupBg:  MosRadius { all: root.themeSource.radiusPopupBg }
    property string contentDescription: '' 
    property alias scrollBar: __menuScrollBar

    property Component menuIconDelegate: MosIconText {
        color: menuButton.colorText
        iconSize: menuButton.iconSize   
        iconSource: menuButton.iconSource
        verticalAlignment: Text.AlignVCenter

        Behavior on x {
            enabled: root.animationEnabled
            NumberAnimation { easing.type: Easing.OutCubic; duration: MosTheme.Primary.durationMid }
        }
        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }
    property Component menuLabelDelegate: MosText {
        text: menuButton.text
        font: menuButton.font
        color: menuButton.colorText
        elide: Text.ElideRight

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }
    property Component menuBgDelegate: MosRectangleInternal {
        radius: root.radiusMenuBg.all
        topLeftRadius: root.radiusMenuBg.topLeft
        topRightRadius: root.radiusMenuBg.topRight
        bottomLeftRadius: root.radiusMenuBg.bottomLeft
        bottomRightRadius: root.radiusMenuBg.bottomRight
        color: menuButton.colorBg

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    }
    property Component menuContentDelegate: Item {
        id: __menuContentItem

        property var __menuButton: menuButton
        property bool isVertical: root.compactMode === MosMenu.Mode_Standard && menuButton.menuDeep === 0

        implicitHeight: isVertical ? __columnLayout.implicitHeight : __rowLayout.implicitHeight

        ColumnLayout {
            id: __columnLayout
            visible: __menuContentItem.isVertical
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: menuButton.iconSpacing

            Loader {
                active: __menuContentItem.isVertical
                visible: active
                Layout.alignment: Qt.AlignHCenter
                sourceComponent: menuButton.iconDelegate
                property var model: __menuButton.model
                property alias menuButton: __menuContentItem.__menuButton
            }

            Loader {
                active: __menuContentItem.isVertical
                visible: active
                Layout.alignment: Qt.AlignHCenter
                sourceComponent: menuButton.labelDelegate
                property var model: __menuButton.model
                property alias menuButton: __menuContentItem.__menuButton
            }
        }

        RowLayout {
            id: __rowLayout
            visible: !__menuContentItem.isVertical
            anchors.left: parent.left
            anchors.right: menuButton.expandedVisible ? __expandedIcon.left : parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: menuButton.iconSpacing

            Loader {
                active: !__menuContentItem.isVertical
                visible: active
                sourceComponent: menuButton.iconDelegate
                property var model: __menuButton.model
                property alias menuButton: __menuContentItem.__menuButton
            }

            Loader {
                active: !__menuContentItem.isVertical
                visible: active
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                sourceComponent: menuButton.labelDelegate
                property var model: __menuButton.model
                property alias menuButton: __menuContentItem.__menuButton
            }
        }

        MosIconText {
            id: __expandedIcon
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: menuButton.showExpanded
            // iconSource: (root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode) ? MosIcon.RightOutlined : MosIcon.DownOutlined
            colorIcon: menuButton.colorText
            transform: Rotation {
                origin {
                    x: __expandedIcon.width * 0.5
                    y: __expandedIcon.height * 0.5
                }
                axis {
                    x: 1
                    y: 0
                    z: 0
                }
                angle: (root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode) ? 0 : (menuButton.expanded ? 180 : 0)
                Behavior on angle { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
            }
            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
        }
    }

    function gotoMenu(key: string) {
        __private.gotoMenuKey = key;
        __private.gotoMenu(key);
    }

    function get(index: int): var {
        if (index >= 0 && index < __listView.model.length) {
            return __listView.model[index];
        }
        return undefined;
    }

    function set(index: int, object: var) {
        if (index >= 0 && index < __listView.model.length) {
            __listView.model[index] = object; 
        }
    }

    function setProperty(index: int, propertyName: string, value: var) {
        if (index >= 0 && index < __listView.model.length) {
            __listView.model[index][propertyName] = value;
            __listView.modelChanged();
        }
    }

    function setData(key: string, data: var) {
        __private.setData(key, data);
    }

    function setDataProperty(key: string, propertyName: string, value: var) {
        __private.setDataProperty(key, propertyName, value);
    }

    function move(from: int, to: int, count = 1) {
        if (from >= 0 && from < __listView.model.length && to >= 0 && to < __listView.model.length) {
            const objects = __listView.model.splice(from, count);
            __listView.model.splice(to, 0, ...objects);
            __listView.modelChanged();
        }
    }

    function insert(index: int, object: var) {
        __listView.model.splice(index, 0, object);
        __listView.modelChanged();
    }

    function append(object: var) {
        __listView.model.push(object);
        __listView.modelChanged();
    }

    function remove(index: int, count = 1) {
        if (index >= 0 && index < __listView.model.length) {
            __listView.model.splice(index, count);
            __listView.modelChanged();
        }
    }

    function clear() {
        __private.gotoMenuKey = '';
        __listView.model = [];
    }
    
    function clearSelection() {
    __private.selectedItem = null;
    selectedKey = "";

    // 遍历清掉父级高亮
    for (let i = 0; i < __listView.count; ++i) {
        let item = __listView.itemAtIndex(i);
        if (item) item.clearIsCurrentParent();
    }
}

    onInitModelChanged: {
        __listView.model = initModel;
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 5
    rightPadding: 8
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    clip: true
    wheelEnabled: true
    contentItem: ListView {
        id: __listView
        implicitWidth: (root.compactMode !== MosMenu.Mode_Relaxed ? root.compactWidth : root.defaultMenuWidth) -
                       (root.leftPadding + root.rightPadding)
        implicitHeight: __listView.contentHeight
        boundsBehavior: Flickable.StopAtBounds
        model: []
        delegate: __menuDelegate
        onContentHeightChanged: cacheBuffer = contentHeight;
        T.ScrollBar.vertical: MosScrollBar {
            id: __menuScrollBar
            anchors.rightMargin: -8
            policy: T.ScrollBar.AsNeeded
            animationEnabled: root.animationEnabled
        }
        property int menuDeep: 0
    }
    background: Item {
        Loader {
            width: 1
            height: parent.height
            anchors.right: parent.right
            active: root.showEdge
            sourceComponent: Rectangle {
                color: root.themeSource.colorEdge
            }
        }
    }

    Behavior on width {
        enabled: root.animationEnabled
        NumberAnimation {
            easing.type: Easing.OutCubic
            duration: MosTheme.Primary.durationMid
        }
    }

    Behavior on implicitWidth {
        enabled: root.animationEnabled
        NumberAnimation {
            easing.type: Easing.OutCubic
            duration: MosTheme.Primary.durationMid
        }
    }
    Component {
        id: __menuDelegate

        Item {
            id: __rootItem
            width: ListView.view.width
            height: {
                switch (menuType) {
                case 'item':
                case 'group':
                    return __layout.height;
                case 'divider':
                    return __dividerLoader.height;
                default:
                    return __layout.height;
                }
            }
            clip: true
            Component.onCompleted: {
                if (menuType == 'item' || menuType == 'group') {
                    layerPopup = __private.createPopupList(view.menuDeep);
                    for (let i = 0; i < menuChildren.length; i++) {
                        __childrenListView.model.push(menuChildren[i]);
                    }
                    if (root.defaultSelectedKeys.length !== 0) {
                        if (root.defaultSelectedKeys.indexOf(menuKey) !== -1) {
                            __rootItem.expandParent();
                            __menuButton.clicked();
                        }
                    }
                }
                if (__rootItem.menuKey !== '' && __rootItem.menuKey === __private.gotoMenuKey) {
                    __rootItem.expandParent();
                    __menuButton.clicked();
                }
            }

            required property var modelData
            property alias model: __rootItem.modelData
            property var view: ListView.view
            property string menuKey: model.key || ''
            property string menuType: model.type || 'item'
            property bool menuEnabled: model.enabled === undefined ? true : model.enabled
            property string menuLabel: model.label || ''   
            property string menuShortLabel: model.shortLabel || menuLabel
            property int menuIconSize: model.iconSize || root.defaultMenuIconSize
            property var menuIconSource: model.iconSource || 0
            property int menuIconSpacing: model.iconSpacing || defaultMenuIconSpacing
            property var menuChildren: model.menuChildren || []
            property int menuChildrenLength: menuChildren ? menuChildren.length : 0
            property var menuIconDelegate: model.hasOwnProperty('iconDelegate') ? model.iconDelegate : root.menuIconDelegate
            property var menuLabelDelegate: model.hasOwnProperty('labelDelegate') ? model.labelDelegate : root.menuLabelDelegate
            property var menuContentDelegate: model.hasOwnProperty('contentDelegate') ? model.contentDelegate : root.menuContentDelegate
            property var menuBgDelegate: model.hasOwnProperty('bgDelegate') ? model.bgDelegate : root.menuBgDelegate
            property var parentMenu: view.menuDeep === 0 ? null : view.parentMenu
            property var keyPath: parentMenu ? [...parentMenu.keyPath, menuKey] : [menuKey]
            property bool isCurrent: __private.selectedItem === __rootItem || isCurrentParent
            property bool isCurrentParent: false
            property var layerPopup: null

            function clickMenu() {
                root.clickMenu(view.menuDeep, menuKey, keyPath, model);
            }

            function expandMenu() {
                if (__menuButton.showExpanded) {
                    __menuButton.expanded = true;
                }
                __rootItem.clickMenu();
            }

             /*! 查找当前菜单的根菜单 */
            function findRootMenu() {
                let parent = parentMenu;
                while (parent !== null) {
                    if (parent.parentMenu === null)
                        return parent;
                    parent = parent.parentMenu;
                }
                /*! 根菜单返回自身 */
                return __rootItem;
            }

            /*! 展开当前菜单的所有父菜单 */
            function expandParent() {
                let parent = parentMenu;
                while (parent !== null) {
                    if (parent.parentMenu === null) {
                        parent.expandMenu();
                        return;
                    }
                    parent.expandMenu();
                    parent = parent.parentMenu;
                }
            }

            /*! 清除当前菜单的所有子菜单 */
            function clearIsCurrentParent() {
                isCurrentParent = false;
                for (let i = 0; i < __childrenListView.count; i++) {
                    let item = __childrenListView.itemAtIndex(i);
                    if (item)
                        item.clearIsCurrentParent();
                }
            }

            /*! 选中当前菜单的所有父菜单 */
            function selectedCurrentParentMenu() {
                for (let i = 0; i < __listView.count; i++) {
                    let item = __listView.itemAtIndex(i);
                    if (item)
                        item.clearIsCurrentParent();
                }
                let parent = parentMenu;
                while (parent !== null) {
                    parent.isCurrentParent = true;
                    if (parent.parentMenu === null)
                        return;
                    parent = parent.parentMenu;
                }
            }

            Connections {
                target: __private
                enabled: __rootItem.menuKey !== ''
                ignoreUnknownSignals: true

                function onGotoMenu(key: string) {
                    if (__rootItem.menuKey === key) {
                        __rootItem.expandParent();
                        __menuButton.clicked();
                    }
                }

                function onSetData(key, data) {
                    if (__rootItem.menuKey === key) {
                        __rootItem.model = data;
                        __rootItem.modelChanged();
                    }
                }

                function onSetDataProperty(key, propertyName, value) {
                    if (__rootItem.menuKey === key) {
                        __rootItem.model[propertyName] = value;
                        __rootItem.modelChanged();
                    }
                }
            }

            Loader {
                id: __dividerLoader
                height: 5
                width: parent.width
                active: __rootItem.menuType == 'divider'
                sourceComponent: MosDivider {
                    animationEnabled: root.animationEnabled
                }
            }

            Rectangle {
                id: __layout
                width: parent.width
                height: root.defaultMenuSpacing + __menuButton.height
                        + ((root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode) ? 0 : __childrenListView.height)
                anchors.top: parent.top
                color: (__rootItem.view.menuDeep === 0 ||
                        root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode) ? 'transparent' : root.themeSource.colorChildBg
                visible: __rootItem.menuType == 'item' || __rootItem.menuType == 'group'

                MosMenuButton {
                    id: __menuButton
                    implicitWidth: parent.width
                    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                             implicitContentHeight + topPadding + bottomPadding) + root.defaultMenuSpacing
                    anchors.top: parent.top
                    anchors.topMargin: root.defaultMenuSpacing
                    topPadding: root.defaultMenuTopPadding
                    bottomPadding: root.defaultMenuBottomPadding
                    leftPadding: 12 + (root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode ? 0 : iconSize * __rootItem.view.menuDeep)
                    enabled: __rootItem.menuEnabled
                    radiusBg: root.radiusMenuBg
                    text: {
                        switch (root.compactMode) {
                        case MosMenu.Mode_Relaxed: return __rootItem.menuLabel;
                        case MosMenu.Mode_Standard: return __rootItem.view.menuDeep === 0 ? __rootItem.menuShortLabel : __rootItem.menuLabel;
                        case MosMenu.Mode_Compact: return __rootItem.view.menuDeep === 0 ? '' : __rootItem.menuLabel;
                        }
                    }
                    checkable: true
                    font: root.font
                    iconSize: __rootItem.menuIconSize
                    iconSource: __rootItem.menuIconSource
                    iconSpacing: __rootItem.menuIconSpacing
                    showExpanded: {
                        if (__rootItem.menuType === 'group' ||
                                (root.compactMode !== MosMenu.Mode_Relaxed && __rootItem.view.menuDeep === 0))
                            return false;
                        else
                            return __rootItem.menuChildrenLength > 0;
                    }
                    isCurrent: __rootItem.isCurrent
                    isGroup: __rootItem.menuType === 'group'
                    model: __rootItem.model
                    menuDeep: __rootItem.view.menuDeep
                    iconDelegate: __rootItem.menuIconDelegate
                    labelDelegate: __rootItem.menuLabelDelegate
                    contentDelegate: __rootItem.menuContentDelegate
                    bgDelegate: __rootItem.menuBgDelegate
                    onClicked: {
                        if (__rootItem.menuChildrenLength == 0) {
                            if (__private.selectedItem != __rootItem) {
                                __private.selectedItem = __rootItem;
                                root.selectedKey = __rootItem.menuKey;
                                __rootItem.selectedCurrentParentMenu();
                                if (root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode)
                                    __rootItem.layerPopup.closeWithParent();
                                __rootItem.clickMenu();
                            }
                        } else {
                            if (root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode) {
                                const h = __rootItem.layerPopup.topPadding +
                                        __rootItem.layerPopup.bottomPadding +
                                        __childrenListView.realHeight + 6;
                                const pos = mapToItem(null, 0, 0);
                                const pos2 = mapToItem(root, 0, 0);
                                if ((pos.y + h) > __private.window.height) {
                                    __rootItem.layerPopup.y = Math.max(0, pos2.y - ((pos.y + h) - __private.window.height));
                                } else {
                                    __rootItem.layerPopup.y = pos2.y;
                                }
                                __rootItem.layerPopup.current = __childrenListView;
                                __rootItem.layerPopup.open();
                            }
                            __rootItem.clickMenu();
                        }
                    }

                    MosToolTip {
                        visible: root.showToolTip ? parent.hovered : false
                        animationEnabled: root.animationEnabled
                        position: root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode ? MosToolTip.Position_Right :
                                                                                                      MosToolTip.Position_Bottom
                        text: __rootItem.menuLabel
                        delay: 500
                    }
                }

                ListView {
                    id: __childrenListView
                    visible: __rootItem.menuEnabled
                    parent: {
                        if (__rootItem.layerPopup && __rootItem.layerPopup.current === __childrenListView)
                            return __rootItem.layerPopup.contentItem;
                        else
                            return __layout;
                    }
                    height: {
                        if (__rootItem.menuType == 'group' || __menuButton.expanded)
                            return realHeight;
                        else if (parent != __layout)
                            return parent.height;
                        else
                            return 0;
                    }
                    anchors.top: parent ? (parent == __layout ? __menuButton.bottom : parent.top) : undefined
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: __childrenListView.visible
                    model: []
                    delegate: __menuDelegate
                    onContentHeightChanged: cacheBuffer = contentHeight;
                    T.ScrollBar.vertical: MosScrollBar {
                        id: childrenScrollBar
                        visible: (root.compactMode !== MosMenu.Mode_Relaxed || root.popupMode) && childrenScrollBar.size !== 1
                        animationEnabled: root.animationEnabled
                    }
                    clip: true
                    /* 子 ListView 从父 ListView 的深度累加可实现自动计算 */
                    property int menuDeep: __rootItem.view.menuDeep + 1
                    property var parentMenu: __rootItem
                    property int realHeight: contentHeight

                    Behavior on height {
                        enabled: root.animationEnabled
                        NumberAnimation { duration: MosTheme.Primary.durationFast }
                    }

                    Connections {
                        target: root
                        function onCompactModeChanged() {
                            if (__rootItem.layerPopup) {
                                __rootItem.layerPopup.current = null;
                                __rootItem.layerPopup.close();
                            }
                        }
                        function onPopupModeChanged() {
                            if (__rootItem.layerPopup) {
                                __rootItem.layerPopup.current = null;
                                __rootItem.layerPopup.close();
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: __private

        signal gotoMenu(key: string)
        signal setData(key: string, data: var)
        signal setDataProperty(key: string, propertyName: string, value: var)

        property string gotoMenuKey: ''
        property var window: Window.window
        property var selectedItem: null
        property var popupList: []

        function createPopupList(deep) {
            /*! 为每一层创建一个弹窗 */
            if (popupList[deep] === undefined) {
                let parentPopup = deep > 0 ? popupList[deep - 1] : null;
                popupList[deep] = __popupComponent.createObject(root, { parentPopup: parentPopup });
            }

            return popupList[deep];
        }
    }

    Component {
        id: __popupComponent

        MosPopup {
            width: root.popupWidth
            height: current ? Math.min(root.popupMaxHeight, current.realHeight + topPadding + bottomPadding) : 0
            padding: 5
            animationEnabled: root.animationEnabled
            radiusBg: root.radiusPopupBg
            contentItem: Item { clip: true }
            onAboutToShow: {
                let toX = root.width + root.popupOffset;
                if (parentPopup) {
                    toX += parentPopup.width + root.popupOffset;
                }
                const pos = mapToItem(null, toX, 0);
                if (pos.x + width > __private.window.width) {
                    if (parentPopup) {
                        x = parentPopup.x - parentPopup.width - root.popupOffset;
                    } else {
                        x = -width - root.popupOffset;
                    }
                } else {
                    x = toX;
                }
            }
            property var current: null
            property var parentPopup: null
            function closeWithParent() {
                close();
                let p = parentPopup;
                while (p) {
                    p.close();
                    p = p.parentPopup;
                }
            }
        }
    }

    Accessible.role: Accessible.MenuBar
    Accessible.description: root.contentDescription
}
