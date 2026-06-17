import QtQuick
import QtQuick.Templates as T
import QtQuick.Effects
import MosuiBasic

T.Control {
    id: root

    /* 结束 */
    signal done(int value)

    property bool animationEnabled: MosTheme.animationEnabled
    property int hoverCursorShape: Qt.PointingHandCursor
    property int count: 5
    property real initValue: 0
    property real value: 0
    property int iconSize: 24
    property bool showToolTip: false
    property alias toolTipFont: root.font
    property list<string> toolTipTexts: []
    /* 允许半星 */
    property bool allowHalf: false
    property var fillIcon: MosIcon.StarFilled || ''
    property var emptyIcon: MosIcon.StarFilled || ''
    property var halfIcon: MosIcon.StarFilled || ''
    property color colorFill: themeSource.colorFill
    property color colorEmpty: themeSource.colorEmpty
    property color colorHalf: themeSource.colorHalf
    property color colorToolTipShadow: themeSource.colorToolTipShadow
    property color colorToolTipText: themeSource.colorToolTipText
    property color colorToolTipBg: MosTheme.isDark ? themeSource.colorToolTipBgDark : themeSource.colorToolTipBg
    property var themeSource: MosTheme.MosRate

    property Component fillDelegate: MosIconText {
        colorIcon: root.colorFill
        iconSource: root.fillIcon
        iconSize: root.iconSize
        
        Behavior on opacity {
            enabled: root.animationEnabled
            NumberAnimation { duration: MosTheme.Primary.durationFast }
        }
    }
    property Component emptyDelegate: MosIconText {
        colorIcon: root.colorEmpty
        iconSource: root.emptyIcon
        iconSize: root.iconSize
        
        Behavior on opacity {
            enabled: root.animationEnabled
            NumberAnimation { duration: MosTheme.Primary.durationFast }
        }
    }
    property Component halfDelegate: MosIconText {
        colorIcon: root.colorEmpty
        iconSource: root.emptyIcon
        iconSize: root.iconSize
        
        Behavior on opacity {
            enabled: root.animationEnabled
            NumberAnimation { duration: MosTheme.Primary.durationFast }
        }

        MosIconText {
            id: __source
            colorIcon: root.colorHalf
            iconSource: root.halfIcon
            iconSize: root.iconSize
            layer.enabled: true
            layer.effect: halfRateHelper
            
            Behavior on opacity {
                enabled: root.animationEnabled
                NumberAnimation { duration: MosTheme.Primary.durationFast }
            }
            
            Behavior on width {
                enabled: root.animationEnabled
                NumberAnimation { duration: MosTheme.Primary.durationFast }
            }
        }
    }
    property Component toolTipDelegate: Item {
        width: 12
        height: 6
        opacity: hovered ? 1 : 0

        Behavior on opacity { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }

        MosShadow {
            anchors.fill: __item
            source: __item
            shadowColor: root.colorToolTipShadow
        }

        Item {
            id: __item
            width: __toolTipBg.width
            height: __arrow.height + __toolTipBg.height - 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            Rectangle {
                id: __toolTipBg
                width: __toolTipText.implicitWidth + 14
                height: __toolTipText.implicitHeight + 12
                anchors.bottom: __arrow.top
                anchors.bottomMargin: -1
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.colorToolTipBg
                radius: root.themeSource.radiusToolTipBg

                MosText {
                    id: __toolTipText
                    color: root.colorToolTipText
                    text: root.toolTipTexts[index]
                    font: root.toolTipFont
                    anchors.centerIn: parent
                }
            }

            Canvas {
                id: __arrow
                width: 12
                height: 6
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                onColorBgChanged: requestPaint();
                onPaint: {
                    const ctx = getContext('2d');
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(width, 0);
                    ctx.lineTo(width * 0.5, height);
                    ctx.closePath();
                    ctx.fillStyle = colorBg;
                    ctx.fill();
                }
                property color colorBg: root.colorToolTipBg
            }
        }
    }

    property Component halfRateHelper: ShaderEffect {
        fragmentShader: 'qrc:/shaders/mosrate.frag.qsb'
    }

    onInitValueChanged: {
        __private.doneValue = value = initValue;
    }

    objectName: '__MosRate__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    spacing: 4
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    contentItem: MouseArea {
        implicitWidth: __row.implicitWidth
        implicitHeight: __row.implicitHeight
        hoverEnabled: true
        enabled: root.enabled
        onExited: {
            root.value = __private.doneValue;
        }

        Row {
            id: __row
            spacing: root.spacing

            Repeater {
                id: __repeater

                property int fillCount: Math.floor(root.value)
                property int emptyStartIndex: Math.round(root.value)
                property bool hasHalf: root.allowHalf && root.value - fillCount > 0

                Behavior on fillCount {
                    enabled: root.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }

                Behavior on emptyStartIndex {
                    enabled: root.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }

                model: root.count
                delegate: MouseArea {
                    id: __rootItem
                    width: root.iconSize
                    height: root.iconSize
                    hoverEnabled: true
                    cursorShape: hovered ? root.hoverCursorShape : Qt.ArrowCursor
                    enabled: root.enabled
                    onEntered: {
                        hovered = true;
                        if (root.animationEnabled) {
                            __scaleAnim.start();
                        }
                    }
                    onExited: hovered = false;
                    onClicked:
                        mouse => {
                            const newValue = getCurrentValue(mouse, index);
                            if (__private.doneValue === newValue) {
                                __private.doneValue = root.value = 0;
                            } else {
                                __private.doneValue = root.value = newValue;
                            }
                            root.done(__private.doneValue);
                        }
                    onPositionChanged:
                        mouse => {
                            const newValue = getCurrentValue(mouse, index);
                            /*! 只有当评分值变化时才触发动画 */
                            if (newValue !== root.value) {
                                root.value = newValue;
                                if (root.animationEnabled && !__scaleAnim.running) {
                                    __scaleAnim.start();
                                }
                            }
                        }
                    required property int index
                    property bool hovered: false

                    function getCurrentValue(mouse, index) {
                        if (root.allowHalf) {
                            if (mouse.x > (width * 0.5)) {
                                return index + 1;
                            } else {
                                return index + 0.5;
                            }
                        } else {
                            return index + 1;
                        }
                    }

                    SequentialAnimation {
                        id: __scaleAnim
                        NumberAnimation {
                            target: __rootItemContainer
                            property: 'scale'
                            from: 1.0
                            to: 1.15
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: __rootItemContainer
                            property: 'scale'
                            from: 1.15
                            to: 1.0
                            duration: 100
                            easing.type: Easing.OutBounce
                        }
                    }

                    Item {
                        id: __rootItemContainer
                        width: parent.width
                        height: parent.height

                        Loader {
                            id: fillLoader
                            anchors.fill: parent
                            active: true
                            opacity: index < __repeater.fillCount ? 1.0 : 0.0
                            sourceComponent: root.fillDelegate
                            property int index: __rootItem.index
                            property bool hovered: __rootItem.hovered

                            Behavior on opacity {
                                enabled: root.animationEnabled
                                NumberAnimation { duration: MosTheme.Primary.durationFast }
                            }
                        }

                        Loader {
                            id: halfLoader
                            anchors.fill: parent
                            active: root.allowHalf
                            opacity: __repeater.hasHalf && index === (__repeater.emptyStartIndex - 1) ? 1.0 : 0.0
                            sourceComponent: root.halfDelegate
                            property int index: __rootItem.index
                            property bool hovered: __rootItem.hovered

                            Behavior on opacity {
                                enabled: root.animationEnabled && __private.supportsHalfAnimation
                                NumberAnimation { duration: MosTheme.Primary.durationFast }
                            }
                        }

                        Loader {
                            id: emptyLoader
                            anchors.fill: parent
                            active: true
                            opacity: index >= __repeater.emptyStartIndex ? 1.0 : 0.0
                            sourceComponent: root.emptyDelegate
                            property int index: __rootItem.index
                            property bool hovered: __rootItem.hovered

                            Behavior on opacity {
                                enabled: root.animationEnabled
                                NumberAnimation { duration: MosTheme.Primary.durationFast }
                            }
                        }
                    }

                    Loader {
                        x: (parent.width - width) * 0.5
                        y: -height - 4
                        z: 10
                        active: root.showToolTip
                        sourceComponent: root.toolTipDelegate
                        property int index: __rootItem.index
                        property bool hovered: __rootItem.hovered
                    }
                }
            }
        }
    }

    QtObject {
        id: __private
        property real doneValue: 0
        /* 是否支持半星动画 */
        property bool supportsHalfAnimation: root.allowHalf &&
                                             ((fillIcon === MosIcon.StarFilled && emptyIcon === MosIcon.StarFilled) || halfIcon !== emptyIcon)
    }
}
