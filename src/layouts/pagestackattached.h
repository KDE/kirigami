// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QJSValue>
#include <QQuickAttachedPropertyPropagator>
#include <QQuickItem>
#include <qqmlregistration.h>

/*!
 * \qmltype PageStack
 * \inqmlmodule org.kde.kirigami.layouts
 *
 * \brief This attached property makes possible to access from anywhere the
 * page stack this page was pushed into.
 *
 * It can be an instance of PageRow or
 * a StackView from QtQuick Controls.
 *
 * \qml
 * Kirigami.Page {
 *     id: root
 *
 *     Button {
 *         text: "Push Page"
 *         onClicked: Kirigami.PageStack.push(Qt.resolvedurl("AnotherPage"));
 *     }
 * }
 * \endqml
 *
 * \since 6.10
 */
class PageStackAttached : public QQuickAttachedPropertyPropagator
{
    Q_OBJECT
    QML_NAMED_ELEMENT(PageStack)
    QML_ATTACHED(PageStackAttached)
    QML_UNCREATABLE("")

    /*!
     * \qmlattachedproperty Item PageStack::pageStack
     *
     * This property holds the pageStack where this page was pushed.
     *
     * It will point to the proper instance in the parent hierarchy
     * and normally is not necessary to explicitly write it.
     *
     * Write on this property only if it's desired this attached
     * property and those of all the children to point to a different
     * PageRow or StackView
     */
    Q_PROPERTY(QQuickItem *pageStack READ pageStack WRITE setPageStack NOTIFY pageStackChanged)

public:
    explicit PageStackAttached(QObject *parent);

    QQuickItem *pageStack() const;
    void setPageStack(QQuickItem *pageStack);

    /*!
     * \qmlattachedmethod void PageStack::push(variant page, object properties)
     */
    Q_INVOKABLE void push(const QVariant &page, const QVariantMap &properties = QVariantMap());

    /*!
     * \qmlattachedmethod void PageStack::replace(variant page, object properties)
     */
    Q_INVOKABLE void replace(const QVariant &page, const QVariantMap &properties = QVariantMap());

    /*!
     * \qmlattachedmethod void PageStack::pop(variant page)
     */
    Q_INVOKABLE void pop(const QVariant &page = QVariant());

    /*!
     * \qmlattachedmethod void PageStack::clear()
     */
    Q_INVOKABLE void clear();

    static PageStackAttached *qmlAttachedProperties(QObject *object);

protected:
    bool hasStackCapabilities(QQuickItem *candidate);
    void propagatePageStack(QQuickItem *pageStack);
    void attachedParentChange(QQuickAttachedPropertyPropagator *newParent, QQuickAttachedPropertyPropagator *oldParent) override;

Q_SIGNALS:
    void pageStackChanged();

    /**
     * Close the currently opened dialog, which was opened with PageRow::pushDialogLayer.
     */
    void closeDialog();

private:
    QPointer<QQuickItem> m_pageStack;
    QPointer<QQuickItem> m_parentItem;
    bool m_customStack = false;
};
