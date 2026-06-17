import QtQuick
import QtQuick.Templates as T
import MosuiBasic

MosInput {
    id: root

    signal search(input: string)
    signal select(option: var)

    property var options: []
    property var filterOption: (input, option) => true
    readonly property int count: options.length
    property string textRole: 'label'
    property string valueRole: 'value'
    property bool showToolTip: false
    property int defaultPopupMaxHeight: 240 * root.sizeRatio
    property int defaultOptionSpacing: 0

    property Component labelDelegate: MosText {
        text: textData
        color: root.themeSource.colorItemText
        font {
            family: root.themeSource.fontFamily
            pixelSize: parseInt(root.themeSource.fontSize)
            weight: highlighted ? Font.DemiBold : Font.Normal
        }
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
    property Component labelBgDelegate: Rectangle {
        radius: root.themeSource.radiusLabelBg
        color: highlighted ? root.themeSource.colorItemBgActive :
                             (hovered || selected) ? root.themeSource.colorItemBgHover :
                                                     root.themeSource.colorItemBg;

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    }

    function clearInput() {
        root.clear();
        root.textEdited();
        __popupListView.currentIndex = __popupListView.selectedIndex = -1;
    }

    function openPopup() {
        if (!__popup.opened)
            __popup.open();
    }

    function closePopup() {
        __popup.close();
    }

    function filter() {
        __private.model = options.filter(option => filterOption(text, option) === true);
        __popupListView.currentIndex = __popupListView.selectedIndex = -1;
    }

    onClickClear: {
        root.clearInput();
    }
    onOptionsChanged: {
        root.filter();
    }
    onFilterOptionChanged: {
        root.filter();
    }
    onTextEdited: {
        root.search(text);
        root.filter();
        if (__private.model.length > 0)
            root.openPopup();
        else
            root.closePopup();
    }
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            root.closePopup();
        } else if (event.key === Qt.Key_Up) {
            root.openPopup();
            if (__popupListView.selectedIndex > 0) {
                __popupListView.selectedIndex -= 1;
                __popupListView.positionViewAtIndex(__popupListView.selectedIndex, ListView.Contain);
            } else {
                __popupListView.selectedIndex = __popupListView.count - 1;
                __popupListView.positionViewAtIndex(__popupListView.selectedIndex, ListView.Contain);
            }
        } else if (event.key === Qt.Key_Down) {
            root.openPopup();
            __popupListView.selectedIndex = (__popupListView.selectedIndex + 1) % __popupListView.count;
            __popupListView.positionViewAtIndex(__popupListView.selectedIndex, ListView.Contain);
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (__popupListView.selectedIndex !== -1) {
                const modelData = __private.model[__popupListView.selectedIndex];
                const textData = modelData[root.textRole];
                const valueData = modelData[root.valueRole] ?? textData;
                root.select(modelData);
                root.text = valueData;
                __popup.close();
                root.filter();
            }
        }
    }

    objectName: '__MosAutoComplete__'
    themeSource: MosTheme.MosAutoComplete
    iconPosition: MosInput.Position_Right
    clearEnabled: 'active'

    Item {
        id: __private
        property var window: Window.window
        property var model: []
    }

    TapHandler {
        enabled: root.enabled && !root.readOnly
        onTapped: {
            if (__private.model.length > 0)
                root.openPopup();
        }
    }

    MosPopup {
        id: __popup
        y: root.height + 6
        implicitWidth: root.width
        implicitHeight: implicitContentHeight + topPadding + bottomPadding
        leftPadding: 4 * root.sizeRatio
        rightPadding: 4 * root.sizeRatio
        topPadding: 6 * root.sizeRatio
        bottomPadding: 6 * root.sizeRatio
        animationEnabled: root.animationEnabled
        closePolicy: T.Popup.NoAutoClose | T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent
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
        contentItem: ListView {
            id: __popupListView
            property int selectedIndex: -1
            implicitHeight: Math.min(root.defaultPopupMaxHeight, contentHeight)
            clip: true
            currentIndex: -1
            model: __private.model
            boundsBehavior: Flickable.StopAtBounds
            spacing: root.defaultOptionSpacing
            delegate: T.ItemDelegate {
                id: __popupDelegate

                required property var modelData
                required property int index

                property var textData: modelData[root.textRole]
                property var valueData: modelData[root.valueRole] ?? textData
                property bool selected: __popupListView.selectedIndex === index

                width: __popupListView.width
                height: implicitContentHeight + topPadding + bottomPadding
                leftPadding: 8 * root.sizeRatio
                rightPadding: 8 * root.sizeRatio
                topPadding: 5 * root.sizeRatio
                bottomPadding: 5 * root.sizeRatio
                highlighted: root.text === valueData
                contentItem: Loader {
                    sourceComponent: root.labelDelegate
                    property alias textData: __popupDelegate.textData
                    property alias valueData: __popupDelegate.valueData
                    property alias modelData: __popupDelegate.modelData
                    property alias hovered: __popupDelegate.hovered
                    property alias highlighted: __popupDelegate.highlighted
                }
                background: Loader {
                    sourceComponent: root.labelBgDelegate
                    property alias textData: __popupDelegate.textData
                    property alias valueData: __popupDelegate.valueData
                    property alias modelData: __popupDelegate.modelData
                    property alias hovered: __popupDelegate.hovered
                    property alias selected: __popupDelegate.selected
                    property alias highlighted: __popupDelegate.highlighted
                }
                onClicked: {
                    root.select(__popupDelegate.modelData);
                    root.text = __popupDelegate.valueData;
                    __popup.close();
                    root.filter();
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                Loader {
                    y: __popupDelegate.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: root.showToolTip
                    sourceComponent: MosToolTip {
                        showArrow: false
                        visible: __popupDelegate.hovered && !__popupDelegate.pressed
                        text: __popupDelegate.textData
                        position: MosToolTip.Position_Bottom
                    }
                }
            }
            T.ScrollBar.vertical: MosScrollBar { }
        }
        Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
        property bool isTop: (y + height * 0.5) < root.height * 0.5
    }
}
