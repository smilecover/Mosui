#include "MosRadarChart.h"

MosRadarChart::MosRadarChart(QQuickItem *parent)
    : MosHighperchart(parent)
{
    setChartType(Radar);
}
