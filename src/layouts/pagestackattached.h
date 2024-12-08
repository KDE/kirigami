// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QJSValue>
#include <QObject>
#include <QQuickItem>
#include <qqmlregistration.h>

/**
 * This attached property contains the information for decorating a org::kde::kirigami::Page and
 * accessing the current org::kde::kirigami::PageRow.
 *
 * Kirigami.Page {
 *     id: root
 *
 *     Button {
 *         text: "Push Page"
 *         onClicked: root.Kirigami.PageStack.push(Qt.resolvedurl("AnotherPage"));
 *     }
 * }
 *
 * @since 6.10
 */
class PageStackAttached : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(PageStack)
    QML_ATTACHED(PageStackAttached)
    QML_UNCREATABLE("")

    Q_PROPERTY(QQuickItem *pageStack READ pageStack WRITE setPageStack NOTIFY pageStackChanged)

public:
    explicit PageStackAttached(QObject *parent);

    /*!
        \qmlattachedproperty PageRow PageStack::pageStack

        This property holds the pageStack where this page was pushed.
    */
    QQuickItem *pageStack() const;
    void setPageStack(QQuickItem *pageStack);

    Q_INVOKABLE void push(const QVariant &page, const QVariant &properties = {});
    Q_INVOKABLE void clear();

    static PageStackAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void pageStackChanged();

private:
    QQuickItem *m_pageStack = nullptr;
    QQuickItem *m_buddyFor = nullptr;
};