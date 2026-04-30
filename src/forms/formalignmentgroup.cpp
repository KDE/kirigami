/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "formalignmentgroup_p.h"
#include <QQuickItem>

FormAlignmentGroup::FormAlignmentGroup(QObject *parent)
    : QObject(parent)
{
}

QQmlListProperty<QQuickItem> FormAlignmentGroup::forms()
{
    return QQmlListProperty<QQuickItem>(this, nullptr, forms_append, forms_count, forms_at, forms_clear);
}

void FormAlignmentGroup::addForm(QQuickItem *form)
{
    if (m_forms.contains(form)) {
        return;
    }
    m_forms.append(form);

    connect(form, &QObject::destroyed, this, [this, form]() {
        removeForm(form);
    });

    Q_EMIT formsChanged();
}

void FormAlignmentGroup::removeForm(QQuickItem *form)
{
    if (!m_forms.contains(form)) {
        return;
    }

    disconnect(form, &QObject::destroyed, this, nullptr);

    m_forms.removeAll(form);
    Q_EMIT formsChanged();
}

FormAlignmentGroupAttached *FormAlignmentGroup::qmlAttachedProperties(QObject *object)
{
    return new FormAlignmentGroupAttached(object);
}

void FormAlignmentGroup::forms_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *form)
{
    FormAlignmentGroup *q = static_cast<FormAlignmentGroup *>(prop->object);
    q->addForm(form);
}

qsizetype FormAlignmentGroup::forms_count(QQmlListProperty<QQuickItem> *prop)
{
    FormAlignmentGroup *q = static_cast<FormAlignmentGroup *>(prop->object);
    return q->m_forms.count();
}

QQuickItem *FormAlignmentGroup::forms_at(QQmlListProperty<QQuickItem> *prop, qsizetype index)
{
    FormAlignmentGroup *q = static_cast<FormAlignmentGroup *>(prop->object);
    if (index < 0 || index >= q->m_forms.count()) {
        return nullptr;
    }
    return q->m_forms.value(index);
}

void FormAlignmentGroup::forms_clear(QQmlListProperty<QQuickItem> *prop)
{
    FormAlignmentGroup *q = static_cast<FormAlignmentGroup *>(prop->object);

    std::for_each(q->m_forms.constBegin(), q->m_forms.constEnd(), [q](QQuickItem *form) {
        disconnect(form, &QObject::destroyed, q, nullptr);
        return form;
    });

    q->m_forms.clear();
    Q_EMIT q->formsChanged();
}

////////////////////// QQuickButtonGroupAttached

FormAlignmentGroupAttached::FormAlignmentGroupAttached(QObject *parent)
    : QObject(parent)
    , m_form(qobject_cast<QQuickItem *>(parent))
{
}

FormAlignmentGroup *FormAlignmentGroupAttached::group() const
{
    return m_group;
}

void FormAlignmentGroupAttached::setGroup(FormAlignmentGroup *group)
{
    if (m_group) {
        m_group->removeForm(m_form);
    }

    m_group = group;

    if (m_form) {
        group->addForm(m_form);
    }

    Q_EMIT groupChanged();
}
