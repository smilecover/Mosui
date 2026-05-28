#include "MosHighperchart.h"
#include "MosHighperchart_p.h"

#include <QtCore/QVariantMap>
#include <QtMath>
#include <QtQuick/QSGFlatColorMaterial>
#include <QtQuick/QSGGeometry>
#include <QtQuick/QSGGeometryNode>
#include <QtQuick/QSGVertexColorMaterial>

namespace {

struct MosChartRange
{
    qreal minX { 0.0 };
    qreal maxX { 1.0 };
    qreal minY { 0.0 };
    qreal maxY { 1.0 };
};

struct MosColoredVertex
{
    QPointF point;
    QColor color;
};

static constexpr int largeValueListCompareLimit = 4096;
static constexpr int autoDecimatePointThreshold = 30000;
static constexpr int maxVerticesPerNode = 60000;

static qreal bounded(qreal value, qreal minValue, qreal maxValue)
{
    return qMax(minValue, qMin(value, maxValue));
}


static qreal eased(qreal progress)
{
    progress = bounded(progress, 0.0, 1.0);
    return 1.0 - qPow(1.0 - progress, 3.0);
}

static bool isNumberVariant(const QVariant &value)
{
    bool ok = false;
    value.toDouble(&ok);
    return ok;
}

static bool readPoint(const QVariant &value, int index, QPointF *point)
{
    if (value.canConvert<QVariantMap>()) {
        const QVariantMap map = value.toMap();
        bool okY = false;
        const qreal y = map.value(QStringLiteral("y"), map.value(QStringLiteral("value"))).toDouble(&okY);
        if (!okY) {
            return false;
        }

        bool okX = false;
        const qreal x = map.value(QStringLiteral("x")).toDouble(&okX);
        *point = QPointF(okX ? x : index, y);
        return true;
    }

    if (value.canConvert<QVariantList>()) {
        const QVariantList list = value.toList();
        if (list.size() >= 2 && isNumberVariant(list.at(0)) && isNumberVariant(list.at(1))) {
            *point = QPointF(list.at(0).toDouble(), list.at(1).toDouble());
            return true;
        }
        if (list.size() == 1 && isNumberVariant(list.at(0))) {
            *point = QPointF(index, list.at(0).toDouble());
            return true;
        }
        return false;
    }

    bool ok = false;
    const qreal y = value.toDouble(&ok);
    if (!ok) {
        return false;
    }

    *point = QPointF(index, y);
    return true;
}

static QVector<QPointF> readSeries(const QVariantList &values)
{
    QVector<QPointF> points;
    points.reserve(values.size());
    for (int i = 0; i < values.size(); ++i) {
        QPointF point;
        if (readPoint(values.at(i), i, &point)) {
            points.push_back(point);
        }
    }
    return points;
}

static QList<QVector<QPointF>> readSeriesList(const QVariantList &values, MosHighperchart::ChartType chartType)
{
    QList<QVector<QPointF>> seriesList;
    if (values.isEmpty()) {
        return seriesList;
    }

    bool hasNestedSeries = false;
    if (chartType != MosHighperchart::Scatter) {
        const bool firstIsList = values.constFirst().canConvert<QVariantList>();
        if (firstIsList) {
            const QVariantList list = values.constFirst().toList();
            const bool looksLikePoint = list.size() == 2 && isNumberVariant(list.at(0)) && isNumberVariant(list.at(1));
            hasNestedSeries = !looksLikePoint || chartType == MosHighperchart::Bar || chartType == MosHighperchart::Radar;
        }

        if (!hasNestedSeries && chartType != MosHighperchart::Line && chartType != MosHighperchart::Area) {
            for (const QVariant &value : values) {
                if (!value.canConvert<QVariantList>()) {
                    continue;
                }
                const QVariantList list = value.toList();
                const bool looksLikePoint = list.size() == 2 && isNumberVariant(list.at(0)) && isNumberVariant(list.at(1));
                if (!looksLikePoint || chartType == MosHighperchart::Bar || chartType == MosHighperchart::Radar) {
                    hasNestedSeries = true;
                    break;
                }
            }
        }
    }

    if (hasNestedSeries) {
        for (const QVariant &value : values) {
            if (!value.canConvert<QVariantList>()) {
                continue;
            }
            const QVector<QPointF> series = readSeries(value.toList());
            if (!series.isEmpty()) {
                seriesList.push_back(series);
            }
        }
    } else {
        const QVector<QPointF> series = readSeries(values);
        if (!series.isEmpty()) {
            seriesList.push_back(series);
        }
    }

    return seriesList;
}

static QVector<QPointF> decimatePeakSeries(const QVector<QPointF> &series, int pointLimit)
{
    if (pointLimit <= 0 || series.size() <= pointLimit) {
        return series;
    }

    const int bucketCount = qMax(1, (pointLimit - 2) / 2);
    const int sourceMiddleCount = qMax(0, series.size() - 2);
    QVector<QPointF> result;
    result.reserve(qMin(series.size(), bucketCount * 2 + 2));
    result.push_back(series.constFirst());

    for (int bucket = 0; bucket < bucketCount; ++bucket) {
        const int begin = 1 + bucket * sourceMiddleCount / bucketCount;
        const int end = 1 + (bucket + 1) * sourceMiddleCount / bucketCount;
        if (begin >= end) {
            continue;
        }

        int minIndex = begin;
        int maxIndex = begin;
        qreal minY = series.at(begin).y();
        qreal maxY = minY;
        for (int i = begin + 1; i < end; ++i) {
            const qreal y = series.at(i).y();
            if (y < minY) {
                minY = y;
                minIndex = i;
            }
            if (y > maxY) {
                maxY = y;
                maxIndex = i;
            }
        }

        if (minIndex == maxIndex) {
            result.push_back(series.at(minIndex));
        } else if (minIndex < maxIndex) {
            result.push_back(series.at(minIndex));
            result.push_back(series.at(maxIndex));
        } else {
            result.push_back(series.at(maxIndex));
            result.push_back(series.at(minIndex));
        }
    }

    result.push_back(series.constLast());
    return result;
}

static QVector<QPointF> decimateStrideSeries(const QVector<QPointF> &series, int pointLimit)
{
    if (pointLimit <= 0 || series.size() <= pointLimit) {
        return series;
    }

    const int step = qMax(1, qCeil(qreal(series.size()) / pointLimit));
    QVector<QPointF> result;
    result.reserve(pointLimit + 1);
    for (int i = 0; i < series.size(); i += step) {
        result.push_back(series.at(i));
    }
    if (result.isEmpty() || result.constLast() != series.constLast()) {
        result.push_back(series.constLast());
    }
    return result;
}

static QList<QVector<QPointF>> decimateSeriesList(const QList<QVector<QPointF>> &seriesList,
                                                  const MosHighperchartPrivate *d,
                                                  int pointLimit,
                                                  bool preservePeaks)
{
    if (pointLimit <= 0) {
        return seriesList;
    }

    QList<QVector<QPointF>> result;
    result.reserve(seriesList.size());
    const int perSeriesLimit = qMax(2, pointLimit / qMax(1, seriesList.size()));
    for (const QVector<QPointF> &series : seriesList) {
        result.push_back(preservePeaks ? decimatePeakSeries(series, perSeriesLimit)
                                       : decimateStrideSeries(series, perSeriesLimit));
    }
    return result;
}

static int totalPointCount(const QList<QVector<QPointF>> &seriesList)
{
    int count = 0;
    for (const QVector<QPointF> &series : seriesList) {
        count += series.size();
    }
    return count;
}

static int effectivePointLimit(const QList<QVector<QPointF>> &seriesList,
                               const MosHighperchartPrivate *d,
                               const QRectF &rect,
                               bool preservePeaks)
{
    const int totalCount = totalPointCount(seriesList);
    if (totalCount <= 0) {
        return 0;
    }

    const int pixelLimit = qMax(512, qCeil(rect.width()) * (preservePeaks ? 3 : 2));
    if (d->highPerformanceMode) {
        return qMax(2, qMin(d->highPerformancePointLimit, pixelLimit));
    }

    if (totalCount > autoDecimatePointThreshold) {
        return qMax(2, pixelLimit);
    }

    return 0;
}

static QVector<qreal> readPieValues(const QVariantList &values)
{
    QVector<qreal> result;
    result.reserve(values.size());

    for (int i = 0; i < values.size(); ++i) {
        QPointF point;
        if (readPoint(values.at(i), i, &point)) {
            result.push_back(qMax<qreal>(0.0, point.y()));
        } else if (values.at(i).canConvert<QVariantList>()) {
            const QVector<QPointF> series = readSeries(values.at(i).toList());
            for (const QPointF &seriesPoint : series) {
                result.push_back(qMax<qreal>(0.0, seriesPoint.y()));
            }
        }
    }

    return result;
}

static QColor colorAt(const MosHighperchartPrivate *d, int index, int alpha = -1)
{
    QColor color(24, 144, 255);
    if (!d->colors.isEmpty()) {
        const QVariant value = d->colors.at(index % d->colors.size());
        if (value.canConvert<QColor>()) {
            color = value.value<QColor>();
        } else {
            const QColor parsed(value.toString());
            if (parsed.isValid()) {
                color = parsed;
            }
        }
    }
    if (alpha >= 0) {
        color.setAlpha(alpha);
    }
    return color;
}

static QRectF chartRect(const QRectF &bounds, qreal padding)
{
    const qreal inset = qMax<qreal>(0.0, padding);
    QRectF rect = bounds.adjusted(inset, inset, -inset, -inset);
    if (rect.width() <= 0.0 || rect.height() <= 0.0) {
        return bounds;
    }
    return rect;
}

static MosChartRange rangeForSeries(const QList<QVector<QPointF>> &seriesList)
{
    MosChartRange range;
    bool initialized = false;

    for (const QVector<QPointF> &series : seriesList) {
        for (const QPointF &point : series) {
            if (!initialized) {
                range.minX = range.maxX = point.x();
                range.minY = range.maxY = point.y();
                initialized = true;
            } else {
                range.minX = qMin(range.minX, point.x());
                range.maxX = qMax(range.maxX, point.x());
                range.minY = qMin(range.minY, point.y());
                range.maxY = qMax(range.maxY, point.y());
            }
        }
    }

    range.minY = qMin<qreal>(range.minY, 0.0);
    range.maxY = qMax<qreal>(range.maxY, 0.0);

    if (qFuzzyCompare(range.minX, range.maxX)) {
        range.minX -= 1.0;
        range.maxX += 1.0;
    }
    if (qFuzzyCompare(range.minY, range.maxY)) {
        range.minY -= 1.0;
        range.maxY += 1.0;
    }

    return range;
}

static QPointF mapPoint(const QPointF &point, const QRectF &rect, const MosChartRange &range)
{
    const qreal xRatio = (point.x() - range.minX) / (range.maxX - range.minX);
    const qreal yRatio = (point.y() - range.minY) / (range.maxY - range.minY);
    return QPointF(rect.left() + xRatio * rect.width(),
                   rect.bottom() - yRatio * rect.height());
}

static qreal zeroY(const QRectF &rect, const MosChartRange &range)
{
    return mapPoint(QPointF(0.0, 0.0), rect, range).y();
}

static void appendRect(QVector<QPointF> *vertices, const QRectF &rect)
{
    vertices->push_back(rect.topLeft());
    vertices->push_back(rect.bottomLeft());
    vertices->push_back(rect.topRight());
    vertices->push_back(rect.topRight());
    vertices->push_back(rect.bottomLeft());
    vertices->push_back(rect.bottomRight());
}

static void appendSegment(QVector<QPointF> *vertices, QPointF a, QPointF b, qreal width)
{
    const QPointF delta = b - a;
    const qreal length = qSqrt(delta.x() * delta.x() + delta.y() * delta.y());
    if (length <= 0.001) {
        return;
    }

    const QPointF normal(-delta.y() / length * width * 0.5, delta.x() / length * width * 0.5);
    vertices->push_back(a + normal);
    vertices->push_back(a - normal);
    vertices->push_back(b + normal);
    vertices->push_back(b + normal);
    vertices->push_back(a - normal);
    vertices->push_back(b - normal);
}

static void appendAntialiasedSegment(QVector<MosColoredVertex> *vertices,
                                     QPointF a,
                                     QPointF b,
                                     qreal width,
                                     const QColor &color)
{
    const QPointF delta = b - a;
    const qreal length = qSqrt(delta.x() * delta.x() + delta.y() * delta.y());
    if (length <= 0.001 || color.alpha() <= 0) {
        return;
    }

    QColor transparent = color;
    transparent.setAlpha(0);

    const qreal halfWidth = width * 0.5;
    const qreal feather = qBound<qreal>(1.0, width * 0.72, 1.8);
    const qreal coreHalfWidth = qMax<qreal>(0.18, halfWidth - feather * 0.45);
    const QPointF unitNormal(-delta.y() / length, delta.x() / length);
    const QPointF inner = unitNormal * coreHalfWidth;
    const QPointF outer = unitNormal * (halfWidth + feather);

    const QPointF aOuterTop = a + outer;
    const QPointF aInnerTop = a + inner;
    const QPointF aInnerBottom = a - inner;
    const QPointF aOuterBottom = a - outer;
    const QPointF bOuterTop = b + outer;
    const QPointF bInnerTop = b + inner;
    const QPointF bInnerBottom = b - inner;
    const QPointF bOuterBottom = b - outer;

    auto append = [vertices](const QPointF &point, const QColor &vertexColor) {
        vertices->push_back({ point, vertexColor });
    };
    auto appendQuad = [&append](const QPointF &a0, const QColor &c0,
                                const QPointF &a1, const QColor &c1,
                                const QPointF &b0, const QColor &c2,
                                const QPointF &b1, const QColor &c3) {
        append(a0, c0);
        append(a1, c1);
        append(b0, c2);
        append(b0, c2);
        append(a1, c1);
        append(b1, c3);
    };

    appendQuad(aOuterTop, transparent, aInnerTop, color, bOuterTop, transparent, bInnerTop, color);
    appendQuad(aInnerTop, color, aInnerBottom, color, bInnerTop, color, bInnerBottom, color);
    appendQuad(aInnerBottom, color, aOuterBottom, transparent, bInnerBottom, color, bOuterBottom, transparent);
}

static void appendCircle(QVector<QPointF> *vertices, QPointF center, qreal radius, int segmentCount = 28)
{
    if (radius <= 0.0) {
        return;
    }
    const qreal step = M_PI * 2.0 / segmentCount;
    for (int i = 0; i < segmentCount; ++i) {
        const qreal a0 = i * step;
        const qreal a1 = (i + 1) * step;
        vertices->push_back(center);
        vertices->push_back(center + QPointF(qCos(a0) * radius, qSin(a0) * radius));
        vertices->push_back(center + QPointF(qCos(a1) * radius, qSin(a1) * radius));
    }
}

static void appendAntialiasedCircle(QVector<MosColoredVertex> *vertices,
                                    QPointF center,
                                    qreal radius,
                                    const QColor &color,
                                    int segmentCount = 28)
{
    if (radius <= 0.0 || color.alpha() <= 0) {
        return;
    }

    QColor transparent = color;
    transparent.setAlpha(0);

    const qreal feather = qBound<qreal>(0.65, radius * 0.25, 1.15);
    const qreal outerRadius = radius + feather;
    const qreal step = M_PI * 2.0 / segmentCount;

    auto append = [vertices](const QPointF &point, const QColor &vertexColor) {
        vertices->push_back({ point, vertexColor });
    };

    for (int i = 0; i < segmentCount; ++i) {
        const qreal a0 = i * step;
        const qreal a1 = (i + 1) * step;
        const QPointF inner0 = center + QPointF(qCos(a0) * radius, qSin(a0) * radius);
        const QPointF inner1 = center + QPointF(qCos(a1) * radius, qSin(a1) * radius);
        const QPointF outer0 = center + QPointF(qCos(a0) * outerRadius, qSin(a0) * outerRadius);
        const QPointF outer1 = center + QPointF(qCos(a1) * outerRadius, qSin(a1) * outerRadius);

        append(center, color);
        append(inner0, color);
        append(inner1, color);

        append(inner0, color);
        append(outer0, transparent);
        append(inner1, color);
        append(inner1, color);
        append(outer0, transparent);
        append(outer1, transparent);
    }
}

static QSGGeometryNode *createFlatGeometryNode(const QVector<QPointF> &vertices,
                                               int offset,
                                               int count,
                                               const QColor &color)
{
    if (count <= 0 || color.alpha() <= 0) {
        return nullptr;
    }

    QSGGeometryNode *node = new QSGGeometryNode;
    QSGGeometry *geometry = new QSGGeometry(QSGGeometry::defaultAttributes_Point2D(), count);
    geometry->setDrawingMode(QSGGeometry::DrawTriangles);

    QSGGeometry::Point2D *data = geometry->vertexDataAsPoint2D();
    for (int i = 0; i < count; ++i) {
        const QPointF point = vertices.at(offset + i);
        data[i].set(point.x(), point.y());
    }

    QSGFlatColorMaterial *material = new QSGFlatColorMaterial;
    material->setColor(color);
    material->setFlag(QSGMaterial::Blending, color.alpha() < 255);

    node->setGeometry(geometry);
    node->setMaterial(material);
    node->setFlag(QSGNode::OwnsGeometry);
    node->setFlag(QSGNode::OwnsMaterial);
    return node;
}

static QSGNode *createFlatNode(const QVector<QPointF> &vertices, const QColor &color)
{
    if (vertices.isEmpty() || color.alpha() <= 0) {
        return nullptr;
    }

    if (vertices.size() <= maxVerticesPerNode) {
        return createFlatGeometryNode(vertices, 0, vertices.size(), color);
    }

    QSGNode *group = new QSGNode;
    const int chunkSize = maxVerticesPerNode - (maxVerticesPerNode % 3);
    for (int offset = 0; offset < vertices.size(); offset += chunkSize) {
        const int count = qMin(chunkSize, vertices.size() - offset);
        const int triangleAlignedCount = count - (count % 3);
        if (QSGGeometryNode *node = createFlatGeometryNode(vertices, offset, triangleAlignedCount, color)) {
            group->appendChildNode(node);
        }
    }
    return group;
}

static QSGGeometryNode *createColoredGeometryNode(const QVector<MosColoredVertex> &vertices,
                                                  int offset,
                                                  int count)
{
    if (count <= 0) {
        return nullptr;
    }

    QSGGeometryNode *node = new QSGGeometryNode;
    QSGGeometry *geometry = new QSGGeometry(QSGGeometry::defaultAttributes_ColoredPoint2D(), count);
    geometry->setDrawingMode(QSGGeometry::DrawTriangles);

    QSGGeometry::ColoredPoint2D *data = geometry->vertexDataAsColoredPoint2D();
    for (int i = 0; i < count; ++i) {
        const MosColoredVertex &vertex = vertices.at(offset + i);
        data[i].set(vertex.point.x(), vertex.point.y(),
                    vertex.color.red(), vertex.color.green(), vertex.color.blue(), vertex.color.alpha());
    }

    QSGVertexColorMaterial *material = new QSGVertexColorMaterial;
    material->setFlag(QSGMaterial::Blending, true);

    node->setGeometry(geometry);
    node->setMaterial(material);
    node->setFlag(QSGNode::OwnsGeometry);
    node->setFlag(QSGNode::OwnsMaterial);
    return node;
}

static QSGNode *createColoredNode(const QVector<MosColoredVertex> &vertices)
{
    if (vertices.isEmpty()) {
        return nullptr;
    }

    if (vertices.size() <= maxVerticesPerNode) {
        return createColoredGeometryNode(vertices, 0, vertices.size());
    }

    QSGNode *group = new QSGNode;
    const int chunkSize = maxVerticesPerNode - (maxVerticesPerNode % 3);
    for (int offset = 0; offset < vertices.size(); offset += chunkSize) {
        const int count = qMin(chunkSize, vertices.size() - offset);
        const int triangleAlignedCount = count - (count % 3);
        if (QSGGeometryNode *node = createColoredGeometryNode(vertices, offset, triangleAlignedCount)) {
            group->appendChildNode(node);
        }
    }
    return group;
}

static QSGGeometryNode *createGradientAreaGeometryNode(const QVector<QPointF> &top,
                                                       int firstSegment,
                                                       int segmentCount,
                                                       qreal baseline,
                                                       const QColor &color)
{
    if (segmentCount <= 0 || color.alpha() <= 0) {
        return nullptr;
    }

    const int vertexCount = segmentCount * 6;
    QSGGeometryNode *node = new QSGGeometryNode;
    QSGGeometry *geometry = new QSGGeometry(QSGGeometry::defaultAttributes_ColoredPoint2D(), vertexCount);
    geometry->setDrawingMode(QSGGeometry::DrawTriangles);

    QColor high = color;
    high.setAlpha(qMin(120, qMax(32, color.alpha())));
    QColor low = color;
    low.setAlpha(18);

    QSGGeometry::ColoredPoint2D *data = geometry->vertexDataAsColoredPoint2D();
    int cursor = 0;
    auto setVertex = [&data, &cursor](const QPointF &point, const QColor &vertexColor) {
        data[cursor++].set(point.x(), point.y(),
                           vertexColor.red(), vertexColor.green(), vertexColor.blue(), vertexColor.alpha());
    };

    const int endSegment = firstSegment + segmentCount;
    for (int i = firstSegment; i < endSegment; ++i) {
        const QPointF a = top.at(i);
        const QPointF b = top.at(i + 1);
        const QPointF ba(a.x(), baseline);
        const QPointF bb(b.x(), baseline);

        setVertex(a, high);
        setVertex(ba, low);
        setVertex(b, high);
        setVertex(b, high);
        setVertex(ba, low);
        setVertex(bb, low);
    }

    QSGVertexColorMaterial *material = new QSGVertexColorMaterial;
    material->setFlag(QSGMaterial::Blending, true);

    node->setGeometry(geometry);
    node->setMaterial(material);
    node->setFlag(QSGNode::OwnsGeometry);
    node->setFlag(QSGNode::OwnsMaterial);
    return node;
}

static QSGNode *createGradientAreaNode(const QVector<QPointF> &top, qreal baseline, const QColor &color)
{
    if (top.size() < 2 || color.alpha() <= 0) {
        return nullptr;
    }

    const int segmentCount = top.size() - 1;
    const int maxSegmentsPerNode = qMax(1, maxVerticesPerNode / 6);
    if (segmentCount <= maxSegmentsPerNode) {
        return createGradientAreaGeometryNode(top, 0, segmentCount, baseline, color);
    }

    QSGNode *group = new QSGNode;
    for (int firstSegment = 0; firstSegment < segmentCount; firstSegment += maxSegmentsPerNode) {
        const int count = qMin(maxSegmentsPerNode, segmentCount - firstSegment);
        if (QSGGeometryNode *node = createGradientAreaGeometryNode(top, firstSegment, count, baseline, color)) {
            group->appendChildNode(node);
        }
    }
    return group;
}

static void appendGrid(QSGNode *root, const QRectF &rect, const MosHighperchartPrivate *d)
{
    if (!d->showGrid && !d->showAxis) {
        return;
    }

    QVector<QPointF> grid;
    QVector<MosColoredVertex> antialiasedGrid;
    const int count = qMax(1, d->gridLineCount);
    if (d->showGrid) {
        for (int i = 0; i <= count; ++i) {
            const qreal y = rect.top() + rect.height() * i / count;
            if (d->edgeAntialiasing) {
                appendAntialiasedSegment(&antialiasedGrid, QPointF(rect.left(), y), QPointF(rect.right(), y), 1.0, d->gridColor);
            } else {
                appendSegment(&grid, QPointF(rect.left(), y), QPointF(rect.right(), y), 1.0);
            }
        }
    }
    if (d->edgeAntialiasing && !antialiasedGrid.isEmpty()) {
        if (QSGNode *node = createColoredNode(antialiasedGrid)) {
            root->appendChildNode(node);
        }
    } else if (!grid.isEmpty()) {
        if (QSGNode *node = createFlatNode(grid, d->gridColor)) {
            root->appendChildNode(node);
        }
    }

    if (d->showAxis) {
        QVector<QPointF> axis;
        QVector<MosColoredVertex> antialiasedAxis;
        if (d->edgeAntialiasing) {
            appendAntialiasedSegment(&antialiasedAxis, rect.bottomLeft(), rect.bottomRight(), 1.25, d->axisColor);
            appendAntialiasedSegment(&antialiasedAxis, rect.bottomLeft(), rect.topLeft(), 1.25, d->axisColor);
            if (QSGNode *node = createColoredNode(antialiasedAxis)) {
                root->appendChildNode(node);
            }
        } else {
            appendSegment(&axis, rect.bottomLeft(), rect.bottomRight(), 1.25);
            appendSegment(&axis, rect.bottomLeft(), rect.topLeft(), 1.25);
            if (QSGNode *node = createFlatNode(axis, d->axisColor)) {
                root->appendChildNode(node);
            }
        }
    }
}

static void drawLineLike(QSGNode *root, const QRectF &rect, const MosHighperchartPrivate *d, bool area)
{
    const QList<QVector<QPointF>> rawSeriesList = readSeriesList(d->values, d->chartType);
    if (rawSeriesList.isEmpty()) {
        return;
    }

    appendGrid(root, rect, d);
    const MosChartRange range = rangeForSeries(rawSeriesList);
    const QList<QVector<QPointF>> seriesList = decimateSeriesList(rawSeriesList,
                                                                  d,
                                                                  effectivePointLimit(rawSeriesList, d, rect, true),
                                                                  true);
    const qreal baseline = zeroY(rect, range);
    const qreal progress = eased(d->animationProgress);

    for (int seriesIndex = 0; seriesIndex < seriesList.size(); ++seriesIndex) {
        const QVector<QPointF> &series = seriesList.at(seriesIndex);
        if (series.isEmpty()) {
            continue;
        }

        QVector<QPointF> mapped;
        mapped.reserve(series.size());
        for (const QPointF &point : series) {
            QPointF visual = point;
            visual.setY(point.y() * progress);
            mapped.push_back(mapPoint(visual, rect, range));
        }

        const QColor color = colorAt(d, seriesIndex);
        if (area) {
            if (QSGNode *areaNode = createGradientAreaNode(mapped, baseline, color)) {
                root->appendChildNode(areaNode);
            }
        }

        if (d->edgeAntialiasing) {
            QVector<MosColoredVertex> line;
            const qreal strokeWidth = qMax<qreal>(1.0, d->lineWidth);
            for (int i = 0; i < mapped.size() - 1; ++i) {
                appendAntialiasedSegment(&line, mapped.at(i), mapped.at(i + 1), strokeWidth, color);
            }
            for (const QPointF &point : mapped) {
                appendAntialiasedCircle(&line, point, strokeWidth * 0.52, color, 20);
            }
            if (QSGNode *node = createColoredNode(line)) {
                root->appendChildNode(node);
            }
        } else {
            QVector<QPointF> line;
            for (int i = 0; i < mapped.size() - 1; ++i) {
                appendSegment(&line, mapped.at(i), mapped.at(i + 1), qMax<qreal>(1.0, d->lineWidth));
            }
            if (QSGNode *node = createFlatNode(line, color)) {
                root->appendChildNode(node);
            }
        }

        if (d->showPoints) {
            const QColor pointColor = color.lighter(112);
            if (d->edgeAntialiasing) {
                QVector<MosColoredVertex> points;
                for (const QPointF &point : mapped) {
                    appendAntialiasedCircle(&points, point, qMax<qreal>(1.0, d->pointSize * 0.5), pointColor, 24);
                }
                if (QSGNode *node = createColoredNode(points)) {
                    root->appendChildNode(node);
                }
            } else {
                QVector<QPointF> points;
                for (const QPointF &point : mapped) {
                    appendCircle(&points, point, qMax<qreal>(1.0, d->pointSize * 0.5), 24);
                }
                if (QSGNode *node = createFlatNode(points, pointColor)) {
                    root->appendChildNode(node);
                }
            }
        }
    }
}

static void drawScatter(QSGNode *root, const QRectF &rect, const MosHighperchartPrivate *d)
{
    const QList<QVector<QPointF>> rawSeriesList = readSeriesList(d->values, d->chartType);
    if (rawSeriesList.isEmpty()) {
        return;
    }

    appendGrid(root, rect, d);
    const MosChartRange range = rangeForSeries(rawSeriesList);
    const QList<QVector<QPointF>> seriesList = decimateSeriesList(rawSeriesList,
                                                                  d,
                                                                  effectivePointLimit(rawSeriesList, d, rect, false),
                                                                  false);
    const qreal progress = eased(d->animationProgress);

    for (int seriesIndex = 0; seriesIndex < seriesList.size(); ++seriesIndex) {
        QVector<QPointF> circles;
        QVector<MosColoredVertex> antialiasedCircles;
        const QVector<QPointF> &series = seriesList.at(seriesIndex);
        const QColor color = colorAt(d, seriesIndex, 220);
        for (const QPointF &point : series) {
            QPointF visual = point;
            visual.setY(point.y() * progress);
            const QPointF mapped = mapPoint(visual, rect, range);
            const qreal radius = qMax<qreal>(1.0, d->pointSize * 0.64);
            if (d->edgeAntialiasing) {
                appendAntialiasedCircle(&antialiasedCircles, mapped, radius, color, 26);
            } else {
                appendCircle(&circles, mapped, radius, 26);
            }
        }
        if (d->edgeAntialiasing) {
            if (QSGNode *node = createColoredNode(antialiasedCircles)) {
                root->appendChildNode(node);
            }
        } else if (QSGNode *node = createFlatNode(circles, color)) {
            root->appendChildNode(node);
        }
    }
}

static void drawBar(QSGNode *root, const QRectF &rect, const MosHighperchartPrivate *d)
{
    const QList<QVector<QPointF>> rawSeriesList = readSeriesList(d->values, d->chartType);
    if (rawSeriesList.isEmpty()) {
        return;
    }
    const QList<QVector<QPointF>> seriesList = decimateSeriesList(rawSeriesList,
                                                                  d,
                                                                  effectivePointLimit(rawSeriesList, d, rect, true),
                                                                  true);

    appendGrid(root, rect, d);

    int categoryCount = 0;
    for (const QVector<QPointF> &series : seriesList) {
        categoryCount = qMax(categoryCount, series.size());
    }
    if (categoryCount <= 0) {
        return;
    }

    MosChartRange range;
    range.minX = 0.0;
    range.maxX = qMax(1, categoryCount - 1);
    bool initialized = false;
    for (const QVector<QPointF> &series : seriesList) {
        for (const QPointF &point : series) {
            if (!initialized) {
                range.minY = range.maxY = point.y();
                initialized = true;
            } else {
                range.minY = qMin(range.minY, point.y());
                range.maxY = qMax(range.maxY, point.y());
            }
        }
    }
    range.minY = qMin<qreal>(range.minY, 0.0);
    range.maxY = qMax<qreal>(range.maxY, 0.0);
    if (qFuzzyCompare(range.minY, range.maxY)) {
        range.maxY += 1.0;
    }

    const qreal baseline = zeroY(rect, range);
    const qreal slotWidth = rect.width() / categoryCount;
    const qreal groupPadding = slotWidth * bounded(d->barSpacing, 0.0, 0.8) * 0.5;
    const qreal barWidth = qMax<qreal>(1.0, (slotWidth - groupPadding * 2.0) / seriesList.size());
    const qreal progress = eased(d->animationProgress);

    for (int seriesIndex = 0; seriesIndex < seriesList.size(); ++seriesIndex) {
        QVector<QPointF> bars;
        QVector<QPointF> shine;
        const QVector<QPointF> &series = seriesList.at(seriesIndex);
        for (int i = 0; i < series.size(); ++i) {
            const qreal value = series.at(i).y() * progress;
            const qreal left = rect.left() + i * slotWidth + groupPadding + seriesIndex * barWidth;
            const qreal right = left + barWidth * 0.82;
            const qreal top = mapPoint(QPointF(i, value), rect, range).y();
            QRectF bar(QPointF(left, qMin(top, baseline)), QPointF(right, qMax(top, baseline)));
            if (bar.height() < 1.0) {
                bar.setHeight(1.0);
            }
            appendRect(&bars, bar);

            QRectF highlight = bar.adjusted(bar.width() * 0.12, 1.0, -bar.width() * 0.12, 0.0);
            highlight.setHeight(qMin<qreal>(3.0, bar.height()));
            appendRect(&shine, highlight);
        }
        if (QSGNode *node = createFlatNode(bars, colorAt(d, seriesIndex, 218))) {
            root->appendChildNode(node);
        }
        if (QSGNode *node = createFlatNode(shine, QColor(255, 255, 255, 78))) {
            root->appendChildNode(node);
        }
    }
}

static QPointF polarPoint(const QPointF &center, qreal radius, qreal angle)
{
    return center + QPointF(qCos(angle) * radius, qSin(angle) * radius);
}

static void drawPieLike(QSGNode *root, const QRectF &rect, const MosHighperchartPrivate *d, bool donut)
{
    const QVector<qreal> values = readPieValues(d->values);
    qreal total = 0.0;
    for (qreal value : values) {
        total += value;
    }
    if (values.isEmpty() || total <= 0.0) {
        return;
    }

    const QPointF center = rect.center();
    const qreal radius = qMin(rect.width(), rect.height()) * 0.5;
    const qreal inner = donut ? radius * bounded(d->innerRadius, 0.05, 0.9) : 0.0;
    const qreal progress = eased(d->animationProgress);
    qreal start = -M_PI_2;

    for (int i = 0; i < values.size(); ++i) {
        const qreal sweep = M_PI * 2.0 * values.at(i) / total * progress;
        if (sweep <= 0.0) {
            continue;
        }

        const int steps = qMax(6, qCeil(qAbs(sweep) / (M_PI / 30.0)));
        QVector<QPointF> slice;
        for (int step = 0; step < steps; ++step) {
            const qreal a0 = start + sweep * step / steps;
            const qreal a1 = start + sweep * (step + 1) / steps;
            if (donut) {
                const QPointF o0 = polarPoint(center, radius, a0);
                const QPointF i0 = polarPoint(center, inner, a0);
                const QPointF o1 = polarPoint(center, radius, a1);
                const QPointF i1 = polarPoint(center, inner, a1);
                slice.push_back(o0);
                slice.push_back(i0);
                slice.push_back(o1);
                slice.push_back(o1);
                slice.push_back(i0);
                slice.push_back(i1);
            } else {
                slice.push_back(center);
                slice.push_back(polarPoint(center, radius, a0));
                slice.push_back(polarPoint(center, radius, a1));
            }
        }

        if (QSGNode *node = createFlatNode(slice, colorAt(d, i, 232))) {
            root->appendChildNode(node);
        }
        start += M_PI * 2.0 * values.at(i) / total;
    }

    if (donut) {
        QVector<QPointF> centerCircle;
        appendCircle(&centerCircle, center, inner * 0.96, 72);
        if (QSGNode *node = createFlatNode(centerCircle, d->backgroundColor.alpha() > 0
                                                                  ? d->backgroundColor
                                                                  : QColor(255, 255, 255, 245))) {
            root->appendChildNode(node);
        }
    }
}

static void drawRadar(QSGNode *root, const QRectF &rect, const MosHighperchartPrivate *d)
{
    const QList<QVector<QPointF>> seriesList = readSeriesList(d->values, d->chartType);
    if (seriesList.isEmpty()) {
        return;
    }

    int count = 0;
    qreal maxValue = 0.0;
    for (const QVector<QPointF> &series : seriesList) {
        count = qMax(count, series.size());
        for (const QPointF &point : series) {
            maxValue = qMax(maxValue, qAbs(point.y()));
        }
    }
    if (count < 3 || maxValue <= 0.0) {
        return;
    }

    const QPointF center = rect.center();
    const qreal radius = qMin(rect.width(), rect.height()) * 0.5;
    const qreal stepAngle = M_PI * 2.0 / count;
    const int rings = qMax(1, d->gridLineCount);

    if (d->showGrid) {
        QVector<QPointF> grid;
        QVector<MosColoredVertex> antialiasedGrid;
        for (int ring = 1; ring <= rings; ++ring) {
            const qreal ringRadius = radius * ring / rings;
            for (int i = 0; i < count; ++i) {
                const QPointF a = polarPoint(center, ringRadius, -M_PI_2 + i * stepAngle);
                const QPointF b = polarPoint(center, ringRadius, -M_PI_2 + ((i + 1) % count) * stepAngle);
                if (d->edgeAntialiasing) {
                    appendAntialiasedSegment(&antialiasedGrid, a, b, 1.0, d->gridColor);
                } else {
                    appendSegment(&grid, a, b, 1.0);
                }
            }
        }
        if (d->edgeAntialiasing) {
            if (QSGNode *node = createColoredNode(antialiasedGrid)) {
                root->appendChildNode(node);
            }
        } else if (QSGNode *node = createFlatNode(grid, d->gridColor)) {
            root->appendChildNode(node);
        }
    }

    if (d->showAxis) {
        QVector<QPointF> axis;
        QVector<MosColoredVertex> antialiasedAxis;
        for (int i = 0; i < count; ++i) {
            const QPointF endPoint = polarPoint(center, radius, -M_PI_2 + i * stepAngle);
            if (d->edgeAntialiasing) {
                appendAntialiasedSegment(&antialiasedAxis, center, endPoint, 1.0, d->axisColor);
            } else {
                appendSegment(&axis, center, endPoint, 1.0);
            }
        }
        if (d->edgeAntialiasing) {
            if (QSGNode *node = createColoredNode(antialiasedAxis)) {
                root->appendChildNode(node);
            }
        } else if (QSGNode *node = createFlatNode(axis, d->axisColor)) {
            root->appendChildNode(node);
        }
    }

    const qreal progress = eased(d->animationProgress);
    for (int seriesIndex = 0; seriesIndex < seriesList.size(); ++seriesIndex) {
        const QVector<QPointF> &series = seriesList.at(seriesIndex);
        QVector<QPointF> polygon;
        polygon.reserve(series.size());
        for (int i = 0; i < series.size(); ++i) {
            const qreal ratio = bounded(series.at(i).y() / maxValue * progress, 0.0, 1.0);
            polygon.push_back(polarPoint(center, radius * ratio, -M_PI_2 + i * stepAngle));
        }
        if (polygon.size() < 3) {
            continue;
        }

        QVector<QPointF> fill;
        for (int i = 0; i < polygon.size(); ++i) {
            fill.push_back(center);
            fill.push_back(polygon.at(i));
            fill.push_back(polygon.at((i + 1) % polygon.size()));
        }
        if (QSGNode *node = createFlatNode(fill, colorAt(d, seriesIndex, 48))) {
            root->appendChildNode(node);
        }

        const QColor outlineColor = colorAt(d, seriesIndex, 228);
        if (d->edgeAntialiasing) {
            QVector<MosColoredVertex> outline;
            for (int i = 0; i < polygon.size(); ++i) {
                appendAntialiasedSegment(&outline, polygon.at(i), polygon.at((i + 1) % polygon.size()), qMax<qreal>(1.0, d->lineWidth), outlineColor);
            }
            if (QSGNode *node = createColoredNode(outline)) {
                root->appendChildNode(node);
            }
        } else {
            QVector<QPointF> outline;
            for (int i = 0; i < polygon.size(); ++i) {
                appendSegment(&outline, polygon.at(i), polygon.at((i + 1) % polygon.size()), qMax<qreal>(1.0, d->lineWidth));
            }
            if (QSGNode *node = createFlatNode(outline, outlineColor)) {
                root->appendChildNode(node);
            }
        }

        if (d->showPoints) {
            const QColor pointColor = colorAt(d, seriesIndex);
            if (d->edgeAntialiasing) {
                QVector<MosColoredVertex> points;
                for (const QPointF &point : polygon) {
                    appendAntialiasedCircle(&points, point, qMax<qreal>(1.0, d->pointSize * 0.42), pointColor, 18);
                }
                if (QSGNode *node = createColoredNode(points)) {
                    root->appendChildNode(node);
                }
            } else {
                QVector<QPointF> points;
                for (const QPointF &point : polygon) {
                    appendCircle(&points, point, qMax<qreal>(1.0, d->pointSize * 0.42), 18);
                }
                if (QSGNode *node = createFlatNode(points, pointColor)) {
                    root->appendChildNode(node);
                }
            }
        }
    }
}

static void clearNode(QSGNode *node)
{
    while (QSGNode *child = node->firstChild()) {
        node->removeChildNode(child);
        delete child;
    }
}

} // namespace

