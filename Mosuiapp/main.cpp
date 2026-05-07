#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQuickStyle>
#include <QIcon>

#include "Mosapp.h"
// #include "Mostheme.h"


int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Fusion");

    QQmlApplicationEngine engine;
    engine.addImportPath("E:/QtWork/Mosui/shared");

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
