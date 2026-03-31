#ifndef MOSAPP_H
#define MOSAPP_H

#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosApp : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosApp)

public:
    ~MosApp();

    static void initialize(QQmlEngine *engine);

    Q_INVOKABLE static QString libName();
    Q_INVOKABLE static QString libVersion();

    static MosApp *instance();
    static MosApp *create(QQmlEngine *, QJSEngine *);

private:
    explicit MosApp(QObject *parent = nullptr);
};

#endif // MOSAPP_H
