#ifndef MOSTHEME_H
#define MOSTHEME_H

#include <QObject>
#include <QtQml/qqml.h>
#include "Mosglobal.h"
#include "Mosdefinitions.h"

QT_FORWARD_DECLARE_CLASS(MosThemePrivate)
class MOSUIBASIC_EXPORT MosTheme : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosTheme)

    Q_PROPERTY(bool isDark READ isDark NOTIFY isDarkChanged)
    Q_PROPERTY(DarkMode darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged FINAL)

    MOSUI_PROPERTY_READONLY(QVariantMap, Primary);


public:
    ~MosTheme();
    static MosTheme *instance();
    static MosTheme *create(QQmlEngine *, QJSEngine *);
    enum class DarkMode {
    Light = 0,
    Dark,

    };
    Q_ENUM(DarkMode)

    // 主题重新加载
    Q_INVOKABLE void reloadTheme();
    // 暗色|亮色
    Q_INVOKABLE bool isDark() const;
    // 设置暗色|亮色
    Q_INVOKABLE void setDarkMode(DarkMode darkMode);
    // 获取暗色|亮色
    Q_INVOKABLE DarkMode darkMode() const;




signals:
    void darkModeChanged();
    void isDarkChanged();
private:
    explicit MosTheme(QObject *parent = nullptr);


    Q_DECLARE_PRIVATE(MosTheme)
    QScopedPointer<MosThemePrivate> d_ptr;



};

#endif // MOSTHEME_H
