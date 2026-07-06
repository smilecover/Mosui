#ifndef K3DATAPROCESS_H
#define K3DATAPROCESS_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QtQml/qqml.h>

class K3Client;

class K3dataprocess : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(K3dataprocess)

public:
    ~K3dataprocess() override;

    static K3dataprocess *instance();
    static K3dataprocess *create(QQmlEngine *, QJSEngine *);

signals:

private:
    explicit K3dataprocess(QObject *parent = nullptr);

};

#endif // K3DATAPROCESS_H
