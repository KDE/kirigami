// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "pagestackattached.h"

#include "formlayoutattached.h"
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
    static QObject *ensureTypeEval(QQmlEngine *engine);
    static bool isStack(QQuickItem *candidate);
    static void push(QQuickItem *stack, const QVariant &page, const QVariant &properties);
    void pop(QQuickItem *stack, const QVariant &page);

private:
    QHash<QQmlEngine *, QObject *> m_instances;
};

Q_GLOBAL_STATIC(TypeEvalSingleton, privateTypeEvalSingletonSelf)

QObject *TypeEvalSingleton::ensureTypeEval(QQmlEngine *engine)
{
    QObject *typeEval = privateTypeEvalSingletonSelf->m_instances.value(engine);

    if (!typeEval) {
        QQmlComponent component(engine);
        component.setData(QByteArrayLiteral(R"(
import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

QtObject {
    function isStack(obj): bool {
        return (obj instanceof Kirigami.PageRow) || (obj instanceof StackView);
    }
    function pushOnStackView(stack, page, properties): void {
        if (!stack instanceof StackView) return;
        stack.push(page, properties);
    }
    function popFromStackView(stack, page): void {
        if (!stack instanceof StackView) return;
        stack.pop(page);
    }
})"),
                          QUrl(QStringLiteral("pagestackattached.cpp")));

        typeEval = component.create();
        if (!typeEval) {
            return nullptr;
        }
        privateTypeEvalSingletonSelf->m_instances[engine] = typeEval;
    }

    return typeEval;
}

bool TypeEvalSingleton::isStack(QQuickItem *candidate)
{
    if (!candidate) {
        return false;
    }
    QQmlEngine *engine = qmlEngine(candidate);
    if (!engine) {
        return false;
    }

    QObject *typeEval = ensureTypeEval(qmlEngine(candidate));
    if (!typeEval) {
        return false;
    }

    QVariant retVal = false;
    QMetaObject::invokeMethod(typeEval, "isStack", Q_RETURN_ARG(QVariant, retVal), Q_ARG(QVariant, QVariant::fromValue(candidate)));

    return retVal.toBool();
}

void TypeEvalSingleton::push(QQuickItem *stack, const QVariant &page, const QVariant &properties)
{
    if (!stack) {
        return;
    }

    QObject *typeEval = ensureTypeEval(qmlEngine(stack));
    if (!typeEval) {
        return;
    }

    QMetaObject::invokeMethod(typeEval, "pushOnStackView", QVariant::fromValue(stack), QVariant::fromValue(page), QVariant::fromValue(properties));
}

void TypeEvalSingleton::pop(QQuickItem *stack, const QVariant &page)
{
    if (!stack) {
        return;
    }

    QObject *typeEval = ensureTypeEval(qmlEngine(stack));
    if (!typeEval) {
        return;
    }

    QMetaObject::invokeMethod(typeEval, "popFromStackView", QVariant::fromValue(stack), QVariant::fromValue(page));
}

PageStackAttached::PageStackAttached(QObject *parent)
    : QQuickAttachedPropertyPropagator(parent)
{
    m_buddyFor = qobject_cast<QQuickItem *>(parent);

    if (!m_buddyFor) {
        qCDebug(KirigamiLayoutsLog) << "PageStack must be attached to an Item" << parent;
        return;
    }

    if (privateTypeEvalSingletonSelf->isStack(m_buddyFor)) {
        setPageStack(m_buddyFor);
    } else if (!m_pageStack) {
        QQuickItem *candidate = m_buddyFor->parentItem();
        while (candidate) {
            if (privateTypeEvalSingletonSelf->isStack(candidate)) {
                qmlAttachedPropertiesObject<PageStackAttached>(candidate, true);
                break;
            }
            candidate = candidate->parentItem();
        }
    }

    initialize();
}

QQuickItem *PageStackAttached::pageStack() const
{
    return m_pageStack;
}

void PageStackAttached::setPageStack(QQuickItem *pageStack)
{
    if (!pageStack || m_pageStack == pageStack || !privateTypeEvalSingletonSelf->isStack(pageStack)) {
        return;
    }

    m_customStack = true;
    m_pageStack = pageStack;

    propagatePageStack(pageStack);

    Q_EMIT pageStackChanged();
}

void PageStackAttached::propagatePageStack(QQuickItem *pageStack)
{
    if (!pageStack) {
        return;
    }

    if (!m_customStack && m_pageStack != pageStack) {
        m_pageStack = pageStack;
        Q_EMIT pageStackChanged();
    }

    const auto stacks = attachedChildren();
    for (QQuickAttachedPropertyPropagator *child : stacks) {
        PageStackAttached *stackAttached = qobject_cast<PageStackAttached *>(child);
        if (stackAttached) {
            stackAttached->propagatePageStack(m_pageStack);
        }
    }
}

void PageStackAttached::push(const QVariant &page, const QVariant &properties)
{
    if (!m_pageStack) {
        qCWarning(KirigamiLayoutsLog) << "Pushing in an empty PageStackAttached";
        return;
    }

    auto metaObject = m_pageStack->metaObject();
    Q_ASSERT(metaObject);

    auto push = metaObject->method(metaObject->indexOfMethod("push(QVariant,QVariant)"));

    if (!push.isValid()) {
        // It's a StackView instead
        push = metaObject->method(metaObject->indexOfMethod("push(QQmlV4FunctionPtr)"));
        if (push.isValid()) {
            privateTypeEvalSingletonSelf->push(m_pageStack, page, properties);
            return;
        }
    }

    Q_ASSERT(push.isValid());

    push.invoke(m_pageStack, page, properties);
}

void PageStackAttached::pop(const QVariant &page)
{
    if (!m_pageStack) {
        qCWarning(KirigamiLayoutsLog) << "Pushing in an empty PageStackAttached";
        return;
    }

    auto metaObject = m_pageStack->metaObject();
    Q_ASSERT(metaObject);

    auto pop = metaObject->method(metaObject->indexOfMethod("pop(QVariant)"));

    if (!pop.isValid()) {
        // It's a StackView instead
        pop = metaObject->method(metaObject->indexOfMethod("pop(QQmlV4FunctionPtr)"));
        if (pop.isValid()) {
            privateTypeEvalSingletonSelf->pop(m_pageStack, page);
            return;
        }
    }

    Q_ASSERT(pop.isValid());

    pop.invoke(m_pageStack, page);
}

void PageStackAttached::clear()
{
    if (!m_pageStack) {
        qCWarning(KirigamiLayoutsLog) << "Clearing in an empty PageStackAttached";
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

    QQuickItem *candidate = m_buddyFor;
    while (candidate) {
        // It might be that we have been reparented inside a StackView which doesn't
        // have an attached property yet, so in this case it will need a
        // manual check by looking into the parent chain
        auto *attach = qmlAttachedPropertiesObject<PageStackAttached>(candidate, false);
        if (attach && static_cast<PageStackAttached *>(attach)->m_customStack) {
            break;
        } else if (privateTypeEvalSingletonSelf->isStack(candidate)) {
            propagatePageStack(candidate);
            return;
        }
        candidate = candidate->parentItem();
    }

    PageStackAttached *stackAttached = qobject_cast<PageStackAttached *>(newParent);
    if (stackAttached) {
        propagatePageStack(stackAttached->pageStack());
    }
}

#include "moc_pagestackattached.cpp"
