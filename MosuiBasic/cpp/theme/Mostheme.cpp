#include "Mostheme.h"
#include "Mostheme_p.h"
#include <QtCore/QFile>
#include <QtCore/QLoggingCategory>
#include <QtCore/QJsonArray>
#include <QtGui/QFont>


MosTheme *MosTheme::instance()
{
    static MosTheme *theme = new MosTheme;


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
    
    reloadTheme();

}
// @brief 主题重新加载
// @Function void reloadTheme()
// @Description 重新加载主题
void MosTheme::reloadTheme()
{
    Q_D(MosTheme);
    // 打开json文件
    QFile index(d->m_themeMainPath);
    if (!index.open(QIODevice::ReadOnly)) {
        qDebug() << "Index.json open faild:" << index.errorString();
        return;
    }
    QByteArray indexJson = index.readAll();
    index.close();
    QJsonParseError error;
    QJsonDocument indexDoc = QJsonDocument::fromJson(indexJson, &error);
    if (error.error == QJsonParseError::NoError) {
        d->m_mainObject = indexDoc.object();
        d->reloadMainTheme();
    } else {
        qDebug() << "Index.json parse error:" << error.errorString();
    }
} 
void MosThemePrivate::reloadMainTheme()
{
    Q_Q(MosTheme);
    m_mainTokenTable.clear();
    q->m_Primary.clear();

    auto __init__ = m_mainObject["__init__"].toObject();
    auto __base__ = __init__["__base__"].toObject();

    auto colorTextBase = __base__["colorTextBase"].toString();
    auto colorBgBase = __base__["colorBgBase"].toString();
    auto colorTextBaseList = colorTextBase.split("|");
    auto colorBgBaseList = colorBgBase.split("|");

    m_mainTokenTable["colorTextBase"] = q->isDark() ? colorTextBaseList.at(1) : colorTextBaseList.at(0);
    m_mainTokenTable["colorBgBase"] = q->isDark() ? colorBgBaseList.at(1) : colorBgBaseList.at(0);

    for (auto it = m_mainTokenTable.constBegin(); it != m_mainTokenTable.constEnd(); it++) {
        q->m_Primary[it.key()] = it.value();
    }
    emit q->PrimaryChanged();

}
// @brief 暗色|亮色
// @Function bool isDark() const
// @Description 判断是否为暗色主题
bool MosTheme::isDark() const
{
    Q_D(const MosTheme);
    return d->m_darkMode == MosTheme::DarkMode::Dark;
}
// @brief 设置暗色|亮色
// @Function void setDarkMode(DarkMode darkMode)
// @Description 设置暗色主题
void MosTheme::setDarkMode(MosTheme::DarkMode darkMode)
{
    Q_D(MosTheme);
    d->m_darkMode = darkMode;
    emit darkModeChanged();
}
// @brief 获取暗色|亮色
// @Function DarkMode darkMode() const
// @Description 获取暗色主题
MosTheme::DarkMode MosTheme::darkMode() const
{
    Q_D(const MosTheme);
    return d->m_darkMode;
}

