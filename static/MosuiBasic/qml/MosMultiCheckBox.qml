import QtQuick
import QtQuick.Templates as T
import MosuiBasic

MosSelect {
    id: root

    signal search(input: string)
    signal select(option: var)
    signal deselect(option: var)

    property var options: []
    property var filterOption: (input, option) => true
    property alias text: __input.text
    property string prefix: ''
    property string suffix: ''
    property bool genDefaultKey: true
    property var defaultSelectedKeys: []
    property var selectedKeys: []
    property alias searchEnabled: root.editable
    readonly property alias tagCount: __tagListModel.count
    property int maxTagCount: -1
    property int tagSpacing: 5 * sizeRatio
    property real itemWidth: 120 * sizeRatio
    property real itemHeight: 30 * sizeRatio
    property real defaultPopupWidth: width
    property color colorTagText: enabled ? themeSource.colorTagText :
                                           themeSource.colorTagTextDisabled
    property color colorTagBg: themeSource.colorTagBg
    property MosRadius radiusTagBg: MosRadius { all: themeSource.radiusTagBg }

    property Component prefixDelegate: MosText {
        font: root.font
        text: root.prefix
        color: root.themeSource.colorText
    }
    property Component suffixDelegate: MosText {
        font: root.font
        text: root.suffix
        color: root.themeSource.colorText
    }
    property Component tagDelegate: MosRectangleInternal {
        id: __tag

        required property int index
        required property var tagData

        implicitWidth: __row.implicitWidth + 16 * root.sizeRatio
        implicitHeight: Math.max(__text.implicitHeight, __closeIcon.implicitHeight) + 4 * root.sizeRatio
        radius: root.radiusTagBg.all
        topLeftRadius: root.radiusTagBg.topLeft
        topRightRadius: root.radiusTagBg.topRight
        bottomLeftRadius: root.radiusTagBg.bottomLeft
        bottomRightRadius: root.radiusTagBg.bottomRight
        color: root.colorTagBg

        MouseArea {
            anchors.fill: parent
        }

        Row {
            id: __row
            anchors.centerIn: parent
            spacing: 5 * root.sizeRatio

            MosText {
                id: __text
                anchors.verticalCenter: parent.verticalCenter
                text: __tag.tagData.label
                font: root.font
                color: root.colorTagText

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
            }

            MosIconText {
                id: __closeIcon
                anchors.verticalCenter: parent.verticalCenter
                colorIcon: __hoverHander.hovered ? root.themeSource.colorTagCloseHover : root.themeSource.colorTagClose
                iconSize: (parseInt(root.themeSource.fontSize) - 2) * root.sizeRatio
                iconSource: MosIcon.CloseOutlined
                verticalAlignment: Text.AlignVCenter

                Behavior on colorIcon { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

                HoverHandler {
                    id: __hoverHander
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: __tapHander
                    onTapped: {
                        root.removeTagAtIndex(__tag.index);
                    }
                }
            }
        }
    }

    function findKey(key: string): var {
        return __private.findKey(key);
    }

    function filter() {
        model = options.filter(option => filterOption(text, option) === true);
    }

    function insertTag(index: int, key: string) {
        const data = findKey(key);
        if (data !== undefined) {
            __private.insert(index, key, data);
        }
    }

    function appendTag(key: string) {
        const data = findKey(key);
        if (data !== undefined) {
            __private.append(key, data);
        }
    }

    function removeTagAtKey(key: string) {
        __private.remove(key);
    }

    function removeTagAtIndex(index: int) {
        if (index >= 0 && index < __tagListModel.count) {
            __private.removeAtIndex(index);
        }
    }

    function clearTag() {
        __private.clear();
    }

    function clearInput() {
        __input.clear();
        __input.textEdited();
    }

    function openPopup() {
        if (!__popup.opened)
            __popup.open();
    }

    function closePopup() {
        __popup.close();
    }

    onOptionsChanged: {
        if (genDefaultKey) {
            options.forEach(
                        (item, index) => {
                            if (!item.hasOwnProperty('key')) {
                                item.key = item.label;
                            }
                        });
        }
        if (defaultSelectedKeys.length > 0) {
            const keysSet = new Set;
            defaultSelectedKeys.forEach(key => keysSet.add(key));
            options.forEach(
                        item => {
                            if (item.key && keysSet.has(item.key)) {
                                __private.append(item.key, item, false);
                                keysSet.delete(item.key);
                            }
                        });
        }
        filter();
    }
    onFilterOptionChanged: {
        filter();
    }

    Behavior on colorTagText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorTagBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

    objectName: '__MosMultiCheckBox__'
    themeSource: MosTheme.MosMultiCheckBox
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    active: hovered || visualFocus || __input.hovered || __input.activeFocus
    editable: true
    topPadding: 4 * sizeRatio
    bottomPadding: 4 * sizeRatio
    leftPadding: 2 * sizeRatio
    clearEnabled: false
    contentItem: Item {
        implicitHeight: Math.max(__flow.implicitHeight, 22 * root.sizeRatio)

        Loader {
            id: __prefixLoader
            anchors.left: parent.left
            anchors.leftMargin: 5 * root.sizeRatio
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.prefixDelegate
        }

        Loader {
            id: __suffixLoader
            anchors.right: parent.right
            anchors.rightMargin: 5 * root.sizeRatio
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.suffixDelegate
        }

        MosInput {
            id: __input
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: __flow.left
            anchors.leftMargin: 2 * root.sizeRatio
            anchors.right: __flow.right
            background: Item { }
            animationEnabled: root.animationEnabled
            sizeRatio: root.sizeRatio
            colorText: root.themeSource.colorText
            placeholderTextColor: root.themeSource.colorTextDisabled
            placeholderText: (__tagListModel.count > 0 || length > 0) ? '' : root.placeholderText
            font: root.font
            readOnly: !root.searchEnabled
            onTextEdited: {
                root.search(text);
                root.filter();
                if (root.model.length > 0)
                    root.openPopup();
                else
                    root.closePopup();
            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Backspace) {
                    if (length === 0 && __tagListModel.count > 0) {
                        root.removeTagAtIndex(__tagListModel.count - 1);
                    }
                }
            }

            TapHandler {
                onTapped: {
                    if (root.popup.opened) {
                        root.popup.close();
                    } else {
                        root.popup.open();
                    }
                }
            }
        }

        Flow {
            id: __flow
            anchors.left: __prefixLoader.right
            anchors.leftMargin: 4 * root.sizeRatio
            anchors.right: __suffixLoader.left
            anchors.rightMargin: 4 * root.sizeRatio
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.tagSpacing
            onPositioningComplete: {
                const item = __tagRepeater.itemAt(__tagListModel.count - 1);
                __input.leftPadding = item ? (item.x + item.width + 5 * root.sizeRatio) : 0;
                __input.topPadding = item ? item.y : 0;
            }

            Repeater {
                id: __tagRepeater
                model: ListModel { id: __tagListModel }
                delegate: root.tagDelegate
            }
        }
    }
    popup: MosPopup {
        id: __popup
        x: (root.width - width) * 0.5
        y: root.height + 2
        implicitWidth: implicitContentWidth + leftPadding + rightPadding
        implicitHeight: implicitContentHeight + topPadding + bottomPadding
        leftPadding: 4 * root.sizeRatio
        rightPadding: 4 * root.sizeRatio
        topPadding: 6 * root.sizeRatio
        bottomPadding: 6 * root.sizeRatio
        animationEnabled: root.animationEnabled
        radiusBg: root.radiusPopupBg
        colorBg: MosTheme.isDark ? root.themeSource.colorPopupBgDark : root.themeSource.colorPopupBg
        transformOrigin: isTop ? Item.Bottom : Item.Top
        enter: Transition {
            NumberAnimation {
                property: 'scale'
                from: 0.9
                to: 1.0
                easing.type: Easing.OutQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
            NumberAnimation {
                property: 'opacity'
                from: 0.0
                to: 1.0
                easing.type: Easing.OutQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: 'scale'
                from: 1.0
                to: 0.9
                easing.type: Easing.InQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
            NumberAnimation {
                property: 'opacity'
                from: 1.0
                to: 0.0
                easing.type: Easing.InQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
        }
        contentItem: GridView {
            id: __popupGridView
            implicitWidth: root.defaultPopupWidth
            implicitHeight: Math.min(root.defaultPopupMaxHeight, contentHeight)
            clip: true
            model: root.popup.visible ? root.model : null
            currentIndex: root.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: root.itemWidth
            cellHeight: root.itemHeight
            delegate: MosCheckBox {
                id: __popupDelegate

                required property var model
                required property int index
                readonly property string key: model.key
                readonly property bool selected: __private.selectedKeysMap.has(key)

                width: __popupGridView.cellWidth
                height: __popupGridView.cellHeight
                leftPadding: 8 * root.sizeRatio
                rightPadding: 8 * root.sizeRatio
                topPadding: 5 * root.sizeRatio
                bottomPadding: 5 * root.sizeRatio
                checked: selected
                enabled: (model.enabled ?? true) && ((!selected && root.maxTagCount >= 0) ? (__tagListModel.count < root.maxTagCount) : true)
                text: __popupDelegate.model[root.textRole]
                colorText: __popupDelegate.enabled ? root.themeSource.colorItemText :
                                                     root.themeSource.colorItemTextDisabled
                font {
                    family: root.themeSource.fontFamily
                    pixelSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
                    weight: selected ? Font.DemiBold : Font.Normal
                }
                elide: Text.ElideRight
                onClicked: {
                    root.currentIndex = index;
                    const data = __popupDelegate.model.modelData;
                    const key = data.key;
                    if (__private.contains(key)) {
                        __private.remove(key);
                    } else {
                        __private.append(key, data);
                    }
                }

                HoverHandler {
                    cursorShape: root.hoverCursorShape
                }

                Loader {
                    y: __popupDelegate.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: root.showToolTip
                    sourceComponent: root.toolTipDelegate
                    property alias index: __popupDelegate.index
                    property alias model: __popupDelegate.model
                    property alias hovered: __popupDelegate.hovered
                    property alias pressed: __popupDelegate.pressed
                }
            }
            T.ScrollBar.vertical: MosScrollBar {
                animationEnabled: root.animationEnabled
            }
        }
        property bool isTop: (y + height * 0.5) < root.height * 0.5
    }

    QtObject {
        id: __private

        property var selectedKeysMap: new Map

        function contains(key: string) {
            return selectedKeysMap.has(key);
        }

        function clear() {
            selectedKeysMap.forEach((value, key) => root.deselect(value));
            __tagListModel.clear();
            selectedKeysMap.clear();
            selectedKeysMapChanged();
        }

        function insert(index: int, key: string, data: var, emit = true) {
            if (!selectedKeysMap.has(key)) {
                __tagListModel.insert(index, { '__related__': key, 'tagData': data });
                selectedKeysMap.set(key, data);
                selectedKeysMapChanged();
                if (emit) {
                    root.select(data);
                }
            }
        }

        function append(key: string, data: var, emit = true) {
            if (!selectedKeysMap.has(key)) {
                __tagListModel.append({ '__related__': key, 'tagData': data });
                selectedKeysMap.set(key, data);
                selectedKeysMapChanged();
                if (emit) {
                    root.select(data);
                }
            }
        }

        function remove(key: string, emit = true) {
            for (let i = 0; i < __tagListModel.count; i++) {
                if (__tagListModel.get(i).__related__ === key) {
                    const relatedKey = __tagListModel.get(i).__related__;
                    const data = selectedKeysMap.get(relatedKey);
                    __tagListModel.remove(i);
                    selectedKeysMap.delete(relatedKey);
                    selectedKeysMapChanged();
                    if (emit) {
                        root.deselect(data);
                    }
                    break;
                }
            }
        }

        function removeAtIndex(index: int, emit = true) {
            const relatedKey = __tagListModel.get(index).__related__;
            const data = selectedKeysMap.get(relatedKey);
            __tagListModel.remove(index);
            selectedKeysMap.delete(relatedKey);
            selectedKeysMapChanged();
            if (emit) {
                root.deselect(data);
            }
        }

        function findKey(key: string): var {
            const index = root.options.findIndex(item => item.key === key);
            if (index === -1) {
                return undefined;
            } else {
                return root.options[index];
            }
        }

        function updateSelectedKeys() {
            root.selectedKeys = [...selectedKeysMap.keys()];
        }

        onSelectedKeysMapChanged: updateSelectedKeys();
    }
}
