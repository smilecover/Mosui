#ifndef MOSICON_H
#define MOSICON_H

#include <QtCore/QObject>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosIcon : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosIcon)
public:
    enum class Type : uint16_t {
        
        
    };
    Q_ENUM(Type);

    ~MosIcon();

    static MosIcon *instance();
    static MosIcon *create(QQmlEngine *, QJSEngine *);

    static Q_INVOKABLE QVariantMap allIconNames();
private:
    MosIcon(QObject *parent = nullptr);
};

#endif // MOSICON_H