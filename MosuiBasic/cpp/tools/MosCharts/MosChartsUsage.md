# MosCharts 使用说明

`MosCharts` 是基于 `QQuickItem + QSGGeometryNode` 的高性能 QML 图表组件。组件直接走 Qt Quick Scene Graph 渲染路径，适合实时刷新、较大数据量波形、仪表盘和工具页面。

## 可用组件

在 QML 中导入：

```qml
import MosuiBasic
```

可直接使用以下类型：

```qml
MosHighperchart   // 通用图表，通过 chartType 切换类型
MosLineChart      // 折线图
MosBarChart       // 柱状图
MosPieChart       // 饼图
MosDonutChart     // 环形图
MosAreaChart      // 面积图
MosScatterChart   // 散点图
MosRadarChart     // 雷达图
```

## 最简单示例

```qml
MosLineChart {
    anchors.fill: parent
    values: [12, 28, 22, 46, 38, 64, 58, 82, 74]
    colors: ["#1677ff"]
    lineWidth: 2
    showPoints: false
}
```

## 通用属性

所有图表类型都继承自 `MosHighperchart`，支持以下属性：

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `chartType` | enum | `Line` | 通用组件使用，子类会自动设置 |
| `values` | `QVariantList` | 示例数据 | 图表数据 |
| `colors` | `QVariantList` | 内置色盘 | 系列颜色或分片颜色 |
| `backgroundColor` | `color` | `transparent` | 背景色 |
| `gridColor` | `color` | 半透明灰蓝 | 网格线颜色 |
| `axisColor` | `color` | 灰蓝 | 坐标轴颜色 |
| `showGrid` | `bool` | `true` | 是否显示网格 |
| `showAxis` | `bool` | `true` | 是否显示坐标轴 |
| `showPoints` | `bool` | `true` | 折线、面积、雷达是否显示点 |
| `padding` | `real` | `22` | 图表内边距 |
| `lineWidth` | `real` | `3` | 折线/雷达线宽 |
| `pointSize` | `real` | `7` | 点大小 |
| `innerRadius` | `real` | `0.56` | 环形图内半径比例 |
| `barSpacing` | `real` | `0.22` | 柱状图间距比例 |
| `gridLineCount` | `int` | `4` | 网格线数量 |
| `animationProgress` | `real` | `1` | 0 到 1 的绘制进度 |
| `highPerformanceMode` | `bool` | `false` | 开启高性能抽稀渲染 |
| `highPerformancePointLimit` | `int` | `8000` | 高性能模式下最大绘制点数 |
| `edgeAntialiasing` | `bool` | `true` | 是否开启边缘抗锯齿 |

## 通用 MosHighperchart

如果想通过一个类型动态切换图表，可以使用 `MosHighperchart`：

```qml
MosHighperchart {
    anchors.fill: parent
    chartType: MosHighperchart.Line
    values: [12, 28, 22, 46, 38, 64]
}
```

支持的 `chartType`：

```qml
MosHighperchart.Line
MosHighperchart.Bar
MosHighperchart.Pie
MosHighperchart.Donut
MosHighperchart.Area
MosHighperchart.Scatter
MosHighperchart.Radar
```

更推荐业务页面直接使用具体类型，例如 `MosLineChart`、`MosBarChart`，可读性更好。

## 折线图 MosLineChart

### 单条折线

```qml
MosLineChart {
    anchors.fill: parent
    values: [10, 24, 18, 36, 28, 55, 47]
    colors: ["#1677ff"]
    lineWidth: 2
    showPoints: false
}
```

### 多条折线

```qml
MosLineChart {
    anchors.fill: parent
    values: [
        [12, 28, 22, 46, 38, 64],
        [18, 22, 35, 30, 56, 48]
    ]
    colors: ["#1677ff", "#13c2c2"]
    lineWidth: 2
    showPoints: false
}
```

### 指定 x/y 数据

如果需要不等间距 x 轴，可以传对象：

```qml
MosLineChart {
    anchors.fill: parent
    values: [
        { x: 0.0, y: 12 },
        { x: 0.3, y: 24 },
        { x: 1.1, y: 18 },
        { x: 2.0, y: 36 }
    ]
}
```

也可以传二维数组点：

```qml
values: [[0, 12], [0.3, 24], [1.1, 18], [2.0, 36]]
```

## 面积图 MosAreaChart

面积图的数据格式与折线图一致：

```qml
MosAreaChart {
    anchors.fill: parent
    values: [12, 28, 22, 46, 38, 64, 58]
    colors: ["#13c2c2"]
    lineWidth: 2
    showPoints: false
}
```

面积图内部会绘制一层半透明渐变填充，适合趋势、功率、温度等连续数据。

## 柱状图 MosBarChart

### 单组柱状图

```qml
MosBarChart {
    anchors.fill: parent
    values: [12, 28, 22, 46, 38, 64]
    colors: ["#52c41a"]
    barSpacing: 0.24
}
```

### 多组柱状图

```qml
MosBarChart {
    anchors.fill: parent
    values: [
        [12, 28, 22, 46],
        [18, 20, 35, 30],
        [8, 16, 24, 28]
    ]
    colors: ["#52c41a", "#faad14", "#722ed1"]
}
```

## 饼图 MosPieChart

