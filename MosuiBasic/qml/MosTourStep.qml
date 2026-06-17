import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Popup {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool penetrationEvent: false
    property bool closable: true
    property bool maskClosable: false
    property var stepModel: []
    property Item currentTarget: null
    property int currentStep: 0
    property color colorOverlay: MosTheme.MosTour.colorOverlay
    property bool showArrow: true
    property int arrowWidth: 16
    property int arrowHeight: 8
    property int focusMargin: 5
    property int focusRadius: 2
    property int stepCardWidth: 250
    property MosRadius radiusStepCard: MosRadius { all: MosTheme.MosTour.radiusCard }
    property color colorStepCard: MosTheme.MosTour.colorBg
    property font stepTitleFont: Qt.font({
                                             bold: true,
                                             family: MosTheme.MosTour.fontFamily,
                                             pixelSize: parseInt(MosTheme.MosTour.fontSizeTitle)
                                         })
    property color colorStepTitle: MosTheme.MosTour.colorText
    property font stepDescriptionFont: Qt.font({
                                                   family: MosTheme.MosTour.fontFamily,
                                                   pixelSize: parseInt(MosTheme.MosTour.fontSizeDescription)
                                               })
    property color colorStepDescription: MosTheme.MosTour.colorText
    property font indicatorFont: Qt.font({
                                             family: MosTheme.MosTour.fontFamily,
                                             pixelSize: parseInt(MosTheme.MosTour.fontSizeIndicator)
                                         })
    property color colorIndicator: MosTheme.MosTour.colorText
    property font buttonFont: Qt.font({
                                          family: MosTheme.MosTour.fontFamily,
                                          pixelSize: parseInt(MosTheme.MosTour.fontSizeButton)
                                      })
    property Component arrowDelegate: Canvas {
        id: __arrowDelegate
        width: arrowWidth
        height: arrowHeight
        onWidthChanged: requestPaint();
        onHeightChanged: requestPaint();
        onFillStyleChanged: requestPaint();
        onPaint: {
            const ctx = getContext('2d');
            ctx.fillStyle = fillStyle;
            ctx.beginPath();
            ctx.moveTo(0, height);
            ctx.lineTo(width * 0.5, 0);
            ctx.lineTo(width, height);
            ctx.closePath();
            ctx.fill();
        }
        property color fillStyle: root.colorStepCard

        Connections {
            target: root
            function onCurrentTargetChanged() {
                if (root.stepModel.length > root.currentStep) {
                    const stepData = root.stepModel[root.currentStep];
                    __arrowDelegate.fillStyle = Qt.binding(() => stepData.cardColor ? stepData.cardColor : root.colorStepCard);
                }
                __arrowDelegate.requestPaint();
            }
        }
    }
    property Component closeButtonDelegate: MosCaptionButton {
        topPadding: 2
        bottomPadding: 2
        leftPadding: 4
        rightPadding: 4
        animationEnabled: root.animationEnabled
        radiusBg.all: MosTheme.MosTour.radiusButtonBg
        iconSource: MosIcon.CloseOutlined
        hoverCursorShape: Qt.PointingHandCursor
        onClicked: {
            root.close();
        }
    }
    property Component stepCardDelegate: MosRectangleInternal {
        id: __stepCardDelegate
        width: stepData.cardWidth ? stepData.cardWidth : root.stepCardWidth
        height: stepData.cardHeight ? stepData.cardHeight : (__stepCardColumn.height + 20)
        color: stepData.cardColor ? stepData.cardColor : root.colorStepCard
        radius: stepData.cardRadius ? stepData.cardRadius : root.radiusStepCard.all
        topLeftRadius: stepData.cardRadius ? stepData.cardRadius : root.radiusStepCard.topLeft
        topRightRadius: stepData.cardRadius ? stepData.cardRadius : root.radiusStepCard.topRight
        bottomLeftRadius: stepData.cardRadius ? stepData.cardRadius : root.radiusStepCard.bottomLeft
        bottomRightRadius: stepData.cardRadius ? stepData.cardRadius : root.radiusStepCard.bottomRight
        clip: true

        property var stepData: root.stepModel[root.currentStep]

        Connections {
            target: root
            function onCurrentTargetChanged() {
                if (root.stepModel.length > root.currentStep)
                    __stepCardDelegate.stepData = root.stepModel[root.currentStep];
            }
        }

        Column {
            id: __stepCardColumn
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            MosText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: stepData.title ? stepData.title : ''
                color: stepData.titleColor ? stepData.titleColor : root.colorStepTitle
                font: root.stepTitleFont
            }

            MosText {
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                text: stepData.description || ''
                visible: text.length !== 0
                color: stepData.descriptionColor ? stepData.descriptionColor : root.colorStepDescription
                font: root.stepDescriptionFont
            }

            Item {
                width: parent.width
                height: 30

                Loader {
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: root.indicatorDelegate
                }

                MosButton {
                    id: __prevButton
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: __nextButton.left
                    anchors.rightMargin: 15
                    anchors.bottom: __nextButton.bottom
                    visible: root.currentStep != 0
                    animationEnabled: root.animationEnabled
                    text: qsTr('上一步')
                    font: root.buttonFont
                    type: MosButton.Type_Outlined
                    onClicked: {
                        if (root.currentStep > 0) {
                            root.currentStep -= 1;
                            __stepCardDelegate.stepData = root.stepModel[root.currentStep];
                            root.currentTarget = __stepCardDelegate.stepData.target;
                        }
                    }
                }

                MosButton {
                    id: __nextButton
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.bottom: parent.bottom
                    animationEnabled: root.animationEnabled
                    text: (root.currentStep + 1 == root.stepModel.length) ? qsTr('结束导览') : qsTr('下一步')
                    font: root.buttonFont
                    type: MosButton.Type_Primary
                    onClicked: {
                        if ((root.currentStep + 1 == root.stepModel.length)) {
                            root.close();
                        } else if (root.currentStep + 1 < root.stepModel.length) {
                            root.currentStep += 1;
                            __stepCardDelegate.stepData = root.stepModel[root.currentStep];
                            root.currentTarget = __stepCardDelegate.stepData.target;
                        }
                    }
                }
            }
        }

        Loader {
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.top: parent.top
            anchors.topMargin: 2
            sourceComponent: root.closeButtonDelegate
            active: root.closable
        }
    }
    property Component indicatorDelegate: MosText {
        text: (root.currentStep + 1) + ' / ' + root.stepModel.length
        font: root.indicatorFont
        color: root.colorIndicator
    }

    function gotoStep(step: int) {
        if (stepModel.length > step) {
            currentStep = step;
            currentTarget = stepModel[root.currentStep].target;
        }
    }

    function resetStep() {
        currentStep = 0;
        if (stepModel.length > currentStep) {
            currentTarget = stepModel[root.currentStep].target;
        }
    }

    function appendStep(object) {
        stepModel.push(object);
        stepModelChanged();
    }

    function close() {
        if (!visible || __private.isClosing) return;
        if (animationEnabled) {
            __private.startClosing();
        } else {
            visible = false;
        }
    }

    onStepModelChanged: {
        resetStep();
        __private.recalcPosition();
    }
    onCurrentTargetChanged: __private.recalcPosition();
    onFocusMarginChanged: {
        __private.recalcPosition();
    }
    onFocusRadiusChanged: {
        __private.repaint();
    }
    onAboutToShow: {
        __private.recalcPosition();
        opacity = 1.0;
    }
    onAboutToHide: {
        if (animationEnabled && !__private.isClosing && opacity > 0) {
            visible = true;
            __private.startClosing();
        }
    }

    objectName: '__MosTourStep__'
    x: 0
    y: 0
    enter: Transition {
        NumberAnimation {
            property: 'opacity';
            from: 0.0
            to: 1.0
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
    }
    exit: null
    focus: true
    modal: !penetrationEvent
    dim: true
    closePolicy: maskClosable ? T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside : T.Popup.NoAutoClose
    parent: T.Overlay.overlay
    T.Overlay.modal: Item {
        Canvas {
            id: __canvas
            anchors.fill: parent
            opacity: root.opacity
            onPaint: {
                const ctx = getContext('2d');
                ctx.clearRect(0, 0, width, height);

                ctx.save();
                ctx.fillStyle = root.colorOverlay;
                ctx.fillRect(0, 0, width, height);

                ctx.globalCompositeOperation = 'destination-out';
                ctx.fillStyle = '#fff';

                const rect = Qt.rect(__private.focusX, __private.focusY, __private.focusWidth, __private.focusHeight);
                ctx.beginPath();
                ctx.moveTo(rect.x + root.focusRadius, rect.y);
                ctx.lineTo(rect.x + rect.width - root.focusRadius, rect.y);
                ctx.arcTo(rect.x + rect.width, rect.y, rect.x + rect.width, rect.y + root.focusRadius, root.focusRadius);
                ctx.lineTo(rect.x + rect.width, rect.y + rect.height - root.focusRadius);
                ctx.arcTo(rect.x + rect.width, rect.y + rect.height, rect.x + rect.width - root.focusRadius, rect.y + rect.height, root.focusRadius);
                ctx.lineTo(rect.x + root.focusRadius, rect.y + rect.height);
                ctx.arcTo(rect.x, rect.y + rect.height, rect.x, rect.y + rect.height - root.focusRadius, root.focusRadius);
                ctx.lineTo(rect.x, rect.y + root.focusRadius);
                ctx.arcTo(rect.x, rect.y, rect.x + root.focusRadius, rect.y, root.focusRadius);
                ctx.closePath();
                ctx.fill();

                ctx.restore();
            }
        }

        Connections {
            target: __private
            function onRepaint() {
                __canvas.requestPaint();
            }
        }

        Item {
            id: __eventArea
            x: __private.focusX
            y: __private.focusY
            width: __private.focusWidth
            height: __private.focusHeight
            visible: false
        }

        /*! 禁止 currentTarget 外的滚动 */
        WheelHandler {
            onWheel:
                event => {
                    if (!__eventArea.contains(Qt.point(event.x, event.y))) {
                        event.accepted = true;
                    }
                }
        }
    }
    T.Overlay.modeless: T.Overlay.modal
    background: Item {
        Item {
            id: __anchor
            x: __private.focusX + __private.focusWidth * 0.5
            y: __private.focusY + __private.focusHeight
            opacity: root.opacity
            onYChanged: recalcPosition();

            property bool isTop: false

            function recalcPosition() {
                isTop = (__anchor.y + __arrowLoader.height + __stepLoader.itemHeight + 5) > __stepLoader.winHeight;
            }

            Loader {
                id: __arrowLoader
                y: __anchor.isTop ? (-__private.focusHeight - height - 5) : 5
                width: root.arrowWidth
                height: root.arrowHeight
                anchors.horizontalCenter: parent.horizontalCenter
                sourceComponent: root.arrowDelegate
                rotation: __anchor.isTop ? 180 : 0
            }

            Loader {
                id: __stepLoader
                x: {
                    if (__anchor.x - itemWidth * 0.5 > 0) {
                        if (__anchor.x + itemWidth * 0.5 > winWidth) {
                            /*! 最右 */
                            return winWidth - __anchor.x - itemWidth;
                        } else {
                            /*! 中心 */
                            return -itemWidth * 0.5;
                        }
                    } else {
                        /*! 最左 */
                        return -__anchor.x;
                    }
                }
                y: __anchor.isTop ? (__arrowLoader.y - itemHeight + 1) : (__arrowLoader.y + __arrowLoader.height - 1)
                sourceComponent: root.stepCardDelegate
                onItemWidthChanged: __anchor.recalcPosition();
                onItemHeightChanged: __anchor.recalcPosition();
                onWinWidthChanged: {
                    __private.recalcPosition(true);
                    __anchor.recalcPosition();
                }
                onWinHeightChanged: {
                    __private.recalcPosition(true);
                    __anchor.recalcPosition();
                }

                property real itemWidth: item?.width ?? 0
                property real itemHeight: item?.height ?? 0
                property real winWidth: Window.window?.width ?? 0
                property real winHeight: Window.window?.height ?? 0
            }
        }
    }

    NumberAnimation {
        running: __private.isClosing
        target: root
        property: 'opacity'
        from: 1.0
        to: 0.0
        duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        easing.type: Easing.InQuad
        onFinished: {
            __private.isClosing = false;
            root.resetStep();
            root.visible = false;
        }
    }

    Item {
        id: __private

        signal repaint()

        property bool first: true
        property real focusX: 0
        property real focusY: 0
        property real focusWidth: root.currentTarget ? (currentTarget.width + focusMargin * 2) : 0
        property real focusHeight: root.currentTarget ? (currentTarget.height + focusMargin * 2) : 0
        property bool isClosing: false

        onFocusXChanged: repaint();
        onFocusYChanged: repaint();
        onFocusWidthChanged: repaint();
        onFocusHeightChanged: repaint();

        function recalcPosition(delay = false) {
            if (delay) {
                /*! 需要延时计算 */
                __privateTimer.restart();
            } else {
                __privateTimer.calcPosition();
            }
        }

        function startClosing() {
            if (isClosing) return;
            isClosing = true;
        }

        Behavior on focusX {
            enabled: root.animationEnabled
            NumberAnimation { easing.type: Easing.OutQuart; duration: MosTheme.Primary.durationSlow }
        }
        Behavior on focusY {
            enabled: root.animationEnabled
            NumberAnimation { easing.type: Easing.OutQuart; duration: MosTheme.Primary.durationSlow }
        }
        Behavior on focusWidth {
            enabled: root.animationEnabled
            NumberAnimation { easing.type: Easing.OutQuart; duration: MosTheme.Primary.durationSlow }
        }
        Behavior on focusHeight {
            enabled: root.animationEnabled
            NumberAnimation { easing.type: Easing.OutQuart; duration: MosTheme.Primary.durationSlow }
        }
    }

    Timer {
        id: __privateTimer
        interval: 200
        onTriggered: calcPosition();

        function calcPosition() {
            if (!root.currentTarget) return;
            const pos = root.currentTarget.mapToItem(null, 0, 0);
            __private.focusX = pos.x - root.focusMargin;
            __private.focusY = pos.y - root.focusMargin;
            __private.repaint();
        }
    }
}
