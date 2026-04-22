import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosButton {
    id: root
    objectName: "__MosRotateIconButton__"

    property bool rotateLoading: false
    property int rotateDuration: 200
    property bool iconRotateOnClick: true
    property real pressScale: 0.92
    property bool loading: false
    property var iconSource: 0 ?? ''
    property int iconSize: parseInt(themeSource.fontSize)
    property int iconSpacing: 5 * sizeRatio
    property int iconPosition: MosIconButton.Position_Start
    property int orientation: Qt.Horizontal
    property alias textFont: root.font
    property color colorIcon: root.colorText
    property font iconFont: Qt.font({
                                        family: 'MOSUI',
                                        pixelSize: iconSize
                                    })
    type: MosButton.Type_Text

    onClicked: {
        if (iconRotateOnClick) {
            restoreRotation.start()
        }
    }
    MosIconText {
        id: iconTextLoading
        font: root.iconFont
        color: root.colorIcon
        iconSize: root.iconSize
        
        anchors.centerIn: root
        iconSource: root.loading ? MosIcon.LoadingOutlined : root.iconSource
        verticalAlignment: Text.AlignVCenter
        visible: root.loading || (root.iconSource !== 0 && root.iconSource !== "")

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

        transform:[
            Scale {
                id: scale
                origin.x: root.width / 2
                origin.y: root.height / 2
                xScale: 1.0
                yScale: 1.0
            },
            Rotation {
                id: iconRotation
                origin.x: iconTextLoading.width / 2
                origin.y: iconTextLoading.height / 2
                angle: 0
            }
        ]

        PropertyAnimation {
            id: restoreRotation
            target: iconRotation
            property: "angle"
            from: 0
            to: 360
            easing.type: Easing.InOutQuad
            duration: root.rotateDuration
        }
    }

}
