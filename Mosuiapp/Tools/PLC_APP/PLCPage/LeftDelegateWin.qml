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

    property string loopBackPressure: "0.000"
    property string addBackPressure: "0.000"
    property string mainChannelPressure: "7.5"
    property string wellheadPressure: "0.00"
    property string auxiliaryChannelPressure: "1.2"
    property string standpipePressure: "0"
    property string throttledPressure: "0.8"
    property string pumpStroke1: "70.143"
    property string pumpStroke2: "70.265"
    property string pumpStroke3: "70.396"
    property string inletFlow: "0"
    property string outletFlow: "0"
    property string bitDepth: "3660.6"
    property string wellDepth: "3660.6"
    property string outletDensity: "1.141"
    property string ecdDensity: "1.141"

    readonly property var sections: [
        {
            title: "井口压力控制参数(MPa)",
            rows: 1,
            metrics: [
                { name: "循环回压", value: root.loopBackPressure, accent: false },
                { name: "附加回压", value: root.addBackPressure, accent: false }
            ]
        },
        {
            title: "实际测量压力(MPa)",
            rows: 4,
            metrics: [
                { name: "主通道压力", value: root.mainChannelPressure, accent: true },
                { name: "井口压力", value: root.wellheadPressure, accent: true },
                { name: "辅助通道压力", value: root.auxiliaryChannelPressure, accent: true },
                { name: "立管压力", value: root.standpipePressure, accent: true },
                { name: "节流后压力", value: root.throttledPressure, accent: false },
                { name: "泵冲1", value: root.pumpStroke1, accent: false },
                { name: "泵冲2", value: root.pumpStroke2, accent: false },
                { name: "泵冲3", value: root.pumpStroke3, accent: false }
            ]
        },
        {
            title: "流量测量(L/s)",
            rows: 1,
            metrics: [
                { name: "入口流量", value: root.inletFlow, accent: true },
                { name: "出口流量", value: root.outletFlow, accent: true }
            ]
        },
        {
            title: "深度测量(m)",
            rows: 1,
            metrics: [
                { name: "钻头深度", value: root.bitDepth, accent: false },
                { name: "井深", value: root.wellDepth, accent: false }
            ]
        },
        {
            title: "密度测量(g/cm³)",
            rows: 1,
            metrics: [
                { name: "出口密度", value: root.outletDensity, accent: false },
                { name: "ECD密度", value: root.ecdDensity, accent: false }
            ]
        }
    ]

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
            model: root.sections

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
                            text: modelData.name + "\n" + modelData.value
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

