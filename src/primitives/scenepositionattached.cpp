/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "scenepositionattached.h"
#include <QDebug>
#include <QQuickItem>

ScenePositionAttached::ScenePositionAttached(QObject *parent)
    : QObject(parent)
{
    m_item = qobject_cast<QQuickItem *>(parent);
    connectAncestors(m_item);
}

ScenePositionAttached::~ScenePositionAttached()
{
}

qreal ScenePositionAttached::x() const
{
    qreal x = 0.0;
    QQuickItem *item = m_item;

    while (item) {
        x += item->x();
        item = item->parentItem();
    }

    return x;
}

qreal ScenePositionAttached::y() const
{
    qreal y = 0.0;
    QQuickItem *item = m_item;

    while (item) {
        y += item->y();
        item = item->parentItem();
    }

    return y;
}

void ScenePositionAttached::connectAncestors(QQuickItem *item)
{
    if (!item) {
        return;
    }

    QQuickItem *ancestor = item;
    while (ancestor) {
        m_ancestors << ancestor;

        connect(ancestor, &QQuickItem::xChanged, this, &ScenePositionAttached::xChanged);
        connect(ancestor, &QQuickItem::yChanged, this, &ScenePositionAttached::yChanged);
        connect(ancestor, &QQuickItem::parentChanged, this, [this, ancestor]() {
            while (!m_ancestors.isEmpty()) {
                QQuickItem *last = m_ancestors.takeLast();
                // Disconnect the item which had its parent changed too,
                // because connectAncestors() would reconnect it next.
                disconnect(last, nullptr, this, nullptr);
                if (last == ancestor) {
                    break;
                }
            }

            connectAncestors(ancestor);

            Q_EMIT xChanged();
            Q_EMIT yChanged();
        });

        ancestor = ancestor->parentItem();
    }
}

ScenePositionAttached *ScenePositionAttached::qmlAttachedProperties(QObject *object)
{
    return new ScenePositionAttached(object);
}

#include "moc_scenepositionattached.cpp"
