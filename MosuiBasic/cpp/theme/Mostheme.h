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
    Q_PROPERTY(TextRenderType textRenderType READ textRenderType WRITE setTextRenderType NOTIFY textRenderTypeChanged FINAL)

    Q_PROPERTY(QVariantMap sizeHint READ sizeHint NOTIFY sizeHintChanged FINAL)

    MOSUI_PROPERTY_INIT(bool, animationEnabled, setAnimationEnabled, true); // 是否启用动画效果


    MOSUI_PROPERTY_READONLY(QVariantMap, Primary);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosButton);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosCard);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosCaptionbar);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosIconText);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosCaptionButton);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosMenuButton);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosMenu);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosScrollBar);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosDivider);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosToolTip);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosPopup);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosRadioBlock);
    MOSUI_PROPERTY_READONLY(QVariantMap, MosRadio);


public:
    ~MosTheme();
    static MosTheme *instance();
    static MosTheme *create(QQmlEngine *, QJSEngine *);
    enum class DarkMode {
    Light = 0,
    Dark,
    System,
    };
    Q_ENUM(DarkMode)
    enum class TextRenderType {
        QtRendering = 0,
        NativeRendering = 1,
        CurveRendering = 2
    };
    Q_ENUM(TextRenderType);


    QVariantMap sizeHint() const;

    TextRenderType textRenderType() const;
    void setTextRenderType(TextRenderType renderType);

    // 主题重新加载
    Q_INVOKABLE void reloadTheme();
    // 暗色|亮色
    Q_INVOKABLE bool isDark() const;
    // 设置暗色|亮色
    Q_INVOKABLE void setDarkMode(DarkMode darkMode);
    // 获取暗色|亮色
    Q_INVOKABLE DarkMode darkMode() const;
        // 注册自定义组件主题
    Q_INVOKABLE void registerCustomComponentTheme(QObject *themeObject, const QString &component, QVariantMap *themeMap, const QString &themePath);
    Q_INVOKABLE void installComponentToken(const QString &component, const QString &token, const QString &value);
    // 设置尺寸提示比率
    Q_INVOKABLE void installSizeHintRatio(const QString &size, qreal ratio);


signals:    
    void darkModeChanged();
    void isDarkChanged();
    void textRenderTypeChanged();
    void sizeHintChanged();
private:
    explicit MosTheme(QObject *parent = nullptr);


    Q_DECLARE_PRIVATE(MosTheme)
    QScopedPointer<MosThemePrivate> d_ptr;



};

#endif // MOSTHEME_H
