#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQuickStyle>
#include <QIcon>
#include <QCoreApplication>
#include <QDir>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include "Mosapp.h"
// #include "Mostheme.h"


int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QtWebEngineQuick::initialize();
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Fusion");

    QDir appDir(app.applicationDirPath());
    app.setLibraryPaths(QStringList() << appDir.absolutePath() << app.libraryPaths().join(";"));

    QQmlApplicationEngine engine;

    // 添加 QML 模块搜索路径
    QString sharedPath = appDir.absoluteFilePath("shared");
    engine.addImportPath(sharedPath);
    qDebug() << "QML import path:" << sharedPath;

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