MosHighperchart::MosHighperchart(QQuickItem *parent)
    : QQuickItem(parent)
    , d_ptr(new MosHighperchartPrivate(this))
{
    Q_D(MosHighperchart);
    setFlag(ItemHasContents, true);
    setAntialiasing(d->edgeAntialiasing);
}

MosHighperchart::~MosHighperchart()
{
}

MosHighperchart::ChartType MosHighperchart::chartType() const
{
    Q_D(const MosHighperchart);
    return d->chartType;
}

void MosHighperchart::setChartType(ChartType type)
{
    Q_D(MosHighperchart);
    if (d->chartType == type) {
        return;
    }
    d->chartType = type;
    emit chartTypeChanged();
    update();
}

QVariantList MosHighperchart::values() const
{
    Q_D(const MosHighperchart);
    return d->values;
}

void MosHighperchart::setValues(const QVariantList &values)
{
    Q_D(MosHighperchart);
    if (values.size() <= largeValueListCompareLimit && d->values == values) {
        return;
    }
    d->values = values;
    emit valuesChanged();
    update();
}

QVariantList MosHighperchart::colors() const
{
    Q_D(const MosHighperchart);
    return d->colors;
}

void MosHighperchart::setColors(const QVariantList &colors)
{
    Q_D(MosHighperchart);
    if (d->colors == colors) {
        return;
    }
    d->colors = colors;
    emit colorsChanged();
    update();
}

