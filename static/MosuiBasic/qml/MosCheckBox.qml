import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Templates as T
import MosuiBasic

T.CheckBox {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool effectEnabled: true
    property int hoverCursorShape: Qt.PointingHandCursor
    property int indicatorSize: 18 * sizeRatio
    property int elide: Text.ElideNone
    property color colorText: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    property color colorIndicator: {
        if (enabled) {
            return (checkState !== Qt.Unchecked) ? hovered ? themeSource.colorIndicatorCheckedHover :
                                                             themeSource.colorIndicatorChecked : themeSource.colorIndicator
        } else {
            return themeSource.colorIndicatorDisabled;
        }
    }
    property color colorIndicatorBorder: enabled ?
                                             (hovered || checked) ? themeSource.colorIndicatorBorderChecked :
                                                                    themeSource.colorIndicatorBorder : themeSource.colorIndicatorDisabled
    property MosRadius radiusIndicator: MosRadius { all: themeSource.radiusIndicator }
    property string contentDescription: ''
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosCheckBox

    Behavior on colorText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorIndicator { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    Behavior on colorIndicatorBorder { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

    objectName: '__MosCheckBox__'
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(implicitContentHeight, implicitIndicatorHeight) + topPadding + bottomPadding
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    spacing: 6 * sizeRatio
    indicator: Item {
        x: root.leftPadding
        implicitWidth: __bg.width
        implicitHeight: __bg.height
        anchors.verticalCenter: parent.verticalCenter

        MosRectangleInternal {
            id: __effect
            width: __bg.width
            height: __bg.height
            anchors.centerIn: parent
            visible: root.effectEnabled
            radius: __bg.radius
            topLeftRadius: __bg.topLeftRadius
            topRightRadius: __bg.topRightRadius
            bottomLeftRadius: __bg.bottomLeftRadius
            bottomRightRadius: __bg.bottomRightRadius
            color: 'transparent'
            border.width: 0
            border.color: root.enabled ? root.themeSource.colorEffectBg : 'transparent'
            opacity: 0.2

            ParallelAnimation {
                id: __animation
                onFinished: __effect.border.width = 0;
                NumberAnimation {
                    target: __effect; property: 'width'; from: __bg.width + 2; to: __bg.width + 10;
                    duration: MosTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'height'; from: __bg.height + 2; to: __bg.height + 10;
                    duration: MosTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'opacity'; from: 0.1; to: 0;
                    duration: MosTheme.Primary.durationSlow
                }
            }

            Connections {
                target: root
                function onReleased() {
                    if (root.animationEnabled && root.effectEnabled) {
                        __effect.border.width = 6;
                        __animation.restart();
                    }
                }
            }
        }

        MosRectangleInternal {
            id: __bg
            width: root.indicatorSize
            height: root.indicatorSize
            radius: root.radiusIndicator.all
            topLeftRadius: root.radiusIndicator.topLeft
            topRightRadius: root.radiusIndicator.topRight
            bottomLeftRadius: root.radiusIndicator.bottomLeft
            bottomRightRadius: root.radiusIndicator.bottomRight
            color: 'transparent'
            border.color: root.colorIndicatorBorder
            border.width: 1
            anchors.centerIn: parent

            /*! 勾选背景 */
            MosRectangleInternal {
                id: __checkedBg
                anchors.fill: parent
                color: root.colorIndicator
                visible: opacity > 0
                opacity: enabled ? (root.checkState === Qt.Checked ? 1 : 0) : 1
                radius: parent.radius - 1
                topLeftRadius: Math.max(0, parent.topLeftRadius - 1)
                topRightRadius: Math.max(0, parent.topRightRadius - 1)
                bottomLeftRadius: Math.max(0, parent.bottomLeftRadius - 1)
                bottomRightRadius: Math.max(0, parent.bottomRightRadius - 1)

                Behavior on opacity {
                    enabled: root.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }
            }

            /*! 勾选标记 */
            Item {
                id: __checkMarkContainer
                anchors.centerIn: parent
                width: parent.width * 0.6
                height: parent.height * 0.6
                visible: opacity > 0
                scale: root.checkState === Qt.Checked ? 1.1 : 0.2
                opacity: root.checkState === Qt.Checked ? 1.0 : 0.0

                Behavior on scale {
                    enabled: root.animationEnabled && __checkMark.animationEnabled
                    NumberAnimation { easing.overshoot: 2.5; easing.type: Easing.OutBack; duration: MosTheme.Primary.durationSlow }
                }

                Behavior on opacity {
                    enabled: root.animationEnabled && __checkMark.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }

                Canvas {
                    id: __checkMark
                    anchors.fill: parent
                    visible: root.checkState === Qt.Checked

                    property bool animationEnabled: false
                    property real animationProgress: root.checkState === Qt.Checked ? 1 : 0
                    property real lineWidth: 2
                    property color checkColor: root.enabled ? '#fff' : root.themeSource.colorIndicatorDisabled

                    onAnimationProgressChanged: requestPaint();
                    onCheckColorChanged: requestPaint();
                    onVisibleChanged: requestPaint();
                    Component.onCompleted: animationEnabled = true;

                    onPaint: {
                        const ctx = getContext('2d');
                        ctx.clearRect(0, 0, width, height);

                        ctx.lineWidth = lineWidth;
                        ctx.strokeStyle = checkColor;
                        ctx.fillStyle = 'transparent';
                        ctx.lineCap = 'round';
                        ctx.lineJoin = 'round';

                        const startX = width * 0.2;
                        const midPointX = width * 0.4;
                        const endX = width * 0.8;
                        const midPointY = height * 0.75;
                        const startY = height * 0.5;
                        const endY = height * 0.2;

                        ctx.beginPath();

                        if (animationProgress > 0) {
                            ctx.moveTo(startX, startY);
                            if (animationProgress < 0.5) {
                                const currentX = startX + (midPointX - startX) * (animationProgress * 2);
                                const currentY = startY + (midPointY - startY) * (animationProgress * 2);
                                ctx.lineTo(currentX, currentY);
                            } else {
                                const t = (animationProgress - 0.5) * 2;
                                const currentX = midPointX + (endX - midPointX) * t;
                                const currentY = midPointY + (endY - midPointY) * t;
                                ctx.lineTo(midPointX, midPointY);
                                ctx.lineTo(currentX, currentY);
                            }
                        }

                        ctx.stroke();
                    }

                    Behavior on animationProgress {
                        enabled: root.animationEnabled && __checkMark.animationEnabled
                        NumberAnimation {
                            duration: MosTheme.Primary.durationSlow
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            /*! 部分选择状态 */
            Rectangle {
                id: __partialCheckMark
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: parent.width * 0.5
                height: parent.height * 0.5
                color: root.colorIndicator
                visible: root.checkState === Qt.PartiallyChecked
                radius: parent.radius * 0.5

                Behavior on opacity {
                    enabled: root.animationEnabled && __checkMark.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }
            }
        }
    }
    contentItem: MosText {
        leftPadding: root.indicator && !root.mirrored ? root.indicator.width + spacing : 0
        rightPadding: root.indicator && root.mirrored ? root.indicator.width + spacing : 0
        text: root.text
        font: root.font
        color: root.colorText
        verticalAlignment: Text.AlignVCenter
        elide: root.elide
        property real spacing: (text.length > 0 ? root.spacing : 0)

        Behavior on color {
            enabled: root.animationEnabled
            ColorAnimation { duration: MosTheme.Primary.durationMid }
        }
    }

    HoverHandler {
        cursorShape: root.hoverCursorShape
    }

    Accessible.role: Accessible.CheckBox
    Accessible.name: root.text
    Accessible.description: root.contentDescription
    Accessible.onPressAction: root.clicked();
}
