import QtQuick
import MosuiBasic
import QtQuick.Templates as T
import QtQuick.Layouts
T.Control {
    id: root

    property Component contentDelegate : {}
    objectName: "__MosCard__"

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    

    contentItem: Loader{
        id: contentloader
        anchors.fill: parent
        visible: contentDelegate ?   true : false
        sourceComponent: contentDelegate
    }
}






