import QtQuick
import QtQuick.Templates as T
import MosuiBasic

MosPopup {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled

    property real scaleMin: 1.0
    property real scaleMax: 5.0
    property real scaleStep: 0.5

    readonly property alias currentScale: __private.scale
    readonly property alias currentRotation: __private.rotation

    property var items: []
    property alias currentIndex: __listView.currentIndex
    readonly property alias count: __listView.count

    property Component sourceDelegate: Image {
        source: sourceUrl
        fillMode: Image.PreserveAspectFit
        onStatusChanged: {
            if (status === Image.Ready)
                root.resetTransform();
        }
    }
    property Component closeDelegate: MosIconButton {
        topPadding: 10
        bottomPadding: 10
        animationEnabled: root.animationEnabled
        effectEnabled: false
        iconSource: MosIcon.CloseOutlined
        iconSize: 20
        shape: MosButton.Shape_Circle
        type: MosButton.Type_Default
        colorIcon: MosTheme.MosImage.colorButtonTextHover
        colorBg: hovered ? MosTheme.MosImage.colorButtonBgHover : MosTheme.MosImage.colorButtonBg
        colorBorder: colorBg
        onClicked: root.close();
    }
    property Component prevDelegate: MosIconButton {
        topPadding: 10
        bottomPadding: 10
        animationEnabled: root.animationEnabled
        effectEnabled: false
        iconSource: MosIcon.LeftOutlined
        iconSize: 20
        shape: MosButton.Shape_Circle
        type: MosButton.Type_Default
        hoverCursorShape: root.currentIndex <= 0 ? Qt.ForbiddenCursor : Qt.PointingHandCursor
        colorIcon: root.currentIndex <= 0 ? MosTheme.MosImage.colorButtonText :
                                               MosTheme.MosImage.colorButtonTextHover
        colorBg: root.currentIndex <= 0 ?
                     'transparent' : hovered ? MosTheme.MosImage.colorButtonBgHover :
                                               MosTheme.MosImage.colorButtonBg
        colorBorder: 'transparent'
        onClicked: root.decrementCurrentIndex();
    }
    property Component nextDelegate: MosIconButton {
        topPadding: 10
        bottomPadding: 10
        animationEnabled: root.animationEnabled
        effectEnabled: false
        iconSource: MosIcon.RightOutlined
        iconSize: 20
        shape: MosButton.Shape_Circle
        type: MosButton.Type_Default
        hoverCursorShape: root.currentIndex >= (root.count - 1) ? Qt.ForbiddenCursor : Qt.PointingHandCursor
        colorIcon: root.currentIndex >= (root.count - 1) ? MosTheme.MosImage.colorButtonText :
                                                                 MosTheme.MosImage.colorButtonTextHover
        colorBg: root.currentIndex >= (root.count - 1) ?
                     'transparent' : hovered ? MosTheme.MosImage.colorButtonBgHover :
                                               MosTheme.MosImage.colorButtonBg
        colorBorder: 'transparent'
        onClicked: root.incrementCurrentIndex();
    }
    property Component indicatorDelegate: MosText {
        color: MosTheme.MosImage.colorIndicatorText
        text: `${root.currentIndex + 1} / ${root.count}`
        font {
            family: MosTheme.MosImage.fontFamily
            pixelSize: parseInt(MosTheme.MosImage.fontSize) + 1
        }
    }
    property Component operationDelegate: MouseArea {
        width: 380
        height: 40
        hoverEnabled: true

        Rectangle {
            id: __operations
            anchors.fill: parent
            radius: height * 0.5
            color: MosTheme.MosImage.colorOperationBg

            Row {
                anchors.centerIn: parent

                MosIconButton {
                    animationEnabled: root.animationEnabled
                    type: MosButton.Type_Link
                    iconSource: MosIcon.SwapOutlined
                    colorIcon: hovered ? MosTheme.MosImage.colorButtonTextHover : MosTheme.MosImage.colorButtonText
                    iconSize: 20
                    contentItem: MosIconText {
                        color: parent.colorIcon
                        iconSource: parent.iconSource
                        iconSize: parent.iconSize
                        rotation: 90
                    }
                    onClicked: root.flipY();

                    MosToolTip {
                        animationEnabled: root.animationEnabled
                        visible: parent.hovered
                        text: qsTr('垂直翻转')
                    }
                }

                MosIconButton {
                    animationEnabled: root.animationEnabled
                    type: MosButton.Type_Link
                    iconSource: MosIcon.SwapOutlined
                    colorIcon: hovered ? MosTheme.MosImage.colorButtonTextHover : MosTheme.MosImage.colorButtonText
                    iconSize: 20
                    onClicked: root.flipX();

                    MosToolTip {
                        animationEnabled: root.animationEnabled
                        visible: parent.hovered
                        text: qsTr('水平翻转')
                    }
                }

                MosIconButton {
                    animationEnabled: root.animationEnabled
                    type: MosButton.Type_Link
                    iconSource: MosIcon.RotateLeftOutlined
                    colorIcon: hovered ? MosTheme.MosImage.colorButtonTextHover : MosTheme.MosImage.colorButtonText
                    iconSize: 20
                    onClicked: root.rotate(-90);

                    MosToolTip {
                        animationEnabled: root.animationEnabled
                        visible: parent.hovered
                        text: qsTr('向左旋转')
                    }
                }

                MosIconButton {
                    animationEnabled: root.animationEnabled
                    type: MosButton.Type_Link
                    iconSource: MosIcon.RotateRightOutlined
                    colorIcon: hovered ? MosTheme.MosImage.colorButtonTextHover : MosTheme.MosImage.colorButtonText
                    iconSize: 20
                    onClicked: root.rotate(90);

                    MosToolTip {
                        animationEnabled: root.animationEnabled
                        visible: parent.hovered
                        text: qsTr('向右旋转')
                    }
                }

                MosIconButton {
                    animationEnabled: root.animationEnabled
                    type: MosButton.Type_Link
                    iconSource: MosIcon.ZoomOutOutlined
                    hoverCursorShape: root.currentScale > root.scaleMin ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    colorIcon: root.currentScale > root.scaleMin ?
                                   hovered ? MosTheme.MosImage.colorButtonTextHover :
                                             MosTheme.MosImage.colorButtonText : MosTheme.MosImage.colorButtonTextDisabled
                    iconSize: 20
                    onClicked: root.zoomOut();

                    MosToolTip {
                        animationEnabled: root.animationEnabled
                        visible: parent.hovered
                        text: qsTr('缩小')
                    }
                }

                MosIconButton {
                    animationEnabled: root.animationEnabled
                    type: MosButton.Type_Link
                    iconSource: MosIcon.ZoomInOutlined
                    hoverCursorShape: root.currentScale < root.scaleMax ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    colorIcon: root.currentScale < root.scaleMax ?
                                   hovered ? MosTheme.MosImage.colorButtonTextHover :
                                             MosTheme.MosImage.colorButtonText : MosTheme.MosImage.colorButtonTextDisabled
                    iconSize: 20
                    onClicked: root.zoomIn();

                    MosToolTip {
                        animationEnabled: root.animationEnabled
                        visible: parent.hovered
                        text: qsTr('放大')
                    }
                }
            }
        }
    }

    function get(index) {
        return __listModel.get(index);
    }

    function set(index, object) {
        __listModel.set(index, __private.initObject(object));
    }

    function setProperty(index, propertyName, value) {
        __listModel.setProperty(index, propertyName, value);
    }

    function move(from, to, count = 1) {
        __listModel.move(from, to, count);
    }

    function insert(index, object) {
        __listModel.insert(index, __private.initObject(object));
    }

    function append(object) {
        __listModel.append(__private.initObject(object));
    }

    function remove(index, count = 1) {
        __listModel.remove(index, count);
    }

    function clear() {
        __listModel.clear();
    }

    function zoomIn() {
        __private.isCenterScale = true;
        const nextScale = __private.scale + scaleStep;
        if (nextScale < scaleMax)
            __private.scale = nextScale;
        else
            __private.scale = scaleMax;
    }

    function zoomOut() {
        __private.isCenterScale = true;
        const nextScale = __private.scale - scaleStep;
        if (nextScale > scaleMin)
            __private.scale = nextScale;
        else
            __private.scale = scaleMin;
    }

    function flipX() {
        __private.flipX = !__private.flipX;
    }

    function flipY() {
        __private.flipY = !__private.flipY;
    }

    function rotate(angle: real) {
        __private.rotation += angle;
    }

    function resetTransform() {
        __private.isCenterScale = true;
        __private.flipX = false;
        __private.flipY = false;
        __private.scale = 1.0;
        __private.rotation = 0;
        __private.toCenter();
    }

    function incrementCurrentIndex() {
        __listView.incrementCurrentIndex();
    }

    function decrementCurrentIndex() {
        __listView.decrementCurrentIndex();
    }

    onItemsChanged:  {
        clear();
        for (const object of items) {
            append(object);
        }
    }
    onCurrentIndexChanged: {
        resetTransform();
    }

    objectName: '__MosImagePreview__'
    width: parent.width
    height: parent.height
    closePolicy: T.Popup.NoAutoClose
    parent: T.Overlay.overlay
    modal: true
    focus: true
    onAboutToShow: {
        resetTransform();
        __private.visible = true;
        __imagePreview.forceActiveFocus();
    }
    onAboutToHide: {
        __private.visible = false;
    }
    background: Item { }

    QtObject {
        id: __private

        signal toCenter()

        property bool visible: false
        property bool instantTransform: false
        property real scale: 1.0
        property real scaleOriginX: 0.0
        property real scaleOriginY: 0.0
        property bool isCenterScale: true
        property bool flipX: false
        property bool flipY: false
        property real rotation: 0

        function initObject(object) {
            if (!object.hasOwnProperty('url')) object.url = '';

            return object;
        }

        Behavior on scale {
            enabled: root.animationEnabled && !__private.instantTransform
            NumberAnimation {
                duration: MosTheme.Primary.durationMid
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: MosTheme.MosTour.colorOverlay

        Item {
            id: __imagePreview
            anchors.fill: parent
            focus: true
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Left) {
                    decrementCurrentIndex();
                } else if (event.key === Qt.Key_Right) {
                    incrementCurrentIndex();
                } else if (event.key === Qt.Key_Escape) {
                    root.close();
                }
            }
            states: [
                State {
                    name: 'open'
                    when: __private.visible
                    PropertyChanges { __imagePreview.opacity: 1.0 }
                    PropertyChanges { __imagePreview.scale: 1.0 }
                },
                State {
                    name: 'close'
                    when: !__private.visible
                    PropertyChanges { __imagePreview.opacity: 0.0 }
                    PropertyChanges { __imagePreview.scale: 0.0 }
                }
            ]
            transitions: [
                Transition {
                    from: 'open'
                    to: 'close'
                    NumberAnimation {
                        properties: 'opacity'
                        easing.type: Easing.InOutQuad
                        duration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
                    }
                    NumberAnimation {
                        properties: 'scale'
                        easing.type: Easing.InOutQuad
                        duration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
                    }
                },
                Transition {
                    to: 'open'
                    from: 'close'
                    NumberAnimation {
                        properties: 'opacity'
                        easing.type: Easing.InOutQuad
                        duration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
                    }
                    NumberAnimation {
                        properties: 'scale'
                        easing.type: Easing.InOutQuad
                        duration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
                    }
                }
            ]

            ListView {
                id: __listView
                anchors.fill: parent
                clip: true
                model: ListModel { id: __listModel }
                interactive: false
                orientation: ListView.Horizontal
                highlightMoveDuration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
                delegate: MouseArea {
                    id: __rootItem
                    width: __listView.width
                    height: __listView.height
                    clip: true
                    drag.target: __image
                    onClicked:
                        mouse => {
                            if (!imageContains(mouse.x, mouse.y)) {
                                root.close();
                            }
                        }
                    onDoubleClicked:
                        () => {
                            if (__private.scale > 1.0) {
                                __private.scale = 1.0;
                                __private.toCenter();
                            } else {
                                root.zoomIn();
                            }
                        }

                    required property string url
                    property bool isCurrent: ListView.isCurrentItem

                    function imageContains(x, y) {
                        return x >= __image.x && x <= __image.x + __image.width && y >= __image.y && y <= __image.y + __image.height;
                    }

                    Loader {
                        id: __image

                        property string sourceUrl: __rootItem.url
                        property size sourceSize: item ? item.sourceSize : Qt.size(0, 0)

                        property real minViewHeight: __rootItem.height - 200
                        property real aspectRatio: sourceSize.width / sourceSize.height
                        property rect mappedRect: Qt.rect(x, y, width, height)
                        property size mappedSize: Qt.size(mappedRect.width, mappedRect.height)

                        function shouldAutoCenter() {
                            return __private.isCenterScale && __private.scale === 1.0 &&
                                   __private.rotation === 0 && !__private.flipX && !__private.flipY;
                        }

                        function scheduleCenter() {
                            __centerTimer.restart();
                        }

                        sourceComponent: root.sourceDelegate
                        onSourceSizeChanged: {
                            if (shouldAutoCenter())
                                scheduleCenter();
                        }
                        onMappedSizeChanged: {
                            if (mappedSize.width < __rootItem.width || mappedSize.height < __rootItem.height)
                                __adjustTimer.restart();
                        }

                        function calcMapRect() {
                            const topLeft = mapToItem(parent, 0, 0);
                            const topRight = mapToItem(parent, width, 0);
                            const bottomLeft = mapToItem(parent, 0, height);
                            const bottomRight = mapToItem(parent, width, height);
                            const left = Math.min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x);
                            const right = Math.max(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x);
                            const top = Math.min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y);
                            const bottom = Math.max(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y);
                            mappedRect = Qt.rect(left, top, right - left, bottom - top);
                        }

                        function toCenterX() {
                            calcMapRect();
                            x += __rootItem.width * 0.5 - (mappedRect.x + mappedRect.width * 0.5);
                        }

                        function toCenterY() {
                            calcMapRect();
                            y += __rootItem.height * 0.5 - (mappedRect.y + mappedRect.height * 0.5);
                        }

                        function adjustPosition() {
                            calcMapRect();
                            if (mappedRect.width > __rootItem.width) {
                                const right = mappedRect.x + mappedRect.width;
                                if (mappedRect.x > 0) {
                                    x += -mappedRect.x;
                                } else if (right < __rootItem.width) {
                                    x += __rootItem.width - right;
                                }
                            } else {
                                toCenterX();
                            }

                            calcMapRect();
                            if (mappedRect.height > __rootItem.height) {
                                const bottom = mappedRect.y + mappedRect.height;
                                if (mappedRect.y > 0) {
                                    y += -mappedRect.y;
                                } else if (bottom < __rootItem.height) {
                                    y += __rootItem.height - bottom;
                                }
                            } else {
                                toCenterY();
                            }
                        }

                        function scaleTo(pointX, pointY, nextScale) {
                            const clampedScale = Math.max(root.scaleMin, Math.min(root.scaleMax, nextScale));
                            if (clampedScale === __private.scale)
                                return;

                            const startX = x;
                            const startY = y;
                            const startScale = __private.scale;
                            const mappedBeforeOrigin = mapToItem(parent, pointX, pointY);
                            __private.instantTransform = true;
                            __private.isCenterScale = false;
                            __private.scaleOriginX = pointX;
                            __private.scaleOriginY = pointY;

                            const mappedAfterOrigin = mapToItem(parent, pointX, pointY);
                            const baseX = startX + mappedBeforeOrigin.x - mappedAfterOrigin.x;
                            const baseY = startY + mappedBeforeOrigin.y - mappedAfterOrigin.y;
                            x = baseX;
                            y = baseY;

                            const mappedBeforeScale = mapToItem(parent, pointX, pointY);
                            __private.scale = clampedScale;
                            calcMapRect();

                            const mappedAfterScale = mapToItem(parent, pointX, pointY);
                            const targetX = baseX + mappedBeforeScale.x - mappedAfterScale.x;
                            const targetY = baseY + mappedBeforeScale.y - mappedAfterScale.y;

                            __private.scale = startScale;
                            x = baseX;
                            y = baseY;
                            calcMapRect();

                            Qt.callLater(() => {
                                __private.scale = clampedScale;
                                x = targetX;
                                y = targetY;
                                __adjustTimer.restart();
                            });
                            __private.instantTransform = false;
                        }

                        onXChanged: calcMapRect();
                        onYChanged: calcMapRect();

                        x: (parent.width - width) * 0.5
                        y: (parent.height - height) * 0.5
                        width: height * aspectRatio
                        height: Math.min(sourceSize.height, minViewHeight)
                        transform: [
                            Scale {
                                id: __scale
                                origin.x: __private.isCenterScale ? __image.width * 0.5 : __private.scaleOriginX
                                origin.y: __private.isCenterScale ? __image.height * 0.5 : __private.scaleOriginY
                                xScale: __private.scale
                                yScale: __private.scale
                                onXScaleChanged: __image.calcMapRect();
                                onYScaleChanged: __image.calcMapRect();
                            },
                            Rotation {
                                id: __rotationZ
                                origin.x: __image.width * 0.5
                                origin.y: __image.height * 0.5
                                axis { x: 0; y: 0; z: 1 }
                                angle: __rootItem.isCurrent ? __private.rotation : 0
                                onAngleChanged: __image.calcMapRect();

                                Behavior on angle {
                                    enabled: root.animationEnabled
                                    NumberAnimation {
                                        duration: MosTheme.Primary.durationMid
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            },
                            Rotation {
                                id: __rotationY
                                origin.x: __image.width * 0.5
                                origin.y: __image.height * 0.5
                                axis { x: 0; y: 1; z: 0 }
                                angle: __rootItem.isCurrent ? (__private.flipX ? 180 : 0) : 0
                                onAngleChanged: __image.calcMapRect();

                                Behavior on angle {
                                    enabled: root.animationEnabled
                                    NumberAnimation {
                                        duration: MosTheme.Primary.durationMid
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            },
                            Rotation {
                                origin.x: __image.width * 0.5
                                origin.y: __image.height * 0.5
                                axis { x: 1; y: 0; z: 0 }
                                angle: __rootItem.isCurrent ? (__private.flipY ? 180 : 0) : 0
                                onAngleChanged: __image.calcMapRect();

                                Behavior on angle {
                                    enabled: root.animationEnabled
                                    NumberAnimation {
                                        duration: MosTheme.Primary.durationMid
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        ]

                        onWidthChanged: {
                            calcMapRect();
                            if (shouldAutoCenter())
                                scheduleCenter();
                        }
                        onHeightChanged: {
                            calcMapRect();
                            if (shouldAutoCenter())
                                scheduleCenter();
                        }

                        Behavior on x {
                            enabled: root.animationEnabled && !__private.instantTransform
                            NumberAnimation {
                                duration: MosTheme.Primary.durationMid
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on y {
                            enabled: root.animationEnabled && !__private.instantTransform
                            NumberAnimation {
                                duration: MosTheme.Primary.durationMid
                                easing.type: Easing.OutCubic
                            }
                        }

                        Timer {
                            id: __centerTimer
                            interval: 0
                            onTriggered: {
                                if (!__image.sourceSize.width || !__image.sourceSize.height || width <= 0 || height <= 0)
                                    return;

                                if (__image.shouldAutoCenter()) {
                                    __private.instantTransform = true;
                                    __image.x = (__rootItem.width - __image.width) * 0.5;
                                    __image.y = (__rootItem.height - __image.height) * 0.5;
                                    __image.calcMapRect();
                                    __private.instantTransform = false;
                                } else {
                                    __image.toCenterX();
                                    __image.toCenterY();
                                }
                            }
                        }

                        Timer {
                            id: __adjustTimer
                            running: !__rootItem.drag.active
                            interval: 100
                            onTriggered: __image.adjustPosition();
                        }

                        Connections {
                            target: __private
                            function onToCenter() {
                                __private.isCenterScale = true;
                                __image.scheduleCenter();
                            }
                        }

                        HoverHandler {
                            cursorShape: Qt.ClosedHandCursor
                        }

                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel:
                                (wheel) => {
                                    const step = wheel.angleDelta.y / 120 * root.scaleStep;
                                    __image.scaleTo(wheel.x, wheel.y, __private.scale + step);
                                }
                        }
                    }
                }
            }

            Loader {
                anchors.bottom: __operationLoader.top
                anchors.bottomMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                active: __listModel.count > 1
                sourceComponent: root.indicatorDelegate
            }

            Loader {
                id: __operationLoader
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                sourceComponent: root.operationDelegate
            }

            Loader {
                anchors.left: parent.left
                anchors.leftMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                active: __listModel.count > 1
                sourceComponent: root.prevDelegate
            }

            Loader {
                anchors.right: parent.right
                anchors.rightMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                active: __listModel.count > 1
                sourceComponent: root.nextDelegate
            }

            Loader {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 30
                sourceComponent: root.closeDelegate
            }
        }
    }
}
