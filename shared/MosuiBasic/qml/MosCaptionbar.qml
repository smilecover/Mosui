/*
 * MoskarUI
 *
 * Copyright (C) mengps (MenPenS) (MIT License)
 * https://github.com/mengps/MoskarUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * - The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 * - The Software is provided "as is", without warranty of any kind, express or
 *   implied, including but not limited to the warranties of merchantability,
 *   fitness for a particular purpose and noninfringement. In no event shall the
 *   authors or copyright holders be liable for any claim, damages or other
 *   liability, whether in an action of contract, tort or otherwise, arising from,
 *   out of or in connection with the Software or the use or other dealings in the
 *   Software.
 */

import QtQuick
import QtQuick.Layouts
import MosuiBasic

Rectangle {
    id: root

    property var targetWindow: null
    property MosWindowAgent windowAgent: null

    property alias layoutDirection: __row.layoutDirection

    property bool mirrored: false
    property string winIcon: ''
    property alias winIconWidth: __winIconLoader.width
    property alias winIconHeight: __winIconLoader.height
    property alias winIconVisible: __winIconLoader.visible

    property string winTitle: targetWindow?.title ?? ''
    property font winTitleFont: Qt.font({
                                            family: MosTheme.Primary.fontPrimaryFamily,
                                            pixelSize: 14
                                        })
    property color winTitleColor: MosTheme.Primary.colorTextBase
    property alias showWinTitle: __winTitleLoader.visible

    property bool showReturnButton: false
    property bool showThemeButton: false
    property bool topButtonChecked: false
    property bool showTopButton: false
    property bool showMinimizeButton: Qt.platform.os !== 'osx'
    property bool showMaximizeButton: Qt.platform.os !== 'osx'
    property bool showCloseButton: Qt.platform.os !== 'osx'

    property var returnCallback: () => { }
    property var themeCallback: () => { MosTheme.darkMode = MosTheme.isDark ? MosTheme.Light : MosTheme.Dark; }
    property var topCallback: checked => { }
    property var minimizeCallback:
        () => {
            if (targetWindow) {
                MosApi.setWindowState(targetWindow, Qt.WindowMinimized);
            }
        }
    property var maximizeCallback:
        () => {
            if (!targetWindow) return;

            if (targetWindow.visibility === Window.Maximized ||
                targetWindow.visibility === Window.FullScreen) {
                targetWindow.showNormal();
            } else {
                targetWindow.showMaximized();
            }
        }
    property var closeCallback:
        () => {
            if (targetWindow) targetWindow.close();
        }
    property string contentDescription: winTitle
    property var themeSource: MosTheme.MosCaptionButton

    property Component winNavButtonsDelegate: Row {
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        MosCaptionButton {  
            id: __returnButton
            noDisabledState: true
            // iconSource: MosIcon.ArrowLeftOutlined
            iconSize: parseInt(root.themeSource.fontSize) + 2
            visible: root.showReturnButton
            onClicked: root.returnCallback();
            contentDescription: qsTr('返回')
        }
    }
    property Component winIconDelegate: Image {
        width: 20
        height: 20
        source: root.winIcon
        sourceSize.width: width
        sourceSize.height: height
        mipmap: true
    }
    property Component winTitleDelegate: MosText {
        text: root.winTitle
        color: root.winTitleColor
        font: root.winTitleFont
    }
    property Component winPresetButtonsDelegate: Row {
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Connections {
            target: root
            function onWindowAgentChanged() {
                root.addInteractionItem(__themeButton);
                root.addInteractionItem(__topButton);
            }
        }

        MosCaptionButton {
            id: __themeButton
            height: parent.height
            visible: root.showThemeButton
            noDisabledState: true
            // iconSource: MosTheme.isDark ? MosIcon.MoonOutlined : MosIcon.SunOutlined
            iconSize: 14
            contentDescription: qsTr('明暗主题切换')
            onClicked: root.themeCallback();
        }

        MosCaptionButton {
            id: __topButton
            height: parent.height
            visible: root.showTopButton
            noDisabledState: true
            // iconSource: MosIcon.PushpinOutlined
            iconSize: 14
            checkable: true
            checked: root.topButtonChecked
            contentDescription: qsTr('置顶')
            onClicked: root.topCallback(checked);
        }
    }
    property Component winExtraButtonsDelegate: Item { }
    property Component winButtonsDelegate: Row {
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Connections {
            target: root
            function onWindowAgentChanged() {
                if (windowAgent) {
                    windowAgent.setSystemButton(MosWindowAgent.Minimize, __minimizeButton);
                    windowAgent.setSystemButton(MosWindowAgent.Maximize, __maximizeButton);
                    windowAgent.setSystemButton(MosWindowAgent.Close, __closeButton);
                }
            }
        }

        MosCaptionButton {
            id: __minimizeButton
            height: parent.height
            visible: root.showMinimizeButton
            noDisabledState: true
            iconSource: 0xe624
            iconSize: 14
            contentDescription: qsTr('最小化')
            onClicked: root.minimizeCallback();
        }

        MosCaptionButton {
            id: __maximizeButton
            height: parent.height
            visible: root.showMaximizeButton
            noDisabledState: true
            iconSize: 14
            iconSource: targetWindow.visibility === Window.Maximized ? 0xeb49 : 0xe665

            contentDescription: qsTr('最大化')
            onClicked: root.maximizeCallback();
        }

        MosCaptionButton {
            id: __closeButton
            height: parent.height
            visible: root.showCloseButton
            noDisabledState: true
            iconSource: 0xeb1b
            iconSize: 14
            isError: true
            contentDescription: qsTr('关闭')
            onClicked: root.closeCallback();
        }
    }

    objectName: '__MosCaptionBar__'
    color: 'transparent'

    function addInteractionItem(item) {
        if (windowAgent)
            windowAgent.setHitTestVisible(item, true);
    }

    function removeInteractionItem(item) {
        if (windowAgent)
            windowAgent.setHitTestVisible(item, false);
    }

    RowLayout {
        id: __row
        anchors.fill: parent
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        spacing: 0

        Loader {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: root.winNavButtonsDelegate
        }

        Item {
            id: __title
            Layout.fillWidth: true
            Layout.fillHeight: true
            Component.onCompleted: {
                if (root.windowAgent)
                    root.windowAgent.setTitleBar(__title);
            }
            readonly property real maxMargin: Math.max(x,  __row.width - (x + width))
            readonly property real leftMargin: maxMargin > x ? (maxMargin - x) : 0
            readonly property real rightMargin: maxMargin > x ? 0 : (maxMargin - (__row.width - (x + width)))

            Item {
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: Qt.platform.os === 'osx' ? __title.leftMargin : (root.mirrored ? 0 : 8)
                anchors.right: parent.right
                anchors.rightMargin: Qt.platform.os === 'osx' ? __title.rightMargin : (root.mirrored ? 8 : 0)

                Row {
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: Qt.platform.os === 'osx' ? parent.horizontalCenter : undefined
                    layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight
                    spacing: 5

                    Loader {
                        id: __winIconLoader
                        width: 22
                        height: Math.min(parent.height, 22)
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: root.winIconDelegate
                    }

                    Loader {
                        id: __winTitleLoader
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: root.winTitleDelegate
                    }
                }
            }
        }

        Loader {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: root.winPresetButtonsDelegate
        }

        Loader {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: root.winExtraButtonsDelegate
        }

        Loader {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: root.winButtonsDelegate
        }
    }

    Accessible.role: Accessible.TitleBar
    Accessible.name: root.contentDescription
    Accessible.description: root.contentDescription
}