QColor MosHighperchart::backgroundColor() const
{
    Q_D(const MosHighperchart);
    return d->backgroundColor;
}

void MosHighperchart::setBackgroundColor(const QColor &color)
{
    Q_D(MosHighperchart);
    if (d->backgroundColor == color) {
        return;
    }
    d->backgroundColor = color;
    emit backgroundColorChanged();
    update();
}

QColor MosHighperchart::gridColor() const
{
    Q_D(const MosHighperchart);
    return d->gridColor;
}

void MosHighperchart::setGridColor(const QColor &color)
{
    Q_D(MosHighperchart);
    if (d->gridColor == color) {
        return;
    }
    d->gridColor = color;
    emit gridColorChanged();
    update();
}

QColor MosHighperchart::axisColor() const
{
    Q_D(const MosHighperchart);
    return d->axisColor;
}

void MosHighperchart::setAxisColor(const QColor &color)
{
    Q_D(MosHighperchart);
    if (d->axisColor == color) {
        return;
    }
    d->axisColor = color;
    emit axisColorChanged();
    update();
}

bool MosHighperchart::showGrid() const
{
    Q_D(const MosHighperchart);
    return d->showGrid;
}

void MosHighperchart::setShowGrid(bool show)
{
    Q_D(MosHighperchart);
    if (d->showGrid == show) {
        return;
    }
    d->showGrid = show;
    emit showGridChanged();
    update();
}

