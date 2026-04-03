#ifndef MOSWINDOWAGENT_H
#define MOSWINDOWAGENT_H

#include <QtCore/QObject>
#include <QtQml/qqml.h>
#include <QQmlParserStatus> 

#include <QWKQuick/quickwindowagent.h>

#include "Mosglobal.h"


class MOSUIBASIC_EXPORT MosWindowAgent : public QWK::QuickWindowAgent, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    QML_NAMED_ELEMENT(MosWindowAgent)
public:
    explicit MosWindowAgent(QObject *parent = nullptr);
    ~MosWindowAgent();

    void classBegin() override;
    void componentComplete() override;
    
};



#endif // MOSWINDOWAGENT_H