import QtQuick
import MosuiBasic
MosRectangle {
    width: 200
    height: 200
    color: "blue"

    // 直接套上这个组件
    MosResizeMouseArea {
        anchors.fill: parent
        target: parent               // 控制自己
        resizable: true              // 允许缩放
        movable: true                // 允许拖动
        minimumWidth: 100            // 最小宽
        minimumHeight: 100           // 最小高
        maximumWidth: 500
        maximumHeight: 500
    }
}