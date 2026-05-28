#ifndef MOSBARCHART_H
#define MOSBARCHART_H

#include "MosHighperchart.h"

class MOSUIBASIC_EXPORT MosBarChart : public MosHighperchart
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosBarChart)

public:
    explicit MosBarChart(QQuickItem *parent = nullptr);
};

#endif // MOSBARCHART_H
