/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "formlayoutattached.h"
#include "loggingcategory.h"

#include <QDebug>
#include <QQuickItem>

FormLayoutAttached::FormLayoutAttached(QObject *parent)
    : QObject(parent)
{
    m_buddyFor = qobject_cast<QQuickItem *>(parent);
    if (!m_buddyFor) {
        qWarning(KirigamiLayoutsLog) << "FormData must be attached to an Item";
    }
}

FormLayoutAttached::~FormLayoutAttached()
{
}

void FormLayoutAttached::setLabel(const QString &text)
{
    if (m_label == text) {
        return;
    }

    m_label = text;
    Q_EMIT labelChanged();
}

QString FormLayoutAttached::label() const
{
    return m_label;
}

void FormLayoutAttached::setLabelAlignment(int alignment)
{
    if (m_labelAlignment == alignment) {
        return;
    }

    m_labelAlignment = alignment;
    Q_EMIT labelAlignmentChanged();
}

int FormLayoutAttached::labelAlignment() const
{
    return m_labelAlignment;
}

void FormLayoutAttached::setIsSection(bool section)
{
    if (m_isSection == section) {
        return;
    }

    m_isSection = section;
    Q_EMIT isSectionChanged();
}

bool FormLayoutAttached::isSection() const
{
    return m_isSection;
}

QQuickItem *FormLayoutAttached::buddyFor() const
{
    return m_buddyFor;
}

void FormLayoutAttached::setBuddyFor(QQuickItem *aBuddyFor)
{
    if (m_buddyFor == aBuddyFor) {
        return;
    }

    const auto attachee = qobject_cast<QQuickItem *>(parent());

    if (!attachee) {
        return;
    }

    // TODO: Use ScenePosition or introduce new type for optimized relative
    // position calculation to support more nested buddy.

    if (m_buddyFor) {
        disconnect(m_buddyFor, &QObject::destroyed, this, &FormLayoutAttached::resetBuddyFor);
    }

    m_buddyFor = aBuddyFor;

    if (m_buddyFor) {
        connect(m_buddyFor, &QObject::destroyed, this, &FormLayoutAttached::resetBuddyFor);
    }

    Q_EMIT buddyForChanged();
}

void FormLayoutAttached::resetBuddyFor()
{
    const auto attachee = qobject_cast<QQuickItem *>(parent());
    setBuddyFor(attachee);
}

FormLayoutAttached *FormLayoutAttached::qmlAttachedProperties(QObject *object)
{
    return new FormLayoutAttached(object);
}

#include "moc_formlayoutattached.cpp"
