// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "actionhelper.h"

ActionHelper::ActionHelper(QObject *parent)
    : QObject(parent)
{
}

QString ActionHelper::nativeKey(const QKeySequence &keys)
{
    return keys.toString();
}

QString ActionHelper::iconName(const QIcon &icon) const
{
    return icon.name();
}

QList<QKeySequence> ActionHelper::alternateShortcuts(QAction *action) const
{
    if (!action || action->shortcuts().length() <= 1) {
        return {};
    } else {
        return action->shortcuts().mid(1);
    }
}

// qt_strippedText from QAction.
static QString strippedText(QString s)
{
    for (qsizetype i = 0; i < s.size(); ++i) {
        const QChar &c = s.at(i);
        if (c == u'&' || c == u'\x2026') // Horizontal Ellipsis
            s.remove(i, 1);
        else if (i + 2 < s.size() && c == u'.' && s.at(i + 1) == u'.' && s.at(i + 2) == u'.')
            s.remove(i, 3);
    }
    return s.trimmed();
}

bool ActionHelper::hasUsefulToolTip(const QString &text, const QString &toolTip) const
{
    // QAction tooltip returns its text when there is no custom tooltip,
    // unfortunately we cannot ask Qt for the actual tooltip that was set.
    return !toolTip.isEmpty() && (strippedText(text) != toolTip);
}

#include "moc_actionhelper.cpp"
