import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property real spinSize: 24 * root.sizeRatio
    property real indicatorSize: 7 * root.sizeRatio
    property int indicatorItemCount: 4
    property bool spinning: true
    property string tip: ''
    property var percent: 'auto' || 0
    property color colorTip: themeSource.colorTip
    property color colorIndicator: themeSource.colorIndicator
    property color colorProgressBar: themeSource.colorProgressBar
    property string sizeHint: 'normal'
    property real sizeRatio: {
        switch (sizeHint) {
        case 'small': return 0.6;
        case 'normal': return 1.0;
        case 'large': return 1.6;
        }
    }
    property string contentDescription: ''
    property var themeSource: MosTheme.MosSpin

    property Component indicatorDelegate: Repeater {
        model: root.indicatorItemCount
        delegate: Item {
            id: __rootItem
            x: halfSize + (halfSize - root.indicatorSize * 0.5) *
               Math.cos(2 * Math.PI * index / root.indicatorItemCount) - root.indicatorSize * 0.5
            y: halfSize + (halfSize - root.indicatorSize * 0.5) *
               Math.sin(2 * Math.PI * index / root.indicatorItemCount) - root.indicatorSize * 0.5

            required property int index

            Loader {
                sourceComponent: root.indicatorItemDelegate
                property alias index: __rootItem.index
                property real itemSize: root.indicatorSize
            }
        }
        property real halfSize: root.spinSize * 0.5
    }
    property Component indicatorItemDelegate: Rectangle {
        id: __indicatorDelegate
        width: itemSize
        height: width
        radius: width * 0.5
        color: root.colorIndicator

        OpacityAnimator on opacity {
            id: opacityAnimator
            duration: 1200
            loops: 1
            alwaysRunToEnd: true
            onFinished: {
                reverse = !reverse;
                from = reverse ? 1.0 : 0.2;
                to = reverse ? 0.2 : 1.0;
                restart();
            }
            property bool reverse: false
        }

        Timer {
            interval: (index + 1) * 1200 / root.indicatorItemCount
            onCanRunChanged: {
                if (canRun) {
                    restart();
                } else {
                    opacityAnimator.stop();
                }
            }
            onTriggered: {
                opacityAnimator.reverse = false;
                opacityAnimator.from = 0.2;
                opacityAnimator.to = 1.0;
                opacityAnimator.restart();
            }
            property bool canRun: root.animationEnabled && root.spinning
        }
    }
    property Component tipDelegate: MosText {
        text: root.tip
        font: root.font
        color: root.colorTip
    }

    objectName: '__MosSpin__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 0
    spacing: 5
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    contentItem: ColumnLayout {
        spacing: root.spacing

        Item {
            id: __spinner
            Layout.preferredWidth: root.spinSize
            Layout.preferredHeight: root.spinSize
            Layout.alignment: Qt.AlignHCenter
            visible: root.spinning
            opacity: root.spinning ? 1 : 0

            property bool isProgress: typeof root.percent === 'number'

            Loader {
                id: __indicatorLoader
                anchors.fill: parent
                scale: __spinner.isProgress ? 0.0 : 1.0
                visible: scale > 0
                sourceComponent: root.indicatorDelegate

                Behavior on scale {
                    enabled: root.animationEnabled
                    NumberAnimation {
                        easing.type: Easing.InOutQuad
                        duration: MosTheme.Primary.durationSlow
                    }
                }

                Behavior on opacity {
                    enabled: root.animationEnabled;
                    NumberAnimation {
                        easing.type: Easing.InOutQuad
                        duration: MosTheme.Primary.durationMid
                    }
                }

                RotationAnimator on rotation {
                    running: root.animationEnabled && root.spinning
                    from: 0
                    to: 360
                    duration: 1200
                    loops: Animation.Infinite
                }
            }

            Loader {
                active: __spinner.isProgress
                anchors.fill: parent
                scale: 1.0 - __indicatorLoader.scale
                visible: scale > 0
                sourceComponent: MosProgress {
                    type: MosProgress.Type_Circle
                    animationEnabled: root.animationEnabled
                    showInfo: false
                    percent: root.percent
                    barThickness: 4 * root.sizeRatio
                    colorBar: root.colorProgressBar
                }
            }
        }

        Loader {
            Layout.alignment: Qt.AlignHCenter
            active: root.tip !== ''
            sourceComponent: root.tipDelegate
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: root.tip
    Accessible.description: root.contentDescription
}
