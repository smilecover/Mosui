import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }

    Column {
        id: column
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 15
        spacing: 30

        MosDescription {
            desc: qsTr(`
# MosHighperchart 高性能图表

基于 \`QQuickItem + QSGGeometryNode\` 的高性能图表组件，适合实时波形、大数据量曲线、仪表盘和工具页面。

* **模块 { MosuiBasic }**
* **继承自 { QQuickItem }**
* **渲染方式 { Qt Quick Scene Graph }**

<br/>

### 支持的图表：

- \`MosLineChart\` 折线图
- \`MosBarChart\` 柱状图
- \`MosPieChart\` 饼图
- \`MosDonutChart\` 环形图
- \`MosAreaChart\` 面积图
- \`MosScatterChart\` 散点图
- \`MosRadarChart\` 雷达图
- \`MosHighperchart\` 通用图表，可通过 \`chartType\` 切换类型

<br/>

### 支持的属性：

属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
chartType | enum | Line | 通用图表类型
values | QVariantList | 示例数据 | 图表数据
colors | QVariantList | 内置色盘 | 系列颜色或分片颜色
backgroundColor | color | transparent | 背景色
gridColor | color | 半透明灰蓝 | 网格线颜色
axisColor | color | 灰蓝 | 坐标轴颜色
showGrid | bool | true | 是否显示网格
showAxis | bool | true | 是否显示坐标轴
showPoints | bool | true | 是否显示数据点
padding | real | 22 | 图表内边距
lineWidth | real | 3 | 折线或雷达线宽
pointSize | real | 7 | 数据点大小
innerRadius | real | 0.56 | 环形图内半径比例
barSpacing | real | 0.22 | 柱状图间距
gridLineCount | int | 4 | 网格线数量
animationProgress | real | 1 | 绘制进度，范围 0 到 1
highPerformanceMode | bool | false | 是否开启高性能抽稀渲染
highPerformancePointLimit | int | 8000 | 高性能模式下最大绘制点数
edgeAntialiasing | bool | true | 是否开启边缘抗锯齿
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当需要在 QML 中展示实时曲线、采样波形、趋势图、设备状态统计或大数据量图表时使用。

\`MosCanvasChart\` 更适合轻量展示和 Canvas 风格绘制；\`MosHighperchart\` 更适合频繁刷新和较大数据量，因为它直接构建 Scene Graph 几何。
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
最常用的是直接使用具体图表类型，例如 \`MosLineChart\`。单条折线可直接传数字数组，数组下标会作为 x 值。
                       `)
            code: `
import QtQuick
import MosuiBasic

MosLineChart {
    width: 560
    height: 260
    values: [12, 28, 22, 46, 38, 64, 58, 82, 74]
    colors: ["#1677ff"]
    lineWidth: 2
    pointSize: 0
    showPoints: false
    edgeAntialiasing: true
    gridLineCount: 4
}
            `
            exampleDelegate: MosRectangle {
                width: parent ? parent.width : 760
                height: 280
                color: "#ffffff"
                radius: 8
                border.color: "#dbeafe"
                border.width: 1

                MosLineChart {
                    anchors.fill: parent
                    anchors.margins: 16
                    values: [12, 28, 22, 46, 38, 64, 58, 82, 74]
                    colors: ["#1677ff"]
                    lineWidth: 2
                    pointSize: 0
                    showPoints: false
                    edgeAntialiasing: true
                    gridLineCount: 4
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
可以在同一张图中传入多组数据。折线图、面积图、柱状图和雷达图都支持多系列。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

GridLayout {
    width: 760
    columns: 2

    MosLineChart {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 220
        values: [
            [12, 28, 22, 46, 38, 64],
            [18, 22, 35, 30, 56, 48]
        ]
        colors: ["#1677ff", "#13c2c2"]
        showPoints: false
        lineWidth: 2
    }

    MosAreaChart {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 220
        values: [12, 28, 22, 46, 38, 64, 58]
        colors: ["#13c2c2"]
        showPoints: false
        lineWidth: 2
    }

    MosBarChart {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 220
        values: [
            [12, 28, 22, 46],
            [18, 20, 35, 30],
            [8, 16, 24, 28]
        ]
        colors: ["#52c41a", "#faad14", "#722ed1"]
    }

    MosRadarChart {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 220
        values: [
            [42, 64, 58, 80, 72, 55],
            [50, 48, 70, 62, 85, 66]
        ]
        colors: ["#fa541c", "#2f54eb"]
        lineWidth: 2
        pointSize: 6
        padding: 28
    }
}
            `
            exampleDelegate: GridLayout {
                width: parent ? parent.width : 760
                height: 480
                columns: 2
                rowSpacing: 12
                columnSpacing: 12

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    color: "#ffffff"
                    radius: 8
                    border.color: "#dbeafe"
                    border.width: 1

                    MosLineChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        values: [
                            [12, 28, 22, 46, 38, 64],
                            [18, 22, 35, 30, 56, 48]
                        ]
                        colors: ["#1677ff", "#13c2c2"]
                        showPoints: false
                        lineWidth: 2
                    }
                }

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    color: "#ffffff"
                    radius: 8
                    border.color: "#dbeafe"
                    border.width: 1

                    MosAreaChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        values: [12, 28, 22, 46, 38, 64, 58]
                        colors: ["#13c2c2"]
                        showPoints: false
                        lineWidth: 2
                    }
                }

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    color: "#ffffff"
                    radius: 8
                    border.color: "#dbeafe"
                    border.width: 1

                    MosBarChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        values: [
                            [12, 28, 22, 46],
                            [18, 20, 35, 30],
                            [8, 16, 24, 28]
                        ]
                        colors: ["#52c41a", "#faad14", "#722ed1"]
                    }
                }

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    color: "#ffffff"
                    radius: 8
                    border.color: "#dbeafe"
                    border.width: 1

                    MosRadarChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        values: [
                            [42, 64, 58, 80, 72, 55],
                            [50, 48, 70, 62, 85, 66]
                        ]
                        colors: ["#fa541c", "#2f54eb"]
                        lineWidth: 2
                        pointSize: 6
                        padding: 28
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
饼图和环形图使用一维数值数组，每个数值代表一个分片。建议关闭坐标轴和网格。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

RowLayout {
    width: 760
    spacing: 12

    MosPieChart {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 260
        values: [26, 18, 34, 22, 15]
        colors: ["#1677ff", "#13c2c2", "#52c41a", "#faad14", "#eb2f96"]
        showAxis: false
        showGrid: false
        padding: 28
    }

    MosDonutChart {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 260
        values: [26, 18, 34, 22, 15]
        colors: ["#1677ff", "#13c2c2", "#52c41a", "#faad14", "#eb2f96"]
        innerRadius: 0.62
        showAxis: false
        showGrid: false
        padding: 28
    }
}
            `
            exampleDelegate: RowLayout {
                width: parent ? parent.width : 760
                height: 280
                spacing: 12

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 260
                    color: "#ffffff"
                    radius: 8
                    border.color: "#dbeafe"
                    border.width: 1

                    MosPieChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        values: [26, 18, 34, 22, 15]
                        colors: ["#1677ff", "#13c2c2", "#52c41a", "#faad14", "#eb2f96"]
                        showAxis: false
                        showGrid: false
                        padding: 28
                    }
                }

                MosRectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 260
                    color: "#ffffff"
                    radius: 8
                    border.color: "#dbeafe"
                    border.width: 1

                    MosDonutChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        values: [26, 18, 34, 22, 15]
                        colors: ["#1677ff", "#13c2c2", "#52c41a", "#faad14", "#eb2f96"]
                        innerRadius: 0.62
                        showAxis: false
                        showGrid: false
                        padding: 28
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
散点图推荐使用 \`{ x, y }\` 对象数组，也可以使用 \`[[x, y], [x, y]]\` 二维数组。
                       `)
            code: `
import QtQuick
import MosuiBasic

MosScatterChart {
    width: 560
    height: 260
    values: [
        { x: 0, y: 12 },
        { x: 1, y: 24 },
        { x: 2, y: 18 },
        { x: 3, y: 36 },
        { x: 4, y: 28 },
        { x: 5, y: 48 }
    ]
    colors: ["#faad14"]
    pointSize: 7
}
            `
            exampleDelegate: MosRectangle {
                width: parent ? parent.width : 760
                height: 280
                color: "#ffffff"
                radius: 8
                border.color: "#dbeafe"
                border.width: 1

                MosScatterChart {
                    anchors.fill: parent
                    anchors.margins: 16
                    values: [
                        { x: 0, y: 12 },
                        { x: 1, y: 24 },
                        { x: 2, y: 18 },
                        { x: 3, y: 36 },
                        { x: 4, y: 28 },
                        { x: 5, y: 48 }
                    ]
                    colors: ["#faad14"]
                    pointSize: 7
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
实时大数据波形建议开启 \`highPerformanceMode\`。开启后折线图会保峰谷抽稀，并自动拆分 QSG 几何节点，适合 50k、100k 级别数据。

\`edgeAntialiasing\` 默认开启，会为折线、坐标轴、雷达轮廓和点标记生成透明羽化边缘；极限压力测试时可以关闭，减少顶点数量和混合开销。
                       `)
            code: `
import QtQuick
import MosuiBasic

Item {
    id: waveRoot
    width: 760
    height: 300

    property int tick: 0
    property int pointCount: 100000
    property var waveData: []

    function rebuildWave() {
        tick += 1
        const data = new Array(pointCount)
        for (let i = 0; i < pointCount; ++i) {
            data[i] = Math.sin((i + tick) * 0.02) * 40
                    + Math.cos(i * 0.005) * 20
                    + 80
        }
        waveData = data
    }

    Component.onCompleted: rebuildWave()

    Timer {
        interval: 33
        repeat: true
        running: true
        onTriggered: waveRoot.rebuildWave()
    }

    MosLineChart {
        anchors.fill: parent
        values: waveRoot.waveData
        colors: ["#1677ff"]
        lineWidth: 2
        pointSize: 0
    showPoints: false
    highPerformanceMode: true
    highPerformancePointLimit: 8000
    edgeAntialiasing: false
}
}
            `
            exampleDelegate: MosRectangle {
                id: waveRoot
                width: parent ? parent.width : 760
                height: 340
                color: "#ffffff"
                radius: 8
                border.color: "#dbeafe"
                border.width: 1

                property int tick: 0
                property int pointCount: 50000
                property var waveData: []

                function rebuildWave() {
                    tick += 1
                    const data = new Array(pointCount)
                    for (let i = 0; i < pointCount; ++i) {
                        data[i] = Math.sin((i + tick) * 0.02) * 40
                                + Math.cos(i * 0.005) * 20
                                + Math.sin((i + tick) * 0.11) * 6
                                + 80
                    }
                    waveData = data
                }

                Component.onCompleted: rebuildWave()

                Timer {
                    interval: 33
                    repeat: true
                    running: true
                    onTriggered: waveRoot.rebuildWave()
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Row {
                        width: parent.width
                        spacing: 12

                        MosText {
                            text: qsTr("High performance waveform")
                            font.bold: true
                        }

                        MosText {
                            text: waveRoot.pointCount + qsTr(" points / 30 FPS")
                            color: MosTheme.Primary.colorTextSecondary
                        }
                    }

                    MosLineChart {
                        width: parent.width
                        height: parent.height - 30
                        values: waveRoot.waveData
                        colors: ["#1677ff"]
                        lineWidth: 2
                        pointSize: 0
                        showPoints: false
                        highPerformanceMode: true
                        highPerformancePointLimit: 8000
                        edgeAntialiasing: false
                    }
                }
            }
        }

        MosDescription {
            title: qsTr('数据格式')
            desc: qsTr(`
### 数字数组

\`\`\`qml
values: [10, 20, 15, 40]
\`\`\`

自动使用数组下标作为 x 值。

### 点对象数组

\`\`\`qml
values: [
    { x: 0, y: 10 },
    { x: 1.5, y: 20 }
]
\`\`\`

### 二维点数组

\`\`\`qml
values: [[0, 10], [1.5, 20]]
\`\`\`

### 多系列

\`\`\`qml
values: [
    [10, 20, 15, 40],
    [8, 16, 24, 30]
]
\`\`\`
                       `)
        }

        MosDescription {
            title: qsTr('高性能模式建议')
            desc: qsTr(`
实时波形推荐配置：

\`\`\`qml
showPoints: false
highPerformanceMode: true
highPerformancePointLimit: 8000
edgeAntialiasing: false
\`\`\`

数据量建议：

数据量 | 建议
------ | ---
1k 以下 | 普通模式即可
1k - 30k | 关闭数据点显示
30k - 200k | 开启高性能模式
200k 以上 | 建议只传当前可见窗口数据

组件内部已经做了大数据保护：超过安全阈值会自动抽稀，且单个 QSG 几何节点会自动分块，避免 50k、100k 数据只渲染左侧一段。

\`edgeAntialiasing\` 默认开启；它会增加一圈透明羽化顶点来平滑边缘。当更重视极限刷新率时可以关闭，当更重视视觉平滑时保持开启。
                       `)
        }
    }
}
