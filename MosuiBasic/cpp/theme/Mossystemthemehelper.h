#ifndef MOSSYSTEMTHEMEHELPER_H
#define MOSSYSTEMTHEMEHELPER_H

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtGui/QWindow>
#include <QtQml/qqml.h>

#ifdef QT_WIDGETS_LIB
#include <QtWidgets/QWidget>
#endif

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosSystemThemeHelperPrivate);

// #ifndef BUILD_MOSUIBASIC_ON_DESKTOP_PLATFORM
// Q_DECLARE_OPAQUE_POINTER(QWindow*);
// Q_DECLARE_OPAQUE_POINTER(QWidget*);
// #endif

class MOSUIBASIC_EXPORT MosSystemThemeHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY accentColorChanged)
    Q_PROPERTY(MosSystemThemeHelper::ColorScheme colorScheme READ colorScheme NOTIFY colorSchemeChanged)

    QML_NAMED_ELEMENT(MosSystemThemeHelper)

public:
    enum class ColorScheme {
        None = 0,
        Light = 1,
        Dark = 2,
    };
    Q_ENUM(ColorScheme);

    MosSystemThemeHelper(QObject *parent = nullptr);
    ~MosSystemThemeHelper();

    /**
     * @brief accentColor 获取当前主题强调色{可用于绑定}
     * @return QColor
     */
    QColor accentColor();
    /**
     * @brief colorScheme 获取当前颜色方案{可用于绑定}
     * @return {@link MosSystemThemeHelper::ColorScheme}    
     */
    MosSystemThemeHelper::ColorScheme colorScheme();

    /**
     * @brief getAccentColor 立即获取当前主题强调色{不可用于绑定}
     * @warning 此接口更快，但不会自动更新
     * @return QColor
     */
    Q_INVOKABLE QColor getAccentColor() const;
    /**
     * @brief getColorScheme 立即获取当前颜色方案{不可用于绑定}
     * @warning 此接口更快，但不会自动更新
     * @return {@link MosSystemThemeHelper::ColorScheme}
     */
    Q_INVOKABLE MosSystemThemeHelper::ColorScheme getColorScheme() const;

    Q_INVOKABLE static bool setWindowTitleBarMode(QWindow *window, bool isDark);

#ifdef QT_WIDGETS_LIB
    Q_INVOKABLE static bool setWindowTitleBarMode(QWidget *window, bool isDark);
#endif

signals:
    void accentColorChanged(const QColor &color);
    void colorSchemeChanged(MosSystemThemeHelper::ColorScheme scheme);

protected:
    virtual void timerEvent(QTimerEvent *);

private:
    Q_DECLARE_PRIVATE(MosSystemThemeHelper);
    QScopedPointer<MosSystemThemeHelperPrivate> d_ptr;
};


#endif // MOSSYSTEMTHEMEHELPER_H
