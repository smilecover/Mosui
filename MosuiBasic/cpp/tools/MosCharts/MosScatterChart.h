#ifndef MOSSCATTERCHART_H
#define MOSSCATTERCHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosScatterChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosScatterChart)

public:
    explicit MosScatterChart(QQuickItem *parent = nullptr);
};

#endif // MOSSCATTERCHART_H
