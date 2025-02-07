// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "pagestackattached.h"

#include "loggingcategory.h"

#include <QMetaObject>

using namespace Qt::StringLiterals;

PageStackAttached::PageStackAttached(QObject *parent)
    : QQuickAttachedPropertyPropagator(parent)
{
    m_buddyFor = qobject_cast<QQuickItem *>(parent);

    if (!m_buddyFor) {
        qWarning(KirigamiLayoutsLog) << "PageStack must be attached to an Item";
        return;
    }

    initialize();

    if (QByteArray(m_buddyFor->metaObject()->className()).startsWith("PageRow_QMLTYPE_")) {
        qWarning() << "found";
        m_parentIsStack = true;
        setPageStack(m_buddyFor);
    }
}

QQuickItem *PageStackAttached::pageStack() const
{
    return m_pageStack;
}

void PageStackAttached::setPageStack(QQuickItem *pageStack)
{
    if (m_parentIsStack || m_pageStack == pageStack) {
        return;
    }

    if (!pageStack) {
        qCWarning(KirigamiLayoutsLog) << "Trying to assign anything aside of a PageRow to PageStackAttached is not authorized.";
        return;
    }

    m_pageStack = pageStack;

    const auto styles = attachedChildren();
    for (QQuickAttachedPropertyPropagator *child : styles) {
        PageStackAttached *stackAttached = qobject_cast<PageStackAttached *>(child);
        if (stackAttached)
            stackAttached->setPageStack(m_pageStack);
    }

    Q_EMIT pageStackChanged();
}

void PageStackAttached::push(const QVariant &page, const QVariant &properties)
{
    if (!m_pageStack) {
        qCFatal(KirigamiLayoutsLog) << "Pushing in an empty PageStackAttached";
        return;
    }

    auto metaObject = m_pageStack->metaObject();
    Q_ASSERT(metaObject);

    auto push = metaObject->method(metaObject->indexOfMethod("push(QVariant,QVariant)"));
    Q_ASSERT(push.isValid());

    push.invoke(m_pageStack, page, properties);
}

void PageStackAttached::clear()
{
    if (!m_pageStack) {
        qCFatal(KirigamiLayoutsLog) << "Clearing in an empty PageStackAttached";
        return;
    }

    auto metaObject = m_pageStack->metaObject();
    Q_ASSERT(metaObject);

    auto clear = metaObject->method(metaObject->indexOfMethod("clear()"));
    Q_ASSERT(clear.isValid());

    clear.invoke(m_pageStack);
}

PageStackAttached *PageStackAttached::qmlAttachedProperties(QObject *object)
{
    return new PageStackAttached(object);
}

void PageStackAttached::attachedParentChange(QQuickAttachedPropertyPropagator *newParent, QQuickAttachedPropertyPropagator *oldParent)
{
    Q_UNUSED(oldParent);
    qWarning() << newParent << oldParent;
    PageStackAttached *stackAttached = qobject_cast<PageStackAttached *>(newParent);
    if (stackAttached) {
        setPageStack(stackAttached->pageStack());
    }
}

#include "moc_pagestackattached.cpp"
