import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic
import "./Controls"


Item {
    id: root
    property Component chartAreaDelegate: ChartArea{}
    property Component pipelineAreaDelegate: PipelineArea{}
    property real chartAreaHeightRatio: 0.3
    MosRectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: MosTheme.Primary.colorSplit
        border.width: 1
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Loader{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight:root.height * chartAreaHeightRatio
            id: chartAreaLoader
            asynchronous: true
            sourceComponent: root.chartAreaDelegate
        }
        Loader{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight:root.height * (1 - chartAreaHeightRatio)
            id: pipelineAreaLoader
            asynchronous: true
            sourceComponent: root.pipelineAreaDelegate
        }
    }
}
