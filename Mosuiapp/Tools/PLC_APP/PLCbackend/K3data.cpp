#include "K3data.h"
#include <QQmlEngine>

K3data::K3data(QObject *parent)
    : QObject(parent)
{


}
K3data::~K3data() = default;

K3data *K3data::instance()
{
    static K3data ins;
    return &ins;
}

K3data *K3data::create(QQmlEngine *, QJSEngine *)
{
    auto *k3data = instance();
    QQmlEngine::setObjectOwnership(k3data, QQmlEngine::CppOwnership);
    return k3data;
}