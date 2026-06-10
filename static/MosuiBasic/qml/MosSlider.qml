import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum SnapMode
    {
        NoSnap = 0,
        SnapAlways = 1,
        SnapOnRelease = 2
    }

    signal firstMoved()
    signal firstReleased()
    signal secondMoved()
    signal secondReleased()

    property bool animationEnabled: MosTheme.animationEnabled
    property int hoverCursorShape: Qt.PointingHandCursor
    property real min: 0
    property real max: 100
    property real stepSize: 0.0
    property var value: range ? [0, 0] : 0
    readonly property var currentValue: {
        if (__sliderLoader.item) {
            return range ? [__sliderLoader.item.first.value, __sliderLoader.item.second.value] : __sliderLoader.item.value;
        } else {
            return value;
        }
    }
    property bool range: false
    property int snapMode: MosSlider.NoSnap
    property int orientation: Qt.Horizontal
    property color colorBg: (enabled && hovered) ? themeSource.colorBgHover : themeSource.colorBg
    property color colorHandle: themeSource.colorHandle
    property color colorTrack: {
        if (!enabled) return themeSource.colorTrackDisabled;

        if (MosTheme.isDark)
            return hovered ? themeSource.colorTrackHoverDark : themeSource.colorTrackDark;
        else
            return hovered ? themeSource.colorTrackHover : themeSource.colorTrack;
    }
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string contentDescription: ''
    property var themeSource: MosTheme.MosSlider

    property Component handleToolTipDelegate: Item { }
    property Component handleDelegate: Rectangle {
        id: __handleItem
        x: {
            if (root.orientation == Qt.Horizontal) {
                return slider.leftPadding + visualPosition * (slider.availableWidth - width);
            } else {
                return slider.topPadding + (slider.availableWidth - width) * 0.5;
            }
        }
        y: {
            if (root.orientation == Qt.Horizontal) {
                return slider.topPadding + (slider.availableHeight - height) * 0.5;
            } else {
                return slider.leftPadding + visualPosition * (slider.availableHeight - height);
            }
        }
        implicitWidth: active ? 18 : 14
        implicitHeight: active ? 18 : 14
        radius: height * 0.5
        color: root.colorHandle
        border.color: {
            if (root.enabled) {
                if (MosTheme.isDark)
                    return active ? root.themeSource.colorHandleBorderHoverDark : root.themeSource.colorHandleBorderDark;
                else
                    return active ? root.themeSource.colorHandleBorderHover : root.themeSource.colorHandleBorder;
            } else {
                return root.themeSource.colorHandleBorderDisabled;
            }
        }
        border.width: active ? 4 : 2

        property bool down: pressed
        property bool active: __hoverHandler.hovered || down

        Behavior on implicitWidth { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on implicitHeight { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on border.width { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
        Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

        HoverHandler {
            id: __hoverHandler
            enabled: root.enabled
            cursorShape: root.hoverCursorShape
        }

        Loader {
            sourceComponent: handleToolTipDelegate
            onLoaded: item.parent = __handleItem;
            property alias handleHovered: __hoverHandler.hovered
            property alias handlePressed: __handleItem.down
        }
    }
    property Component bgDelegate: Item {
        MosRectangleInternal {
            width: root.orientation == Qt.Horizontal ? parent.width : 4
            height: root.orientation == Qt.Horizontal ? 4 : parent.height
            anchors.horizontalCenter: root.orientation == Qt.Horizontal ? undefined : parent.horizontalCenter
            anchors.verticalCenter: root.orientation == Qt.Horizontal ? parent.verticalCenter : undefined
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
            color: root.colorBg

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

            Rectangle {
                x: {
                    if (root.orientation == Qt.Horizontal)
                        return range ? (slider.first.visualPosition * parent.width) : 0;
                    else
                        return 0;
                }
                y: {
                    if (root.orientation == Qt.Horizontal)
                        return 0;
                    else
                        return range ? (slider.second.visualPosition * parent.height) : slider.visualPosition * parent.height;
                }
                width: {
                    if (root.orientation == Qt.Horizontal)
                        return range ? (slider.second.visualPosition * parent.width - x) : slider.visualPosition * parent.width;
                    else
                        return parent.width;
                }
                height: {
                    if (root.orientation == Qt.Horizontal)
                        return parent.height;
                    else
                        return range ? (slider.first.visualPosition * parent.height - y) : ((1.0 - slider.visualPosition) * parent.height);
                }
                color: colorTrack
                radius: parent.radius

                Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
            }
        }
    }

    function decrease(first = true) {
        if (__sliderLoader.item) {
            if (range) {
                if (first)
                    __sliderLoader.item.first.decrease();
                else
                    __sliderLoader.item.second.decrease();
            } else {
                __sliderLoader.item.decrease();
            }
        }
    }

    function increase(first = true) {
        if (range) {
            if (first)
                __sliderLoader.item.first.increase();
            else
                __sliderLoader.item.second.increase();
        } else {
            __sliderLoader.item.increase();
        }
    }

    onValueChanged: __private.fromValueUpdate();

    objectName: '__MosSlider__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    contentItem: Loader {
        id: __sliderLoader
        sourceComponent: root.range ? __rangeSliderComponent : __sliderComponent
        onLoaded: __private.fromValueUpdate();
    }

    QtObject {
        id: __private

        function fromValueUpdate() {
            if (__sliderLoader.item) {
                if (range) {
                    __sliderLoader.item.setValues(...value);
                } else {
                    __sliderLoader.item.value = value;
                }
            }
        }
    }

    Component {
        id: __sliderComponent

        T.Slider {
            id: __slider
            from: min
            to: max
            stepSize: root.stepSize
            orientation: root.orientation
            snapMode: {
                switch (root.snapMode) {
                case MosSlider.SnapAlways: return T.Slider.SnapAlways;
                case MosSlider.SnapOnRelease: return T.Slider.SnapOnRelease;
                default: return T.Slider.NoSnap;
                }
            }
            handle: Loader {
                sourceComponent: handleDelegate
                property alias slider: __slider
                property alias visualPosition: __slider.visualPosition
                property alias pressed: __slider.pressed
            }
            background: Loader {
                sourceComponent: bgDelegate
                property alias slider: __slider
                property alias visualPosition: __slider.visualPosition
            }
            onMoved: root.firstMoved();
            onPressedChanged: {
                if (!pressed)
                    root.firstReleased();
            }
        }
    }

    Component {
        id: __rangeSliderComponent

        T.RangeSlider {
            id: __rangeSlider
            from: min
            to: max
            stepSize: root.stepSize
            snapMode: {
                switch (root.snapMode) {
                case MosSlider.SnapAlways: return T.RangeSlider.SnapAlways;
                case MosSlider.SnapOnRelease: return T.RangeSlider.SnapOnRelease;
                default: return T.RangeSlider.NoSnap;
                }
            }
            orientation: root.orientation
            first.handle: Loader {
                sourceComponent: handleDelegate
                property alias slider: __rangeSlider
                property alias visualPosition: __rangeSlider.first.visualPosition
                property alias pressed: __rangeSlider.first.pressed
            }
            first.onMoved: root.firstMoved();
            first.onPressedChanged: {
                if (!first.pressed)
                    root.firstReleased();
            }
            second.handle: Loader {
                sourceComponent: handleDelegate
                property alias slider: __rangeSlider
                property alias visualPosition: __rangeSlider.second.visualPosition
                property alias pressed: __rangeSlider.second.pressed
            }
            second.onMoved: root.secondMoved();
            second.onPressedChanged: {
                if (!second.pressed)
                    root.secondReleased();
            }
            background: Loader {
                sourceComponent: bgDelegate
                property alias slider: __rangeSlider
            }
        }
    }

    Accessible.role: Accessible.Slider
    Accessible.name: root.contentDescription
    Accessible.description: root.contentDescription
    Accessible.onIncreaseAction: increase();
    Accessible.onDecreaseAction: decrease();
}
