import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    signal editingFinished()

    property bool animationEnabled: MosTheme.animationEnabled
    property bool active: __textArea.hovered || __textArea.activeFocus
    property bool resizable: false
    property int minResizeHeight: 30
    property bool autoSize: false
    property int minRows: -1
    property int maxRows: -1
    readonly property alias lineCount: __textArea.lineCount
    property alias length: __textArea.length
    property int maxLength: -1
    property alias readOnly: __textArea.readOnly
    property alias textFormat: __textArea.textFormat
    property alias text: __textArea.text
    property alias placeholderText: __textArea.placeholderText
    property alias colorText: __textArea.color
    property alias colorPlaceholderText: __textArea.placeholderTextColor
    property alias colorSelectedText: __textArea.selectedTextColor
    property alias colorSelection: __textArea.selectionColor
    property color colorBorder: enabled ? active ? themeSource.colorBorderHover :
                                                   themeSource.colorBorder : themeSource.colorBorderDisabled
    property color colorBg: enabled ? themeSource.colorBg : themeSource.colorBgDisabled
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string contentDescription: ''
    property var themeSource: MosTheme.MosTextArea

    property alias textArea: __textArea
    property alias verScrollBar: __vScrollBar
    property alias horScrollBar: __hScrollBar

    property Component bgDelegate: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
    }

    function scrollToBeginning() {
        __textArea.cursorPosition = 0;
    }

    function scrollToEnd() {
        __textArea.cursorPosition = __textArea.length;
    }

    function clear() {
        __textArea.clear();
    }

    Behavior on colorText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorPlaceholderText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorSelectedText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorBorder { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

    onTextChanged: __private.removeExcess();
    onMaxLengthChanged: __private.removeExcess();

    objectName: '__MosTextArea__'
    topPadding: 6
    bottomPadding: 6
    leftPadding: 10
    rightPadding: 10
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    wheelEnabled: autoSize ? (minRows > 0 && maxRows > 0) : (__vScrollBar.visible || __vScrollBar.active)
    contentItem: Item {
        implicitHeight: {
            if (root.autoSize) {
                if (root.minRows > 0 && root.maxRows > 0) {
                    if (root.lineCount < root.minRows)
                        return __private.minHeight + __textArea.topPadding + __textArea.bottomPadding;
                    else if (lineCount > maxRows) {
                        return __private.maxHeight + __textArea.topPadding + __textArea.bottomPadding;
                    } else {
                        return root.lineCount * __private.lineHeight + __textArea.topPadding + __textArea.bottomPadding;
                    }
                } else {
                    return __textArea.implicitHeight;
                }
            } else {
                return root.minResizeHeight;
            }
        }

        Behavior on implicitHeight {
            enabled: root.animationEnabled && !__resize.pressed
            NumberAnimation {
                duration: MosTheme.Primary.durationMid
            }
        }

        /*! [QtBug] 必须先创建一遍 ScrollBar */
        component SV: T.ScrollView {
            id: __root
            T.ScrollBar.vertical: T.ScrollBar { }
            T.ScrollBar.horizontal: T.ScrollBar { }
        }

        SV {
            id: __scrollView
            focus: true
            anchors.fill: parent
            T.ScrollBar.vertical: MosScrollBar {
                id: __vScrollBar
                parent: __scrollView
                x: __scrollView.mirrored ? 0 : __scrollView.width - width
                y: __scrollView.topPadding
                height: __scrollView.availableHeight
                orientation: Qt.Vertical
                policy: MosScrollBar.AlwaysOn
                animationEnabled: root.animationEnabled
                active: __scrollView.MosScrollBar.horizontal.active
            }
            T.ScrollBar.horizontal: MosScrollBar {
                id: __hScrollBar
                parent: __scrollView
                x: __scrollView.leftPadding
                y: __scrollView.height - height
                width: __scrollView.availableWidth
                orientation: Qt.Horizontal
                policy: T.ScrollBar.AlwaysOn
                animationEnabled: root.animationEnabled
                active: __scrollView.T.ScrollBar.vertical.active
            }
            Component.onCompleted: {
                contentItem.boundsBehavior = Flickable.StopAtBounds;
            }

            T.TextArea {
                id: __textArea
                focus: true
                implicitWidth: Math.max(contentWidth + leftPadding + rightPadding,
                                        implicitBackgroundWidth + leftInset + rightInset,
                                        __placeholder.implicitWidth + leftPadding + rightPadding)
                implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                                         implicitBackgroundHeight + topInset + bottomInset,
                                         __placeholder.implicitHeight + topPadding + bottomPadding)
                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0
                wrapMode: T.TextArea.WrapAnywhere
                renderType: MosTheme.textRenderType
                selectByMouse: true
                selectByKeyboard: true
                color: enabled ? root.themeSource.colorText : root.themeSource.colorTextDisabled
                placeholderTextColor: enabled ? themeSource.colorPlaceholderText : themeSource.colorPlaceholderTextDisabled
                selectedTextColor: root.themeSource.colorTextSelected
                selectionColor: root.themeSource.colorSelection
                font: root.font
                onEditingFinished: root.editingFinished();

                PlaceholderText {
                    id: __placeholder
                    x: parent.leftPadding
                    y: parent.topPadding
                    width: parent.width - (parent.leftPadding + parent.rightPadding)
                    height: parent.height - (parent.topPadding + parent.bottomPadding)

                    text: parent.placeholderText
                    font: parent.font
                    color: parent.placeholderTextColor
                    verticalAlignment: parent.verticalAlignment
                    visible: !parent.length && !parent.preeditText && (!parent.activeFocus || parent.horizontalAlignment !== Qt.AlignHCenter)
                    elide: Text.ElideRight
                    renderType: parent.renderType
                }
            }
        }
    }
    background: Loader {
        sourceComponent: root.bgDelegate
    }

    MosIconText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 1
        iconSource: MosIcon.MinusOutlined
        rotation: -45
        visible: root.resizable
        enabled: visible

        MosIconText {
            y: 4
            iconSource: MosIcon.MinusOutlined
            scale: 0.5
        }

        MouseArea {
            id: __resize
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            onEntered: cursorShape = Qt.SizeVerCursor;
            onExited: cursorShape = Qt.ArrowCursor;
            onPressed: mouse => {
                startY = mouseY;
                mouse.accepted = true;
            }
            onReleased: mouse => mouse.accepted = true;
            onPositionChanged: mouse => {
                if (pressed) {
                    const offsetY = mouse.y - startY;
                    root.height = Math.max(root.height + offsetY, root.minResizeHeight);
                    mouse.accepted = true;
                }
            }
            property int startY: 0
        }
    }

    QtObject {
        id: __private

        property real minHeight: lineHeight * root.minRows
        property real maxHeight: lineHeight * root.maxRows
        property real lineHeight: __textArea.contentHeight / __textArea.lineCount

        function removeExcess() {
            if (root.maxLength > 0 && root.length > root.maxLength) {
                __textArea.remove(root.maxLength, root.length);
            }
        }
    }

    Accessible.role: Accessible.EditableText
    Accessible.editable: !root.readOnly
    Accessible.description: root.contentDescription
}
