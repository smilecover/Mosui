#include "Mosapp.h"

#include <QtGui/QFontDatabase>
#include <QtCore/QCoreApplication>

// 在 QGuiApplication 构造完成后、QML 引擎创建前注册字体
static void loadFonts()
{
    const QString path = QStringLiteral(":/font/font/iconfont.ttf");
    int id = QFontDatabase::addApplicationFont(path);
    if (id < 0)
        qWarning() << "MosUI: failed to load font:" << path;
}

// 利用静态初始化在 main() 入口前注册回调
// Q_COREAPP_STARTUP_FUNCTION 会在 Q[Core|Gui]Application 构造后调用
Q_COREAPP_STARTUP_FUNCTION(loadFonts)

Q_GLOBAL_STATIC_WITH_ARGS(bool, g_initialized, (false));

MosApp::~MosApp()
{

}

void MosApp::initialize(QQmlEngine *engine)
{
    *g_initialized = true;
}

QString MosApp::libName()
{
    return "MosUI";
}

QString MosApp::libVersion()
{
    return "0.0.1";
}

MosApp *MosApp::instance()
{
    static MosApp *ins = new MosApp;
    return ins;
}

MosApp *MosApp::create(QQmlEngine *qmlEngine, QJSEngine *)
{

    if (!*g_initialized)
        initialize(qmlEngine);

    return instance();
}

MosApp::MosApp(QObject *parent)
    : QObject{parent}
{

}