bool MosHighperchart::showAxis() const
{
    Q_D(const MosHighperchart);
    return d->showAxis;
}

void MosHighperchart::setShowAxis(bool show)
{
    Q_D(MosHighperchart);
    if (d->showAxis == show) {
        return;
    }
    d->showAxis = show;
    emit showAxisChanged();
    update();
}

bool MosHighperchart::showPoints() const
{
    Q_D(const MosHighperchart);
    return d->showPoints;
}

void MosHighperchart::setShowPoints(bool show)
{
    Q_D(MosHighperchart);
    if (d->showPoints == show) {
        return;
    }
    d->showPoints = show;
    emit showPointsChanged();
    update();
}

qreal MosHighperchart::padding() const
{
    Q_D(const MosHighperchart);
    return d->padding;
}

void MosHighperchart::setPadding(qreal padding)
{
    Q_D(MosHighperchart);
    padding = qMax<qreal>(0.0, padding);
    if (qFuzzyCompare(d->padding, padding)) {
        return;
    }
    d->padding = padding;
    emit paddingChanged();
    update();
}

qreal MosHighperchart::lineWidth() const
{
    Q_D(const MosHighperchart);
    return d->lineWidth;
}

void MosHighperchart::setLineWidth(qreal width)
{
    Q_D(MosHighperchart);
    width = qMax<qreal>(0.5, width);
    if (qFuzzyCompare(d->lineWidth, width)) {
        return;
    }
    d->lineWidth = width;
    emit lineWidthChanged();
    update();
}

