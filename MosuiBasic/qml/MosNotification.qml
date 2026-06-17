pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

Item {
    id: root

    enum NotificationPosition {
        Position_Top = 0,
        Position_TopLeft = 1,
        Position_TopRight = 2,
        Position_Bottom = 3,
        Position_BottomLeft = 4,
        Position_BottomRight = 5,
        Position_Left = 6,
        Position_Right = 7
    }

    enum MessageType {
        Type_None = 0,
        Type_Success = 1,
        Type_Warning = 2,
        Type_Message = 3,
        Type_Error = 4
    }

    signal closed(key: string)

    property bool animationEnabled: MosTheme.animationEnabled
    property int position: MosNotification.Position_Top
    property bool pauseOnHover: true
    property bool showProgress: false
    property bool stackMode: true
    property int stackThreshold: 5
    property int defaultIconSize: 20
    property int maxNotificationWidth: 300
    property int spacing: 10
    property bool showCloseButton: true
    property int topMargin: 12
    property int bgTopPadding: 12
    property int bgBottomPadding: 12
    property int bgLeftPadding: 12
    property int bgRightPadding: 12
    property color colorMessage: MosTheme.MosNotification.colorMessage
    property color colorDescription: MosTheme.MosNotification.colorDescription
    property color colorBg: MosTheme.isDark ? MosTheme.MosNotification.colorBgDark : MosTheme.MosNotification.colorBg
    property color colorBgShadow: MosTheme.MosNotification.colorBgShadow
    property MosRadius radiusBg: MosRadius { all: MosTheme.MosNotification.radiusBg }

    property font messageFont: Qt.font({
                                           family: MosTheme.MosNotification.fontFamily,
                                           pixelSize: parseInt(MosTheme.MosNotification.fontSizeMessage)
                                       })
    property int messageSpacing: 8

    property font descriptionFont: Qt.font({
                                               family: MosTheme.MosNotification.fontFamily,
                                               pixelSize: parseInt(MosTheme.MosNotification.fontSizeDescription)
                                           })
    property int descriptionSpacing: 10

    property Component messageDelegate: MosText {
        font: root.messageFont
        color: root.colorMessage
        text: parent.message
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }
    property Component descriptionDelegate: MosText {
        width: parent.width
        font: root.descriptionFont
        color: root.colorDescription
        text: parent.description
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }

    function info(message: string, description: string, duration = 4500) {
        open({
                 'message': message,
                 'description': description,
                 'type': MosNotification.Type_Message,
                 'duration': duration
             });
    }

    function success(message: string, description: string, duration = 4500) {
        open({
                 'message': message,
                 'description': description,
                 'type': MosNotification.Type_Success,
                 'duration': duration
             });
    }

    function error(message: string, description: string, duration = 4500) {
        open({
                 'message': message,
                 'description': description,
                 'type': MosNotification.Type_Error,
                 'duration': duration
             });
    }

    function warning(message: string, description: string, duration = 4500) {
        open({
                 'message': message,
                 'description': description,
                 'type': MosNotification.Type_Warning,
                 'duration': duration
             });
    }

    function loading(message: string, description: string, duration = 4500) {
        open({
                 'loading': true,
                 'message': message,
                 'description': description,
                 'type': MosNotification.Type_Message,
                 'duration': duration
             });
    }

    function open(object) {
        __listModel.insert(0, __private.initObject(object));
    }

    function close(key: string) {
        for (let i = 0; i < __listModel.count; i++) {
            const object = __listModel.get(i);
            if (object.key && object.key === key) {
                const item = __repeater.itemAt(i);
                if (item)
                    item.removeSelf();
                break;
            }
        }
    }

    function clear() {
        __listModel.clear();
    }

    function getNotification(key: string): var {
        for (let i = 0; i < __listModel.count; i++) {
            const object = __listModel.get(i);
            if (object.key && object.key === key) {
                return object;
            }
        }
        return undefined;
    }

    function setProperty(key: string, property: string, value: var) {
        for (let i = 0; i < __listModel.count; i++) {
            const object = __listModel.get(i);
            if (object.key && object.key === key) {
                __listModel.setProperty(i, property, value);
                break;
            }
        }
    }

    objectName: '__MosNotification__'

    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorMessage { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorDescription { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

    QtObject {
        id: __private

        property bool isLeft: root.position == MosNotification.Position_Left ||
                              root.position == MosNotification.Position_TopLeft ||
                              root.position == MosNotification.Position_BottomLeft
        property bool isRight: root.position == MosNotification.Position_Right ||
                               root.position == MosNotification.Position_TopRight ||
                               root.position == MosNotification.Position_BottomRight
        property bool isTop: root.position == MosNotification.Position_Top ||
                             root.position == MosNotification.Position_TopLeft ||
                             root.position == MosNotification.Position_TopRight
        property bool isBottom: root.position == MosNotification.Position_Bottom ||
                                root.position == MosNotification.Position_BottomLeft ||
                                root.position == MosNotification.Position_BottomRight

        function initObject(object) {
            if (!object.hasOwnProperty('key')) object.key = '';
            if (!object.hasOwnProperty('loading')) object.loading = false;
            if (!object.hasOwnProperty('message')) object.message = '';
            if (!object.hasOwnProperty('description')) object.description = '';
            if (!object.hasOwnProperty('type')) object.type = MosNotification.Type_None;
            if (!object.hasOwnProperty('duration')) object.duration = 4500;
            if (!object.hasOwnProperty('iconSize')) object.iconSize = root.defaultIconSize;
            if (!object.hasOwnProperty('iconSource') || object.iconSource == null || object.iconSource === undefined) object.iconSource = 0;

            if (!object.hasOwnProperty('colorIcon')) object.colorIcon = '';
            else object.colorIcon = String(object.colorIcon);

            return object;
        }
    }

    ColumnLayout {
        id: __columnLayout
        anchors {
            left: __private.isLeft ? parent.left : undefined
            right: __private.isRight ? parent.right : undefined
            top: __private.isTop ? parent.top : undefined
            bottom: __private.isBottom ? parent.bottom : undefined
            horizontalCenter: root.position == MosNotification.Position_Top||
                              root.position == MosNotification.Position_Bottom ? parent.horizontalCenter : undefined
            verticalCenter: root.position == MosNotification.Position_Left ||
                            root.position == MosNotification.Position_Right ? parent.verticalCenter : undefined
            margins: 10
            topMargin: root.topMargin
        }
        spacing: 0

        Repeater {
            id: __repeater

            property bool collapsed: root.stackMode && __listModel.count > root.stackThreshold && !__hoverHandler.hovered

            model: ListModel { id: __listModel }
            delegate: Item {
                id: __rootItem
                z: -index
                Layout.preferredWidth: __content.width
                Layout.preferredHeight: __content.height
                Layout.leftMargin: __private.isLeft ? (-__content.width - 20) : 0
                Layout.rightMargin: __private.isRight ? (-__content.width - 20) : 0
                Layout.topMargin: index == 0 ? 0 : (__repeater.collapsed ? collapseTopMargin : root.spacing)
                Layout.alignment: __private.isLeft ? Qt.AlignLeft : Qt.AlignRight
                transform: Scale {
                    origin.x: __rootItem.width * 0.5
                    origin.y: __rootItem.height * 0.5
                    xScale: __repeater.collapsed ? Math.max(0.8, 1.0 - __rootItem.index * 0.015) : 1

                    Behavior on xScale {
                        enabled: root.animationEnabled
                        NumberAnimation {
                            easing.type: Easing.OutQuad
                            duration: MosTheme.Primary.durationMid
                        }
                    }
                }

                required property int index
                required property string key
                required property bool loading
                required property string message
                required property string description
                required property int type
                required property int duration
                required property int iconSize
                required property int iconSource
                required property string colorIcon

                property real collapseTopMargin: index == 0 ? 10 : (index == 1 || index == 2) ? (10 - __content.height) : (- __content.height)

                function removeSelf() {
                    __content.height = 0;
                    __removeTimer.start();
                }

                NumberAnimation on Layout.leftMargin {
                    running: root.animationEnabled && __private.isLeft
                    to: 0
                    easing.type: Easing.OutQuad
                    duration: MosTheme.Primary.durationMid
                }

                NumberAnimation on Layout.rightMargin {
                    running: root.animationEnabled && __private.isRight
                    to: 0
                    easing.type: Easing.OutQuad
                    duration: MosTheme.Primary.durationMid
                }

                Behavior on Layout.topMargin {
                    enabled: root.animationEnabled
                    NumberAnimation {
                        easing.type: Easing.OutQuad
                        duration: MosTheme.Primary.durationMid
                    }
                }

                Timer {
                    id: __timer
                    running: root.pauseOnHover ? !__hoverHandler.hovered : true
                    interval: 25
                    repeat: true
                    onTriggered: {
                        time += 25;
                        if (time >= __rootItem.duration) {
                            stop();
                            __rootItem.removeSelf();
                        }
                    }
                    property int time: 0
                }

                MosShadow {
                    anchors.fill: __rootItem
                    source: __bgRect
                    shadowColor: root.colorBgShadow
                    shadowEnabled: __repeater.collapsed ? index <= 2 : true
                }

                MosRectangleInternal {
                    id: __bgRect
                    anchors.fill: parent
                    radius: root.radiusBg.all
                    topLeftRadius: root.radiusBg.topLeft
                    topRightRadius: root.radiusBg.topRight
                    bottomLeftRadius: root.radiusBg.bottomLeft
                    bottomRightRadius: root.radiusBg.bottomRight
                    color: root.colorBg
                    visible: false
                }

                Item {
                    id: __content
                    width: __rowLayout.width + root.bgLeftPadding + root.bgRightPadding
                    height: 0
                    opacity: 0
                    clip: true

                    Component.onCompleted: {
                        opacity = 1;
                        height = Qt.binding(() => __rowLayout.height + root.bgTopPadding + root.bgBottomPadding);
                    }

                    Behavior on opacity { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
                    Behavior on height { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }

                    Timer {
                        id: __removeTimer
                        running: false
                        interval: root.animationEnabled ? MosTheme.Primary.durationMid : 0
                        onTriggered: {
                            root.closed(__rootItem.key);
                            __listModel.remove(__rootItem.index);
                        }
                    }

                    RowLayout {
                        id: __rowLayout
                        width: Math.min(root.maxNotificationWidth, root.width - root.bgLeftPadding - root.bgRightPadding)
                        anchors.centerIn: parent
                        spacing: root.messageSpacing

                        MosIconText {
                            id: __loadingIcon
                            Layout.alignment: Qt.AlignTop
                            Layout.topMargin: 5
                            iconSize: __rootItem.iconSize
                            iconSource: {
                                if (__rootItem.loading) return MosIcon.LoadingOutlined;
                                if (__rootItem.iconSource != 0) return __rootItem.iconSource;
                                switch (type) {
                                    case MosNotification.Type_Success: return MosIcon.CheckCircleFilled;
                                    case MosNotification.Type_Warning: return MosIcon.ExclamationCircleFilled;
                                    case MosNotification.Type_Message: return MosIcon.ExclamationCircleFilled;
                                    case MosNotification.Type_Error: return MosIcon.CloseCircleFilled;
                                    default: return 0;
                                }
                            }
                            colorIcon: {
                                if (__rootItem.loading) return MosTheme.Primary.colorInfo;
                                if (__rootItem.colorIcon !== '') return __rootItem.colorIcon;
                                switch ((type)) {
                                    case MosNotification.Type_Success: return MosTheme.Primary.colorSuccess;
                                    case MosNotification.Type_Warning: return MosTheme.Primary.colorWarning;
                                    case MosNotification.Type_Message: return MosTheme.Primary.colorInfo;
                                    case MosNotification.Type_Error: return MosTheme.Primary.colorError;
                                    default: return MosTheme.Primary.colorInfo;
                                }
                            }

                            NumberAnimation on rotation {
                                running: __rootItem.loading
                                from: 0
                                to: 360
                                loops: Animation.Infinite
                                duration: 1000
                                onRunningChanged: {
                                    if (!running) {
                                        __loadingIcon.rotation = 0;
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.alignment: Qt.AlignTop
                            Layout.topMargin: 5
                            Layout.fillWidth: true
                            Layout.preferredHeight: __messageLoader.height + __descriptionLoader.height + root.descriptionSpacing

                            Loader {
                                id: __messageLoader
                                width: parent.width
                                sourceComponent: root.messageDelegate
                                property alias index: __rootItem.index
                                property alias key: __rootItem.key
                                property alias message: __rootItem.message
                            }

                            Loader {
                                id: __descriptionLoader
                                width: parent.width
                                anchors.top: __messageLoader.bottom
                                anchors.topMargin: root.descriptionSpacing
                                sourceComponent: root.descriptionDelegate
                                property alias index: __rootItem.index
                                property alias key: __rootItem.key
                                property alias description: __rootItem.description
                            }
                        }

                        Loader {
                            Layout.alignment: Qt.AlignTop
                            Layout.topMargin: 5
                            active: root.showCloseButton
                            sourceComponent: MosCaptionButton {
                                topPadding: 2
                                bottomPadding: 2
                                leftPadding: 4
                                rightPadding: 4
                                radiusBg.all: 2
                                animationEnabled: root.animationEnabled
                                hoverCursorShape: Qt.PointingHandCursor
                                iconSource: MosIcon.CloseOutlined
                                colorIcon: hovered ? MosTheme.MosNotification.colorCloseHover : MosTheme.MosNotification.colorClose
                                onClicked: {
                                    __timer.stop();
                                    __rootItem.removeSelf();
                                }
                            }
                        }
                    }

                    Loader {
                        width: parent.width - __bgRect.radius * 2
                        height: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        active: root.showProgress
                        sourceComponent: MosProgress {
                            percent: (__rootItem.duration - __timer.time) / __rootItem.duration * 100
                            animationEnabled: false
                            showInfo: false
                        }
                    }
                }
            }
        }

        HoverHandler {
            id: __hoverHandler
        }
    }
}
