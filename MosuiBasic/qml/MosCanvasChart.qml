import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum Type {
        Type_Line = 0,
        Type_Bar = 1,
        Type_Pie = 2,
        Type_Doughnut = 3,
        Type_Area = 4,
        Type_Scatter = 5,
        Type_Radar = 6
    }

    signal chartHovered(index: int, seriesIndex: int, var data)
    signal chartClicked(index: int, seriesIndex: int, var data)

    property bool animationEnabled: MosTheme.animationEnabled
    property bool hoverable: true
    property bool showShadow: false
    property bool showTitle: title !== ''
    property bool showSubtitle: subtitle !== ''
    property bool showLegend: true
    property bool showGrid: true
    property bool showAxis: true
    property bool showLabels: true
    property bool showValues: false
    property bool smooth: true
    property bool stacked: false
    property bool fillBackground: true
    property bool highPerformance: false
    property bool optimizeLargeData: highPerformance
    property bool autoXRange: true
    property bool autoYRange: true

    property int chartType: MosCanvasChart.Type_Line
    property int animationDuration: MosTheme.Primary.durationSlow
    property int maxRenderPoints: 2400
    property int maxInteractivePoints: 2400
    property int pointRenderThreshold: 900
    property int barRenderThreshold: 900
    property int scatterRenderThreshold: 1800
    property int xBlockCount: 0
    property int yBlockCount: 5
    property real animationProgress: animationEnabled ? 0 : 1
    property real xMin: 0
    property real xMax: 1
    property real yMin: 0
    property real yMax: 1
    property real lineWidth: parseFloat(themeSource.lineWidth) * sizeRatio
    property real pointSize: parseFloat(themeSource.pointSize) * sizeRatio
    property real barRadius: parseFloat(themeSource.barRadius) * sizeRatio
    property real doughnutWidthRatio: parseFloat(themeSource.doughnutWidthRatio)
    property real radarFillOpacity: parseFloat(themeSource.radarFillOpacity)
    property real areaFillOpacity: parseFloat(themeSource.areaFillOpacity)
    property real gridLineWidth: parseFloat(themeSource.gridLineWidth)
    property real axisLineWidth: parseFloat(themeSource.axisLineWidth)
    property real sizeRatio: MosTheme.sizeHint[sizeHint]

    property string title: ''
    property string subtitle: ''
    property string unit: ''
    property string xUnit: ''
    property string sizeHint: 'normal'
    property var labels: []
    property var values: [18, 34, 28, 46, 39, 58, 51]
    property var series: []
    property var colors: [
        themeSource.colorSeries1,
        themeSource.colorSeries2,
        themeSource.colorSeries3,
        themeSource.colorSeries4,
        themeSource.colorSeries5,
        themeSource.colorSeries6,
        themeSource.colorSeries7,
        themeSource.colorSeries8,
        themeSource.colorSeries9,
        themeSource.colorSeries10
    ]
    property var themeSource: MosTheme.MosCanvasChart

    property font titleFont: Qt.font({
                                         family: themeSource.fontFamily,
                                         pixelSize: parseInt(themeSource.fontSizeTitle) * sizeRatio,
                                         weight: Font.DemiBold
                                     })
    property font subtitleFont: Qt.font({
                                            family: themeSource.fontFamily,
                                            pixelSize: parseInt(themeSource.fontSizeSubtitle) * sizeRatio
                                        })
    property font labelFont: Qt.font({
                                         family: themeSource.fontFamily,
                                         pixelSize: parseInt(themeSource.fontSizeLabel) * sizeRatio
                                     })
    property font valueFont: Qt.font({
                                         family: themeSource.fontFamily,
                                         pixelSize: parseInt(themeSource.fontSizeValue) * sizeRatio,
                                         weight: Font.DemiBold
                                     })
    property color colorBg: MosTheme.isDark ? themeSource.colorBgDark : themeSource.colorBg
    property color colorPlotBg: MosTheme.isDark ? themeSource.colorPlotBgDark : themeSource.colorPlotBg
    property color colorText: themeSource.colorText
    property color colorTextSecondary: themeSource.colorTextSecondary
    property color colorGrid: themeSource.colorGrid
    property color colorAxis: themeSource.colorAxis
    property color colorShadow: themeSource.colorShadow
    property color colorTooltipBg: MosTheme.isDark ? themeSource.colorTooltipBgDark : themeSource.colorTooltipBg
    property color colorTooltipBorder: themeSource.colorTooltipBorder
    property MosRadius radiusBg: MosRadius { all: root.themeSource.radiusBg }
    property var formatter: value => {
        if (typeof value !== 'number' || !isFinite(value))
            return '';
        const absValue = Math.abs(value);
        if (absValue >= 1000)
            return value.toLocaleString(Qt.locale(), 'f', 0) + root.unit;
        if (absValue >= 10)
            return value.toLocaleString(Qt.locale(), 'f', 1).replace(/\.0$/, '') + root.unit;
        return value.toLocaleString(Qt.locale(), 'f', 2).replace(/\.?0+$/, '') + root.unit;
    }
    property var xFormatter: value => {
        if (typeof value !== 'number' || !isFinite(value))
            return '';
        const absValue = Math.abs(value);
        if (absValue >= 1000)
            return value.toLocaleString(Qt.locale(), 'f', 0) + root.xUnit;
        if (absValue >= 10)
            return value.toLocaleString(Qt.locale(), 'f', 1).replace(/\.0$/, '') + root.xUnit;
        return value.toLocaleString(Qt.locale(), 'f', 2).replace(/\.?0+$/, '') + root.xUnit;
    }
    property var labelFormatter: (label, index) => label !== undefined && label !== null ? String(label) : String(index + 1)
    property int __dataRevision: 0

    readonly property bool __isRoundChart: chartType === MosCanvasChart.Type_Pie ||
                                           chartType === MosCanvasChart.Type_Doughnut ||
                                           chartType === MosCanvasChart.Type_Radar

    function refresh() {
        __canvas.requestPaint();
    }

    function colorAt(index) {
        if (!colors || colors.length === 0)
            return MosTheme.Primary.colorPrimary;
        return colors[index % colors.length];
    }

    onAnimationProgressChanged: __canvas.requestPaint();
    onChartTypeChanged: __invalidateChartData(true);
    onValuesChanged: __invalidateChartData(true);
    onSeriesChanged: __invalidateChartData(true);
    onTitleChanged: __invalidateChartData(false);
    onSubtitleChanged: __canvas.requestPaint();
    onUnitChanged: __canvas.requestPaint();
    onXUnitChanged: __canvas.requestPaint();
    onFormatterChanged: __canvas.requestPaint();
    onXFormatterChanged: __canvas.requestPaint();
    onLabelsChanged: __invalidateChartData(false);
    onColorsChanged: __invalidateChartData(false);
    onShowLegendChanged: __canvas.requestPaint();
    onShowGridChanged: __canvas.requestPaint();
    onShowAxisChanged: __canvas.requestPaint();
    onShowLabelsChanged: __canvas.requestPaint();
    onShowValuesChanged: __canvas.requestPaint();
    onSmoothChanged: __canvas.requestPaint();
    onStackedChanged: __invalidateRangeCache();
    onFillBackgroundChanged: __canvas.requestPaint();
    onHighPerformanceChanged: __invalidateChartData(false);
    onOptimizeLargeDataChanged: __invalidateChartData(false);
    onAutoXRangeChanged: __invalidateRangeCache();
    onAutoYRangeChanged: __invalidateRangeCache();
    onXMinChanged: __invalidateRangeCache();
    onXMaxChanged: __invalidateRangeCache();
    onYMinChanged: __invalidateRangeCache();
    onYMaxChanged: __invalidateRangeCache();
    onXBlockCountChanged: __canvas.requestPaint();
    onYBlockCountChanged: __canvas.requestPaint();
    onMaxRenderPointsChanged: __invalidateChartData(false);
    onMaxInteractivePointsChanged: __canvas.requestPaint();
    onPointRenderThresholdChanged: __canvas.requestPaint();
    onBarRenderThresholdChanged: __canvas.requestPaint();
    onScatterRenderThresholdChanged: __invalidateChartData(false);
    onWidthChanged: __canvas.requestPaint();
    onHeightChanged: __canvas.requestPaint();
    Component.onCompleted: __restartAnimation();

    objectName: '__MosCanvasChart__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 18 * sizeRatio

    background: Item {
        Loader {
            anchors.fill: __bg
            active: root.showShadow
            sourceComponent: MosShadow {
                source: __bg
                shadowOpacity: 0.18
                shadowScale: 1.02
                shadowColor: root.colorShadow
            }
        }

        MosRectangleInternal {
            id: __bg
            anchors.fill: parent
            radius: root.radiusBg.all
            topLeftRadius: root.radiusBg.topLeft
            topRightRadius: root.radiusBg.topRight
            bottomLeftRadius: root.radiusBg.bottomLeft
            bottomRightRadius: root.radiusBg.bottomRight
            color: root.fillBackground ? root.colorBg : 'transparent'
            border.width: root.fillBackground ? 1 : 0
            border.color: root.colorAxis

            Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
            Behavior on border.color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        }
    }

    contentItem: Canvas {
        id: __canvas
        renderTarget: Canvas.Image
        antialiasing: true
        property int hoverIndex: -1
        property int hoverSeriesIndex: -1
        property real hoverX: 0
        property real hoverY: 0
        property var hoverHit: null
        property var hitItems: []

        onPaint: {
            const ctx = getContext('2d');
            ctx.clearRect(0, 0, width, height);
            if (width <= 0 || height <= 0)
                return;

            const data = __private.normalizedSeries();
            const progress = __private.effectiveProgress(data);
            __canvas.hitItems.length = 0;

            __private.drawHeader(ctx);
            if (data.length === 0 || __private.maxSeriesLength(data) === 0) {
                __private.drawEmpty(ctx);
                return;
            }

            if (root.chartType === MosCanvasChart.Type_Pie || root.chartType === MosCanvasChart.Type_Doughnut) {
                __private.drawPie(ctx, data, progress, root.chartType === MosCanvasChart.Type_Doughnut);
            } else if (root.chartType === MosCanvasChart.Type_Radar) {
                __private.drawRadar(ctx, data, progress);
            } else {
                __private.drawCartesian(ctx, data, progress);
            }
            if (root.showLegend)
                __private.drawLegend(ctx, data);
            __private.drawTooltip(ctx);
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: root.hoverable
            cursorShape: root.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onPositionChanged: function(event) {
                __private.updateHover(event.x, event.y);
            }
            onExited: {
                if (__canvas.hoverIndex !== -1 || __canvas.hoverSeriesIndex !== -1) {
                    __canvas.hoverIndex = -1;
                    __canvas.hoverSeriesIndex = -1;
                    __canvas.hoverHit = null;
                    __canvas.requestPaint();
                }
            }
            onClicked: function(event) {
                __private.updateHover(event.x, event.y);
                if (__canvas.hoverIndex >= 0)
                    root.chartClicked(__canvas.hoverIndex, __canvas.hoverSeriesIndex, __private.hoverData());
            }
        }
    }

    NumberAnimation {
        id: __animation
        target: root
        property: 'animationProgress'
        from: 0
        to: 1
        duration: root.animationEnabled ? root.animationDuration : 0
        easing.type: Easing.OutCubic
    }

    function __restartAnimation() {
        if (animationEnabled) {
            __animation.stop();
            animationProgress = 0;
            __animation.restart();
        } else {
            animationProgress = 1;
            __canvas.requestPaint();
        }
    }

    function __invalidateChartData(restart) {
        ++__dataRevision;
        __private.invalidateDataCache();
        if (restart)
            __restartAnimation();
        else
            __canvas.requestPaint();
    }

    function __invalidateRangeCache() {
        __private.invalidateRangeCache();
        __canvas.requestPaint();
    }

    QtObject {
        id: __private

        readonly property real headerHeight: (root.showTitle ? 24 * root.sizeRatio : 0) +
                                             (root.showSubtitle ? 18 * root.sizeRatio : 0)
        readonly property real legendHeight: root.showLegend ? 28 * root.sizeRatio : 0
        property var __cachedData: []
        property int __cachedRevision: -1
        property int __cachedMaxLength: 0
        property var __cachedXRange: null
        property string __cachedXRangeKey: ''
        property var __cachedValueRange: null
        property string __cachedValueRangeKey: ''
        property var __cachedScatterRangeX: null
        property var __cachedScatterRangeY: null
        property var __colorCache: ({})
        property var __alphaCache: ({})
        property var __lightenCache: ({})

        function normalizedSeries() {
            if (__cachedRevision === root.__dataRevision)
                return __cachedData;

            const source = root.series && root.series.length > 0 ? root.series : [{ name: root.title, values: root.values }];
            const result = [];
            let maxLength = 0;
            for (let i = 0; i < source.length; ++i) {
                const item = source[i];
                const name = item && item.name !== undefined ? String(item.name) : '';
                const color = item && item.color ? item.color : root.colorAt(i);
                const values = normalizeValues(item && item.values !== undefined ? item.values : item);
                maxLength = Math.max(maxLength, values.length);
                result.push({
                                name: name,
                                color: color,
                                values: values,
                                renderValues: optimizedRenderValues(values)
                            });
            }
            __cachedData = result;
            __cachedMaxLength = maxLength;
            __cachedRevision = root.__dataRevision;
            invalidateRangeCache();
            return result;
        }

        function normalizeValues(source) {
            if (!source)
                return [];
            const result = [];
            for (let i = 0; i < source.length; ++i) {
                const item = source[i];
                if (typeof item === 'number') {
                    result.push({ x: i, y: item, value: item, label: labelAt(i), index: i });
                } else if (item && typeof item === 'object') {
                    const x = numberOr(item.x, i);
                    const y = numberOr(item.y, numberOr(item.value, 0));
                    const value = numberOr(item.value, y);
                    result.push({
                                    x: x,
                                    y: y,
                                    value: value,
                                    label: item.label !== undefined ? String(item.label) : labelAt(i),
                                    size: numberOr(item.size, root.pointSize),
                                    index: i
                                });
                }
            }
            return result;
        }

        function optimizedRenderValues(values) {
            if (!root.optimizeLargeData || values.length <= 0)
                return values;
            if (root.chartType === MosCanvasChart.Type_Line || root.chartType === MosCanvasChart.Type_Area) {
                if (values.length > root.maxRenderPoints)
                    return decimateExtrema(values, root.maxRenderPoints);
            } else if (root.chartType === MosCanvasChart.Type_Scatter) {
                if (values.length > root.scatterRenderThreshold)
                    return decimateUniform(values, root.scatterRenderThreshold);
            }
            return values;
        }

        function decimateUniform(values, limit) {
            const length = values.length;
            const maxPoints = Math.max(2, limit);
            if (length <= maxPoints)
                return values;
            const step = Math.ceil(length / maxPoints);
            const result = [];
            for (let i = 0; i < length; i += step)
                result.push(values[i]);
            if (result[result.length - 1] !== values[length - 1])
                result.push(values[length - 1]);
            return result;
        }

        function decimateExtrema(values, limit) {
            const length = values.length;
            const maxPoints = Math.max(8, limit);
            if (length <= maxPoints)
                return values;

            const bucketSize = Math.max(2, Math.ceil(length / Math.max(1, Math.floor(maxPoints / 4))));
            const result = [];
            for (let start = 0; start < length; start += bucketSize) {
                const end = Math.min(length, start + bucketSize);
                let minIndex = start;
                let maxIndex = start;
                let minValue = values[start].value;
                let maxValue = values[start].value;
                for (let i = start + 1; i < end; ++i) {
                    const value = values[i].value;
                    if (value < minValue) {
                        minValue = value;
                        minIndex = i;
                    }
                    if (value > maxValue) {
                        maxValue = value;
                        maxIndex = i;
                    }
                }

                const bucket = [
                    { item: values[start], index: start },
                    { item: values[minIndex], index: minIndex },
                    { item: values[maxIndex], index: maxIndex },
                    { item: values[end - 1], index: end - 1 }
                ];
                bucket.sort((a, b) => a.index - b.index);
                for (let b = 0; b < bucket.length; ++b)
                    pushUniqueRenderItem(result, bucket[b].item);
            }
            pushUniqueRenderItem(result, values[length - 1]);
            return result;
        }

        function pushUniqueRenderItem(target, item) {
            if (target.length === 0 || itemIndex(target[target.length - 1], target.length - 1) !== itemIndex(item, target.length))
                target.push(item);
        }

        function invalidateDataCache() {
            __cachedRevision = -1;
            __cachedData = [];
            __cachedMaxLength = 0;
            invalidateRangeCache();
        }

        function invalidateRangeCache() {
            __cachedXRange = null;
            __cachedXRangeKey = '';
            __cachedValueRange = null;
            __cachedValueRangeKey = '';
            __cachedScatterRangeX = null;
            __cachedScatterRangeY = null;
        }

        function effectiveProgress(data) {
            if (!root.animationEnabled)
                return 1;
            if (root.optimizeLargeData)
                return 1;
            return root.animationProgress;
        }

        function labelAt(index) {
            const label = root.labels && index < root.labels.length ? root.labels[index] : undefined;
            return root.labelFormatter(label, index);
        }

        function numberOr(value, fallback) {
            const num = Number(value);
            return isFinite(num) ? num : fallback;
        }

        function maxSeriesLength(data) {
            if (__cachedRevision === root.__dataRevision)
                return __cachedMaxLength;
            let length = 0;
            for (let i = 0; i < data.length; ++i)
                length = Math.max(length, data[i].values.length);
            return length;
        }

        function plotRect() {
            const left = root.__isRoundChart ? 18 * root.sizeRatio : 48 * root.sizeRatio;
            const right = 18 * root.sizeRatio;
            const top = headerHeight + 12 * root.sizeRatio;
            const bottom = (root.__isRoundChart ? 8 : 34) * root.sizeRatio + legendHeight;
            return {
                x: left,
                y: top,
                w: Math.max(10, __canvas.width - left - right),
                h: Math.max(10, __canvas.height - top - bottom)
            };
        }

        function drawHeader(ctx) {
            let y = 0;
            if (root.showTitle) {
                ctx.fillStyle = root.colorText;
                ctx.font = fontString(root.titleFont);
                ctx.textAlign = 'left';
                ctx.textBaseline = 'top';
                ctx.fillText(root.title, 0, y);
                y += 24 * root.sizeRatio;
            }
            if (root.showSubtitle) {
                ctx.fillStyle = root.colorTextSecondary;
                ctx.font = fontString(root.subtitleFont);
                ctx.textAlign = 'left';
                ctx.textBaseline = 'top';
                ctx.fillText(root.subtitle, 0, y);
            }
        }

        function drawEmpty(ctx) {
            ctx.fillStyle = root.colorTextSecondary;
            ctx.font = fontString(root.labelFont);
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(qsTr('No data'), __canvas.width * 0.5, __canvas.height * 0.5);
        }

        function drawCartesian(ctx, data, progress) {
            const rect = plotRect();
            const range = valueRange(data);
            const count = Math.max(1, maxSeriesLength(data));
            const xRange = axisXRange(data, count);
            const scaleX = value => rect.x + ((value - xRange.min) / (xRange.max - xRange.min)) * rect.w;
            const scaleY = value => rect.y + rect.h - ((value - range.min) / (range.max - range.min)) * rect.h;
            const zeroY = scaleY(Math.max(range.min, Math.min(0, range.max)));

            drawPlotBg(ctx, rect);
            if (root.showGrid)
                drawGrid(ctx, rect, range, xRange);
            if (root.showAxis)
                drawAxis(ctx, rect, range);

            ctx.save();
            ctx.beginPath();
            ctx.rect(rect.x, rect.y, rect.w, rect.h);
            ctx.clip();
            switch (root.chartType) {
            case MosCanvasChart.Type_Bar:
                drawBars(ctx, data, rect, range, xRange, scaleX, progress, zeroY);
                break;
            case MosCanvasChart.Type_Area:
                drawAreas(ctx, data, rect, xRange, scaleX, scaleY, zeroY, progress);
                break;
            case MosCanvasChart.Type_Scatter:
                drawScatter(ctx, data, rect, xRange, range, progress);
                break;
            default:
                drawLines(ctx, data, rect, xRange, scaleX, scaleY, progress);
                break;
            }
            ctx.restore();

            if (root.showLabels)
                drawXLabels(ctx, rect, count, xRange);
        }

        function drawPlotBg(ctx, rect) {
            ctx.save();
            ctx.fillStyle = root.colorPlotBg;
            roundRect(ctx, rect.x, rect.y, rect.w, rect.h, 12 * root.sizeRatio);
            ctx.fill();
            ctx.restore();
        }

        function drawGrid(ctx, rect, range, xRange) {
            ctx.save();
            ctx.strokeStyle = root.colorGrid;
            ctx.lineWidth = root.gridLineWidth;
            ctx.fillStyle = root.colorTextSecondary;
            ctx.font = fontString(root.labelFont);
            ctx.textAlign = 'right';
            ctx.textBaseline = 'middle';
            const steps = axisBlockCount(root.yBlockCount, 5);
            for (let i = 0; i <= steps; ++i) {
                const y = rect.y + rect.h * i / steps;
                const value = range.max - (range.max - range.min) * i / steps;
                ctx.beginPath();
                ctx.moveTo(rect.x, y);
                ctx.lineTo(rect.x + rect.w, y);
                ctx.stroke();
                if (root.showAxis)
                    ctx.fillText(root.formatter(value), rect.x - 8 * root.sizeRatio, y);
            }
            if (root.xBlockCount > 0) {
                const xSteps = axisBlockCount(root.xBlockCount, 5);
                for (let i = 0; i <= xSteps; ++i) {
                    const x = rect.x + rect.w * i / xSteps;
                    ctx.beginPath();
                    ctx.moveTo(x, rect.y);
                    ctx.lineTo(x, rect.y + rect.h);
                    ctx.stroke();
                }
            }
            ctx.restore();
        }

        function drawAxis(ctx, rect, range) {
            ctx.save();
            ctx.strokeStyle = root.colorAxis;
            ctx.lineWidth = root.axisLineWidth;
            ctx.beginPath();
            ctx.moveTo(rect.x, rect.y);
            ctx.lineTo(rect.x, rect.y + rect.h);
            ctx.lineTo(rect.x + rect.w, rect.y + rect.h);
            ctx.stroke();
            ctx.restore();
        }

        function drawXLabels(ctx, rect, count, xRange) {
            ctx.save();
            ctx.fillStyle = root.colorTextSecondary;
            ctx.font = fontString(root.labelFont);
            ctx.textAlign = 'center';
            ctx.textBaseline = 'top';
            const blocks = root.xBlockCount > 0
                    ? axisBlockCount(root.xBlockCount, 5)
                    : Math.max(2, Math.floor(rect.w / (54 * root.sizeRatio)));
            for (let i = 0; i <= blocks; ++i) {
                const value = xRange.min + (xRange.max - xRange.min) * i / blocks;
                const x = rect.x + rect.w * i / blocks;
                ctx.fillText(xLabelText(value, count), x, rect.y + rect.h + 10 * root.sizeRatio);
            }
            ctx.restore();
        }

        function axisXRange(data, count) {
            const cacheKey = root.chartType + ':' + root.autoXRange + ':' + root.xMin + ':' + root.xMax + ':' + __cachedRevision;
            if (__cachedXRange && __cachedXRangeKey === cacheKey)
                return __cachedXRange;

            if (!root.autoXRange)
                return cacheXRange(cacheKey, root.xMin, root.xMax, 0);

            if (root.chartType === MosCanvasChart.Type_Scatter) {
                let min = Number.POSITIVE_INFINITY;
                let max = Number.NEGATIVE_INFINITY;
                for (let s = 0; s < data.length; ++s) {
                    for (let i = 0; i < data[s].values.length; ++i) {
                        const value = data[s].values[i].x;
                        min = Math.min(min, value);
                        max = Math.max(max, value);
                    }
                }
                return cacheXRange(cacheKey, min, max, 0.1);
            }

            return cacheXRange(cacheKey, 0, Math.max(0, count - 1), 0);
        }

        function cacheXRange(cacheKey, min, max, paddingRatio) {
            const range = normalizedAxisRange(min, max, paddingRatio);
            __cachedXRange = range;
            __cachedXRangeKey = cacheKey;
            return range;
        }

        function valueRange(data) {
            const cacheKey = root.chartType + ':' + root.stacked + ':' + root.autoYRange + ':' +
                             root.yMin + ':' + root.yMax + ':' + __cachedRevision;
            if (__cachedValueRange && __cachedValueRangeKey === cacheKey)
                return __cachedValueRange;

            if (!root.autoYRange)
                return cacheValueRange(cacheKey, root.yMin, root.yMax, 0);

            if (root.stacked && root.chartType === MosCanvasChart.Type_Bar) {
                let min = 0;
                let max = 0;
                const count = maxSeriesLength(data);
                for (let i = 0; i < count; ++i) {
                    let pos = 0;
                    let neg = 0;
                    for (let s = 0; s < data.length; ++s) {
                        const v = data[s].values[i] ? data[s].values[i].value : 0;
                        if (v >= 0)
                            pos += v;
                        else
                            neg += v;
                    }
                    max = Math.max(max, pos);
                    min = Math.min(min, neg);
                }
                return cacheValueRange(cacheKey, min, max);
            } else {
                const includeZero = root.chartType === MosCanvasChart.Type_Bar;
                let min = includeZero ? 0 : Number.POSITIVE_INFINITY;
                let max = includeZero ? 0 : Number.NEGATIVE_INFINITY;
                for (let s = 0; s < data.length; ++s) {
                    for (let i = 0; i < data[s].values.length; ++i) {
                        const item = data[s].values[i];
                        const v = root.chartType === MosCanvasChart.Type_Scatter ? item.y : item.value;
                        min = Math.min(min, v);
                        max = Math.max(max, v);
                    }
                }
                return cacheValueRange(cacheKey, min, max);
            }
        }

        function cacheValueRange(cacheKey, min, max, paddingRatio = 0.12) {
            const range = normalizedAxisRange(min, max, paddingRatio);
            __cachedValueRange = range;
            __cachedValueRangeKey = cacheKey;
            return __cachedValueRange;
        }

        function normalizedAxisRange(min, max, paddingRatio) {
            if (!isFinite(min) || !isFinite(max)) {
                min = 0;
                max = 1;
            }
            if (min === max) {
                max += 1;
                min -= 1;
            }
            if (min > max) {
                const temp = min;
                min = max;
                max = temp;
            }
            const padding = (max - min) * Math.max(0, paddingRatio);
            return { min: min - padding, max: max + padding };
        }

        function axisBlockCount(value, fallback) {
            const count = Math.round(Number(value));
            return isFinite(count) && count > 0 ? count : fallback;
        }

        function xLabelText(value, count) {
            if (root.chartType !== MosCanvasChart.Type_Scatter && root.labels && root.labels.length > 0) {
                const index = Math.round(value);
                if (index >= 0 && index < count)
                    return labelAt(index);
            }
            return root.xFormatter(value);
        }

        function scatterRange(data, key) {
            if (key === 'x' && __cachedScatterRangeX)
                return __cachedScatterRangeX;
            if (key === 'y' && __cachedScatterRangeY)
                return __cachedScatterRangeY;

            let min = Number.POSITIVE_INFINITY;
            let max = Number.NEGATIVE_INFINITY;
            for (let s = 0; s < data.length; ++s) {
                for (let i = 0; i < data[s].values.length; ++i) {
                    const v = data[s].values[i][key];
                    min = Math.min(min, v);
                    max = Math.max(max, v);
                }
            }
            if (!isFinite(min) || !isFinite(max)) {
                min = 0;
                max = 1;
            }
            if (min === max) {
                max += 1;
                min -= 1;
            }
            const padding = (max - min) * 0.1;
            const range = { min: min - padding, max: max + padding };
            if (key === 'x')
                __cachedScatterRangeX = range;
            else
                __cachedScatterRangeY = range;
            return range;
        }

        function drawLines(ctx, data, rect, xRange, scaleX, scaleY, progress) {
            for (let s = 0; s < data.length; ++s) {
                const items = data[s].renderValues || data[s].values;
                if (items.length === 0)
                    continue;
                const pathProgress = items.length === data[s].values.length ? progress : 1;
                ctx.save();
                ctx.strokeStyle = data[s].color;
                ctx.lineWidth = root.lineWidth;
                ctx.lineJoin = 'round';
                ctx.lineCap = 'round';
                drawSeriesPath(ctx, items, scaleX, value => scaleY(value), pathProgress);
                ctx.stroke();
                ctx.restore();
                drawPoints(ctx, data[s], s, xRange, scaleX, scaleY, progress);
            }
        }

        function drawAreas(ctx, data, rect, xRange, scaleX, scaleY, zeroY, progress) {
            for (let s = 0; s < data.length; ++s) {
                const items = data[s].renderValues || data[s].values;
                if (items.length === 0)
                    continue;
                const pathProgress = items.length === data[s].values.length ? progress : 1;
                ctx.save();
                const gradient = ctx.createLinearGradient(0, rect.y, 0, rect.y + rect.h);
                gradient.addColorStop(0, alphaColor(data[s].color, root.areaFillOpacity * 1.3));
                gradient.addColorStop(1, alphaColor(data[s].color, 0.02));
                ctx.fillStyle = gradient;
                ctx.beginPath();
                ctx.moveTo(scaleX(itemIndex(items[0], 0)), zeroY);
                appendSeriesPath(ctx, items, scaleX, value => scaleY(value), pathProgress);
                ctx.lineTo(seriesEndX(items, scaleX, pathProgress), zeroY);
                ctx.closePath();
                ctx.fill();
                ctx.strokeStyle = data[s].color;
                ctx.lineWidth = root.lineWidth;
                ctx.beginPath();
                appendSeriesPath(ctx, items, scaleX, value => scaleY(value), pathProgress);
                ctx.stroke();
                ctx.restore();
                drawPoints(ctx, data[s], s, xRange, scaleX, scaleY, progress);
            }
        }

        function drawSeriesPath(ctx, items, scaleX, scaleY, progress) {
            ctx.beginPath();
            appendSeriesPath(ctx, items, scaleX, scaleY, progress);
        }

        function appendSeriesPath(ctx, items, scaleX, scaleY, progress) {
            const end = Math.max(0, (items.length - 1) * progress);
            const full = Math.floor(end);
            ctx.moveTo(scaleX(itemIndex(items[0], 0)), scaleY(items[0].value));
            for (let i = 1; i <= full; ++i)
                drawToPoint(ctx, items, i, scaleX, scaleY);
            if (full < items.length - 1) {
                const t = end - full;
                const currentIndex = itemIndex(items[full], full);
                const nextIndex = itemIndex(items[full + 1], full + 1);
                const x = scaleX(currentIndex) + (scaleX(nextIndex) - scaleX(currentIndex)) * t;
                const y = scaleY(items[full].value) + (scaleY(items[full + 1].value) - scaleY(items[full].value)) * t;
                if (root.smooth && full > 0) {
                    const prevX = scaleX(currentIndex);
                    const prevY = scaleY(items[full].value);
                    ctx.quadraticCurveTo(prevX, prevY, x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
        }

        function drawToPoint(ctx, items, index, scaleX, scaleY) {
            const x = scaleX(itemIndex(items[index], index));
            const y = scaleY(items[index].value);
            if (root.smooth && index > 0) {
                const prevX = scaleX(itemIndex(items[index - 1], index - 1));
                const prevY = scaleY(items[index - 1].value);
                const midX = (prevX + x) * 0.5;
                ctx.quadraticCurveTo(prevX, prevY, midX, (prevY + y) * 0.5);
                ctx.quadraticCurveTo(x, y, x, y);
            } else {
                ctx.lineTo(x, y);
            }
        }

        function seriesEndX(items, scaleX, progress) {
            if (items.length === 0)
                return 0;
            const end = Math.max(0, (items.length - 1) * progress);
            const full = Math.floor(end);
            if (full >= items.length - 1)
                return scaleX(itemIndex(items[items.length - 1], items.length - 1));
            const t = end - full;
            const currentIndex = itemIndex(items[full], full);
            const nextIndex = itemIndex(items[full + 1], full + 1);
            return scaleX(currentIndex + (nextIndex - currentIndex) * t);
        }

        function itemIndex(item, fallback) {
            return item && item.index !== undefined ? item.index : fallback;
        }

        function drawPoints(ctx, serie, seriesIndex, xRange, scaleX, scaleY, progress) {
            const values = root.optimizeLargeData && serie.values.length > root.maxInteractivePoints
                    ? (serie.renderValues || serie.values)
                    : serie.values;
            const drawMarkers = root.showValues || serie.values.length <= root.pointRenderThreshold;
            const endIndex = Math.max(0, (serie.values.length - 1) * progress);
            ctx.save();
            for (let i = 0; i < values.length; ++i) {
                const item = values[i];
                const sourceIndex = itemIndex(item, i);
                if (sourceIndex > endIndex + 0.001)
                    continue;
                if (sourceIndex < xRange.min || sourceIndex > xRange.max)
                    continue;
                const x = scaleX(sourceIndex);
                const y = scaleY(item.value);
                const hovered = __canvas.hoverIndex === sourceIndex && __canvas.hoverSeriesIndex === seriesIndex;
                const r = hovered ? root.pointSize * 1.55 : root.pointSize;
                if (drawMarkers || hovered) {
                    ctx.fillStyle = root.colorBg;
                    ctx.strokeStyle = serie.color;
                    ctx.lineWidth = hovered ? root.lineWidth + 1 : root.lineWidth;
                    ctx.beginPath();
                    ctx.arc(x, y, r, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.stroke();
                }
                addHit(x, y, Math.max(12 * root.sizeRatio, r + 6), sourceIndex, seriesIndex, item, serie);
                if (root.showValues)
                    drawValueLabel(ctx, root.formatter(item.value), x, y - r - 8 * root.sizeRatio, serie.color);
            }
            ctx.restore();
        }

        function drawBars(ctx, data, rect, range, xRange, scaleX, progress, zeroY) {
            const count = maxSeriesLength(data);
            const step = root.optimizeLargeData && count > root.barRenderThreshold
                    ? Math.ceil(count / root.barRenderThreshold)
                    : 1;
            const fastBars = step > 1;
            const rawGroupWidth = count <= 1
                    ? rect.w
                    : Math.max(4 * root.sizeRatio,
                               Math.abs(scaleX(Math.min(xRange.max, xRange.min + step)) - scaleX(xRange.min)));
            const groupGap = 10 * root.sizeRatio;
            const seriesCount = root.stacked ? 1 : data.length;
            const barWidth = Math.max(4 * root.sizeRatio, (rawGroupWidth - groupGap) / Math.max(1, seriesCount) * 0.72);
            const scaleY = value => rect.y + rect.h - ((value - range.min) / (range.max - range.min)) * rect.h;

            for (let i = 0; i < count; i += step) {
                let positiveBase = 0;
                let negativeBase = 0;
                for (let s = 0; s < data.length; ++s) {
                    const item = step === 1 ? data[s].values[i] : bucketBarItem(data[s].values, i, Math.min(count, i + step));
                    if (!item)
                        continue;
                    const sourceIndex = itemIndex(item, i);
                    if (sourceIndex < xRange.min || sourceIndex > xRange.max)
                        continue;
                    const value = item.value * progress;
                    let x;
                    let y;
                    let h;
                    if (root.stacked) {
                        x = scaleX(sourceIndex) - barWidth * 0.5;
                        const base = item.value >= 0 ? positiveBase : negativeBase;
                        const y0 = scaleY(base);
                        const y1 = scaleY(base + value);
                        y = Math.min(y0, y1);
                        h = Math.max(2, Math.abs(y1 - y0));
                        if (item.value >= 0)
                            positiveBase += item.value * progress;
                        else
                            negativeBase += item.value * progress;
                    } else {
                        x = scaleX(sourceIndex) - barWidth * data.length * 0.5 + s * barWidth;
                        const yValue = scaleY(value);
                        y = Math.min(zeroY, yValue);
                        h = Math.max(2, Math.abs(zeroY - yValue));
                    }
                    drawBar(ctx, x, y, barWidth * 0.82, h, data[s].color, item.value >= 0, fastBars);
                    addHit(x + barWidth * 0.41, y + h * 0.5, Math.max(barWidth, 18 * root.sizeRatio), sourceIndex, s, item, data[s]);
                    if (root.showValues)
                        drawValueLabel(ctx, root.formatter(item.value), x + barWidth * 0.41, y - 8 * root.sizeRatio, data[s].color);
                }
            }
        }

        function bucketBarItem(values, start, end) {
            let best = null;
            let bestValue = -1;
            for (let i = start; i < end; ++i) {
                const item = values[i];
                if (!item)
                    continue;
                const value = Math.abs(item.value);
                if (value > bestValue) {
                    best = item;
                    bestValue = value;
                }
            }
            return best;
        }

        function drawBar(ctx, x, y, w, h, color, positive, fast) {
            ctx.save();
            if (fast) {
                ctx.fillStyle = color;
            } else {
                const gradient = ctx.createLinearGradient(x, y, x, y + h);
                gradient.addColorStop(positive ? 0 : 1, lightenColor(color, 0.2));
                gradient.addColorStop(positive ? 1 : 0, color);
                ctx.fillStyle = gradient;
            }
            roundRect(ctx, x, y, w, h, Math.min(root.barRadius, w * 0.5, h * 0.5));
            ctx.fill();
            ctx.restore();
        }

        function drawScatter(ctx, data, rect, xRange, yRange, progress) {
            const scaleX = value => rect.x + ((value - xRange.min) / (xRange.max - xRange.min)) * rect.w;
            const scaleY = value => rect.y + rect.h - ((value - yRange.min) / (yRange.max - yRange.min)) * rect.h;

            for (let s = 0; s < data.length; ++s) {
                const values = data[s].renderValues || data[s].values;
                const fillNormal = alphaColor(data[s].color, 0.78);
                const fillHover = alphaColor(data[s].color, 0.95);
                ctx.save();
                for (let i = 0; i < values.length; ++i) {
                    const item = values[i];
                    const sourceIndex = itemIndex(item, i);
                    if (item.x < xRange.min || item.x > xRange.max ||
                            item.y < yRange.min || item.y > yRange.max)
                        continue;
                    const x = scaleX(item.x);
                    const y = scaleY(item.y);
                    const hovered = __canvas.hoverIndex === sourceIndex && __canvas.hoverSeriesIndex === s;
                    const r = (item.size || root.pointSize) * (hovered ? 1.7 : 1.0) * Math.max(0.1, progress);
                    ctx.fillStyle = hovered ? fillHover : fillNormal;
                    ctx.strokeStyle = root.colorBg;
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.arc(x, y, r, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.stroke();
                    addHit(x, y, Math.max(14 * root.sizeRatio, r + 7), sourceIndex, s, item, data[s]);
                    if (root.showValues)
                        drawValueLabel(ctx, root.formatter(item.y), x, y - r - 8 * root.sizeRatio, data[s].color);
                }
                ctx.restore();
            }
        }

        function drawPie(ctx, data, progress, doughnut) {
            const rect = plotRect();
            const items = data[0].values;
            const total = items.reduce((sum, item) => sum + Math.max(0, item.value), 0);
            if (total <= 0) {
                drawEmpty(ctx);
                return;
            }
            const cx = rect.x + rect.w * 0.5;
            const cy = rect.y + rect.h * 0.5;
            const radius = Math.max(8, Math.min(rect.w, rect.h) * 0.42);
            const inner = doughnut ? radius * Math.max(0.1, Math.min(0.8, root.doughnutWidthRatio)) : 0;
            let start = -Math.PI * 0.5;
            for (let i = 0; i < items.length; ++i) {
                const value = Math.max(0, items[i].value);
                const sweep = value / total * Math.PI * 2 * progress;
                const end = start + sweep;
                const hovered = __canvas.hoverIndex === i;
                const offset = hovered ? 8 * root.sizeRatio : 0;
                const mid = (start + end) * 0.5;
                const ox = Math.cos(mid) * offset;
                const oy = Math.sin(mid) * offset;
                drawPieSlice(ctx, cx + ox, cy + oy, radius, inner, start, end, root.colorAt(i), hovered);
                const hitRadius = (radius + inner) * 0.5;
                addHit(cx + Math.cos(mid) * hitRadius, cy + Math.sin(mid) * hitRadius,
                       Math.max(18 * root.sizeRatio, radius * value / total), i, 0, items[i], data[0]);
                if (root.showValues && sweep > 0.2) {
                    const percent = value / total * 100;
                    drawValueLabel(ctx, percent.toLocaleString(Qt.locale(), 'f', 1) + '%',
                                   cx + Math.cos(mid) * radius * 0.68,
                                   cy + Math.sin(mid) * radius * 0.68,
                                   root.colorAt(i));
                }
                start += value / total * Math.PI * 2;
            }
            if (doughnut) {
                ctx.save();
                ctx.fillStyle = root.colorBg;
                ctx.beginPath();
                ctx.arc(cx, cy, inner, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = root.colorText;
                ctx.font = fontString(root.titleFont);
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText(root.formatter(total), cx, cy);
                ctx.restore();
            }
        }

        function drawPieSlice(ctx, cx, cy, radius, inner, start, end, color, hovered) {
            if (end <= start)
                return;
            ctx.save();
            const gradient = ctx.createRadialGradient(cx, cy, inner, cx, cy, radius);
            gradient.addColorStop(0, lightenColor(color, 0.18));
            gradient.addColorStop(1, color);
            ctx.fillStyle = gradient;
            ctx.strokeStyle = root.colorBg;
            ctx.lineWidth = hovered ? 3 : 2;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, start, end);
            if (inner > 0) {
                ctx.arc(cx, cy, inner, end, start, true);
            } else {
                ctx.lineTo(cx, cy);
            }
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
            ctx.restore();
        }

        function drawRadar(ctx, data, progress) {
            const rect = plotRect();
            const count = maxSeriesLength(data);
            if (count < 3) {
                drawEmpty(ctx);
                return;
            }
            let max = 0;
            for (let s = 0; s < data.length; ++s) {
                for (let i = 0; i < data[s].values.length; ++i)
                    max = Math.max(max, Math.abs(data[s].values[i].value));
            }
            if (max <= 0)
                max = 1;

            const cx = rect.x + rect.w * 0.5;
            const cy = rect.y + rect.h * 0.52;
            const radius = Math.min(rect.w, rect.h) * 0.42;

            ctx.save();
            ctx.strokeStyle = root.colorGrid;
            ctx.fillStyle = root.colorTextSecondary;
            ctx.font = fontString(root.labelFont);
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            for (let level = 1; level <= 5; ++level) {
                const r = radius * level / 5;
                ctx.beginPath();
                for (let i = 0; i < count; ++i) {
                    const p = radarPoint(cx, cy, r, i, count);
                    if (i === 0)
                        ctx.moveTo(p.x, p.y);
                    else
                        ctx.lineTo(p.x, p.y);
                }
                ctx.closePath();
                ctx.stroke();
            }
            for (let i = 0; i < count; ++i) {
                const p = radarPoint(cx, cy, radius, i, count);
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.lineTo(p.x, p.y);
                ctx.stroke();
                if (root.showLabels) {
                    const lp = radarPoint(cx, cy, radius + 18 * root.sizeRatio, i, count);
                    ctx.fillText(labelAt(i), lp.x, lp.y);
                }
            }
            ctx.restore();

            for (let s = 0; s < data.length; ++s) {
                ctx.save();
                ctx.beginPath();
                for (let i = 0; i < count; ++i) {
                    const item = data[s].values[i] || { value: 0 };
                    const r = radius * Math.abs(item.value) / max * progress;
                    const p = radarPoint(cx, cy, r, i, count);
                    if (i === 0)
                        ctx.moveTo(p.x, p.y);
                    else
                        ctx.lineTo(p.x, p.y);
                }
                ctx.closePath();
                ctx.fillStyle = alphaColor(data[s].color, root.radarFillOpacity);
                ctx.strokeStyle = data[s].color;
                ctx.lineWidth = root.lineWidth;
                ctx.fill();
                ctx.stroke();
                for (let i = 0; i < count; ++i) {
                    const item = data[s].values[i] || { value: 0, label: labelAt(i) };
                    const r = radius * Math.abs(item.value) / max * progress;
                    const p = radarPoint(cx, cy, r, i, count);
                    ctx.fillStyle = root.colorBg;
                    ctx.strokeStyle = data[s].color;
                    ctx.beginPath();
                    ctx.arc(p.x, p.y, root.pointSize, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.stroke();
                    addHit(p.x, p.y, 14 * root.sizeRatio, i, s, item, data[s]);
                }
                ctx.restore();
            }
        }

        function radarPoint(cx, cy, radius, index, count) {
            const angle = -Math.PI * 0.5 + Math.PI * 2 * index / count;
            return { x: cx + Math.cos(angle) * radius, y: cy + Math.sin(angle) * radius };
        }

        function drawLegend(ctx, data) {
            const items = root.chartType === MosCanvasChart.Type_Pie || root.chartType === MosCanvasChart.Type_Doughnut
                    ? data[0].values.map((item, index) => ({ name: item.label, color: root.colorAt(index) }))
                    : data.map(item => ({ name: item.name || qsTr('Series'), color: item.color }));
            if (items.length === 0)
                return;

            ctx.save();
            ctx.font = fontString(root.labelFont);
            ctx.textBaseline = 'middle';
            let x = 0;
            const y = __canvas.height - 12 * root.sizeRatio;
            for (let i = 0; i < items.length; ++i) {
                const name = items[i].name || labelAt(i);
                const width = ctx.measureText(name).width + 26 * root.sizeRatio;
                if (x + width > __canvas.width)
                    break;
                ctx.fillStyle = items[i].color;
                roundRect(ctx, x, y - 4 * root.sizeRatio, 14 * root.sizeRatio, 8 * root.sizeRatio, 4 * root.sizeRatio);
                ctx.fill();
                ctx.fillStyle = root.colorTextSecondary;
                ctx.fillText(name, x + 20 * root.sizeRatio, y);
                x += width + 12 * root.sizeRatio;
            }
            ctx.restore();
        }

        function drawValueLabel(ctx, text, x, y, color) {
            ctx.save();
            ctx.font = fontString(root.valueFont);
            const metrics = ctx.measureText(text);
            const w = metrics.width + 10 * root.sizeRatio;
            const h = 20 * root.sizeRatio;
            ctx.fillStyle = alphaColor(color, 0.12);
            roundRect(ctx, x - w * 0.5, y - h * 0.5, w, h, 8 * root.sizeRatio);
            ctx.fill();
            ctx.fillStyle = color;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(text, x, y);
            ctx.restore();
        }

        function drawTooltip(ctx) {
            if (__canvas.hoverIndex < 0)
                return;
            const data = hoverData();
            if (!data)
                return;
            const label = data.item.label || labelAt(__canvas.hoverIndex);
            const value = root.chartType === MosCanvasChart.Type_Scatter ? data.item.y : data.item.value;
            const title = data.serie.name ? data.serie.name + ' / ' + label : label;
            const text = root.formatter(value);
            ctx.save();
            ctx.font = fontString(root.labelFont);
            const w = Math.max(ctx.measureText(title).width, ctx.measureText(text).width) + 22 * root.sizeRatio;
            const h = 46 * root.sizeRatio;
            let x = __canvas.hoverX + 14 * root.sizeRatio;
            let y = __canvas.hoverY - h - 12 * root.sizeRatio;
            if (x + w > __canvas.width)
                x = __canvas.hoverX - w - 14 * root.sizeRatio;
            if (y < 0)
                y = __canvas.hoverY + 14 * root.sizeRatio;
            ctx.fillStyle = root.colorTooltipBg;
            ctx.strokeStyle = root.colorTooltipBorder;
            ctx.lineWidth = 1;
            roundRect(ctx, x, y, w, h, 10 * root.sizeRatio);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = data.serie.color;
            ctx.beginPath();
            ctx.arc(x + 11 * root.sizeRatio, y + 15 * root.sizeRatio, 4 * root.sizeRatio, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = root.colorTextSecondary;
            ctx.textAlign = 'left';
            ctx.textBaseline = 'middle';
            ctx.fillText(title, x + 20 * root.sizeRatio, y + 15 * root.sizeRatio);
            ctx.fillStyle = root.colorText;
            ctx.font = fontString(root.valueFont);
            ctx.fillText(text, x + 10 * root.sizeRatio, y + 32 * root.sizeRatio);
            ctx.restore();
        }

        function addHit(x, y, radius, index, seriesIndex, item, serie) {
            if (__canvas.hitItems.length >= root.maxInteractivePoints)
                return;
            __canvas.hitItems.push({
                                       x: x,
                                       y: y,
                                       r: radius,
                                       index: index,
                                       seriesIndex: seriesIndex,
                                       item: item,
                                       serie: serie
                                   });
        }

        function updateHover(x, y) {
            if (!root.hoverable)
                return;
            let found = null;
            let minDistance = Number.POSITIVE_INFINITY;
            for (let i = 0; i < __canvas.hitItems.length; ++i) {
                const hit = __canvas.hitItems[i];
                const dx = x - hit.x;
                const dy = y - hit.y;
                const distance = dx * dx + dy * dy;
                if (distance <= hit.r * hit.r && distance < minDistance) {
                    found = hit;
                    minDistance = distance;
                }
            }
            const nextIndex = found ? found.index : -1;
            const nextSeriesIndex = found ? found.seriesIndex : -1;
            const hoverChanged = __canvas.hoverIndex !== nextIndex || __canvas.hoverSeriesIndex !== nextSeriesIndex;
            const tooltipMoved = found && (Math.abs(__canvas.hoverX - x) > 6 * root.sizeRatio ||
                                           Math.abs(__canvas.hoverY - y) > 6 * root.sizeRatio);
            __canvas.hoverX = x;
            __canvas.hoverY = y;
            __canvas.hoverHit = found;
            if (hoverChanged) {
                __canvas.hoverIndex = nextIndex;
                __canvas.hoverSeriesIndex = nextSeriesIndex;
                root.chartHovered(nextIndex, nextSeriesIndex, hoverData());
            }
            if (hoverChanged || tooltipMoved)
                __canvas.requestPaint();
        }

        function hoverData() {
            if (__canvas.hoverHit && __canvas.hoverHit.index === __canvas.hoverIndex &&
                    __canvas.hoverHit.seriesIndex === __canvas.hoverSeriesIndex) {
                return {
                    index: __canvas.hoverHit.index,
                    seriesIndex: __canvas.hoverHit.seriesIndex,
                    item: __canvas.hoverHit.item,
                    serie: __canvas.hoverHit.serie
                };
            }
            for (let i = 0; i < __canvas.hitItems.length; ++i) {
                const hit = __canvas.hitItems[i];
                if (hit.index === __canvas.hoverIndex && hit.seriesIndex === __canvas.hoverSeriesIndex)
                    return { index: hit.index, seriesIndex: hit.seriesIndex, item: hit.item, serie: hit.serie };
            }
            return null;
        }

        function roundRect(ctx, x, y, w, h, r) {
            const radius = Math.max(0, Math.min(r, w * 0.5, h * 0.5));
            ctx.beginPath();
            ctx.moveTo(x + radius, y);
            ctx.lineTo(x + w - radius, y);
            ctx.quadraticCurveTo(x + w, y, x + w, y + radius);
            ctx.lineTo(x + w, y + h - radius);
            ctx.quadraticCurveTo(x + w, y + h, x + w - radius, y + h);
            ctx.lineTo(x + radius, y + h);
            ctx.quadraticCurveTo(x, y + h, x, y + h - radius);
            ctx.lineTo(x, y + radius);
            ctx.quadraticCurveTo(x, y, x + radius, y);
            ctx.closePath();
        }

        function fontString(font) {
            const weight = font.weight >= Font.DemiBold ? '600 ' : '';
            return weight + font.pixelSize + 'px "' + font.family + '"';
        }

        function alphaColor(color, alpha) {
            const key = String(color) + ':' + alpha;
            if (__alphaCache[key])
                return __alphaCache[key];
            const c = parseColor(color);
            const text = 'rgba(' + c.r + ',' + c.g + ',' + c.b + ',' + Math.max(0, Math.min(1, alpha)) + ')';
            __alphaCache[key] = text;
            return text;
        }

        function lightenColor(color, amount) {
            const key = String(color) + ':' + amount;
            if (__lightenCache[key])
                return __lightenCache[key];
            const c = parseColor(color);
            const r = Math.round(c.r + (255 - c.r) * amount);
            const g = Math.round(c.g + (255 - c.g) * amount);
            const b = Math.round(c.b + (255 - c.b) * amount);
            const text = 'rgb(' + r + ',' + g + ',' + b + ')';
            __lightenCache[key] = text;
            return text;
        }

        function parseColor(color) {
            let text = String(color);
            if (__colorCache[text])
                return __colorCache[text];
            const original = text;
            if (text[0] === '#') {
                if (text.length === 4) {
                    const r1 = text[1];
                    const g1 = text[2];
                    const b1 = text[3];
                    text = '#' + r1 + r1 + g1 + g1 + b1 + b1;
                } else if (text.length === 9) {
                    text = '#' + text.substr(3, 6);
                }
                const parsed = {
                    r: parseInt(text.substr(1, 2), 16),
                    g: parseInt(text.substr(3, 2), 16),
                    b: parseInt(text.substr(5, 2), 16)
                };
                __colorCache[original] = parsed;
                return parsed;
            }
            const match = text.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
            if (match) {
                const parsed = { r: Number(match[1]), g: Number(match[2]), b: Number(match[3]) };
                __colorCache[original] = parsed;
                return parsed;
            }
            const fallback = { r: 64, g: 128, b: 255 };
            __colorCache[original] = fallback;
            return fallback;
        }
    }
}
