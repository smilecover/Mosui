import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

MosPopup {
    id: root

    property var iconSource: MosIcon.ExclamationCircleFilled || ''
    property int iconSize: 16
    property string title: ''
    property string description: ''
    property bool showArrow: true
    property int arrowWidth: 16
    property int arrowHeight: 8
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
        property color fillStyle: root.colorBg
    }
    property Component iconDelegate: MosIconText {
        color: root.colorIcon
        iconSource: root.iconSource
        iconSize: root.iconSize
    }
    property Component titleDelegate: MosText {
        font: root.titleFont
        color: root.colorTitle
        text: root.title
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }
    property Component descriptionDelegate: MosText {
        font: root.descriptionFont
        color: root.colorDescription
        text: root.description
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }
    property Component contentDelegate: Item {
        height: __columnLayout.implicitHeight + 20

        ColumnLayout {
            id: __columnLayout
            width: parent.width - 20
            anchors.centerIn: parent
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                visible: __iconLoader.active || __titleLoader.active

                Loader {
                    id: __iconLoader
                    Layout.alignment: Qt.AlignVCenter
                    active: root.iconSource !== 0 && root.iconSource !== ''
                    sourceComponent: root.iconDelegate
                }

                Loader {
                    id: __titleLoader
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    active: root.title !== ''
                    sourceComponent: root.titleDelegate
                }
            }

            Loader {
                Layout.leftMargin: __iconLoader.width + 5
                Layout.fillWidth: true
                visible: active
                active: root.description !== ''
                sourceComponent: root.descriptionDelegate
            }

            Loader {
                id: __footerLoader
                Layout.fillWidth: true
                sourceComponent: root.footerDelegate
            }
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
    property Component footerDelegate: Item { }

    objectName: '__MosPopover__'
    themeSource: MosTheme.MosPopover
    implicitHeight: implicitBackgroundHeight + topInset + bottomInset
    transformOrigin: __private.isTop ? Item.Bottom : Item.Top
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
    exit: Transition {
        NumberAnimation {
            property: 'scale'
            from: 1.0
            to: 0.5
            easing.type: Easing.InQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
        NumberAnimation {
            property: 'opacity'
            from: 1.0
            to: 0
            easing.type: Easing.InQuad
            duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
        }
    }
    background: Item {
        implicitHeight: __bg.height

        MosShadow {
            anchors.fill: __bg
            source: __bg
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

        Item {
            id: __bg
            width: parent.width
            height: __arrowLoader.height + __contentLoader.height

            Loader {
                id: __arrowLoader
                x: -root.x + (__private.parentWidth - width) * 0.5
                y: __private.isTop ? (__bg.height - height) : 0
                width: root.arrowWidth
                height: root.arrowHeight
                rotation: __private.isTop ? 180 : 0
                active: root.showArrow
                sourceComponent: root.arrowDelegate
            }

            Loader {
                id: __bgLoader
                y: __private.isTop ? 0 : __arrowLoader.height
                width: parent.width
                height: __contentLoader.height
                sourceComponent: root.bgDelegate
            }
        }

        Loader {
            id: __contentLoader
            y: __private.isTop ? 0 : __arrowLoader.height
            width: parent.width
            sourceComponent: root.contentDelegate
        }
    }
    Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);

    QtObject {
        id: __private
        property real parentWidth: root.parent?.width ?? 0
        property real parentHeight: root.parent?.height ?? 0
        property bool isTop: root.y < parentHeight
    }
}
