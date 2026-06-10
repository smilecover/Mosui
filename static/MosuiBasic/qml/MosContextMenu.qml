import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosPopup {
    id: root

    signal clickMenu(deep: int, key: string, keyPath: var, data: var)

    property bool animationEnabled: MosTheme.animationEnabled
    property var initModel: []
    property bool showToolTip: false
    property int defaultMenuIconSize: parseInt(MosTheme.MosMenu.fontSize)
    property int defaultMenuIconSpacing: 8
    property int defaultMenuWidth: 140
    property int defaultMenuTopPadding: 5
    property int defaultMenuBottomPadding: 5
    property int defaultMenuSpacing: 4
    property int subMenuOffset: -4
    property MosRadius radiusMenuBg: MosRadius { all: MosTheme.Primary.radiusPrimary }

    property alias menu: __menu

    function open() {
        visible = true;
        if (parent && parent instanceof Item) {
            const pos = parent.mapToItem(null, x, y);
            if ((pos.x + implicitWidth + 6) > __private.window.width) {
                x = parent.mapFromItem(null, __private.window.width - 6, 0).x - implicitWidth;
            }
            if ((pos.y + implicitHeight + 6) > __private.window.height) {
                y = parent.mapFromItem(null, 0, __private.window.height - 6).y - implicitHeight;
            }
        }
    }

    objectName: '__MosContextMenu__'
    implicitWidth: defaultMenuWidth
    implicitHeight: implicitContentHeight
    enter: Transition {
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
            property: 'opacity'
            from: 1.0
            to: 0
            easing.type: Easing.InQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
    }
    contentItem: MosMenu {
        id: __menu
        radiusMenuBg: root.radiusMenuBg
        radiusPopupBg: root.radiusBg
        initModel: root.initModel
        showToolTip: root.showToolTip
        popupMode: true
        popupWidth: root.defaultMenuWidth
        popupOffset: root.subMenuOffset
        defaultMenuIconSize: root.defaultMenuIconSize
        defaultMenuIconSpacing: root.defaultMenuIconSpacing
        defaultMenuWidth: root.defaultMenuWidth
        defaultMenuTopPadding: root.defaultMenuTopPadding
        defaultMenuBottomPadding: root.defaultMenuBottomPadding
        defaultMenuSpacing: root.defaultMenuSpacing
        onClickMenu:
            (deep, key, keyPath, data) => {
                root.clickMenu(deep, key, keyPath, data);
                if (!data.hasOwnProperty('menuChildren')) {
                    close();
                }
            }
        menuIconDelegate: MosIconText {
            color: !menuButton.isGroup && menuButton.enabled ? MosTheme.MosMenu.colorText : MosTheme.MosMenu.colorTextDisabled
            iconSize: menuButton.iconSize
            iconSource: menuButton.iconSource
            verticalAlignment: Text.AlignVCenter

            Behavior on x {
                enabled: root.animationEnabled
                NumberAnimation { easing.type: Easing.OutCubic; duration: MosTheme.Primary.durationMid }
            }
            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
        }
        menuLabelDelegate: MosText {
            text: menuButton.text
            font: menuButton.font
            color: !menuButton.isGroup && menuButton.enabled ? MosTheme.MosMenu.colorText : MosTheme.MosMenu.colorTextDisabled
            elide: Text.ElideRight

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
        }

        menuContentDelegate: Item {
            id: __menuContentItem
            implicitHeight: __rowLayout.implicitHeight
            property var __menuButton: menuButton
            property var model: menuButton.model
            property bool isGroup: menuButton.isGroup

            RowLayout {
                id: __rowLayout
                visible: !__menuContentItem.isVertical
                anchors.left: parent.left
                anchors.right: menuButton.expandedVisible ? __expandedIcon.left : parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: menuButton.iconSpacing

                Loader {
                    sourceComponent: menuButton.iconDelegate
                    property var model: __menuButton.model
                    property alias menuButton: __menuContentItem.__menuButton
                }

                Loader {
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
                anchors.verticalCenter: parent.verticalCenter
                visible: menuButton.showExpanded
                iconSource: MosIcon.RightOutlined
                colorIcon: !isGroup && menuButton.enabled ? MosTheme.MosMenu.colorText : MosTheme.MosMenu.colorTextDisabled

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            }
        }
        menuBgDelegate: MosRectangleInternal {
            radius: root.radiusMenuBg.all
            topLeftRadius: root.radiusMenuBg.topLeft
            topRightRadius: root.radiusMenuBg.topRight
            bottomLeftRadius: root.radiusMenuBg.bottomLeft
            bottomRightRadius: root.radiusMenuBg.bottomRight
            color: {
                if (enabled) {
                    if (menuButton.isGroup) return MosTheme.MosMenu.colorBgDisabled;
                    else if (menuButton.pressed) return MosTheme.MosMenu.colorBgActive;
                    else if (menuButton.hovered) return MosTheme.MosMenu.colorBgHover;
                    else return MosTheme.MosMenu.colorBg;
                } else {
                    return MosTheme.MosMenu.colorBgDisabled;
                }
            }
            border.color: menuButton.colorBorder
            border.width: 1

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        }
    }

    Item {
        id: __private
        property var window: Window.window
    }
}
