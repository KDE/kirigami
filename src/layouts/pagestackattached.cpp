// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "pagestackattached.h"

#include "loggingcategory.h"

#include <QMetaObject>
#include <QQmlContext>
#include <QQmlEngine>

using namespace Qt::StringLiterals;

QObject *PageStackAttached::s_typeEval = nullptr;

class TypeEvalSingleton
{
public:
    TypeEvalSingleton()
    {
    }
    ~TypeEvalSingleton()
    {
        qDeleteAll(m_instances.values());
    }
    static bool isStack(QQuickItem *candidate);

private:
    QHash<QQmlEngine *, QObject *> m_instances;
};

Q_GLOBAL_STATIC(TypeEvalSingleton, privateTypeEvalSingletonSelf)

bool TypeEvalSingleton::isStack(QQuickItem *candidate)
{
    if (!candidate) {
        return false;
    }
    QQmlEngine *engine = qmlEngine(candidate);
    if (!engine) {
        return false;
    }

    QObject *typeEval = privateTypeEvalSingletonSelf->m_instances.value(engine);

    if (!typeEval) {
        QQmlComponent component(engine);
        component.setData(QByteArrayLiteral(R"(
import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

QtObject {
    function isStack(obj) {
        return (obj instanceof Kirigami.PageRow) || (obj instanceof StackView);
    }
})"),
                          QUrl(QStringLiteral("pagestackattached.cpp")));

        typeEval = component.create();
        if (!typeEval) {
            return false;
        }
        privateTypeEvalSingletonSelf->m_instances[engine] = typeEval;
    }

    QVariant retVal = false;
    QMetaObject::invokeMethod(typeEval, "isStack", Q_RETURN_ARG(QVariant, retVal), Q_ARG(QVariant, QVariant::fromValue(candidate)));

    return retVal.toBool();
}

PageStackAttached::PageStackAttached(QObject *parent)
    : QQuickAttachedPropertyPropagator(parent)
{
    m_buddyFor = qobject_cast<QQuickItem *>(parent);

    if (!m_buddyFor) {
        qCDebug(KirigamiLayoutsLog) << "PageStack must be attached to an Item" << parent;
        return;
    }

    initialize();

    if (privateTypeEvalSingletonSelf->isStack(m_buddyFor)) {
        setPageStack(m_buddyFor);
        m_parentIsStack = true;
    }
}

QQuickItem *PageStackAttached::pageStack() const
{
    return m_pageStack;
}

void PageStackAttached::setPageStack(QQuickItem *pageStack)
{
    if (!pageStack || m_parentIsStack || m_pageStack == pageStack) {
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
    PageStackAttached *stackAttached = qobject_cast<PageStackAttached *>(newParent);
    if (stackAttached) {
        setPageStack(stackAttached->pageStack());
    }
}

#include "moc_pagestackattached.cpp"
