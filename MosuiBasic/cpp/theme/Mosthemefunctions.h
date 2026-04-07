#ifndef MOSTHEMEFUNCTIONS_H
#define MOSTHEMEFUNCTIONS_H

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosThemeFunctions : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosThemeFunctions)

public:
    MosThemeFunctions(QObject *parent = nullptr);
    ~MosThemeFunctions();

    static MosThemeFunctions *instance();
    static MosThemeFunctions *create(QQmlEngine *, QJSEngine *);    

    Q_INVOKABLE static QList<QColor> genColor(int preset, bool light = true, const QColor &background = QColor(QColor::Invalid));
    Q_INVOKABLE static QList<QColor> genColor(const QColor &color, bool light = true, const QColor &background = QColor(QColor::Invalid));
    Q_INVOKABLE static QList<QString> genColorString(const QColor &color, bool light = true, const QColor &background = QColor(QColor::Invalid));
    Q_INVOKABLE static QList<qreal> genFontSize(qreal fontSizeBase);
    Q_INVOKABLE static QList<qreal> genFontLineHeight(qreal fontSizeBase);
    Q_INVOKABLE static QList<int> genRadius(int radiusBase);
    Q_INVOKABLE static QString genFontFamily(const QString &fontFamilyBase);
    Q_INVOKABLE static QColor darker(const QColor &color, int factor = 140);
    Q_INVOKABLE static QColor lighter(const QColor &color, int factor = 140);
    Q_INVOKABLE static QColor brightness(const QColor &color, bool light = true, int lighterFactor = 140, int darkerFactor = 140);
    Q_INVOKABLE static QColor alpha(const QColor &color, qreal alpha = 0.5);
    Q_INVOKABLE static QColor onBackground(const QColor &color, const QColor &background);
    Q_INVOKABLE static qreal multiply(qreal num1, qreal num2);
};

#endif // MOSTHEMEFUNCTIONS_H
