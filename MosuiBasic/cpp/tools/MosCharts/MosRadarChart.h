#ifndef MOSRADARCHART_H
#define MOSRADARCHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosRadarChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosRadarChart)

public:
    explicit MosRadarChart(QQuickItem *parent = nullptr);
};

#endif // MOSRADARCHART_H
