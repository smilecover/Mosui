import QtQuick
import QtQuick.Layouts
import MosuiBasic
MosRectangle{
    id: root

    property var targetWindow: null
    property MosWindowAgent windowAgent: null

    property string winIcon: ''

    property string winTitle: targetWindow?.title ?? ''
    property font winTitleFont: Qt.font({
                                        family: MosTheme.Primary.fontPrimaryFamily,
                                        pixelSize: 14
                                    })
    property color winTitleColor: MosTheme.Primary.colorTextBase

    objectName: '__MosCaptionBar__'
    color: "red"



}
