import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import MosuiBasic

T.Control {
    id: root

    signal valueModified()
    signal beforeActivated(index: int, var data)
    signal afterActivated(index: int, var data)

    property bool animationEnabled: MosTheme.animationEnabled
    property bool active: hovered || activeFocus
    property alias type: __input.type
    property alias showShadow: __input.showShadow
    property alias clearEnabled: __input.clearEnabled
    property alias clearIconSource: __input.clearIconSource
    property alias clearIconSize: __input.clearIconSize
    property alias clearIconPosition: __input.clearIconPosition
    property alias readOnly: __input.readOnly
    property bool showHandler: true
    property bool alwaysShowHandler: false
    property bool useWheel: false
    property bool useKeyboard: true
    property real value: 0
    property real min: Number.MIN_SAFE_INTEGER
    property real max: Number.MAX_SAFE_INTEGER
    property real step: 1
    property int precision: 0
    property alias validator: __input.validator
    property string prefix: ''
    property string suffix: ''
    property var upIcon: MosIcon.UpOutlined || ''
    property var downIcon: MosIcon.DownOutlined || ''
    property alias inputFont: root.font
    property font labelFont: Qt.font({
                                         family: 'MoskarUI-Icons',
                                         pixelSize: parseInt(themeSource.fontSize) * sizeRatio
                                     })
    property var beforeLabel: '' || []
    property var afterLabel: '' || []
    property int initBeforeLabelIndex: 0
    property int initAfterLabelIndex: 0
    property string currentBeforeLabel: ''
    property string currentAfterLabel: ''
    property var formatter: (value, locale) => value.toLocaleString(locale, 'f', precision)
    property var parser: (text, locale) => MosApi.clamp(Number.fromLocaleString(locale, text), min, max)
    property int defaultHandlerWidth: 22
    property alias colorText: __input.colorText
    property alias colorBg: __input.colorBg
    property color colorShadow: enabled ? themeSource.colorShadow : 'transparent'
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosInput

    property alias input: __input

    property Component beforeDelegate: MosRectangleInternal {
        width: Math.max(30 * root.sizeRatio, __beforeCompLoader.implicitWidth + 10 * root.sizeRatio)
        topLeftRadius: root.radiusBg.topLeft
        bottomLeftRadius: root.radiusBg.bottomLeft
        color: root.colorBg
        border.color: enabled ? root.themeSource.colorBorder :
                                root.themeSource.colorBorderDisabled

        Loader {
            id: __beforeCompLoader
            anchors.centerIn: parent
            sourceComponent: typeof root.beforeLabel == 'string' ? __labelComp : __selectComp
            property bool isBefore: true
        }
    }
    property Component afterDelegate: MosRectangleInternal {
        width: Math.max(30 * root.sizeRatio, __afterCompLoader.implicitWidth + 10 * root.sizeRatio)
        topRightRadius: root.radiusBg.topRight
        bottomRightRadius: root.radiusBg.bottomRight
        color: root.colorBg
        border.color: enabled ? root.themeSource.colorBorder :
                                root.themeSource.colorBorderDisabled

        Loader {
            id: __afterCompLoader
            anchors.centerIn: parent
            sourceComponent: typeof root.afterLabel == 'string' ? __labelComp : __selectComp
            property bool isBefore: false
        }
    }
    property Component handlerDelegate: MosRectangleInternal {
        id: __handlerRoot
        clip: true
        width: enabled && (root.hovered || root.alwaysShowHandler) ? root.defaultHandlerWidth : 0
        radius: 0
        topRightRadius: root.afterLabel?.length === 0 ? root.radiusBg.topRight : 0
        bottomRightRadius: root.afterLabel?.length === 0 ? root.radiusBg.bottomRight : 0
        color: root.colorBg

        property real halfHeight: height * 0.5
        property real hoverHeight: height * 0.6
        property real noHoverHeight: height * 0.4
        property color colorBorder: enabled ? root.themeSource.colorBorder :
                                              root.themeSource.colorBorderDisabled
        property color colorHandlerBg: 'transparent'

        Behavior on width {
            enabled: root.animationEnabled;
            NumberAnimation {
                easing.type: Easing.OutCubic
                duration: MosTheme.Primary.durationMid
            }
        }

        MosIconButton {
            id: __upButton
            padding: 0
            width: parent.width
            height: hovered ? parent.hoverHeight :
                              __downButton.hovered ? parent.noHoverHeight : parent.halfHeight
            animationEnabled: root.animationEnabled
            sizeRatio: root.sizeRatio
            autoRepeat: true
            colorIcon: root.enabled ?
                           hovered ? root.themeSource.colorBorderHover :
                                     root.themeSource.colorBorder : root.themeSource.colorBorderDisabled
            iconSize: parseInt(root.themeSource.fontSize) - 4
            iconSource: root.upIcon
            hoverCursorShape: root.value >= root.max ? Qt.ForbiddenCursor : Qt.PointingHandCursor
            background: null
            onClicked: {
                root.increase();
                root.valueModified();
            }

            Behavior on height { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        }

        MosIconButton {
            id: __downButton
            padding: 0
            width: parent.width
            height: (hovered ? parent.hoverHeight :
                               __upButton.hovered ? parent.noHoverHeight : parent.halfHeight) + 1
            anchors.top: __upButton.bottom
            anchors.topMargin: -1
            animationEnabled: root.animationEnabled
            sizeRatio: root.sizeRatio
            autoRepeat: true
            colorIcon: root.enabled ?
                           hovered ? root.themeSource.colorBorderHover :
                                     root.themeSource.colorBorder : root.themeSource.colorBorderDisabled
            iconSize: parseInt(root.themeSource.fontSize) - 4
            iconSource: root.downIcon
            hoverCursorShape: root.value <= root.min ? Qt.ForbiddenCursor : Qt.PointingHandCursor
            background: null
            onClicked: {
                root.decrease();
                root.valueModified();
            }

            Behavior on height { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationFast } }
        }

        Rectangle {
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: __handlerRoot.colorBorder
        }

        Rectangle {
            width: parent.width
            height: 1
            anchors.top: __upButton.bottom
            color: __handlerRoot.colorBorder
        }
    }

    function getFullText(): string {
        return __input.text;
    }

    function increase() {
        value = value + step > max ? max : value + step;
    }

    function decrease() {
        value = value - step < min ? min : value - step;
    }

    function select(start: int, end: int) {
        __input.select(start, end);
    }

    function selectAll(start: int, end: int) {
        __input.selectAll(start, end);
    }

    function selectWord(start: int, end: int) {
        __input.selectWord(start, end);
    }

    function clear() {
        __input.clear();
        root.valueChanged();
    }

    function copy() {
        __input.copy();
    }

    function cut() {
        __input.cut();
        root.valueChanged();
    }

    function paste() {
        __input.paste();
        root.valueChanged();
    }

    function redo() {
        __input.redo();
        root.valueChanged();
    }

    function undo() {
        __input.undo();
        root.valueChanged();
    }

    onValueChanged: __input.text = formatter(value, root.locale);
    onPrefixChanged: valueChanged();
    onSuffixChanged: valueChanged();
    onCurrentAfterLabelChanged: valueChanged();
    onCurrentBeforeLabelChanged: valueChanged();
    Component.onCompleted: valueChanged();

    objectName: '__MosInputNumber__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    validator: DoubleValidator {
        locale: root.locale.name
        bottom: Math.min(root.min, root.max)
        top: Math.max(root.min, root.max)
    }
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    contentItem: RowLayout {
        id: __row
        spacing: 0

        Loader {
            Layout.rightMargin: -1
            Layout.fillHeight: true
            visible: active
            active: root.beforeLabel?.length !== 0
            sourceComponent: root.beforeDelegate
        }

        MosInput {
            id: __input
            z: 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            leftPadding: (__prefixLoader.active ? __prefixLoader.implicitWidth : (leftClearIconPadding > 0 ? 5 : 10))
                         + leftIconPadding + leftClearIconPadding
            rightPadding: (__suffixLoader.active ? __suffixLoader.implicitWidth : (rightClearIconPadding > 0 ? 5 : 10))
                          + rightIconPadding + rightClearIconPadding
            animationEnabled: root.animationEnabled
            sizeRatio: root.sizeRatio
            themeSource: root.themeSource
            validator: root.validator
            font: root.font
            radiusBg.all: root.radiusBg.all
            radiusBg.topLeft: root.beforeLabel?.length === 0 ? root.radiusBg.topLeft : 0
            radiusBg.topRight: root.afterLabel?.length === 0 ? root.radiusBg.topRight : 0
            radiusBg.bottomLeft: root.beforeLabel?.length === 0 ? root.radiusBg.bottomLeft : 0
            radiusBg.bottomRight: root.afterLabel?.length === 0 ? root.radiusBg.bottomRight : 0
            clearIconDelegate: MosIconText {
                iconSource: root.clearIconSource
                iconSize: root.clearIconSize
                leftPadding: root.clearIconPosition === MosInput.Position_Left ? (root.leftIconPadding > 0 ? 5 : 10) * root.sizeRatio : 0
                rightPadding: root.clearIconPosition === MosInput.Position_Right ?
                                  ((root.rightIconPadding > 0 ? 5 : 10) * root.sizeRatio + __handlerLoader.implicitWidth) : 0
                colorIcon: {
                    if (root.enabled) {
                        return __tapHandler.pressed ? root.themeSource.colorClearIconActive :
                                                      __hoverHandler.hovered ? root.themeSource.colorClearIconHover :
                                                                               root.themeSource.colorClearIcon;
                    } else {
                        return root.themeSource.colorClearIconDisabled;
                    }
                }

                Behavior on colorIcon { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

                HoverHandler {
                    id: __hoverHandler
                    enabled: (root.clearEnabled === 'active' || root.clearEnabled === true) && !root.readOnly
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: __tapHandler
                    enabled: (root.clearEnabled === 'active' || root.clearEnabled === true) && !root.readOnly
                    onTapped: {
                        root.clear();
                        root.valueModified();
                    }
                }
            }
            onActiveFocusChanged: {
                if (!activeFocus) editingFinished();
            }
            onEditingFinished: {
                if (length === 0) return;
                let v = root.parser(text, root.locale);
                text = root.formatter(v, root.locale);
                root.value = v;
                root.valueModified();
            }

            Keys.onReturnPressed: {
                editingFinished();
            }
            Keys.onEnterPressed: {
                editingFinished();
            }
            Keys.onUpPressed: {
                if (root.enabled && root.useKeyboard) {
                    root.increase();
                    root.valueModified();
                }
            }
            Keys.onDownPressed: {
                if (root.enabled && root.useKeyboard) {
                    root.decrease();
                    root.valueModified();
                }
            }

            WheelHandler {
                enabled: root.enabled && root.useWheel
                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        root.increase();
                        root.valueModified();
                    } else {
                        root.decrease();
                        root.valueModified();
                    }
                }
            }

            Loader {
                id: __prefixLoader
                height: parent.height
                visible: active
                active: root.prefix !== ''
                sourceComponent: MosText {
                    leftPadding: 10 * root.sizeRatio
                    rightPadding: 5 * root.sizeRatio
                    text: root.prefix
                    color: __input.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Loader {
                id: __suffixLoader
                height: parent.height
                anchors.right: __handlerLoader.left
                visible: active
                active: root.suffix !== ''
                sourceComponent: MosText {
                    leftPadding: 5 * root.sizeRatio
                    rightPadding: 10 * root.sizeRatio
                    text: root.suffix
                    color: __input.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Loader {
                id: __handlerLoader
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 1
                visible: active
                active: root.showHandler && !__input.readOnly
                sourceComponent: root.handlerDelegate
            }
        }

        Loader {
            Layout.leftMargin: -1
            Layout.fillHeight: true
            visible: active
            active: root.afterLabel?.length !== 0
            sourceComponent: root.afterDelegate
        }
    }

    Component {
        id: __selectComp

        MosSelect {
            id: __afterText
            animationEnabled: root.animationEnabled
            sizeRatio: root.sizeRatio
            colorBg: 'transparent'
            colorBorder: 'transparent'
            clearEnabled: false
            model: isBefore ? root.beforeLabel : root.afterLabel
            currentIndex: isBefore ? root.initBeforeLabelIndex : root.initAfterLabelIndex
            onActivated:
                (index) => {
                    if (isBefore) {
                        root.beforeActivated(index, valueAt(index));
                    } else {
                        root.afterActivated(index, valueAt(index));
                    }
                }
            onCurrentTextChanged: {
                if (isBefore)
                    root.currentBeforeLabel = currentText;
                else
                    root.currentAfterLabel = currentText;
            }
        }
    }

    Component {
        id: __labelComp

        MosText {
            text: isBefore ? root.beforeLabel : root.afterLabel
            color: __input.colorText
            font: root.labelFont
            Component.onCompleted: {
                if (isBefore)
                    root.currentBeforeLabel = root.beforeLabel;
                else
                    root.currentAfterLabel = root.afterLabel;
            }
        }
    }
}
