import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic
Item {

    MosSpace{
        anchors.fill: parent
        layout: 'RowLayout'
        spacing: 30
        leftPadding: 30
        rightPadding: 30


        // 压力图表
        MosCanvasChart{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        // 流量图表
        MosCanvasChart{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}