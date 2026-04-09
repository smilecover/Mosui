import QtQuick

import MosuiBasic

Text {
    id: control

    objectName: '__MosText__'
    // renderType: MosTheme.textRenderType
    color: enabled ? MosTheme.Primary.colorTextBase :
                     MosTheme.Primary.colorPrimaryTextDisabled
    font {
        family: MosTheme.Primary.fontPrimaryFamily
        pixelSize: parseInt(MosTheme.Primary.fontPrimarySize)
    }
}
