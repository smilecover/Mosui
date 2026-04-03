#include "Moswindowagent.h"

MosWindowAgent::MosWindowAgent(QObject *parent)
        : QWK::QuickWindowAgent(parent)
{

}
MosWindowAgent::~MosWindowAgent()
{

}
void MosWindowAgent::classBegin()
{
    auto p = parent();
    Q_ASSERT_X(p, "MosWindowAgent", "parent() return nullptr!");
    if (p) {
        # if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        if (p->objectName() == QLatin1StringView("__MosWindow__")) {
            setup(qobject_cast<QQuickWindow *>(p));
        }
# else
        if (p->objectName() == QLatin1String("__MosWindow__")) {
            setup(qobject_cast<QQuickWindow *>(p));
        }
# endif
    }
}
void MosWindowAgent::componentComplete()
{

}

