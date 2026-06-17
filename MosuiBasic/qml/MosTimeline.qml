import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum Mode {
        Mode_Left = 0,
        Mode_Right = 1,
        Mode_Alternate = 2
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property var initModel: []
    property int mode: MosTimeline.Mode_Left
    property bool reverse: false
    property int defaultNodeSize: 11
    property int defaultLineWidth: 1
    property string defaultTimeFormat: 'yyyy-MM-dd'
    property int defaultContentFormat: Text.AutoText
    property font timeFont: Qt.font({
                                        family: themeSource.fontFamily,
                                        pixelSize: parseInt(themeSource.fontSize)
                                    })
    property alias contentFont: root.font
    property color colorNode: themeSource.colorNode
    property color colorNodeBg: themeSource.colorNodeBg
    property color colorLine: themeSource.colorLine
    property color colorTimeText: themeSource.colorTimeText
    property color colorContentText: themeSource.colorContentText
    property var themeSource: MosTheme.MosTimeline

    property Component nodeDelegate: Item {
        height: __loading.active ? __loading.height : __icon.active ? __icon.height : defaultNodeSize

        Loader {
            id: __dot
            width: parent.height
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            active: !__icon.active && !__loading.active
            sourceComponent: Rectangle {
                radius: width >> 1
                color: root.colorNodeBg
                border.color: model.colorNode
                border.width: radius * 0.5
            }
        }

        Loader {
            id: __icon
            anchors.horizontalCenter: parent.horizontalCenter
            active: !__loading.active && model.iconSource !== 0 && model.iconSource !== ''
            sourceComponent: MosIconText {
                iconSource: model.iconSource
                iconSize: model.iconSize
                colorIcon: model.colorNode
            }
        }

        Loader {
            id: __loading
            anchors.horizontalCenter: parent.horizontalCenter
            active: model.loading
            sourceComponent: MosIconText {
                id: __loadingIcon
                iconSize: model.iconSize
                iconSource: MosIcon.LoadingOutlined
                colorIcon: model.colorNode

                NumberAnimation on rotation {
                    running: model.loading
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
        }
    }
    property Component lineDelegate: Rectangle {
        color: root.colorLine
    }
    property Component timeDelegate: MosText {
        id: __timeText
        color: root.colorTimeText
        font: root.timeFont
        text: {
            if (!isNaN(model.time))
                return model.time.toLocaleString(root.locale, model.timeFormat);
            else
                return '';
        }
        horizontalAlignment: onLeft ? Text.AlignRight : Text.AlignLeft
    }
    property Component contentDelegate: MosText {
        id: __contentText
        color: root.colorContentText
        font: root.contentFont
        text: model.content
        textFormat: model.contentFormat
        wrapMode: Text.WrapAnywhere
        horizontalAlignment: onLeft ? Text.AlignRight : Text.AlignLeft
    }

    function flick(xVelocity: real, yVelocity: real) {
        __listView.flick(xVelocity, yVelocity);
    }

    function positionViewAtBeginning() {
        __listView.positionViewAtBeginning();
    }

    function positionViewAtIndex(index: int, mode: int) {
        __listView.positionViewAtIndex(index, mode);
    }

    function positionViewAtEnd() {
        __listView.positionViewAtEnd();
    }

    function get(index) {
        return __listModel.get(index);
    }

    function set(index: int, object: var) {
        __listModel.set(index, __private.initObject(object));
    }

    function setProperty(index: int, propertyName: string, value: var) {
        if (propertyName === 'time')
            __private.noTime = false;
        __listModel.setProperty(index, propertyName, value);
    }

    function move(from: int, to: int, count = 1) {
        __listModel.move(from, to, count);
    }

    function insert(index: int, object: var) {
        __listModel.insert(index, __private.initObject(object));
    }

    function remove(index: int, count = 1) {
        __listModel.remove(index, count);
        for (let i = 0; i < __listModel.count; i++) {
            if (__listModel.get(i).hasOwnProperty('time')) {
                __private.noTime = false;
                break;
            }
        }
    }

    function append(object: var) {
        __listModel.append(__private.initObject(object));
    }

    function clear() {
        __private.noTime = true;
        __listModel.clear();
    }

    onInitModelChanged: {
        clear();
        for (const object of initModel) {
            append(object);
        }
    }

    objectName: '__MosTimeline__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize)
    }
    contentItem: ListView {
        id: __listView
        implicitHeight: contentHeight
        clip: true
        verticalLayoutDirection: root.reverse ? ListView.BottomToTop : ListView.TopToBottom
        model: ListModel { id: __listModel }
        T.ScrollBar.vertical: MosScrollBar {
            animationEnabled: root.animationEnabled
        }
        onContentHeightChanged: cacheBuffer = contentHeight;
        add: Transition {
            NumberAnimation { property: 'opacity'; from: 0; to: 1; duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0 }
        }
        remove: Transition {
            NumberAnimation { property: 'opacity'; from: 1; to: 0; duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0 }
        }
        delegate: Item {
            id: __rootItem
            width: __listView.width
            height: __contentLoader.height + ((__listModel.count > 1 && !isLast) ? 25 : 0)

            required property var model
            required property int index
            property bool isLast: index === (root.reverse ? 0 : __listModel.count - 1)
            property bool timeOnLeft: {
                if (root.mode == MosTimeline.Mode_Right)
                    return false;
                else if (root.mode == MosTimeline.Mode_Alternate)
                    return index % 2 == 0;
                else
                    return true;
            }

            Loader {
                active: {
                    if (root.reverse)
                        return __rootItem.index != 0;
                    else
                        return __rootItem.index !== (__listModel.count - 1);
                }
                width: defaultLineWidth
                height: parent.height - __nodeLoader.height
                anchors.horizontalCenter: __nodeLoader.horizontalCenter
                anchors.top: __nodeLoader.bottom
                sourceComponent: root.lineDelegate
                property alias model: __rootItem.model
                property alias index: __rootItem.index
            }

            Loader {
                id: __nodeLoader
                x: {
                    if (__private.noTime && root.mode != MosTimeline.Mode_Alternate)
                        return root.mode == MosTimeline.Mode_Left ? 0 : parent.width - width;
                    else
                        return (__rootItem.width - width) * 0.5;
                }
                width: 30
                sourceComponent: root.nodeDelegate
                property alias model: __rootItem.model
                property alias index: __rootItem.index
            }

            Loader {
                y: (__nodeLoader.height - __timeFontMetrics.height) * 0.5
                anchors.left: __rootItem.timeOnLeft ? parent.left : __nodeLoader.right
                anchors.leftMargin: __rootItem.timeOnLeft ? 0 : 5
                anchors.right: __rootItem.timeOnLeft ? __nodeLoader.left : parent.right
                anchors.rightMargin: __rootItem.timeOnLeft ? 5 : 0
                sourceComponent: root.timeDelegate
                property alias model: __rootItem.model
                property alias index: __rootItem.index
                property bool onLeft: __rootItem.timeOnLeft

                FontMetrics {
                    id: __timeFontMetrics
                    font: root.timeFont
                }
            }

            Loader {
                id: __contentLoader
                y: (__nodeLoader.height - __contentFontMetrics.height) * 0.5
                anchors.left: !__rootItem.timeOnLeft ? parent.left : __nodeLoader.right
                anchors.leftMargin: !__rootItem.timeOnLeft ? 0 : 5
                anchors.right: !__rootItem.timeOnLeft ? __nodeLoader.left : parent.right
                anchors.rightMargin: !__rootItem.timeOnLeft ? 5 : 0
                sourceComponent: root.contentDelegate
                property alias model: __rootItem.model
                property alias index: __rootItem.index
                property bool onLeft: !__rootItem.timeOnLeft

                FontMetrics {
                    id: __contentFontMetrics
                    font: root.contentFont
                }
            }
        }
    }

    QtObject {
        id: __private
        property bool noTime: true
        function initObject(object: var): var {
            /*! 静态角色类型下会有颜色不兼容问题, 统一转换为string即可 */
            if (object.hasOwnProperty('colorNode')) {
                object.colorNode = String(object.colorNode);
            }

            if (!object.hasOwnProperty('colorNode')) object.colorNode = String(root.colorNode);
            if (!object.hasOwnProperty('iconSource') || object.iconSource == null || object.iconSource === undefined) object.iconSource = 0;
            if (!object.hasOwnProperty('iconSize')) object.iconSize = root.defaultNodeSize;
            if (!object.hasOwnProperty('loading')) object.loading = false;

            if (!object.hasOwnProperty('time')) object.time = new Date(undefined);
            if (!object.hasOwnProperty('timeFormat')) object.timeFormat = root.defaultTimeFormat;

            if (!object.hasOwnProperty('content')) object.content = '';
            if (!object.hasOwnProperty('contentFormat')) object.contentFormat = root.defaultContentFormat;

            /*! 判断是否存在有效时间 */
            if (__private.noTime && object.hasOwnProperty('time') && !isNaN(object.time))
                __private.noTime = false;

            return object;
        }
    }
}
