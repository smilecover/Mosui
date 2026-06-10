
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum State {
        State_Success = 1,
        State_Processing = 2,
        State_Error = 3,
        State_Warning  = 4,
        State_Default = 5
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property int badgeState: MosBadge.State_Error
    property string presetColor: ''
    property int count: 0
    property var iconSource: 0 ?? ''
    property bool dot: false
    property bool showZero: false
    property int overflowCount: 99
    property color colorBg: presetColor == '' ? (!__private.isNumber ? 'transparent' : MosTheme.Primary.colorError) :
                                                __private.isCustom ? presetColor : __private.colorArray[5]
    property alias colorBorder: __border.border.color
    property color colorText: 'white'

    onCountChanged: {
        const max = Math.min(count, overflowCount);
        if (max !== __private.lastCount) {
            if (max > __private.lastCount) {
                __numberList.model = [__private.lastCount, max];
                __upAnimation.restart();
            } else {
                __numberList.model = [max, __private.lastCount];
                __downAnimation.restart();
            }
            __private.lastCount = max;
        }
    }
    onBadgeStateChanged: {
        switch (badgeState) {
        case MosBadge.State_Success: presetColor = '#52c41a'; break;
        case MosBadge.State_Processing: presetColor = '#1677ff'; break;
        case MosBadge.State_Error: presetColor = '#ff4d4f'; break;
        case MosBadge.State_Warning: presetColor = '#faad14'; break;
        case MosBadge.State_Default: presetColor = '#888888'; break;
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

        if (badgeState === MosBadge.State_Error) {
            __private.isCustom = preset == -1 ? true : false;
            __private.presetColor = preset == -1 ? '#000' : husColorGenerator.presetToColor(preset);
        } else {
            __private.isCustom = false;
            __private.presetColor = presetColor;
        }
    }

    objectName: '__MosBadge__'
    z: 1
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    anchors.left: __private.parentIsLayout ? undefined : parent.right
    anchors.leftMargin: __private.parentIsLayout ? 0 : -width * 0.5
    anchors.bottom: __private.parentIsLayout ? undefined : parent.top
    anchors.bottomMargin: __private.parentIsLayout ? 0 : -height * 0.5
    font {
        family: __private.isNumber ? MosTheme.Primary.fontPrimaryFamily : 'MoskarUI-Icons'
        pixelSize: __private.isNumber ? 12 : 16
    }
    contentItem: Item {
        implicitWidth: __badge.width
        implicitHeight: __badge.height

        Rectangle {
            id: __effect
            visible: root.badgeState === MosBadge.State_Processing
            x: __border.x + (__border.width - width) * 0.5
            y: __border.y + (__border.height - height) * 0.5
            radius: height * 0.5
            color: 'transparent'
            border.color: __badge.color

            ParallelAnimation {
                running: __effect.visible
                loops: Animation.Infinite

                NumberAnimation {
                    target: __effect
                    property: 'width'
                    from: __border.width + 2
                    to: __border.width + 8
                    easing.type: Easing.OutQuart
                    duration: 1000
                }

                NumberAnimation {
                    target: __effect
                    property: 'height'
                    from: __border.height + 2
                    to: __border.height + 8
                    easing.type: Easing.OutQuart
                    duration: 1000
                }

                NumberAnimation {
                    target: __effect
                    property: 'opacity'
                    from: 0.4
                    to: 0
                    duration: 1000
                }
            }
        }

        Rectangle {
            id: __border
            visible: __badge.visible
            width: __badge.width + 2
            height: __badge.height + 2
            anchors.centerIn: __badge
            radius: height * 0.5
            color: 'transparent'
            border.width: 2
            border.color: !__private.isNumber ? 'transparent' : 'white'
            scale: __badge.scale
        }

        Rectangle {
            id: __badge
            visible: scale !== 0
            width: root.dot ? 8 : Math.max(__content.width + 12, height)
            height: root.dot ? 8 : 20
            anchors.centerIn: parent
            radius: height * 0.5
            color: root.colorBg
            scale: (root.dot || root.count > 0 || root.showZero || !__private.isNumber) ? 1 : 0

            Behavior on scale {
                enabled: root.animationEnabled
                NumberAnimation {
                    duration: MosTheme.Primary.durationMid
                    easing.type: Easing.InOutBack
                }
            }

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            Behavior on width { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }
            Behavior on height { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }

            Item {
                visible: !root.dot
                anchors.fill: parent

                MosText {
                    id: __content
                    visible: (root.count > 0 || root.showZero || !__private.isNumber) && !__upAnimation.running && !__downAnimation.running
                    font: root.font
                    text: root.iconSource === 0 ? (root.count > root.overflowCount ? `${root.overflowCount}+` : root.count) :
                                                     String.fromCharCode(root.iconSource)
                    color: root.colorText
                    anchors.centerIn: parent
                }

                ListView {
                    id: __numberList
                    visible: (root.count > 0 || root.showZero || !__private.isNumber) && root.iconSource === 0 && !__content.visible
                    anchors.fill: parent
                    interactive: false
                    clip: true
                    delegate: MosText {
                        width: __numberList.width
                        height: __numberList.height
                        text: modelData
                        color: root.colorText
                        font: root.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    NumberAnimation on contentY {
                        id: __upAnimation
                        from: 0
                        to: __numberList.height
                        duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
                        easing.type: Easing.InOutBack
                    }

                    NumberAnimation on contentY {
                        id: __downAnimation
                        from: __numberList.height
                        to: 0
                        duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
                        easing.type: Easing.InOutBack
                    }
                }
            }
        }
    }

    MosColorGenerator { id: husColorGenerator }

    QtObject {
        id: __private

        property bool isCustom: false
        property color presetColor: '#000'
        property var colorArray: MosThemeFunctions.genColor(presetColor, !MosTheme.isDark, MosTheme.Primary.colorBgBase)
        property int lastCount: root.count
        property bool isNumber: root.iconSource === 0 || root.iconSource === ''
        property bool parentIsLayout: root.parent instanceof Row || root.parent instanceof RowLayout ||
                                      root.parent instanceof Column || root.parent instanceof ColumnLayout ||
                                      root.parent instanceof Grid || root.parent instanceof GridLayout ||
                                      root.parent instanceof Flow
    }
}
