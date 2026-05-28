#ifndef MOSAREACHART_H
#define MOSAREACHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosAreaChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosAreaChart)

public:
    explicit MosAreaChart(QQuickItem *parent = nullptr);
};

#endif // MOSAREACHART_H
