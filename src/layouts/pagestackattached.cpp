// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "pagestackattached.h"

#include "loggingcategory.h"

#include <QMetaObject>

using namespace Qt::StringLiterals;

PageStackAttached::PageStackAttached(QObject *parent)
    : QObject(parent)
{
    m_buddyFor = qobject_cast<QQuickItem *>(parent);
    if (!m_buddyFor) {
        qWarning(KirigamiLayoutsLog) << "PageStack must be attached to an Item";
    }

    if (!m_buddyFor->inherits("QQuickPage")) {
        qWarning(KirigamiLayoutsLog) << "PageStack must be attached to a Page";
    }
}

QQuickItem *PageStackAttached::pageStack() const
{
    return m_pageStack;
}

void PageStackAttached::setPageStack(QQuickItem *pageStack)
{
    if (m_pageStack == pageStack) {
        return;
    }

    if (!pageStack || pageStack->objectName() != u"PageRow"_s) {
        qCFatal(KirigamiLayoutsLog) << "Trying to assign anything aside of a PageRow to PageStackAttached is not authorized.";
        return;
    }

    m_pageStack = pageStack;
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
