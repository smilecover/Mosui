import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import MosuiBasic

T.Control {
    id: root

    enum ImageStyle
    {
        Style_None = 0,
        Style_Default = 1,
        Style_Simple = 2
    }

    property int imageStyle: MosEmpty.Style_Default
    property string imageSource: {
        switch (imageStyle) {
        case MosEmpty.Style_None: return '';
        case MosEmpty.Style_Default: return 'qrc:/image/image/empty-default.svg';
        case MosEmpty.Style_Simple: return 'qrc:/image/image/empty-simple.svg';
        }
    }
    property int imageWidth: {
        switch (imageStyle) {
        case MosEmpty.Style_None: return width / 3;
        case MosEmpty.Style_Default: return 92;
        case MosEmpty.Style_Simple: return 64;
        }
    }
    property int imageHeight: {
        switch (imageStyle) {
        case MosEmpty.Style_None: return height / 3;
        case MosEmpty.Style_Default: return 76;
        case MosEmpty.Style_Simple: return 41;
        }
    }
    property bool showDescription: true
    property string description: ''
    property int descriptionSpacing: 12
    property alias descriptionFont: root.font
    property color colorDescription: themeSource.colorDescription
    property var themeSource: MosTheme.MosEmpty

    property Component imageDelegate: Image {
        width: root.imageWidth
        height: root.imageHeight
        source: root.imageSource
        sourceSize: Qt.size(width, height)
    }
    property Component descriptionDelegate: MosText {
        text: root.description
        font: root.descriptionFont
        color: root.colorDescription
        horizontalAlignment: Text.AlignHCenter
    }

    objectName: '__MosEmpty__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) - 1
    }
    contentItem: Item {
        implicitWidth: 200
        implicitHeight: 200

        ColumnLayout {
            anchors.centerIn: parent
            spacing: root.descriptionSpacing

            Loader {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                visible: active
                active: root.imageSource !== '' || root.imageStyle !== MosEmpty.Style_None
                sourceComponent: root.imageDelegate
            }

            Loader {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                visible: active
                active: root.showDescription
                sourceComponent: root.descriptionDelegate
            }
        }
    }
}
