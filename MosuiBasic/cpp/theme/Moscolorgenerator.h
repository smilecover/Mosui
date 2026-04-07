#ifndef MOSCOLORGENERATOR_H
#define MOSCOLORGENERATOR_H

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosColorGenerator : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosColorGenerator)

public:
    enum class Preset
    {
        Preset_Red = 1,
        Preset_Volcano,
        Preset_Orange,
        Preset_Gold,
        Preset_Yellow,
        Preset_Lime,
        Preset_Green,
        Preset_Cyan,
        Preset_Blue,
        Preset_Geekblue,
        Preset_Purple,
        Preset_Magenta,
        Preset_Grey
    };
    Q_ENUM(Preset);

    MosColorGenerator(QObject *parent = nullptr);
    ~MosColorGenerator();

    Q_INVOKABLE static QColor reverseColor(const QColor &color);
    Q_INVOKABLE static QColor presetToColor(const QString& color);
    Q_INVOKABLE static QColor presetToColor(MosColorGenerator::Preset color);
    Q_INVOKABLE static QList<QColor> generate(MosColorGenerator::Preset color, bool light = true, const QColor &background = QColor(QColor::Invalid));
    Q_INVOKABLE static QList<QColor> generate(const QColor &color, bool light = true, const QColor &background = QColor(QColor::Invalid));
};


#endif // MOSCOLORGENERATOR_H
