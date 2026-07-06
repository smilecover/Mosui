#ifndef K3DATA_H
#define K3DATA_H

#include <QObject>
#include <QtQml/qqml.h>


class K3data : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(K3Data);
public:
    ~K3data() override;
    static K3data *instance();
    static K3data *create(QQmlEngine *, QJSEngine *);

    
private:
    explicit K3data(QObject *parent = nullptr);
};
#endif // K3DATA_H