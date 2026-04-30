import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

Item {
    id: root

    enum MessageType {
        Type_None = 0,
        Type_Success = 1,
        Type_Warning = 2,
        Type_Message = 3,
        Type_Error = 4
    }

    signal closed(key: string)

    property bool animationEnabled: MosTheme.animationEnabled
    property int defaultIconSize: 18
    property bool showCloseButton: false
    property int spacing: 10
    property int topMargin: 12
    property int bgTopPadding: 12
    property int bgBottomPadding: 12
    property int bgLeftPadding: 12
    property int bgRightPadding: 12
    property int messageSpacing: 8
    property font messageFont: Qt.font({
                                           family: MosTheme.MosMessage.fontFamily,
                                           pixelSize: parseInt(MosTheme.MosMessage.fontSize)
                                       })
    property color colorMessage: MosTheme.MosMessage.colorMessage
    property color colorBg: MosTheme.isDark ? MosTheme.MosMessage.colorBgDark : MosTheme.MosMessage.colorBg
    property color colorBgShadow: MosTheme.MosMessage.colorBgShadow
    property MosRadius radiusBg: MosRadius { all: MosTheme.MosMessage.radiusBg }
    property var themeSource: MosTheme.MosMenu

    property Component messageDelegate: MosText {
        font: root.messageFont
        color: root.colorMessage
        text: parent.message
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAnywhere
    }

    function info(message: string, duration = 3000) {
        open({
                 'message': message,
                 'type': MosMessage.Type_Message,
                 'duration': duration
             });
    }

    function success(message: string, duration = 3000) {
        open({
                 'message': message,
                 'type': MosMessage.Type_Success,
                 'duration': duration
             });
    }

    function error(message: string, duration = 3000) {
        open({
                 'message': message,
                 'type': MosMessage.Type_Error,
                 'duration': duration
             });
    }

    function warning(message: string, duration = 3000) {
        open({
                 'message': message,
                 'type': MosMessage.Type_Warning,
                 'duration': duration
             });
    }

    function loading(message: string, duration = 3000) {
        open({
                 'loading': true,
                 'message': message,
                 'type': MosMessage.Type_Message,
                 'duration': duration
             });
    }

    function open(object) {
        __listModel.append(__private.initObject(object));
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

    function getMessage(key: string): var {
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

    objectName: '__MosMessage__'

    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorMessage { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

    QtObject {
        id: __private

        function initObject(object) {
            if (!object.hasOwnProperty('key')) object.key = '';
            if (!object.hasOwnProperty('loading')) object.loading = false;
            if (!object.hasOwnProperty('message')) object.message = '';
            if (!object.hasOwnProperty('type')) object.type = MosMessage.Type_None;
            if (!object.hasOwnProperty('duration')) object.duration = 3000;
            if (!object.hasOwnProperty('iconSize')) object.iconSize = root.defaultIconSize;
            if (!object.hasOwnProperty('iconSource')) object.iconSource = 0;

            if (!object.hasOwnProperty('colorIcon')) object.colorIcon = '';
            else object.colorIcon = String(object.colorIcon);

            return object;
        }
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: root.topMargin
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.spacing

        Repeater {
            id: __repeater
            model: ListModel { id: __listModel }
            delegate: Item {
                id: __rootItem
                width: __content.width
                height: __content.height
                anchors.horizontalCenter: parent.horizontalCenter

                required property int index
                required property string key
                required property bool loading
                required property string message
                required property int type
                required property int duration
                required property int iconSize
                required property int iconSource
                required property string colorIcon

                function removeSelf() {
                    __content.height = 0;
                    __removeTimer.start();
                }

                Timer {
                    id: __timer
                    running: true
                    interval: __rootItem.duration
                    onTriggered: {
                        __rootItem.removeSelf();
                    }
                }

                MosShadow {
                    anchors.fill: __rootItem
                    source: __bgRect
                    shadowColor: root.colorBgShadow
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
                        width: Math.min(implicitWidth, root.width - root.bgLeftPadding - root.bgRightPadding)
                        anchors.centerIn: parent
                        spacing: root.messageSpacing

                        MosIconText {
                            Layout.alignment: Qt.AlignVCenter
                            iconSize: __rootItem.iconSize
                            iconSource: {
                                if (__rootItem.loading) return MosIcon.LoadingOutlined;
                                if (__rootItem.iconSource != 0) return __rootItem.iconSource;
                                switch (type) {
                                    case MosMessage.Type_Success: return MosIcon.CheckCircleFilled;
                                    case MosMessage.Type_Warning: return MosIcon.ExclamationCircleFilled;
                                    case MosMessage.Type_Message: return MosIcon.ExclamationCircleFilled;
                                    case MosMessage.Type_Error: return MosIcon.CloseCircleFilled;
                                    default: return 0;
                                }
                            }
                            colorIcon: {
                                if (__rootItem.loading) return MosTheme.Primary.colorInfo;
                                if (__rootItem.colorIcon !== '') return __rootItem.colorIcon;
                                switch ((type)) {
                                    case MosMessage.Type_Success: return MosTheme.Primary.colorSuccess;
                                    case MosMessage.Type_Warning: return MosTheme.Primary.colorWarning;
                                    case MosMessage.Type_Message: return MosTheme.Primary.colorInfo;
                                    case MosMessage.Type_Error: return MosTheme.Primary.colorError;
                                    default: return MosTheme.Primary.colorInfo;
                                }
                            }

                            NumberAnimation on rotation {
                                running: __rootItem.loading
                                from: 0
                                to: 360
                                loops: Animation.Infinite
                                duration: 1000
                            }
                        }

                        Loader {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            sourceComponent: root.messageDelegate
                            property alias index: __rootItem.index
                            property alias key: __rootItem.key
                            property alias message: __rootItem.message
                        }

                        Loader {
                            Layout.alignment: Qt.AlignVCenter
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
                                colorIcon: hovered ? MosTheme.MosMessage.colorCloseHover : MosTheme.MosMessage.colorClose
                                onClicked: {
                                    __timer.stop();
                                    __rootItem.removeSelf();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
