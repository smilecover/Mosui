import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum Position
    {
        Position_Top = 0,
        Position_Bottom = 1,
        Position_Left = 2,
        Position_Right = 3
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property var initModel: []
    property int currentIndex: -1
    property int position: MosCarousel.Position_Bottom
    property int speed: 500
    property bool infinite: true
    property bool autoplay: false
    property int autoplaySpeed: 3000
    property bool draggable: true
    property bool showIndicator: true
    property int indicatorSpacing: 6
    property bool showArrow: false

    property Component contentDelegate: Item { }
    property Component indicatorDelegate: Rectangle {
        width: isHorizontal ? __width : __height
        height: isHorizontal ? __height : __width
        color: isCurrent ? MosTheme.MosCarousel.colorIndicatorActive :
                           hovered ? MosTheme.MosCarousel.colorIndicatorHover : MosTheme.MosCarousel.colorIndicator
        radius: MosTheme.MosCarousel.radiusIndicator

        required property int index
        required property var model
        property bool isHorizontal: root.position === MosCarousel.Position_Top || root.position === MosCarousel.Position_Bottom
        property bool isCurrent: index == root.currentIndex
        property bool hovered: __hoverHandler.hovered

        property int __width: isCurrent ? __private.indicatorWidth + 10 : __private.indicatorWidth
        property int __height: 4

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        Behavior on width { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }

        HoverHandler {
            id: __hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: {
                root.switchTo(index);
            }
        }
    }
    property Component prevDelegate: MosIconButton {
        padding: 5
        animationEnabled: root.animationEnabled
        iconSource: __private.isHorizontal ? MosIcon.LeftOutlined : MosIcon.UpOutlined
        iconSize: 20
        colorIcon: hovered ? MosTheme.MosCarousel.colorArrowHover : MosTheme.MosCarousel.colorArrow
        type: MosButton.Type_Link
        onClicked: root.switchToPrev();
    }
    property Component nextDelegate: MosIconButton {
        padding: 5
        animationEnabled: root.animationEnabled
        iconSource: __private.isHorizontal ? MosIcon.RightOutlined : MosIcon.DownOutlined
        iconSize: 20
        colorIcon: hovered ? MosTheme.MosCarousel.colorArrowHover : MosTheme.MosCarousel.colorArrow
        type: MosButton.Type_Link
        onClicked: root.switchToNext();
    }

    function switchTo(index, animated = true) {
        if (animated)
            __listView.currentIndex = infinite ? index + 1 : index;
        else
            __listView.positionViewAtIndex(infinite ? 1 : 0, ListView.SnapPosition);
    }

    function switchToPrev() {
        if (infinite && __listView.currentIndex === 0) {
            __listView.positionViewAtIndex(__listView.count - 2, ListView.SnapPosition);
            __listView.decrementCurrentIndex();
        } else {
            __listView.decrementCurrentIndex();
        }
    }

    function switchToNext() {
        if (infinite && __listView.currentIndex === __listView.count - 1) {
            __listView.positionViewAtIndex(1, ListView.SnapPosition);
            __listView.incrementCurrentIndex();
        } else {
            __listView.incrementCurrentIndex();
        }
    }

    function getSuitableIndicatorWidth(contentWidth, indicatorMaxWidth = 18) {
        let indicatorWidth = 0;
        let totalWidth = 0;
        do {
            if (indicatorWidth >= indicatorMaxWidth) break;
            totalWidth = (++indicatorWidth) * __listModel.count + indicatorSpacing * (__listModel.count - 1) + indicatorMaxWidth;
        } while (totalWidth < contentWidth);

        return indicatorWidth;
    }

    onInfiniteChanged: __private.updateModel();
    onInitModelChanged: __private.updateModel();

    objectName: '__MosCarousel__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    contentItem: ListView {
        id: __listView
        clip: true
        interactive: root.draggable
        orientation: __private.isHorizontal ? Qt.Horizontal : Qt.Vertical
        snapMode: ListView.SnapOneItem
        highlightMoveDuration: root.speed
        highlightRangeMode: ListView.StrictlyEnforceRange
        boundsBehavior: ListView.StopAtBounds
        model: ListModel { id: __listModel }
        delegate: Item {
            id: __rootItem
            width: __listView.width
            height: __listView.height

            required property var model
            required property int index

            Loader {
                anchors.fill: parent
                sourceComponent: root.contentDelegate
                property alias model: __rootItem.model
                property int index: __private.getRealModelIndex(__rootItem.index)
            }
        }
        onCurrentIndexChanged: {
            root.currentIndex = __private.getRealModelIndex(currentIndex);
        }
        onOrientationChanged: {
            positionViewAtIndex(root.infinite ? 1 : 0, ListView.SnapPosition);
        }
        onFlickStarted: updateInfiniteIndex();
        onDragStarted: updateInfiniteIndex();
        onMovementEnded: updateInfiniteIndex();

        function updateInfiniteIndex() {
            if (root.infinite) {
                if (__listView.currentIndex === 0) {
                    __listView.positionViewAtIndex(count - 2, ListView.SnapPosition);
                } else if (__listView.currentIndex === count - 1) {
                    __listView.positionViewAtIndex(1, ListView.SnapPosition);
                }
            }
        }

        Loader {
            active: root.position ===  MosCarousel.Position_Top && root.showIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:  parent.top
            anchors.topMargin: 10
            sourceComponent: Row {
                spacing: root.indicatorSpacing
                Repeater {
                    model: root.initModel
                    delegate: root.indicatorDelegate
                }
            }
        }

        Loader {
            active: root.position === MosCarousel.Position_Bottom && root.showIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            sourceComponent: Row {
                spacing: root.indicatorSpacing
                Repeater {
                    model: root.initModel
                    delegate: root.indicatorDelegate
                }
            }
        }

        Loader {
            active: root.position === MosCarousel.Position_Left && root.showIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            sourceComponent: Column {
                spacing: root.indicatorSpacing
                Repeater {
                    model: root.initModel
                    delegate: root.indicatorDelegate
                }
            }
        }

        Loader {
            active: root.position === MosCarousel.Position_Right && root.showIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            sourceComponent: Column {
                spacing: root.indicatorSpacing
                Repeater {
                    model: root.initModel
                    delegate: root.indicatorDelegate
                }
            }
        }

        Loader {
            active: root.showArrow && showPrev
            anchors.verticalCenter: __private.isHorizontal ? parent.verticalCenter : undefined
            anchors.horizontalCenter: !__private.isHorizontal ? parent.horizontalCenter : undefined
            anchors.top: !__private.isHorizontal ? parent.top : undefined
            anchors.left: __private.isHorizontal ? parent.left : undefined
            sourceComponent: root.prevDelegate
            property bool showPrev: root.infinite ? true : (root.currentIndex !== 0)
        }

        Loader {
            active: root.showArrow && showNext
            anchors.verticalCenter: __private.isHorizontal ? parent.verticalCenter : undefined
            anchors.horizontalCenter: !__private.isHorizontal ? parent.horizontalCenter : undefined
            anchors.bottom: !__private.isHorizontal ? parent.bottom : undefined
            anchors.right: __private.isHorizontal ? parent.right : undefined
            sourceComponent: root.nextDelegate
            property bool showNext: root.infinite ? true : (root.currentIndex !== __listModel.count - 1)
        }
    }

    QtObject {
        id: __private
        property bool isHorizontal: root.position === MosCarousel.Position_Top || root.position === MosCarousel.Position_Bottom
        property int indicatorWidth: root.getSuitableIndicatorWidth(__listView.width)

        function updateModel() {
            if (root.initModel.length > 0) {
                const model = root.infinite ? [root.initModel[root.initModel.length - 1], ...root.initModel, root.initModel[0]] :
                                                 [...root.initModel];
                __listModel.clear();
                for (const item of model) {
                    __listModel.append(item);
                }
                __resetTimer.restart();
            } else {
                __listModel.clear();
            }
        }

        function getVirtualModelIndex(index) {
            if (root.infinite) {
                if (index === 0) {
                    return 1;
                } else if (index === (__listModel.count - 2)) {
                    return __listModel.count - 1;
                } else {
                    return index + 1;
                }
            } else {
                return index;
            }
        }

        function getRealModelIndex(index) {
            if (root.infinite) {
                if (index === 0) {
                    return __listModel.count - 3;
                } else if ((index) === (__listModel.count - 1)) {
                    return 0;
                } else {
                    return index - 1;
                }
            } else {
                return index;
            }
        }
    }

    Timer {
        id: __resetTimer
        interval: 33
        onTriggered: {
            __listView.positionViewAtIndex(root.infinite ? 1 : 0, ListView.SnapPosition);
        }
    }

    Timer {
        id: __autoplayTimer
        repeat: true
        interval: root.autoplaySpeed
        running: root.autoplay
        onTriggered: {
            root.switchToNext();
        }
    }
}