qreal MosHighperchart::pointSize() const
{
    Q_D(const MosHighperchart);
    return d->pointSize;
}

void MosHighperchart::setPointSize(qreal size)
{
    Q_D(MosHighperchart);
    size = qMax<qreal>(1.0, size);
    if (qFuzzyCompare(d->pointSize, size)) {
        return;
    }
    d->pointSize = size;
    emit pointSizeChanged();
    update();
}

qreal MosHighperchart::innerRadius() const
{
    Q_D(const MosHighperchart);
    return d->innerRadius;
}

void MosHighperchart::setInnerRadius(qreal radius)
{
    Q_D(MosHighperchart);
    radius = bounded(radius, 0.05, 0.9);
    if (qFuzzyCompare(d->innerRadius, radius)) {
        return;
    }
    d->innerRadius = radius;
    emit innerRadiusChanged();
    update();
}

qreal MosHighperchart::barSpacing() const
{
    Q_D(const MosHighperchart);
    return d->barSpacing;
}

void MosHighperchart::setBarSpacing(qreal spacing)
{
    Q_D(MosHighperchart);
    spacing = bounded(spacing, 0.0, 0.8);
    if (qFuzzyCompare(d->barSpacing, spacing)) {
        return;
    }
    d->barSpacing = spacing;
    emit barSpacingChanged();
    update();
}

