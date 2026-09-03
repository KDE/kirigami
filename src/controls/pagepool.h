/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>

/*!
 * \qmltype PagePool
 * \inqmlmodule org.kde.kirigami
 *
 * \brief A pool of Page items.
 *
 * Pages will be unique per url and the items
 * will be kept around unless explicitly deleted.
 *
 * Instances are C++ owned and can be deleted only manually using deletePage().
 *
 * Instance are unique per url: if you need 2 different instances for a page
 * url, you should instantiate them in the traditional way
 * or use a different PagePool instance.
 *
 * \sa PagePoolAction
 */
class PagePool : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    /*!
     * \qmlproperty url PagePool::lastLoadedUrl
     *
     * The last url that was loaded with loadPage. Useful if you need
     * to have a "checked" state to buttons or list items that
     * load the page when clicked.
     */
    Q_PROPERTY(QUrl lastLoadedUrl READ lastLoadedUrl NOTIFY lastLoadedUrlChanged FINAL)

    /*!
     * \qmlproperty Item PagePool::lastLoadedItem
     *
     * The last item that was loaded with loadPage.
     */
    Q_PROPERTY(QQuickItem *lastLoadedItem READ lastLoadedItem NOTIFY lastLoadedItemChanged FINAL)

    /*!
     * \qmlproperty list<Item> PagePool::items
     *
     * All items loaded/managed by the PagePool.
     * \since 5.84
     */
    Q_PROPERTY(QList<QQuickItem *> items READ items NOTIFY itemsChanged FINAL)

    /*!
     * \qmlproperty list<url> PagePool::urls
     *
     * All page URLs loaded/managed by the PagePool.
     * \since 5.84
     */
    Q_PROPERTY(QList<QUrl> urls READ urls NOTIFY urlsChanged FINAL)

    /*!
     * \qmlproperty bool PagePool::cachePages
     *
     * If \c true (default) the pages will be kept around, will have C++ ownership and
     * only one instance per page will be created.
     * If \c false the pages will have Javascript ownership (thus deleted on pop by the
     * page stacks) and each call to loadPage will create a new page instance. When
     * cachePages is false, Components get cached nevertheless.
     */
    Q_PROPERTY(bool cachePages READ cachePages WRITE setCachePages NOTIFY cachePagesChanged FINAL)

public:
    PagePool(QObject *parent = nullptr);
    ~PagePool() override;

    QUrl lastLoadedUrl() const;
    QQuickItem *lastLoadedItem() const;
    QList<QQuickItem *> items() const;
    QList<QUrl> urls() const;

    void setCachePages(bool cache);
    bool cachePages() const;

    /*!
     * \qmlmethod Item PagePool::loadPage(string url, var callback)
     *
     * Returns the instance of the item defined in the QML file identified
     * by url, only one instance will be made per url if cachePAges is true.
     * If the url is remote (i.e. http) don't rely on the return value but
     * us the async callback instead.
     *
     * \a url full url of the item: it can be a well formed Url, an
     * absolute path or a relative one to the path of the qml file the
     * PagePool is instantiated from
     *
     * \a callback If we are loading a remote url, we can't have the
     * item immediately but will be passed as a parameter to the provided
     * callback. Normally, don't set a callback, use it only in case of
     * remote urls
     *
     * Return the page instance that will have been created if necessary.
     * If the url is remote it will return null, as well will return null
     * if the callback has been provided
     */
    Q_INVOKABLE QQuickItem *loadPage(const QString &url, QJSValue callback = QJSValue());

    /*!
     * \qmlmethod Item PagePool::loadPageWithProperties(string url, variantMap properties, var callback)
     */
    Q_INVOKABLE QQuickItem *loadPageWithProperties(const QString &url, const QVariantMap &properties, QJSValue callback = QJSValue());

    /*!
     * \qmlmethod url PagePool::urlForPage(Item item)
     *
     * Returns the url of the page for the given instance, empty if there is no correspondence
     */
    Q_INVOKABLE QUrl urlForPage(QQuickItem *item) const;

    /*!
     * \qmlmethod Item PagePool::pageForUrl(url url)
     *
     * Returns the page associated with a given URL, nullptr if there is no correspondence
     */
    Q_INVOKABLE QQuickItem *pageForUrl(const QUrl &url) const;

    /*!
     * \qmlmethod bool PagePool::contains(variant page)
     *
     * Return \c  true if \a page is managed by the PagePool
     */
    Q_INVOKABLE bool contains(const QVariant &page) const;

    /*!
     * \qmlmethod void PagePool::deletePage(variant page)
     *
     * Deletes \a page (only if is managed by the pool).
     */
    Q_INVOKABLE void deletePage(const QVariant &page);

    /*!
     * \qmlmethod url PagePool::resolvedUrl(string file)
     *
     * Returns the full url from an absolute or relative path
     */
    Q_INVOKABLE QUrl resolvedUrl(const QString &file) const;

    /*!
     * \qmlmethod bool PagePool::isLocalUrl(url url)
     *
     * Returns \c true if the url identifies a local resource (local file or a file inside Qt's resource system).
     *
     * \c false if the url points to a network location
     */
    Q_INVOKABLE bool isLocalUrl(const QUrl &url);

    /*!
     * \qmlmethod void PagePool::clear()
     *
     * Deletes all pages managed by the pool.
     */
    Q_INVOKABLE void clear();

Q_SIGNALS:
    void lastLoadedUrlChanged();
    void lastLoadedItemChanged();
    void itemsChanged();
    void urlsChanged();
    void cachePagesChanged();

private:
    QQuickItem *allocatePage(QQmlComponent *component, const QVariantMap &properties);

    QUrl m_lastLoadedUrl;
    QPointer<QQuickItem> m_lastLoadedItem;
    QHash<QUrl, QQuickItem *> m_itemForUrl;
    QHash<QUrl, QQmlComponent *> m_componentForUrl;
    QHash<QQuickItem *, QUrl> m_urlForItem;

    bool m_cachePages = true;
};
