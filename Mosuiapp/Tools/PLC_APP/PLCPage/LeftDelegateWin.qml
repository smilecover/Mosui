import QtQuick
import QtQuick.Layouts
import MosuiBasic

Item {
    id: root
    implicitWidth: 320

    readonly property color panelColor: "black"
    readonly property color borderColor: MosTheme.Primary.colorSplit
    readonly property color textColor: "white"
    readonly property color accentColor: "#FFFFC738"

    MosRectangle {
        anchors.fill: parent
        color: root.panelColor
        border.color: root.borderColor
        border.width: 1
    }

    MosSpace {
        anchors.fill: parent
        anchors.margins: 1
        layout: "ColumnLayout"
        spacing: 0

        Repeater {
            model: K3data.k3data_left

            delegate: MosSpace {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 30 + modelData.rows * 56
                Layout.verticalStretchFactor: modelData.rows
                layout: "ColumnLayout"
                spacing: 0

                MosLabel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    text: modelData.title
                    leftPadding: 6
                    colorBg: "transparent"
                    colorBorder: root.borderColor
                    colorText: root.textColor
                    borderWidth: 1
                    radiusBg: MosRadius { all: 0 }
                    font.pixelSize: 16
                    font.bold: false
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                MosSpace {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    Layout.bottomMargin: 8
                    layout: "GridLayout"
                    columns: 2
                    rows: modelData.rows
                    rowSpacing: 7
                    columnSpacing: 7
                    autoCombineRadius: false
                    uniformCellWidths: true
                    uniformCellHeights: true

                    Repeater {
                        model: modelData.metrics

                        delegate: MosLabel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 50
                            text: modelData.name + "\n" + Number(modelData.value)//.toFixed(2)
                            colorBorder: root.borderColor
                            colorText: modelData.accent ? root.accentColor : root.textColor
                            borderWidth: 1
                            radiusBg: MosRadius { all: 0 }
                            font.pixelSize: 16
                            font.bold: true
                            lineHeight: 1.2
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}