int MosHighperchart::gridLineCount() const
{
    Q_D(const MosHighperchart);
    return d->gridLineCount;
}

void MosHighperchart::setGridLineCount(int count)
{
    Q_D(MosHighperchart);
    count = qMax(1, count);
    if (d->gridLineCount == count) {
        return;
    }
    d->gridLineCount = count;
    emit gridLineCountChanged();
    update();
}

qreal MosHighperchart::animationProgress() const
{
    Q_D(const MosHighperchart);
    return d->animationProgress;
}

void MosHighperchart::setAnimationProgress(qreal progress)
{
    Q_D(MosHighperchart);
    progress = bounded(progress, 0.0, 1.0);
    if (qFuzzyCompare(d->animationProgress, progress)) {
        return;
    }
    d->animationProgress = progress;
    emit animationProgressChanged();
    update();
}

bool MosHighperchart::highPerformanceMode() const
{
    Q_D(const MosHighperchart);
    return d->highPerformanceMode;
}

void MosHighperchart::setHighPerformanceMode(bool enabled)
{
    Q_D(MosHighperchart);
    if (d->highPerformanceMode == enabled) {
        return;
    }
    d->highPerformanceMode = enabled;
    emit highPerformanceModeChanged();
    update();
}

int MosHighperchart::highPerformancePointLimit() const
{
    Q_D(const MosHighperchart);
    return d->highPerformancePointLimit;
}

