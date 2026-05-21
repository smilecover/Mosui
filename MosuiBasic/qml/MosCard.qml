import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import MosuiBasic

T.Control {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool hoverable: false
    property bool showShadow: hoverable
    property string title: ''
    property string coverSource: ''
    property int coverFillMode: Image.Stretch
    property real borderWidth: 1
    property int bodyAvatarSize: 40
    property var bodyAvatarIcon: 0 ?? ''
    property string bodyAvatarSource: ''
    property string bodyAvatarText: ''
    property string bodyTitle: ''
    property string bodyDescription: ''
    property font titleFont: Qt.font({
                                         family: themeSource.fontFamily,
                                         pixelSize: parseInt(themeSource.fontSizeTitle),
                                         weight: Font.DemiBold,
                                     })
    property font bodyTitleFont: Qt.font({
                                             family: themeSource.fontFamily,
                                             pixelSize: parseInt(themeSource.fontSizeBodyTitle),
                                             weight: Font.DemiBold,
                                         })
    property font bodyDescriptionFont: Qt.font({
                                                   family: themeSource.fontFamily,
                                                   pixelSize: parseInt(themeSource.fontSizeBodyDescription),
                                               })
    property color colorTitle: themeSource.colorTitle
    property color colorBg: themeSource.colorBg
    property color colorBorder: themeSource.colorBorder
    property color colorShadow: themeSource.colorShadow
    property color colorBodyAvatar: themeSource.colorBodyAvatar
    property color colorBodyAvatarBg: 'transparent'
    property color colorBodyTitle: themeSource.colorBodyTitle
    property color colorBodyDescription: themeSource.colorBodyDescription
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property var themeSource: MosTheme.MosCard

    property Component titleDelegate: Item {
        implicitHeight: 60

        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            anchors.leftMargin: 15
            anchors.rightMargin: 15

            MosText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.title
                font: root.titleFont
                color: root.colorTitle
                wrapMode: Text.WrapAnywhere
                verticalAlignment: Text.AlignVCenter
            }

            Loader {
                Layout.alignment: Qt.AlignVCenter
                sourceComponent: extraDelegate
            }
        }

        MosDivider {
            width: parent.width;
            height: 1
            anchors.bottom: parent.bottom
            animationEnabled: root.animationEnabled
            visible: root.coverSource == ''
        }
    }
    property Component extraDelegate: Item { }
    property Component coverDelegate: Image {
        height: root.coverSource == '' ? 0 : 180
        source: root.coverSource
        fillMode: root.coverFillMode
    }
    property Component bodyDelegate: Item {
        implicitHeight: 100

        RowLayout {
            anchors.fill: parent

            Item {
                Layout.preferredWidth: __avatar.visible ? 70 : 0
                Layout.fillHeight: true

                MosAvatar {
                    id: __avatar
                    size: root.bodyAvatarSize
                    anchors.centerIn: parent
                    colorBg: root.colorBodyAvatarBg
                    iconSource: root.bodyAvatarIcon
                    imageSource: root.bodyAvatarSource
                    textSource: root.bodyAvatarText
                    colorIcon: root.colorBodyAvatar
                    colorText: root.colorBodyAvatar
                    visible: !((iconSource === 0 || iconSource === '') && imageSource === '' && textSource === '')
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                MosText {
                    Layout.fillWidth: true
                    leftPadding: __avatar.visible ? 0 : 15
                    rightPadding: 15
                    text: root.bodyTitle
                    font: root.bodyTitleFont
                    color: root.colorBodyTitle
                    wrapMode: Text.WrapAnywhere
                    visible: root.bodyTitle != ''
                }

                MosText {
                    Layout.fillWidth: true
                    leftPadding: __avatar.visible ? 0 : 15
                    rightPadding: 15
                    text: root.bodyDescription
                    font: root.bodyDescriptionFont
                    color: root.colorBodyDescription
                    wrapMode: Text.WrapAnywhere
                    visible: root.bodyDescription != ''
                }
            }
        }
    }
    property Component actionDelegate: Item { }
    property Component bgDelegate: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        border.width: root.borderWidth
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    }

    objectName: '__MosCard__'
    z: (hoverable && hovered) ? 1 : 0
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    contentItem: Column {
        Loader {
            width: parent.width
            sourceComponent: root.titleDelegate
        }

        Loader {
            width: parent.width - 2
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: root.coverDelegate
        }

        Loader {
            width: parent.width - 2
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: root.bodyDelegate
        }

        Loader {
            width: parent.width
            sourceComponent: root.actionDelegate
        }
    }
    background: Item {
        implicitWidth: 300

        Loader {
            anchors.fill: __bgLoader
            active: root.hoverable || root.showShadow
            sourceComponent: MosShadow {
                source: __bgLoader
                scale: root.hoverable ? (root.hovered ? 1.01 : 1.0) : 1.0
                shadowOpacity: root.hoverable ? (root.hovered ? 0.3 : 0) : 0.3
                shadowScale: 1.02
                shadowColor: root.colorShadow

                Behavior on scale {
                    enabled: root.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }

                Behavior on shadowOpacity {
                    enabled: root.animationEnabled
                    NumberAnimation { duration: MosTheme.Primary.durationFast }
                }
            }
        }

        Loader {
            id: __bgLoader
            anchors.fill: parent
            visible: !(root.hoverable || root.showShadow)
            sourceComponent: root.bgDelegate
        }
    }
}
