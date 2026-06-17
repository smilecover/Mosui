import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    signal finished(input: string)

    property bool animationEnabled: MosTheme.animationEnabled
    property int type: MosInput.Type_Outlined
    property bool showShadow: false
    property int length: 6
    property int characterLength: 1
    property int currentIndex: 0
    property string currentInput: ''
    property int itemWidth: 45 * sizeRatio
    property int itemHeight: 32 * sizeRatio
    property alias itemSpacing: root.spacing
    property var itemValidator: IntValidator { top: 9; bottom: 0 }
    property int itemInputMethodHints: Qt.ImhHiddenText
    property bool itemPassword: false
    property string itemPasswordCharacter: ''
    property var formatter: (text) => text
    property color colorItemText: enabled ? themeSource.colorText : themeSource.colorTextDisabled
    property color colorItemBorder: enabled ? themeSource.colorBorder : themeSource.colorBorderDisabled
    property color colorItemBorderActive: enabled ? themeSource.colorBorderHover : themeSource.colorBorderDisabled
    property color colorItemBg: enabled ? themeSource.colorBg : themeSource.colorBgDisabled
    property color colorShadow: enabled ? themeSource.colorShadow : 'transparent'
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosInput

    property Component dividerDelegate: Item { }

    function setInput(inputs: var) {
        inputs.forEach((input, i) => setInputAtIndex(i, input));
    }

    function setInputAtIndex(index: int, input: string) {
        const item = __repeater.itemAt(index << 1);
        if (item) {
            currentIndex = index;
            item.item.text = formatter(input);
        }
    }

    function getInput(): string {
        let input = '';
        for (let i = 0; i < __repeater.count; i++) {
            const item = __repeater.itemAt(i);
            if (item && item.index % 2 == 0) {
                input += item.item.text;
            }
        }
        return input;
    }

    function getInputAtIndex(index: int): string {
        const item = __repeater.itemAt(index << 1);
        if (item) {
            return item.item.text;
        }
        return '';
    }

    onCurrentIndexChanged: {
        const item = __repeater.itemAt(currentIndex << 1);
        if (item && item.index % 2 == 0)
            item.item.selectThis();
    }

    objectName: '__MosOTPInput__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    spacing: 8 * sizeRatio
    contentItem: Row {
        id: __row
        spacing: root.spacing

        Repeater {
            id: __repeater
            model: root.length * 2 - 1
            delegate: Loader {
                sourceComponent: index % 2 == 0 ? __inputDelegate : dividerDelegate
                required property int index
            }
        }
    }

    Component {
        id: __inputDelegate

        MosInput {
            id: __rootItem
            width: root.itemWidth
            height: root.itemHeight
            verticalAlignment: MosInput.AlignVCenter
            horizontalAlignment: MosInput.AlignHCenter
            enabled: root.enabled
            animationEnabled: root.animationEnabled
            sizeRatio: root.sizeRatio
            themeSource: root.themeSource
            showShadow: root.showShadow
            font: root.font
            colorText: root.colorItemText
            colorBorder: active ? root.colorItemBorderActive : root.colorItemBorder
            colorBg: root.colorItemBg
            colorShadow: root.colorShadow
            radiusBg: root.radiusBg
            validator: root.itemValidator
            inputMethodHints: root.itemInputMethodHints
            echoMode: root.itemPassword ? MosInput.Password : MosInput.Normal
            passwordCharacter: root.itemPasswordCharacter
            onReleased: __timer.restart();
            onTextEdited: {
                text = root.formatter(text);
                const isFull = length >= root.characterLength;
                if (isFull) selectAll();

                if (isBackspace) isBackspace = false;

                const input = root.getInput();
                root.currentInput = input;

                if (isFull) {
                    if (root.currentIndex < (root.length - 1))
                        root.currentIndex++;
                    else
                        root.finished(input);
                }
            }

            property int __index: index
            property bool isBackspace: false

            function selectThis() {
                forceActiveFocus();
                selectAll();
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Backspace) {
                    clear();
                    const input = root.getInput();
                    root.currentInput = input;
                    isBackspace = true;
                    if (root.currentIndex != 0)
                        root.currentIndex--;
                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    if (root.currentIndex < (root.length - 1))
                        root.currentIndex++;
                    else
                        root.finished(root.getInput());
                }
            }

            Timer {
                id: __timer
                interval: 100
                onTriggered: {
                    root.currentIndex = __rootItem.__index >> 1;
                    __rootItem.selectAll();
                }
            }
        }
    }
}
