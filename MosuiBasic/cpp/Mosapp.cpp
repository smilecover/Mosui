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

// Q_COREAPP_STARTUP_FUNCTION 会在 Q[Core|Gui]Application 构造后调用
Q_COREAPP_STARTUP_FUNCTION(loadFonts)

MosApp::~MosApp() = default;

void MosApp::initialize(QQmlEngine *engine)
{
    Q_UNUSED(engine);
    // 预留：未来可在此处执行 QML 引擎相关的初始化
}

QString MosApp::libName()
{
    return "MosUI";
}

QString MosApp::libVersion()
{
    return QString::fromLatin1(MOSUI_VERSION);
}

MosApp *MosApp::instance()
{
    static MosApp *ins = new MosApp;
    return ins;
}

MosApp *MosApp::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    Q_UNUSED(qmlEngine);
    return instance();
}

MosApp::MosApp(QObject *parent)
    : QObject{parent}
{
}
