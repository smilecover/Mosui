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
# MosCanvasChart 图表

基于 \`Canvas\` 的多类型图表控件，适合仪表盘、统计页、数据概览和带悬浮提示的轻量交互图表。

* **模块 { MosuiBasic }** 
* **继承自 { Control }**
* **渲染方式 { Qt Quick Canvas }**

<br/>

### 支持的图表类型：

- \`MosCanvasChart.Type_Line\` 折线图
- \`MosCanvasChart.Type_Bar\` 柱状图
- \`MosCanvasChart.Type_Pie\` 饼图
- \`MosCanvasChart.Type_Doughnut\` 环形图
- \`MosCanvasChart.Type_Area\` 面积图
- \`MosCanvasChart.Type_Scatter\` 散点图
- \`MosCanvasChart.Type_Radar\` 雷达图

<br/>

### 支持的属性：

属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
chartType | int | Type_Line | 图表类型
values | var | 示例数据 | 单系列数据，支持数字数组或对象数组
series | var | [] | 多系列数据，格式为 \`[{ name, values }]\`
labels | var | [] | 类目标签，常用于 x 轴、图例或分片名称
colors | var | 主题色板 | 系列颜色或分片颜色
title | string | '' | 图表标题
subtitle | string | '' | 图表副标题
unit | string | '' | y 值或分片值单位
xUnit | string | '' | x 值单位
showTitle | bool | title !== '' | 是否显示标题
showSubtitle | bool | subtitle !== '' | 是否显示副标题
showLegend | bool | true | 是否显示图例
showGrid | bool | true | 是否显示网格
showAxis | bool | true | 是否显示坐标轴
showLabels | bool | true | 是否显示标签
showValues | bool | false | 是否显示数值
smooth | bool | true | 折线或面积图是否平滑
stacked | bool | false | 柱状图是否堆叠
fillBackground | bool | true | 是否绘制控件背景
showShadow | bool | false | 是否显示阴影
hoverable | bool | true | 是否启用悬浮提示与命中检测
animationEnabled | bool | MosTheme.animationEnabled | 是否启用入场动画
animationDuration | int | 主题慢速时长 | 动画时长
lineWidth | real | 主题值 | 线条宽度
pointSize | real | 主题值 | 数据点大小
barRadius | real | 主题值 | 柱状图圆角
doughnutWidthRatio | real | 主题值 | 环形图圆环宽度比例
radarFillOpacity | real | 主题值 | 雷达图填充透明度
areaFillOpacity | real | 主题值 | 面积图填充透明度
xBlockCount | int | 0 | x 轴分块数量，0 表示自动
yBlockCount | int | 5 | y 轴分块数量
autoXRange | bool | true | 是否自动计算 x 轴范围
autoYRange | bool | true | 是否自动计算 y 轴范围
xMin / xMax | real | 0 / 1 | 手动 x 轴范围
yMin / yMax | real | 0 / 1 | 手动 y 轴范围
formatter | var | 内置格式化 | y 值或分片值格式化函数
xFormatter | var | 内置格式化 | x 轴数值格式化函数
labelFormatter | var | 内置格式化 | 类目标签格式化函数
highPerformance | bool | false | 是否开启大数据优化
optimizeLargeData | bool | highPerformance | 是否启用抽稀与快速绘制
maxRenderPoints | int | 2400 | 折线/面积最大渲染点数
maxInteractivePoints | int | 2400 | 最大交互命中点数
pointRenderThreshold | int | 900 | 超过后自动减少点标记绘制
barRenderThreshold | int | 900 | 超过后使用快速柱状绘制
scatterRenderThreshold | int | 1800 | 散点抽稀阈值
sizeHint | string | 'normal' | 尺寸提示

<br/>

### 支持的信号与方法：

名称 | 类型 | 描述
------ | --- | ---
chartHovered(index, seriesIndex, data) | signal | 悬浮到数据项时触发
chartClicked(index, seriesIndex, data) | signal | 点击数据项时触发
refresh() | function | 主动请求重绘
colorAt(index) | function | 获取指定序号对应的主题色
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
\`MosCanvasChart\` 更适合展示型图表：它自带标题、副标题、图例、标签、提示气泡、格式化函数和点击信号，写 QML 页面时非常方便。

如果需要 5 万、10 万点以上的实时波形，并且刷新频率很高，优先使用 \`MosHighperchart\`；它走 Scene Graph 几何渲染，更适合压力很大的场景。
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
最简单的用法是设置 \`chartType\`、\`labels\` 和 \`values\`。数字数组会被当作单系列数据，下标会作为 x 轴位置。
                       `)
            code: `
import QtQuick
import MosuiBasic

MosCanvasChart {
    width: 680
    height: 320
    title: qsTr("输出功率")
    subtitle: qsTr("最近 7 个采样周期")
    chartType: MosCanvasChart.Type_Line
    labels: ["00:00", "04:00", "08:00", "12:00", "16:00", "20:00", "24:00"]
    values: [18, 34, 28, 46, 39, 58, 51]
    unit: " kW"
    showValues: true
    smooth: true
}
            `
            exampleDelegate: MosCanvasChart {
                width: parent ? parent.width : 760
                height: 320
                title: qsTr("输出功率")
                subtitle: qsTr("最近 7 个采样周期")
                chartType: MosCanvasChart.Type_Line
                labels: ["00:00", "04:00", "08:00", "12:00", "16:00", "20:00", "24:00"]
                values: [18, 34, 28, 46, 39, 58, 51]
                unit: " kW"
                showValues: true
                smooth: true
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
多系列建议使用 \`series\`，每个系列包含 \`name\` 和 \`values\`。柱状图设置 \`stacked: true\` 后可以绘制堆叠柱。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

GridLayout {
    width: 760
    columns: 2

    MosCanvasChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 280
        title: qsTr("电压 / 电流")
        chartType: MosCanvasChart.Type_Line
        labels: ["A", "B", "C", "D", "E", "F"]
        series: [
            { name: qsTr("电压"), values: [220, 226, 224, 231, 229, 235] },
            { name: qsTr("电流"), values: [40, 46, 42, 52, 49, 56] }
        ]
        colors: ["#1677ff", "#13c2c2"]
    }

    MosCanvasChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 280
        title: qsTr("能耗构成")
        chartType: MosCanvasChart.Type_Bar
        labels: ["一", "二", "三", "四", "五", "六"]
        stacked: true
        series: [
            { name: qsTr("照明"), values: [16, 20, 18, 22, 19, 24] },
            { name: qsTr("动力"), values: [32, 36, 31, 42, 38, 46] },
            { name: qsTr("散热"), values: [12, 15, 14, 18, 16, 20] }
        ]
        colors: ["#52c41a", "#faad14", "#722ed1"]
    }
}
            `
            exampleDelegate: GridLayout {
                width: parent ? parent.width : 760
                height: 300
                columns: 2
                columnSpacing: 12

                MosCanvasChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: qsTr("电压 / 电流")
                    chartType: MosCanvasChart.Type_Line
                    labels: ["A", "B", "C", "D", "E", "F"]
                    series: [
                        { name: qsTr("电压"), values: [220, 226, 224, 231, 229, 235] },
                        { name: qsTr("电流"), values: [40, 46, 42, 52, 49, 56] }
                    ]
                    colors: ["#1677ff", "#13c2c2"]
                }

                MosCanvasChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: qsTr("能耗构成")
                    chartType: MosCanvasChart.Type_Bar
                    labels: ["一", "二", "三", "四", "五", "六"]
                    stacked: true
                    series: [
                        { name: qsTr("照明"), values: [16, 20, 18, 22, 19, 24] },
                        { name: qsTr("动力"), values: [32, 36, 31, 42, 38, 46] },
                        { name: qsTr("散热"), values: [12, 15, 14, 18, 16, 20] }
                    ]
                    colors: ["#52c41a", "#faad14", "#722ed1"]
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
饼图、环形图和雷达图使用同一套 \`values\` 与 \`labels\`。环形图通过 \`doughnutWidthRatio\` 控制圆环厚度，雷达图可以使用多系列。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

GridLayout {
    width: 760
    columns: 3

    MosCanvasChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 260
        title: qsTr("故障占比")
        chartType: MosCanvasChart.Type_Pie
        labels: [qsTr("过压"), qsTr("过流"), qsTr("过温"), qsTr("通信")]
        values: [28, 22, 35, 15]
        showValues: true
    }

    MosCanvasChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 260
        title: qsTr("容量分布")
        chartType: MosCanvasChart.Type_Doughnut
        labels: [qsTr("已用"), qsTr("可用"), qsTr("保留")]
        values: [58, 34, 8]
        doughnutWidthRatio: 0.42
        showValues: true
    }

    MosCanvasChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 260
        title: qsTr("设备评分")
        chartType: MosCanvasChart.Type_Radar
        labels: [qsTr("效率"), qsTr("稳定"), qsTr("温控"), qsTr("噪声"), qsTr("响应"), qsTr("维护")]
        series: [
            { name: qsTr("A 组"), values: [82, 90, 76, 68, 88, 80] },
            { name: qsTr("B 组"), values: [72, 84, 86, 78, 74, 88] }
        ]
        radarFillOpacity: 0.22
    }
}
            `
            exampleDelegate: GridLayout {
                width: parent ? parent.width : 760
                height: 280
                columns: 3
                columnSpacing: 12

                MosCanvasChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: qsTr("故障占比")
                    chartType: MosCanvasChart.Type_Pie
                    labels: [qsTr("过压"), qsTr("过流"), qsTr("过温"), qsTr("通信")]
                    values: [28, 22, 35, 15]
                    showValues: true
                }

                MosCanvasChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: qsTr("容量分布")
                    chartType: MosCanvasChart.Type_Doughnut
                    labels: [qsTr("已用"), qsTr("可用"), qsTr("保留")]
                    values: [58, 34, 8]
                    doughnutWidthRatio: 0.42
                    showValues: true
                }

                MosCanvasChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: qsTr("设备评分")
                    chartType: MosCanvasChart.Type_Radar
                    labels: [qsTr("效率"), qsTr("稳定"), qsTr("温控"), qsTr("噪声"), qsTr("响应"), qsTr("维护")]
                    series: [
                        { name: qsTr("A 组"), values: [82, 90, 76, 68, 88, 80] },
                        { name: qsTr("B 组"), values: [72, 84, 86, 78, 74, 88] }
                    ]
                    radarFillOpacity: 0.22
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
散点图的数据项建议使用对象：\`{ x, y, label, size }\`。其中 \`label\` 用于提示信息，\`size\` 可以控制单点大小。
                       `)
            code: `
import QtQuick
import MosuiBasic

MosCanvasChart {
    width: 680
    height: 320
    title: qsTr("温升分布")
    chartType: MosCanvasChart.Type_Scatter
    xUnit: " A"
    unit: " C"
    values: [
        { x: 12, y: 35, label: qsTr("S1"), size: 5 },
        { x: 18, y: 42, label: qsTr("S2"), size: 7 },
        { x: 26, y: 48, label: qsTr("S3"), size: 6 },
        { x: 34, y: 62, label: qsTr("S4"), size: 9 },
        { x: 48, y: 70, label: qsTr("S5"), size: 8 }
    ]
}
            `
            exampleDelegate: MosCanvasChart {
                width: parent ? parent.width : 760
                height: 320
                title: qsTr("温升分布")
                chartType: MosCanvasChart.Type_Scatter
                xUnit: " A"
                unit: " C"
                values: [
                    { x: 12, y: 35, label: qsTr("S1"), size: 5 },
                    { x: 18, y: 42, label: qsTr("S2"), size: 7 },
                    { x: 26, y: 48, label: qsTr("S3"), size: 6 },
                    { x: 34, y: 62, label: qsTr("S4"), size: 9 },
                    { x: 48, y: 70, label: qsTr("S5"), size: 8 }
                ]
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
可以通过 \`formatter\`、\`xFormatter\` 和 \`labelFormatter\` 统一控制数值与标签显示，也可以监听 \`chartClicked\` 获取被点击的数据项。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

ColumnLayout {
    width: 680
    spacing: 8

    MosText {
        id: tip
        text: qsTr("点击图表中的数据点")
    }

    MosCanvasChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        title: qsTr("转换效率")
        chartType: MosCanvasChart.Type_Area
        labels: ["A1", "A2", "A3", "A4", "A5", "A6"]
        values: [91.2, 93.4, 92.8, 94.6, 95.1, 94.2]
        unit: "%"
        showValues: true
        formatter: value => value.toFixed(1) + unit
        labelFormatter: (label, index) => label + " #" + (index + 1)
        onChartClicked: function(index, seriesIndex, data) {
            tip.text = qsTr("点击：") + data.label + " / " + formatter(data.item.value)
        }
    }
}
            `
            exampleDelegate: ColumnLayout {
                width: parent ? parent.width : 760
                height: 360
                spacing: 8

                MosText {
                    id: clickTip
                    text: qsTr("点击图表中的数据点")
                    color: MosTheme.Primary.colorTextSecondary
                    font.pixelSize: 13
                    Layout.fillWidth: true
                }

                MosCanvasChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: qsTr("转换效率")
                    chartType: MosCanvasChart.Type_Area
                    labels: ["A1", "A2", "A3", "A4", "A5", "A6"]
                    values: [91.2, 93.4, 92.8, 94.6, 95.1, 94.2]
                    unit: "%"
                    showValues: true
                    formatter: value => value.toFixed(1) + unit
                    labelFormatter: (label, index) => label + " #" + (index + 1)
                    onChartClicked: function(index, seriesIndex, data) {
                        clickTip.text = qsTr("点击：") + data.label + " / " + formatter(data.item.value)
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
数据量较大时开启 \`highPerformance\`。控件会自动抽稀折线/面积数据，散点图会按阈值均匀降采样，并减少高成本的点标记与交互命中。
                       `)
            code: `
import QtQuick
import MosuiBasic

MosCanvasChart {
    width: 680
    height: 320
    title: qsTr("大数据波形预览")
    chartType: MosCanvasChart.Type_Line
    highPerformance: true
    maxRenderPoints: 1800
    maxInteractivePoints: 1200
    pointRenderThreshold: 400
    showValues: false
    showLegend: false
    values: buildWave(12000)

    function buildWave(count) {
        const data = new Array(count)
        for (let i = 0; i < count; ++i)
            data[i] = Math.sin(i * 0.018) * 36
                    + Math.cos(i * 0.071) * 12
                    + Math.sin(i * 0.21) * 5
                    + 60
        return data
    }
}
            `
            exampleDelegate: MosCanvasChart {
                width: parent ? parent.width : 760
                height: 320
                title: qsTr("大数据波形预览")
                chartType: MosCanvasChart.Type_Line
                highPerformance: true
                maxRenderPoints: 1800
                maxInteractivePoints: 1200
                pointRenderThreshold: 400
                showValues: false
                showLegend: false
                values: buildWave(12000)

                function buildWave(count) {
                    const data = new Array(count)
                    for (let i = 0; i < count; ++i)
                        data[i] = Math.sin(i * 0.018) * 36
                                + Math.cos(i * 0.071) * 12
                                + Math.sin(i * 0.21) * 5
                                + 60
                    return data
                }
            }
        }

        MosDescription {
            title: qsTr('数据格式')
            desc: qsTr(`
\`values\` 可直接传入数字数组：\`[12, 18, 26]\`，也可以传入对象数组：\`[{ x: 1, y: 12, label: "A", size: 6 }]\`。

\`series\` 用于多系列：\`[{ name: "A", values: [...] }, { name: "B", values: [...] }]\`。折线图、面积图、柱状图、散点图和雷达图都可以使用多系列；饼图和环形图通常使用单组 \`values\` 与 \`labels\`。

需要固定坐标范围时，关闭 \`autoXRange\` 或 \`autoYRange\`，再设置 \`xMin/xMax\` 或 \`yMin/yMax\`。
                       `)
        }
    }
}