void MosHighperchart::setHighPerformancePointLimit(int limit)
{
    Q_D(MosHighperchart);
    limit = qMax(2, limit);
    if (d->highPerformancePointLimit == limit) {
        return;
    }
    d->highPerformancePointLimit = limit;
    emit highPerformancePointLimitChanged();
    update();
}

bool MosHighperchart::edgeAntialiasing() const
{
    Q_D(const MosHighperchart);
    return d->edgeAntialiasing;
}

void MosHighperchart::setEdgeAntialiasing(bool enabled)
{
    Q_D(MosHighperchart);
    if (d->edgeAntialiasing == enabled) {
        return;
    }
    d->edgeAntialiasing = enabled;
    setAntialiasing(enabled);
    emit edgeAntialiasingChanged();
    update();
}

QSGNode *MosHighperchart::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *data)
{
    Q_UNUSED(data)

    Q_D(MosHighperchart);

    QSGNode *root = oldNode ? oldNode : new QSGNode;
    clearNode(root);

    const QRectF bounds(0.0, 0.0, width(), height());
    if (bounds.width() <= 1.0 || bounds.height() <= 1.0) {
        return root;
    }

    if (d->backgroundColor.alpha() > 0) {
        QVector<QPointF> background;
        appendRect(&background, bounds);
        if (QSGNode *node = createFlatNode(background, d->backgroundColor)) {
            root->appendChildNode(node);
        }
    }

    const QRectF rect = chartRect(bounds, d->padding);
    switch (d->chartType) {
    case Line:
        drawLineLike(root, rect, d, false);
        break;
    case Bar:
        drawBar(root, rect, d);
        break;
    case Pie:
        drawPieLike(root, rect, d, false);
        break;
    case Donut:
        drawPieLike(root, rect, d, true);
        break;
    case Area:
        drawLineLike(root, rect, d, true);
        break;
    case Scatter:
        drawScatter(root, rect, d);
        break;
    case Radar:
        drawRadar(root, rect, d);
        break;
    }

    return root;
}
