import QtQuick
import QtWebEngine

Item {
    anchors.fill: parent

    WebEngineView {
        id: webEngine
        anchors.fill: parent
        url: "qrc:/html/rain-on-glass.html"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
    }
}
