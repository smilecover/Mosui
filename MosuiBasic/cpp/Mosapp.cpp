#include "Mosapp.h"

#include <QtGui/QFontDatabase>

Q_GLOBAL_STATIC_WITH_ARGS(bool, g_initialized, (false));

MosApp::~MosApp()
{

}

void MosApp::initialize(QQmlEngine *engine)
{
    QFontDatabase::addApplicationFont(":/HuskarUI/resources/font/HuskarUI-Icons.ttf");

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
