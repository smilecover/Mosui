import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

MosPopup {
    id: root

    enum Position {
        Position_Top = 0,
        Position_Bottom = 1,
        Position_Center = 2,
        Position_Left = 3,
        Position_Right = 4
    }

    signal confirm()
    signal cancel()

    property int position: MosModal.Position_Center
    property int positionMargin: 120
    property bool closable: true
    property bool maskClosable: true
    property var iconSource: 0 ?? ''
    property int iconSize: 24
    property string title: ''
    property string description: ''
    property string confirmText: ''
    property string cancelText: ''
    property color colorOverlay: root.themeSource.colorOverlay
    property color colorIcon: root.themeSource.colorIcon
    property color colorTitle: root.themeSource.colorTitle
    property color colorDescription: root.themeSource.colorDescription
    property font titleFont: Qt.font({
                                         family: root.themeSource.fontFamily,
                                         bold: true,
                                         pixelSize: parseInt(root.themeSource.fontSizeTitle)
                                     })
    property font descriptionFont: Qt.font({
                                               family: root.themeSource.fontFamily,
                                               pixelSize: parseInt(root.themeSource.fontSizeDescription)
                                           })
    property Component iconDelegate: MosIconText {
        color: root.colorIcon
        iconSource: root.iconSource
        iconSize: root.iconSize
    }
    property Component confirmButtonDelegate: MosButton {
        animationEnabled: root.animationEnabled
        text: root.confirmText
        type: MosButton.Type_Primary
        onClicked: root.confirm();
    }
    property Component cancelButtonDelegate: MosButton {
        animationEnabled: root.animationEnabled
        text: root.cancelText
        type: MosButton.Type_Default
        onClicked: root.cancel();
    }
    property Component closeButtonDelegate: MosCaptionButton {
        animationEnabled: root.animationEnabled
        topPadding: 4
        bottomPadding: 4
        leftPadding: 8
        rightPadding: 8
        hoverCursorShape: Qt.PointingHandCursor
        iconSource: MosIcon.CloseOutlined
        radiusBg.all: root.themeSource.radiusCloseBg
        onClicked: root.close();
    }
    property Component titleDelegate: MosText {
        height: root.title == '' ? 0 : implicitHeight
        font: root.titleFont
        color: root.colorTitle
        text: root.title
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }
    property Component bodyDelegate: MosText {
        height: root.description == '' ? 0 : implicitHeight
        font: root.descriptionFont
        color: root.colorDescription
        text: root.description
        lineHeight: root.themeSource.fontLineHeightDescription
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }
    property Component contentDelegate: Item {
        height: __columnLayout.implicitHeight + 40

        Column {
            id: __columnLayout
            width: parent.width - 40
            anchors.centerIn: parent
            spacing: 10

            RowLayout {
                width: parent.width
                spacing: 10

                Loader {
                    id: __iconLoader
                    Layout.alignment: Qt.AlignVCenter
                    visible: active
                    active: root.iconSource !== 0 && root.iconSource !== ''
                    sourceComponent: root.iconDelegate
                }

                Loader {
                    id: __titleLoader
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    sourceComponent: root.titleDelegate
                }
            }

            Loader {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: __iconLoader.active ? (__iconLoader.width + 10) : 0
                sourceComponent: root.bodyDelegate
            }

            Loader {
                width : parent.width
                sourceComponent: root.footerDelegate
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
    property Component bgDelegate: MosRectangleInternal {
        color: root.colorBg
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
    }
    property Component footerDelegate: Item {
        height: __footer.height

        Row {
            id: __footer
            anchors.right: parent.right
            spacing: 10

            Loader {
                active: root.confirmText !== ''
                sourceComponent: root.confirmButtonDelegate
            }

            Loader {
                active: root.cancelText !== ''
                sourceComponent: root.cancelButtonDelegate
            }
        }
    }

    function openInfo() {
        iconSource = MosIcon.ExclamationCircleFilled;
        colorIcon = MosTheme.Primary.colorInfo;
        open();
    }

    function openSuccess() {
        iconSource = MosIcon.CheckCircleFilled;
        colorIcon = MosTheme.Primary.colorSuccess;
        open();
    }

    function openError() {
        iconSource = MosIcon.CloseCircleFilled;
        colorIcon = MosTheme.Primary.colorError;
        open();
    }

    function openWarning() {
        iconSource = MosIcon.ExclamationCircleFilled;
        colorIcon = MosTheme.Primary.colorWarning;
        open();
    }

    function close() {
        if (!visible || __private.isClosing) return;
        if (animationEnabled) {
            __private.startClosing();
        } else {
            visible = false;
        }
    }

    objectName: '__MosModal__'
    themeSource: MosTheme.MosModal
    parent: T.Overlay.overlay
    x: {
        switch (root.position) {
        case MosModal.Position_Top:
            return (parent.width - width) * 0.5;
        case MosModal.Position_Bottom:
            return (parent.width - width) * 0.5;
        case MosModal.Position_Center:
            return (parent.width - width) * 0.5;
        case MosModal.Position_Left:
            return positionMargin;
        case MosModal.Position_Right:
            return parent.width - width - positionMargin;
        }
    }
    y: {
        switch (root.position) {
        case MosModal.Position_Top:
            return positionMargin;
        case MosModal.Position_Bottom:
            return parent.height - height - positionMargin;
        case MosModal.Position_Center:
            return (parent.height - height) * 0.5;
        case MosModal.Position_Left:
            return (parent.height - height) * 0.5;
        case MosModal.Position_Right:
            return (parent.height - height) * 0.5;
        }
    }
    modal: true
    focus: true
    closePolicy: maskClosable ? T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside : T.Popup.NoAutoClose
    enter: Transition {
        NumberAnimation {
            property: 'scale'
            from: 0.5
            to: 1.0
            easing.type: Easing.OutQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
        NumberAnimation {
            property: 'opacity'
            from: 0.0
            to: 1.0
            easing.type: Easing.OutQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
    }
    exit: null
    contentItem: Item {
        implicitWidth: 500
        implicitHeight: __contentLoader.height

        Loader {
            id: __contentLoader
            width: parent.width
            sourceComponent: root.contentDelegate
        }
    }
    background: Item {
        MosShadow {
            anchors.fill: __bgLoader
            source: __bgLoader
            shadowColor: root.colorShadow
        }

        Loader {
            active: root.movable || root.resizable
            sourceComponent: MosResizeMouseArea {
                anchors.fill: parent
                target: root
                movable: root.movable
                resizable: root.resizable
                minimumX: root.minimumX
                maximumX: root.maximumX
                minimumY: root.minimumY
                maximumY: root.maximumY
                minimumWidth: root.minimumWidth
                maximumWidth: root.maximumWidth
                minimumHeight: root.minimumHeight
                maximumHeight: root.maximumHeight
            }
        }

        Loader {
            id: __bgLoader
            anchors.fill: parent
            sourceComponent: root.bgDelegate
        }
    }
    onAboutToHide: {
        if (animationEnabled && !__private.isClosing && opacity > 0) {
            visible = true;
            __private.startClosing();
        }
    }
    T.Overlay.modal: Item {
        Rectangle {
            anchors.fill: parent
            color: root.colorOverlay
            opacity: root.opacity
        }
    }

    QtObject {
        id: __private

        property bool isClosing: false

        function startClosing() {
            if (isClosing) return;
            isClosing = true;
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
            root.visible = false;
        }
    }

    NumberAnimation  {
        running: __private.isClosing
        target: root
        property: 'scale'
        from: 1.0
        to: 0.5
        easing.type: Easing.InQuad
        duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
    }
}
