#ifndef MOSDONUTCHART_H
#define MOSDONUTCHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosDonutChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosDonutChart)

public:
    explicit MosDonutChart(QQuickItem *parent = nullptr);
};

#endif // MOSDONUTCHART_H
