#ifndef MOSHIGHPERCHART_P_H
#define MOSHIGHPERCHART_P_H

#include "MosHighperchart.h"

class MosHighperchartPrivate
{
public:
    Q_DECLARE_PUBLIC(MosHighperchart)

    explicit MosHighperchartPrivate(MosHighperchart *q) : q_ptr(q) { }

    MosHighperchart *q_ptr { nullptr };
    MosHighperchart::ChartType chartType { MosHighperchart::Line };
    QVariantList values {
        12, 28, 22, 46, 38, 64, 58, 82, 74
    };
    QVariantList colors {
        QColor(24, 144, 255),
        QColor(19, 194, 194),
        QColor(250, 173, 20),
        QColor(245, 34, 45),
        QColor(114, 46, 209),
        QColor(82, 196, 26),
        QColor(235, 47, 150)
    };
    QColor backgroundColor { Qt::transparent };
    QColor gridColor { 148, 163, 184, 62 };
    QColor axisColor { 100, 116, 139, 168 };
    bool showGrid { true };
    bool showAxis { true };
    bool showPoints { true };
    qreal padding { 22.0 };
    qreal lineWidth { 3.0 };
    qreal pointSize { 7.0 };
    qreal innerRadius { 0.56 };
    qreal barSpacing { 0.22 };
    int gridLineCount { 4 };
    qreal animationProgress { 1.0 };
};

#endif // MOSHIGHPERCHART_P_H
