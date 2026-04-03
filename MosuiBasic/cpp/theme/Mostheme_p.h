#ifndef MOSTTHEME_P_H
#define MOSTTHEME_P_H

#include "Mostheme.h"
#include <QtCore>
// 哈希表类
#include <QtCore/QHash>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
// 定义哈希表的键值对类型
struct ThemeData
{
    struct Component
    {
        QString path;
        QVariantMap *tokenMap;
        QMap<QString, QString> installTokenMap;
    };
    QObject *themeObject = nullptr;
    QMap<QString, Component> componentMap;
};

class MosThemePrivate
{
public:
    Q_DECLARE_PUBLIC(MosTheme);
    MosThemePrivate(MosTheme *q) : q_ptr(q) { };
    MosTheme *q_ptr { nullptr };
    MosTheme::DarkMode m_darkMode = MosTheme::DarkMode::Dark;


    // json主题处理
    QString m_themeMainPath = ":/theme/theme/main.json"; // 主题主文件路径
    QJsonObject m_mainObject; // json对象
    QMap<QString, QVariant> m_mainTokenTable; // 处理
    QMap<QObject *, ThemeData> m_defaultTheme; // 默认主题

    // 主题重新加载
    void reloadMainTheme();





signals:



};




#endif // MOSTTHEME_P_H