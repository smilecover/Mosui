#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQuickStyle>
#include <QIcon>
#include <QCoreApplication>
#include <QDir>
#ifdef HAS_QT_WEBENGINE
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#endif
#include "Mosapp.h"


int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
#ifdef HAS_QT_WEBENGINE
    QtWebEngineQuick::initialize();
#endif
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Fusion");

    QDir appDir(app.applicationDirPath());
    QStringList paths = app.libraryPaths();
    paths.prepend(appDir.absolutePath());
    app.setLibraryPaths(paths);

    QQmlApplicationEngine engine;

    // 添加 QML 模块搜索路径（appDir 即 shared/ 目录，QML 模块为其子目录）
    engine.addImportPath(appDir.absolutePath());

    QIcon icon(":/logo.png");
    app.setWindowIcon(icon);
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Mosuiapp", "Main");
    qDebug() << MosApp::libName() << MosApp::libVersion();



    return app.exec();
}
