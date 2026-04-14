#ifndef MOSTTHEME_P_H
#define MOSTTHEME_P_H

#include "Mostheme.h"
#include "Mossystemthemehelper.h"
#include <QtCore>
// 哈希表类
#include <QtCore/QHash>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>

enum class Function : uint16_t
{
    GenColor,
    GenFontFamily,
    GenFontSize,
    GenFontLineHeight,
    GenRadius,

    Darker,
    Lighter,
    Brightness,
    Alpha,
    OnBackground,

    Multiply
};


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
    MosTheme::TextRenderType m_textRenderType = MosTheme::TextRenderType::QtRendering;

    MosSystemThemeHelper *m_helper { nullptr };


    // json主题处理
    QString m_themeMainPath = ":/theme/theme/main.json"; // 主题主文件路径
    QJsonObject m_mainObject; // json对象
    QMap<QString, QVariant> m_mainTokenTable; // 处理
    QMap<QObject *, ThemeData> m_defaultTheme; // 默认主题
    QMap<QObject *, ThemeData> m_customTheme; // 自定义主题


    QVariantMap m_sizeHintMap;


    // 主题重新加载（仅重新计算 Token，不重读文件）
    void applyTheme();
    // 主题重新加载
    void reloadMainTheme();
    // 组件默认主题重新加载
    void reloadDefaultComponentTheme();
    // 组件自定义主题重新加载
    void reloadCustomComponentTheme();
    
    // 组件主题重新加载
    void reloadComponentTheme(const QMap<QObject *, ThemeData> &dataMap);
    // 组件文件
    void reloadComponentThemeFile(QObject *themeObject, const QString &componentName,const ThemeData::Component &componentTheme);
    // 组件文件重新加载
    bool reloadComponentImport(QJsonObject &style, const QString &componentName);
    // 主题变量var处理
    void parseIndexExpr(const QString &tokenName, const QString &expr);
    // 初始化组件哈希列表
    void initializeComponentPropertyHash();
    // 注册默认组件主题
    void registerDefaultComponentTheme(const QString &componentName, const QString &themePath);

    void registerComponentTheme(QObject *themeObject, const QString &component, QVariantMap *themeMap,const QString &themePath, QMap<QObject *, ThemeData> &dataMap);
    
    // 组件变量var处理
    void parseComponentExpr(QVariantMap *tokenMapPtr, const QString &tokenName, const QString &expr);
    // 组件变量var处理
    void parse(QMap<QString, QVariant> &out, const QString &tokenName, const QString &expr);

    QColor colorFromIndexTable(const QString &tokenName);

    qreal numberFromIndexTable(const QString &tokenName);
};




#endif // MOSTTHEME_P_H