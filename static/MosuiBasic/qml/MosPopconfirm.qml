import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

MosPopover {
    id: root

    signal confirm()
    signal cancel()

    property string confirmText: ''
    property string cancelText: ''
    property Component confirmButtonDelegate: MosButton {
        animationEnabled: root.animationEnabled
        padding: 10
        topPadding: 4
        bottomPadding: 4
        text: root.confirmText
        type: MosButton.Type_Primary
        onClicked: root.confirm();
    }
    property Component cancelButtonDelegate: MosButton {
        animationEnabled: root.animationEnabled
        padding: 10
        topPadding: 4
        bottomPadding: 4
        text: root.cancelText
        type: MosButton.Type_Default
        onClicked: root.cancel();
    }

    footerDelegate: Item {
        implicitHeight: __rowLayout.implicitHeight

        RowLayout {
            id: __rowLayout
            anchors.right: parent.right
            spacing: 10
            visible: __confirmLoader.active || __cancelLoader.active

            Loader {
                id: __confirmLoader
                visible: active
                active: root.confirmText !== ''
                sourceComponent: root.confirmButtonDelegate
            }

            Loader {
                id: __cancelLoader
                visible: active
                active: root.cancelText !== ''
                sourceComponent: root.cancelButtonDelegate
            }
        }
    }

    objectName: '__MosPopconfirm__'
    themeSource: MosTheme.MosPopconfirm
}
