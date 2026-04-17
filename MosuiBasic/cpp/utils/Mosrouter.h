#ifndef MOSROUTER_H
#define MOSROUTER_H

#include <QtCore/QUrl>
#include <QtCore/QUrlQuery>
#include <QtCore/QVariantMap>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

QT_FORWARD_DECLARE_CLASS(MosRouterPrivate);

class MOSUIBASIC_EXPORT MosRouterHistory : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl location READ location NOTIFY locationChanged FINAL)

    QML_NAMED_ELEMENT(MosRouterHistory)
    QML_UNCREATABLE("MosRouterHistory is only available via read-only properties.")

public:
    explicit MosRouterHistory(const QUrl &location, QObject *parent = nullptr)
        : QObject{parent}
        , m_location(location)
    {
    }

    QUrl location() { return m_location; }

signals:
    void locationChanged();

private:
    friend class MosRouter;

    void setLocation(const QUrl &location) {
        if (m_location != location) {
            m_location = location;
            emit locationChanged();
        }
    }

    QUrl m_location;
};

class MOSUIBASIC_EXPORT MosRouter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl currentUrl READ currentUrl NOTIFY currentUrlChanged FINAL)
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentPathChanged FINAL)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QQmlListProperty<MosRouterHistory> history READ history NOTIFY historyChanged FINAL)
    Q_PROPERTY(int historyMaxCount READ historyMaxCount WRITE setHistoryMaxCount NOTIFY historyMaxCountChanged FINAL)
    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY canGoBackChanged FINAL)
    Q_PROPERTY(bool canGoForward READ canGoForward NOTIFY canGoForwardChanged FINAL)

    QML_NAMED_ELEMENT(MosRouter)

public:
    explicit MosRouter(QObject *parent = nullptr);
    ~MosRouter();

    QUrl currentUrl() const;
    QString currentPath() const;
    int currentIndex() const;
    QQmlListProperty<MosRouterHistory> history();

    int historyMaxCount() const;
    void setHistoryMaxCount(int maxCount);

    bool canGoBack() const;
    bool canGoForward() const;

    /**
     * @brief 导航到指定URL并将新URL添加到历史记录的顶部
     * @param url 要导航到的URL
     */
    Q_INVOKABLE void push(const QUrl &url);
    
    /**
     * @brief 替换当前URL并将老的URL从历史记录中移除, 然后将新URL添加到历史记录顶部
     * @param url 要导航到的URL
     */
    Q_INVOKABLE void replace(const QUrl &url);

    /**
     * @brief 清空所有导航历史
     */
    Q_INVOKABLE void clear();
    
    /**
     * @brief 后退到历史记录中的上一个URL
     */
    Q_INVOKABLE void goBack();
    
    /**
     * @brief 前进到历史记录中的下一个URL
     */
    Q_INVOKABLE void goForward();

    /**
     * @brief 以键值对的形式返回URL中的查询字符串
     * @param url 要获取的URL
     * @return QVariantMap
     * @example /query?id=1&sort=asc { "id": "1", "sort": "asc" }
     */
    Q_INVOKABLE QVariantMap getQueryParams(const QUrl &url) const;

signals:
    void currentUrlChanged();
    void currentPathChanged();
    void currentIndexChanged();
    void historyChanged();
    void historyMaxCountChanged();
    void canGoBackChanged();
    void canGoForwardChanged();

private:
    Q_DECLARE_PRIVATE(MosRouter);
    QScopedPointer<MosRouterPrivate> d_ptr;
};

#endif // MOSROUTER_H
