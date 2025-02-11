// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QJSValue>
#include <QQuickAttachedPropertyPropagator>
#include <QQuickItem>
#include <qqmlregistration.h>

/**
 * This attached property makes possible to access from anywhere the
 * page stack this page was pushed into.
 * It can be an instance of org::kde::kirigami::PageRow or
 * a StackView from QtQuickControls
 *
 * Kirigami.Page {
 *     id: root
 *
 *     Button {
 *         text: "Push Page"
 *         onClicked: Kirigami.PageStack.pageStack.push(Qt.resolvedurl("AnotherPage"));
 *     }
 * }
 *
 * @since 6.10
 */
class PageStackAttached : public QQuickAttachedPropertyPropagator
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
        It will point to the proper instance in the parent hyerarchy
        and normally is not necessary to explicitly write it.
        Write on this property only if it's desired this attached
        property and those of all the children to point to a different
        PageRow or StackView
    */
    QQuickItem *pageStack() const;
    void setPageStack(QQuickItem *pageStack);

    static PageStackAttached *qmlAttachedProperties(QObject *object);

protected:
    void propagatePageStack(QQuickItem *pageStack);
    void attachedParentChange(QQuickAttachedPropertyPropagator *newParent, QQuickAttachedPropertyPropagator *oldParent) override;

Q_SIGNALS:
    void pageStackChanged();

private:
    QPointer<QQuickItem> m_pageStack;
    QPointer<QQuickItem> m_buddyFor;
    bool m_customStack = false;

    static QObject *s_typeEval;
};
