#include "MosIcon.h"

MosIcon::MosIcon(QObject *parent)
    : QObject{parent}
{

}

MosIcon::~MosIcon()
{

}

MosIcon *MosIcon::instance()
{
    static MosIcon *ins = new MosIcon;

    return ins;
}

MosIcon *MosIcon::create(QQmlEngine *, QJSEngine *)
{
    return instance();
}

QVariantMap MosIcon::allIconNames()
{
    QVariantMap iconMap;
    QMetaEnum me = QMetaEnum::fromType<MosIcon::Type>();
    for (int i = 0; i < me.keyCount(); i++) {
        iconMap[QString::fromLatin1(me.key(i))] = me.value(i);
    }

    return iconMap;
}