```qml
MosPieChart {
    anchors.fill: parent
    values: [26, 18, 34, 22, 15]
    colors: ["#1677ff", "#13c2c2", "#52c41a", "#faad14", "#eb2f96"]
    showAxis: false
    showGrid: false
    padding: 28
}
```

饼图会自动忽略负数，负数按 0 处理。

## 环形图 MosDonutChart

```qml
MosDonutChart {
    anchors.fill: parent
    values: [26, 18, 34, 22, 15]
    colors: ["#1677ff", "#13c2c2", "#52c41a", "#faad14", "#eb2f96"]
    innerRadius: 0.62
    showAxis: false
    showGrid: false
    padding: 28
}
```

`innerRadius` 建议范围为 `0.45 - 0.75`。

## 散点图 MosScatterChart

散点图推荐传对象数组：

```qml
MosScatterChart {
    anchors.fill: parent
    values: [
        { x: 0, y: 12 },
        { x: 1, y: 24 },
        { x: 2, y: 18 },
        { x: 3, y: 36 }
    ]
    colors: ["#faad14"]
    pointSize: 5
}
```

也可以传二维数组：

```qml
values: [[0, 12], [1, 24], [2, 18], [3, 36]]
```

## 雷达图 MosRadarChart

```qml
MosRadarChart {
    anchors.fill: parent
    values: [
        [42, 64, 58, 80, 72, 55],
        [50, 48, 70, 62, 85, 66]
    ]
    colors: ["#fa541c", "#2f54eb"]
    lineWidth: 2
    pointSize: 6
    padding: 30
}
```

雷达图至少需要 3 个维度。

## 实时波形示例

适合串口波形、功率曲线、采样数据刷新：

```qml
MosLineChart {
    id: waveChart
    anchors.fill: parent

    values: waveData
    colors: ["#1677ff"]
    lineWidth: 2
    pointSize: 0
    showPoints: false
    animationProgress: 1

    highPerformanceMode: true
    highPerformancePointLimit: 8000
    edgeAntialiasing: false
}

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

Timer {
    interval: 16
    repeat: true
    running: true
    onTriggered: rebuildWave()
}
```

## 高性能模式

当数据量较大时，建议开启：

```qml
highPerformanceMode: true
highPerformancePointLimit: 8000
edgeAntialiasing: false
```

`edgeAntialiasing` 默认开启，会为折线、坐标轴、雷达轮廓和点标记生成透明羽化边缘；极限性能压测时可以关闭，减少顶点数量和混合开销。

高性能模式行为：

- 折线图、面积图、柱状图使用保峰谷抽稀，尽量保留波形尖峰和谷值。
- 散点图使用步进抽样。
- 坐标范围仍基于原始数据计算，所以抽稀不会导致 x 轴被压缩。
- 底层几何会自动拆分为多个 `QSGGeometryNode`，避免单个节点顶点过多导致只渲染一部分。

即使没有打开 `highPerformanceMode`，当总点数超过安全阈值时，组件也会自动进入安全抽稀，防止 50k、100k 数据量把渲染后端顶点提交撑爆。

### 建议配置

| 数据量 | 建议 |
| --- | --- |
| 1k 以下 | 普通模式即可 |
| 1k - 30k | 可关闭点显示：`showPoints: false` |
| 30k - 200k | 开启 `highPerformanceMode` |
| 200k 以上 | 开启高性能模式，并降低刷新频率或只显示可见窗口数据 |

## 数据格式总结

### 数字数组

```qml
values: [10, 20, 15, 40]
```

自动使用数组下标作为 x 值。

### 点对象数组

```qml
values: [
    { x: 0, y: 10 },
    { x: 1.5, y: 20 }
]
```

### 二维点数组

```qml
values: [[0, 10], [1.5, 20]]
```

### 多系列

```qml
values: [
    [10, 20, 15, 40],
    [8, 16, 24, 30]
]
```

## 常见问题

### 50k 或 100k 数据只显示左侧一段

请确认已经使用最新版本。组件内部已经做了两层保护：

- 大数据自动抽稀；
- QSG 几何节点自动分块。

如果仍然出现问题，建议设置：

```qml
highPerformanceMode: true
highPerformancePointLimit: 6000
showPoints: false
```

### 实时刷新时 CPU 高

优先减少 QML 端数组构造频率，或者降低刷新率：

```qml
Timer {
    interval: 33 // 约 30 FPS
}
```

同时建议：

```qml
showPoints: false
highPerformanceMode: true
```

### 数据很多但只关心最新一段

建议在业务侧只传可见窗口数据，例如最近 5000 或 10000 个点，而不是每帧传完整历史数据。

```qml
values: allSamples.slice(Math.max(0, allSamples.length - 10000))
```

## 推荐默认写法

实时大波形推荐：

```qml
MosLineChart {
    anchors.fill: parent
    values: waveData
    colors: ["#1677ff"]
    lineWidth: 2
    pointSize: 0
    showPoints: false
    showGrid: true
    showAxis: true
    highPerformanceMode: true
    highPerformancePointLimit: 8000
}
```

普通图表推荐：

```qml
MosAreaChart {
    anchors.fill: parent
    values: [12, 28, 22, 46, 38, 64]
    colors: ["#13c2c2"]
    showPoints: false
}
```
