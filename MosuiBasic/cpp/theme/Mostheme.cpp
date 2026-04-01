#include "Mostheme.h"
#include <QtCore>
#include "Mostheme_p.h"



MosTheme *MosTheme::instance()
{
    static MosTheme *theme = new MosTheme;

    theme->ceshi();

    return theme;
}

MosTheme *MosTheme::create(QQmlEngine *, QJSEngine *)
{
    return instance();
}
MosTheme::~MosTheme()
{

}
MosTheme::MosTheme(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosThemePrivate(this))
{
    Q_D(MosTheme);

}




