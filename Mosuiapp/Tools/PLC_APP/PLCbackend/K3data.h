#ifndef K3DATA_H
#define K3DATA_H

#include <QHash>
#include <QObject>
#include <QPair>
#include <QtQml/qqml.h>
#include <qvariant.h>

#include "Mosdefinitions.h"


class K3data : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(K3data)

    MOSUI_PROPERTY_READONLY(QVariantList, k3data_all);
    MOSUI_PROPERTY_READONLY(QVariantList, k3data_left);
    MOSUI_PROPERTY_READONLY(QVariantList, k3data_down);

    MOSUI_PROPERTY_INIT(bool, flag_auto_hand, setFlag_auto_hand, false);/* flast : 手动模式 ; true : 自动模式*/


public:
    ~K3data() override;
    static K3data *instance();
    static K3data *create(QQmlEngine *, QJSEngine *);
    Q_INVOKABLE bool InitK3data();
    void setK3data_left(const QVariantList &list);
    void setK3data_down(const QVariantList &list);
    void setK3data_all(const QVariantList &list);
    void applyUpdate(const QString &key, const QVariant &newValue);
    void syncToLeftAndDown();

private:
    explicit K3data(QObject *parent = nullptr);


    QVariantMap makeMonitorGroup(const QString &title,
                                 const QVariant &rows,
                                 const QVariantList &metrics) const;
    QVariantMap makeMonitorItem(const QString &key,
                                const QString &name,
                                const QVariant &value,
                                const QVariant &accent) const;

    void init_k3dataAllDefaults();
    void init_k3dataleftDefaults();
    void init_k3datadownDefaults();

    QVariantMap findItemInAll(const QString &key) const;
    void syncLeftFromAll();
    void syncDownFromAll();

};
#endif // K3DATA_H
