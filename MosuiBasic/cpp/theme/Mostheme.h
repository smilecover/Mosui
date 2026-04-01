#ifndef MOSTHEME_H
#define MOSTHEME_H

#include <QObject>
#include <QtQml/qqml.h>
#include "Mosglobal.h"
#include "Mosdefinitions.h"

QT_FORWARD_DECLARE_CLASS(MosThemePrivate)
class MOSUIBASIC_EXPORT MosTheme : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosTheme)

public:
    ~MosTheme();
    static MosTheme *instance();
    static MosTheme *create(QQmlEngine *, QJSEngine *);

    // Q_INVOKABLE QString ceshi();
private:
    explicit MosTheme(QObject *parent = nullptr);


    Q_DECLARE_PRIVATE(MosTheme)
    QScopedPointer<MosThemePrivate> d_ptr;



};

#endif // MOSTHEME_H
