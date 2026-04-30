import QtQuick
import MosuiBasic

TextEdit {
    id: control

    objectName: '__MosCopyableText__'
    readOnly: true
    renderType: MosTheme.textRenderType
    color: MosTheme.MosCopyableText.colorText
    selectByMouse: true
    selectByKeyboard: true
    selectedTextColor: MosTheme.MosCopyableText.colorTextSelected
    selectionColor: MosTheme.MosCopyableText.colorSelection
    font {
        family: MosTheme.MosCopyableText.fontFamily
        pixelSize: parseInt(MosTheme.MosCopyableText.fontSize)
    }
}
