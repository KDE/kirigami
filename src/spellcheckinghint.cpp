// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "spellcheckinghint.h"
#include <QQuickItem>

SpellCheckingAttached::SpellCheckingAttached(QObject *parent)
    : QObject(parent)
{
}

SpellCheckingAttached::~SpellCheckingAttached()
{
}

void SpellCheckingAttached::setEnabled(bool enabled)
{
    if (enabled == m_enabled) {
        return;
    }

    m_enabled = enabled;
    Q_EMIT enabledChanged();
}

bool SpellCheckingAttached::enabled() const
{
    return m_enabled;
}

SpellCheckingAttached *SpellCheckingAttached::qmlAttachedProperties(QObject *object)
{
    return new SpellCheckingAttached(object);
}
