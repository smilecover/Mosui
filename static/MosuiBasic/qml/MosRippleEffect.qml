import QtQuick
import MosuiBasic

MosRectangleInternal {
    id: root

    property bool animationEnabled: true
    property bool effectEnabled: true
    property color effectColor: "transparent"
    property real targetWidth: 0
    property real targetHeight: 0

    anchors.centerIn: parent
    color: "transparent"
    border.width: 0
    border.color: effectColor
    opacity: 0.2
    visible: effectEnabled

    function trigger() {
        if (!animationEnabled || !effectEnabled) return;
        border.width = 8;
        __animation.restart();
    }

    ParallelAnimation {
        id: __animation
        onFinished: root.border.width = 0;

        NumberAnimation {
            target: root; property: 'width'
            from: root.targetWidth + 3; to: root.targetWidth + 8;
            duration: MosTheme.Primary.durationFast
            easing.type: Easing.OutQuart
        }
        NumberAnimation {
            target: root; property: 'height'
            from: root.targetHeight + 3; to: root.targetHeight + 8;
            duration: MosTheme.Primary.durationFast
            easing.type: Easing.OutQuart
        }
        NumberAnimation {
            target: root; property: 'opacity'
            from: 0.2; to: 0;
            duration: MosTheme.Primary.durationSlow
        }
    }
}
