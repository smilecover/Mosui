#ifndef MOSHIGHPERCHART_H
#define MOSHIGHPERCHART_H

#include <QtCore/QScopedPointer>
#include <QtCore/QVariantList>
#include <QtGui/QColor>
#include <QtQuick/QQuickItem>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosHighperchartPrivate)
QT_FORWARD_DECLARE_CLASS(QSGNode)

class MOSUIBASIC_EXPORT MosHighperchart : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(ChartType chartType READ chartType WRITE setChartType NOTIFY chartTypeChanged FINAL)
    Q_PROPERTY(QVariantList values READ values WRITE setValues NOTIFY valuesChanged FINAL)
    Q_PROPERTY(QVariantList colors READ colors WRITE setColors NOTIFY colorsChanged FINAL)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged FINAL)
    Q_PROPERTY(QColor gridColor READ gridColor WRITE setGridColor NOTIFY gridColorChanged FINAL)
    Q_PROPERTY(QColor axisColor READ axisColor WRITE setAxisColor NOTIFY axisColorChanged FINAL)
    Q_PROPERTY(bool showGrid READ showGrid WRITE setShowGrid NOTIFY showGridChanged FINAL)
    Q_PROPERTY(bool showAxis READ showAxis WRITE setShowAxis NOTIFY showAxisChanged FINAL)
    Q_PROPERTY(bool showPoints READ showPoints WRITE setShowPoints NOTIFY showPointsChanged FINAL)
    Q_PROPERTY(qreal padding READ padding WRITE setPadding NOTIFY paddingChanged FINAL)
    Q_PROPERTY(qreal lineWidth READ lineWidth WRITE setLineWidth NOTIFY lineWidthChanged FINAL)
    Q_PROPERTY(qreal pointSize READ pointSize WRITE setPointSize NOTIFY pointSizeChanged FINAL)
    Q_PROPERTY(qreal innerRadius READ innerRadius WRITE setInnerRadius NOTIFY innerRadiusChanged FINAL)
    Q_PROPERTY(qreal barSpacing READ barSpacing WRITE setBarSpacing NOTIFY barSpacingChanged FINAL)
    Q_PROPERTY(int gridLineCount READ gridLineCount WRITE setGridLineCount NOTIFY gridLineCountChanged FINAL)
    Q_PROPERTY(qreal animationProgress READ animationProgress WRITE setAnimationProgress NOTIFY animationProgressChanged FINAL)
    Q_PROPERTY(bool highPerformanceMode READ highPerformanceMode WRITE setHighPerformanceMode NOTIFY highPerformanceModeChanged FINAL)
    Q_PROPERTY(int highPerformancePointLimit READ highPerformancePointLimit WRITE setHighPerformancePointLimit NOTIFY highPerformancePointLimitChanged FINAL)
    Q_PROPERTY(bool edgeAntialiasing READ edgeAntialiasing WRITE setEdgeAntialiasing NOTIFY edgeAntialiasingChanged FINAL)

    QML_NAMED_ELEMENT(MosHighperchart)

public:
    enum ChartType
    {
        Line = 0,
        Bar,
        Pie,
        Donut,
        Area,
        Scatter,
        Radar
    };
    Q_ENUM(ChartType)

    explicit MosHighperchart(QQuickItem *parent = nullptr);
    ~MosHighperchart() override;

    ChartType chartType() const;
    void setChartType(ChartType type);

    QVariantList values() const;
    void setValues(const QVariantList &values);

    QVariantList colors() const;
    void setColors(const QVariantList &colors);

    QColor backgroundColor() const;
    void setBackgroundColor(const QColor &color);

    QColor gridColor() const;
    void setGridColor(const QColor &color);

    QColor axisColor() const;
    void setAxisColor(const QColor &color);

    bool showGrid() const;
    void setShowGrid(bool show);

    bool showAxis() const;
    void setShowAxis(bool show);

    bool showPoints() const;
    void setShowPoints(bool show);

    qreal padding() const;
    void setPadding(qreal padding);

    qreal lineWidth() const;
    void setLineWidth(qreal width);

    qreal pointSize() const;
    void setPointSize(qreal size);

    qreal innerRadius() const;
    void setInnerRadius(qreal radius);

    qreal barSpacing() const;
    void setBarSpacing(qreal spacing);

    int gridLineCount() const;
    void setGridLineCount(int count);

    qreal animationProgress() const;
    void setAnimationProgress(qreal progress);

    bool highPerformanceMode() const;
    void setHighPerformanceMode(bool enabled);

    int highPerformancePointLimit() const;
    void setHighPerformancePointLimit(int limit);

    bool edgeAntialiasing() const;
    void setEdgeAntialiasing(bool enabled);

Q_SIGNALS:
    void chartTypeChanged();
    void valuesChanged();
    void colorsChanged();
    void backgroundColorChanged();
    void gridColorChanged();
    void axisColorChanged();
    void showGridChanged();
    void showAxisChanged();
    void showPointsChanged();
    void paddingChanged();
    void lineWidthChanged();
    void pointSizeChanged();
    void innerRadiusChanged();
    void barSpacingChanged();
    void gridLineCountChanged();
    void animationProgressChanged();
    void highPerformanceModeChanged();
    void highPerformancePointLimitChanged();
    void edgeAntialiasingChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *data) override;

private:
    Q_DECLARE_PRIVATE(MosHighperchart)
    QScopedPointer<MosHighperchartPrivate> d_ptr;
};

#endif // MOSHIGHPERCHART_H
