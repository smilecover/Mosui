#ifndef MOSSIZEGENERATOR_H
#define MOSSIZEGENERATOR_H

#include <QtCore/QObject>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosSizeGenerator : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosSizeGenerator)

public:
    MosSizeGenerator(QObject *parent = nullptr);
    ~MosSizeGenerator();

    Q_INVOKABLE static QList<qreal> generateFontSize(qreal fontSizeBase);
    Q_INVOKABLE static QList<qreal> generateFontLineHeight(qreal fontSizeBase);
};

#endif // MOSSIZEGENERATOR_H
