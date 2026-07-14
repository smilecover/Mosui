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
    MOSUI_PROPERTY_INIT(bool, flag_model_downhole, setflag_model_downhole, false);/* flast : 关闭井底压力模式 ; true : 打开井底压力模式*/
    MOSUI_PROPERTY_INIT(bool, flag_model_ground, setflag_model_ground, false);/* flast : 关闭井口压力模式 ; true : 打开井口压力模式*/
    MOSUI_PROPERTY_INIT(bool, flag_model_mainsecond, setflag_model_mainsecond, false);/* flast : 关闭主井模式 ; true : 打开主井模式*/
    MOSUI_PROPERTY_INIT(bool, flag_model_profession, setflag_model_profession, false);/* flast : 关闭专业模式 ; true : 打开专业模式*/
    MOSUI_PROPERTY_INIT(bool, flag_stop, setflag_stop, false);/* flast : 停机(关闭) ; true : 停机（打开）*/
    MOSUI_PROPERTY_INIT(bool, flag_board, setflag_board, true);/* true : 板A ; false : 板B*/
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
