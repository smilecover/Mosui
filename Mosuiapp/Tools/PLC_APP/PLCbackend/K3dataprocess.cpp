#include "K3dataprocess.h"

#include <QQmlEngine>

#include "K3Client.h"



K3dataprocess::K3dataprocess(QObject *parent)
    : QObject(parent)
{
}
K3dataprocess::~K3dataprocess() = default;

K3dataprocess *K3dataprocess::instance()
{
    static K3dataprocess ins;
    return &ins;
}

K3dataprocess *K3dataprocess::create(QQmlEngine *, QJSEngine *)
{
    auto *c = instance();
    QQmlEngine::setObjectOwnership(c, QQmlEngine::CppOwnership);
    return c;
}
