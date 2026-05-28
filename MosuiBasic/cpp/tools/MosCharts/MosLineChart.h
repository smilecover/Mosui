#ifndef MOSLINECHART_H
#define MOSLINECHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosLineChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosLineChart)

public:
    explicit MosLineChart(QQuickItem *parent = nullptr);
};

#endif // MOSLINECHART_H
