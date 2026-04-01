import QtQuick
import MosuiBasic


Window {
    id: root
    visible: true
    width: 1200
    height:800
    title: "MosUI"
    MosCard{
        anchors.centerIn: parent
        MosButton{
        }
    }
    // 运行时运行
    Component.onCompleted :{
        // 输出
        console.log(MosApp.libName())
        console.log(MosApp.libVersion())
        console.log(MosTheme.ceshi())
    }

}
