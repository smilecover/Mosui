#ifndef MOSPIECHART_H
#define MOSPIECHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosPieChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosPieChart)

public:
    explicit MosPieChart(QQuickItem *parent = nullptr);
};

#endif // MOSPIECHART_H
