pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: root

    color: "transparent"

    property bool running: true
    property bool highPerformanceMode: true
    property int tick: 0
    property int pointCount: 10000
    property int renderPointLimit: 8000
    property real phase: 0
    property var waveData: []
    readonly property color waveColor: "#1677ff"

    function waveValue(i) {
        return Math.sin((i + phase * 34) * 0.018) * 42
                + Math.cos((i + phase * 9) * 0.006) * 26
                + Math.sin((i + tick) * 0.087) * 8
                + Math.cos((i * 0.173) + phase) * 4
                + 88
    }

    function rebuildData() {
        phase += 0.12
        tick += 1

        const data = new Array(pointCount)
        for (let i = 0; i < pointCount; ++i)
            data[i] = waveValue(i)
        waveData = data
    }

    function setPointCount(count) {
        pointCount = count
        rebuildData()
    }

    Component.onCompleted: rebuildData()

    Timer {
        interval: 16
        repeat: true
        running: root.running
        onTriggered: root.rebuildData()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MosText {
                text: "Single Waveform Stress Test"
                color: MosTheme.Primary.colorTextPrimary
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
            }

            MosText {
                text: root.pointCount + " points"
                color: MosTheme.Primary.colorTextSecondary
                font.pixelSize: 13
            }

            MosText {
                text: root.running ? "running 16ms" : "paused"
                color: root.running ? "#13c2c2" : MosTheme.Primary.colorTextSecondary
                font.pixelSize: 13
            }

            MosButton {
                text: root.running ? "Pause" : "Run"
                Layout.preferredWidth: 82
                type: root.running ? MosButton.Type_Default : MosButton.Type_Primary
                onClicked: root.running = !root.running
            }

            MosButton {
                text: root.highPerformanceMode ? "Fast On" : "Fast Off"
                Layout.preferredWidth: 92
                type: root.highPerformanceMode ? MosButton.Type_Primary : MosButton.Type_Default
                onClicked: root.highPerformanceMode = !root.highPerformanceMode
            }

            MosButton {
                text: "1k"
                Layout.preferredWidth: 58
                type: root.pointCount === 1000 ? MosButton.Type_Primary : MosButton.Type_Default
                onClicked: root.setPointCount(1000)
            }

            MosButton {
                text: "10k"
                Layout.preferredWidth: 62
                type: root.pointCount === 10000 ? MosButton.Type_Primary : MosButton.Type_Default
                onClicked: root.setPointCount(10000)
            }

            MosButton {
                text: "50k"
                Layout.preferredWidth: 62
                type: root.pointCount === 50000 ? MosButton.Type_Primary : MosButton.Type_Default
                onClicked: root.setPointCount(50000)
            }

            MosButton {
                text: "100k"
                Layout.preferredWidth: 70
                type: root.pointCount === 100000 ? MosButton.Type_Primary : MosButton.Type_Default
                onClicked: root.setPointCount(100000)
            }
        }

        MosRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 8
            border.color: "#dbeafe"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MosRectangle {
                        Layout.preferredWidth: 4
                        Layout.preferredHeight: 20
                        radius: 2
                        color: root.waveColor
                    }

                    MosText {
                        text: "Waveform"
                        color: MosTheme.Primary.colorTextPrimary
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    MosText {
                        text: "tick " + root.tick
                        color: MosTheme.Primary.colorTextSecondary
                        font.pixelSize: 12
                    }
                }

                MosLineChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    values: root.waveData
                    colors: [root.waveColor]
                    highPerformanceMode: root.highPerformanceMode
                    highPerformancePointLimit: root.renderPointLimit
                    backgroundColor: "transparent"
                    gridColor: "#1f94a3b8"
                    axisColor: "#667085"
                    gridLineCount: 5
                    lineWidth: 2
                    pointSize: 0
                    padding: 24
                    showPoints: false
                    showGrid: true
                    showAxis: true
                    animationProgress: 1
                }
            }
        }
    }
}
