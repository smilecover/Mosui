#ifndef MOSAPI_H
#define MOSAPI_H

#include <QtCore/QDate>
#include <QtQml/qqml.h>
#include <QtGui/QWindow>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosApi : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosApi)

public:
    ~MosApi();

    static MosApi *instance();
    static MosApi *create(QQmlEngine *, QJSEngine *);

    Q_INVOKABLE qreal clamp(qreal value, qreal min, qreal max);

    Q_INVOKABLE void setWindowStaysOnTopHint(QWindow *window, bool hint);
    Q_INVOKABLE void setWindowState(QWindow *window, int state);

    Q_INVOKABLE void setPopupAllowAutoFlip(QObject *popup, bool allowVerticalFlip = true, bool allowHorizontalFlip = true);

    Q_INVOKABLE QString getClipboardText() const;
    Q_INVOKABLE bool setClipboardText(const QString &text);

    Q_INVOKABLE QString readFileToString(const QString &fileName);

    Q_INVOKABLE int getWeekNumber(const QDateTime &dateTime) const;
    Q_INVOKABLE QDateTime dateFromString(const QString &dateTime, const QString &format) const;

    Q_INVOKABLE void openLocalUrl(const QString &local);

private:
    explicit MosApi(QObject *parent = nullptr);
};

#endif // MOSAPI_H
