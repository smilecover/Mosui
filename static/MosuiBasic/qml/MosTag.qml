import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum State {
        State_Default = 0,
        State_Success = 1,
        State_Processing = 2,
        State_Error = 3,
        State_Warning  = 4
    }

    signal close()

    property bool animationEnabled: MosTheme.animationEnabled
    property int tagState: MosTag.State_Default
    property string text: ''
    property bool rotating: false
    property var iconSource: 0 ?? ''
    property int iconSize: parseInt(MosTheme.MosButton.fontSize)
    property var closeIconSource: 0 ?? ''
    property int closeIconSize: parseInt(MosTheme.MosButton.fontSize)
    property string presetColor: ''
    property color colorText: presetColor == '' ? root.themeSource.colorDefaultText : __private.isCustom ? '#fff' : __private.colorArray[5]
    property color colorBg: presetColor == '' ? root.themeSource.colorDefaultBg : __private.isCustom ? presetColor : __private.colorArray[0]
    property color colorBorder: presetColor == '' ? root.themeSource.colorDefaultBorder : __private.isCustom ? 'transparent' : __private.colorArray[2]
    property color colorIcon: colorText
    property MosRadius radiusBg: MosRadius { all: root.themeSource.radiusBg }
    property var themeSource: MosTheme.MosTag

    onTagStateChanged: {
        switch (tagState) {
        case MosTag.State_Success: presetColor = '#52c41a'; break;
        case MosTag.State_Processing: presetColor = '#1677ff'; break;
        case MosTag.State_Error: presetColor = '#ff4d4f'; break;
        case MosTag.State_Warning: presetColor = '#faad14'; break;
        case MosTag.State_Default:
        default: presetColor = '';
        }
    }
    onPresetColorChanged: {
        let preset = -1;
        switch (presetColor) {
        case 'red': preset = MosColorGenerator.Preset_Red; break;
        case 'volcano': preset = MosColorGenerator.Preset_Volcano; break;
        case 'orange': preset = MosColorGenerator.Preset_Orange; break;
        case 'gold': preset = MosColorGenerator.Preset_Gold; break;
        case 'yellow': preset = MosColorGenerator.Preset_Yellow; break;
        case 'lime': preset = MosColorGenerator.Preset_Lime; break;
        case 'green': preset = MosColorGenerator.Preset_Green; break;
        case 'cyan': preset = MosColorGenerator.Preset_Cyan; break;
        case 'blue': preset = MosColorGenerator.Preset_Blue; break;
        case 'geekblue': preset = MosColorGenerator.Preset_Geekblue; break;
        case 'purple': preset = MosColorGenerator.Preset_Purple; break;
        case 'magenta': preset = MosColorGenerator.Preset_Magenta; break;
        }

        if (tagState == MosTag.State_Default) {
            __private.isCustom = preset == -1 ? true : false;
            __private.presetColor = preset == -1 ? '#000' : husColorGenerator.presetToColor(preset);
        } else {
            __private.isCustom = false;
            __private.presetColor = presetColor;
        }
    }

    objectName: '__MosTag__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    topPadding: 4
    bottomPadding: 4
    leftPadding: 8
    rightPadding: 8
    spacing: 5
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize) - 2
    }
    contentItem: Row {
        height: Math.max(__icon.implicitHeight, __text.implicitHeight, __closeIcon.implicitHeight)
        spacing: root.spacing

        MosIconText {
            id: __icon
            anchors.verticalCenter: parent.verticalCenter
            color: root.colorIcon
            iconSize: root.iconSize
            iconSource: root.iconSource
            verticalAlignment: Text.AlignVCenter
            visible: !isIcon

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

            NumberAnimation on rotation {
                id: __animation
                running: root.rotating
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1000
            }
        }

        MosCopyableText {
            id: __text
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font: root.font
            color: root.colorText

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
        }

        MosIconText {
            id: __closeIcon
            anchors.verticalCenter: parent.verticalCenter
            color: hovered ? root.themeSource.colorCloseIconHover : root.themeSource.colorCloseIcon
            iconSize: root.closeIconSize
            iconSource: root.closeIconSource
            verticalAlignment: Text.AlignVCenter
            visible: !isIcon

            property alias hovered: __hoverHander.hovered
            property alias down: __tapHander.pressed

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

            HoverHandler {
                id: __hoverHander
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                id: __tapHander
                onTapped: root.close();
            }
        }
    }
    background: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }
    }

    MosColorGenerator {
        id: husColorGenerator
    }

    QtObject {
        id: __private
        property bool isCustom: false
        property color presetColor: '#000'
        property var colorArray: MosThemeFunctions.genColor(presetColor, !MosTheme.isDark, MosTheme.Primary.colorBgBase)
    }
}
