import QtQuick
import MosuiBasic
import QtQuick.Templates as T
import QtQuick.Layouts

T.Control {
    id: root


    // 效果
    enum CardEffect{
        Effect_None = 0,
        Effect_FrostedGlass=1
    }

    property int effect: MosCard.Effect_None

    property Component contentDelegate: null
    objectName: "__MosCard__"

    implicitWidth: contentLoader.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentLoader.implicitHeight + topPadding + bottomPadding
    
    topPadding: 6
    bottomPadding: 6
    leftPadding: 6
    rightPadding: 6

    contentItem: Loader {
        id: contentLoader
        sourceComponent: root.contentDelegate
    }
    
}