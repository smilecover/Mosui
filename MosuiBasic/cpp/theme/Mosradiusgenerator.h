#ifndef MOSRADIUSGENERATOR_H
#define MOSRADIUSGENERATOR_H

#include <QtCore/QObject>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosRadiusGenerator : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MosRadiusGenerator)

public:
    MosRadiusGenerator(QObject *parent = nullptr);
    ~MosRadiusGenerator();

    Q_INVOKABLE static QList<int> generateRadius(int radiusBase);
};

#endif // MOSRADIUSGENERATOR_H
