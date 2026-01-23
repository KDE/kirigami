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
     * Returns the instance of the item defined in the QML file identified
     * by url, only one instance will be made per url if cachePAges is true.
     * If the url is remote (i.e. http) don't rely on the return value but
     * us the async callback instead.
     *
     * @param url full url of the item: it can be a well formed Url, an
     * absolute path or a relative one to the path of the qml file the
     * PagePool is instantiated from
     * @param callback If we are loading a remote url, we can't have the
     * item immediately but will be passed as a parameter to the provided
     * callback. Normally, don't set a callback, use it only in case of
     * remote urls
     * @returns the page instance that will have been created if necessary.
     * If the url is remote it will return null, as well will return null
     * if the callback has been provided
     */
    Q_INVOKABLE QQuickItem *loadPage(const QString &url, QJSValue callback = QJSValue());

    Q_INVOKABLE QQuickItem *loadPageWithProperties(const QString &url, const QVariantMap &properties, QJSValue callback = QJSValue());

    /*!
     * @returns The url of the page for the given instance, empty if there is no correspondence
     */
    Q_INVOKABLE QUrl urlForPage(QQuickItem *item) const;

    /*!
     * @returns The page associated with a given URL, nullptr if there is no correspondence
     */
    Q_INVOKABLE QQuickItem *pageForUrl(const QUrl &url) const;

    /*!
     * @returns true if the is managed by the PagePool
     * @param the page can be either a QQuickItem or an url
     */
    Q_INVOKABLE bool contains(const QVariant &page) const;

    /*!
     * Deletes the page (only if is managed by the pool.
     * @param page either the url or the instance of the page
     */
    Q_INVOKABLE void deletePage(const QVariant &page);

    /*!
     * @returns full url from an absolute or relative path
     */
    Q_INVOKABLE QUrl resolvedUrl(const QString &file) const;

    /*!
     * @returns true if the url identifies a local resource (local file or a file inside Qt's resource system).
     * False if the url points to a network location
     */
    Q_INVOKABLE bool isLocalUrl(const QUrl &url);

    /*!
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
