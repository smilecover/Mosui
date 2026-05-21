import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.ComboBox {
    id: root

    signal clickClear()

    property bool animationEnabled: MosTheme.animationEnabled
    property bool active: hovered || visualFocus || contentItem.hovered || contentItem.activeFocus
    property int hoverCursorShape: Qt.PointingHandCursor
    property bool clearEnabled: true
    property var clearIconSource: MosIcon.CloseCircleFilled ?? ''
    property bool showToolTip: false
    property bool loading: false
    property string placeholderText: ''
    property int defaultPopupMaxHeight: 240 * sizeRatio
    property color colorText: enabled ?
                                  (popup.visible && !editable) ? themeSource.colorTextActive :
                                                                 themeSource.colorText : themeSource.colorTextDisabled
    property color colorBorder: enabled ?
                                    active ? themeSource.colorBorderHover :
                                             themeSource.colorBorder : themeSource.colorBorderDisabled
    property color colorBg: enabled ? themeSource.colorBg : themeSource.colorBgDisabled

    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property MosRadius radiusItemBg: MosRadius { all: themeSource.radiusItemBg }
    property MosRadius radiusPopupBg: MosRadius { all: themeSource.radiusPopupBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property string contentDescription: ''
    property var themeSource: MosTheme.MosSelect

    property Component indicatorDelegate: MosIconText {
        colorIcon: {
            if (root.enabled) {
                if (__clearMouseArea.active) {
                    return __clearMouseArea.pressed ? root.themeSource.colorIndicatorActive :
                                                      __clearMouseArea.hovered ? root.themeSource.colorIndicatorHover :
                                                                                 root.themeSource.colorIndicator;
                } else {
                    return root.themeSource.colorIndicator;
                }
            } else {
                return root.themeSource.colorIndicatorDisabled;
            }
        }
        iconSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
        iconSource: {
            if (root.enabled && root.clearEnabled && __clearMouseArea.active)
                return root.clearIconSource;
            else
                root.loading ? MosIcon.LoadingOutlined : MosIcon.DownOutlined
        }

        Behavior on colorIcon { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

        NumberAnimation on rotation {
            running: root.loading
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1000
        }

        MouseArea {
            id: __clearMouseArea
            anchors.fill: parent
            enabled: root.enabled
            hoverEnabled: true
            cursorShape: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: hovered = true;
            onExited: hovered = false;
            onClicked: function(mouse) {
                if (active && root.clearEnabled) {
                    if (root.editable)
                        root.editText = '';
                    root.currentIndex = -1;
                    root.clickClear();
                } else {
                    if (root.popup.opened) {
                        root.popup.close();
                    } else {
                        root.popup.open();
                    }
                }
                mouse.accepted = true;
            }
            property bool active: !root.loading && (root.displayText.length > 0 || root.editText.length > 0) && root.hovered
            property bool hovered: false
        }
    }

    Behavior on colorText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorBorder { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

    objectName: '__MosSelect__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    leftPadding: padding + (!root.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (root.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    topPadding: 6 * sizeRatio
    bottomPadding: 6 * sizeRatio
    spacing: 8 * sizeRatio
    textRole: 'label'
    valueRole: 'value'
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    selectTextByMouse: editable
    delegate: T.ItemDelegate { }
    indicator: Loader {
        x: root.mirrored ? (root.padding + root.spacing) : (root.width - width - root.padding - root.spacing)
        y: root.topPadding + (root.availableHeight - height) / 2
        sourceComponent: root.indicatorDelegate
    }
    contentItem: MosInput {
        id: __input
        topPadding: 0
        bottomPadding: 0
        sizeRatio: root.sizeRatio
        text: root.editable ? root.editText : root.displayText
        readOnly: !root.editable
        autoScroll: root.editable
        placeholderText: root.placeholderText
        font: root.font
        inputMethodHints: root.inputMethodHints
        validator: root.validator
        selectByMouse: root.selectTextByMouse
        verticalAlignment: Text.AlignVCenter
        colorText: root.colorText
        colorBg: 'transparent'
        colorBorder: 'transparent'

        Keys.onEnterPressed: if (active && !root.popup.opened) root.popup.open();

        HoverHandler {
            cursorShape: root.editable ? Qt.IBeamCursor : root.hoverCursorShape
        }

        TapHandler {
            onTapped: {
                if (!root.editable) {
                    if (root.popup.opened) {
                        root.popup.close();
                    } else {
                        root.popup.open();
                    }
                } else {
                    __openPopupTimer.restart();
                }
            }
        }

        Timer {
            id: __openPopupTimer
            interval: 100
            onTriggered: {
                if (!root.popup.opened) {
                    root.popup.open();
                }
            }
        }
    }
    background: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        border.width: 1
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
    }
    popup: MosPopup {
        id: __popup
        y: root.height + 2
        implicitWidth: root.width
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
        contentItem: ListView {
            id: __popupListView
            implicitHeight: Math.min(root.defaultPopupMaxHeight, contentHeight)
            clip: true
            model: root.popup.visible ? root.model : null
            currentIndex: root.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            delegate: T.ItemDelegate {
                id: __popupDelegate

                required property var model
                required property int index

                width: __popupListView.width
                height: implicitContentHeight + topPadding + bottomPadding
                leftPadding: 8 * root.sizeRatio
                rightPadding: 8 * root.sizeRatio
                topPadding: 5 * root.sizeRatio
                bottomPadding: 5 * root.sizeRatio
                enabled: model.enabled ?? true
                contentItem: MosText {
                    text: __popupDelegate.model[root.textRole]
                    color: __popupDelegate.enabled ? root.themeSource.colorItemText : root.themeSource.colorItemTextDisabled
                    font {
                        family: root.font.family
                        pixelSize: root.font.pixelSize
                        weight: highlighted ? Font.DemiBold : Font.Normal
                    }
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: root.radiusItemBg.all
                    topLeftRadius: root.radiusItemBg.topLeft
                    topRightRadius: root.radiusItemBg.topRight
                    bottomLeftRadius: root.radiusItemBg.bottomLeft
                    bottomRightRadius: root.radiusItemBg.bottomRight
                    color: {
                        if (__popupDelegate.enabled)
                            return highlighted ? root.themeSource.colorItemBgActive :
                                                 hovered ? root.themeSource.colorItemBgHover :
                                                           root.themeSource.colorItemBg;
                        else
                            return root.themeSource.colorItemBgDisabled;
                    }

                    Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
                }
                highlighted: root.highlightedIndex === index
                onClicked: {
                    root.currentIndex = index;
                    root.activated(index);
                    root.popup.close();
                }

                HoverHandler {
                    cursorShape: root.hoverCursorShape
                }

                Loader {
                    y: __popupDelegate.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: root.showToolTip
                    sourceComponent: MosToolTip {
                        showArrow: false
                        visible: __popupDelegate.hovered
                        animationEnabled: root.animationEnabled
                        text: __popupDelegate.model[root.textRole]
                        position: MosToolTip.Position_Bottom
                    }
                }
            }
            T.ScrollBar.vertical: MosScrollBar {
                animationEnabled: root.animationEnabled
            }
        }
        property bool isTop: (y + height * 0.5) < root.height * 0.5
    }

    HoverHandler {
        cursorShape: root.hoverCursorShape
    }

    Accessible.role: Accessible.ComboBox
    Accessible.name: root.displayText
    Accessible.description: root.contentDescription
}
