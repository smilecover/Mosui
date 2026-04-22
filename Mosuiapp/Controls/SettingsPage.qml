import QtQuick
import MosuiBasic


MosRectangle {
    id: root

    width: 200
    height: 200
    color: "red"
    radius: 10

    // 直接套上这个组件
    MosResizeMouseArea {
        anchors.fill: parent
        target: parent               // 控制自己
        resizable: true              // 允许缩放
        movable: true                
        minimumWidth: 100           
        minimumHeight: 100           
        maximumWidth: 500
        maximumHeight: 500
    }

    

}