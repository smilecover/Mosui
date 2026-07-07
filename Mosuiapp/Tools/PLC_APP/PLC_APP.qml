import QtQuick
import QtQuick.Controls
import MosuiBasic
import './PLCPage'

MosWindow{
    id: plcappwindow
    visible: true
    width:2000
    height:1000
    visibility: Window.Maximized
    captionbar.visible: false
    MosRectangleInternal{
        anchors.fill: parent
        color: "black"
    }

    // ── 上方栏 delegate ──────────────────────────────
    // 高度由 content 自动决定，宽度撑满可用空间
    property Component upDelegate : UpDelegateWin {}

    // ── 下方栏 delegate ──────────────────────────────
    property Component downDelegate : DownDelegateWin {}

    // ── 左侧栏 delegate ──────────────────────────────
    property Component leftDelegate : LeftDelegateWin {}

    // ── 右侧栏 delegate ──────────────────────────────
    property Component rightDelegate : RightDelegateWin {}

    // ── 中央区域 delegate ────────────────────────────
    // 尺寸由 Loader 锚点决定，自动填充剩余空间
    property Component centerDelegate : CenterDelegateWin {}

    Component.onCompleted: {
        K3data.InitK3data()
        K3dataprocess.InitK3dataprocess()
    }

    Loader {
        id: __up
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: __right.left        // 宽度锚定，不设固定值
        // 高度由 upDelegate 的 implicitHeight 自动决定
        sourceComponent: plcappwindow.upDelegate
    }

    Loader {
        id: __down
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: __right.left        // 宽度锚定，不设固定值
        // 高度由 downDelegate 的 implicitHeight 自动决定
        sourceComponent: plcappwindow.downDelegate
    }

    Loader {
        id: __left
        anchors.left: parent.left
        anchors.top: __up.bottom
        anchors.bottom: __down.top         // 高度锚定，填满上/下之间
        // 宽度由 leftDelegate 的 implicitWidth 自动决定
        sourceComponent: plcappwindow.leftDelegate
    }

    Loader {
        id: __right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom      // 高度锚定，填满窗口
        // 不设 anchors.left — 宽度由 delegate 内容决定，自动靠右
        sourceComponent: plcappwindow.rightDelegate
    }

    Loader {
        id: __center
        anchors.top: __up.bottom
        anchors.bottom: __down.top
        anchors.left: __left.right
        anchors.right: __right.left
        sourceComponent: plcappwindow.centerDelegate
    }

}
