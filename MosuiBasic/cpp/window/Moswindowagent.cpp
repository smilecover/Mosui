#include "Moswindowagent.h"
#include <QWKCore/private/windowagentbase_p.h>
#include "theme/Mostheme.h"

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
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        if (p->objectName() == QLatin1StringView("__MosWindow__")) {
#else
        if (p->objectName() == QLatin1String("__MosWindow__")) {
#endif
            setup(qobject_cast<QQuickWindow *>(p));
            // dark-mode 必须在 setup() 后立即设置，否则系统边框在首次绘制时是白色
            setWindowAttribute("dark-mode", MosTheme::instance()->isDark());
        }
    }
}

void MosWindowAgent::componentComplete()
{

}
