/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "cutoutmargins_p.h"
#include "cutouts_p.h"

#include <QQuickWindow>

namespace Kirigami
{
namespace Platform
{

CutoutsMargins::CutoutsMargins(QObject *parent)
    : QObject(parent)
    , m_parentItem(qobject_cast<QQuickItem *>(parent))
{
    connect(Cutouts::self(), &Cutouts::cutoutsChanged, this, [this](QWindow *window, const QList<QRectF> &cutouts) {
        if (window != m_window) {
            return;
        }

        m_cutouts = cutouts;
        refreshGeometries();
    });

    if (m_parentItem) {
        connectAncestors(m_parentItem);
        connect(m_parentItem, &QQuickItem::widthChanged, this, &CutoutsMargins::refreshGeometries);
        connect(m_parentItem, &QQuickItem::heightChanged, this, &CutoutsMargins::refreshGeometries);
        connect(m_parentItem, &QQuickItem::windowChanged, this, &CutoutsMargins::handleWindowChanged);
        handleWindowChanged();
    }
}

CutoutsMargins::~CutoutsMargins() = default;

void CutoutsMargins::handleWindowChanged()
{
    QWindow *window = m_parentItem ? m_parentItem->window() : nullptr;
    if (window == m_window) {
        //   return;
    }

    m_window = window;
    m_cutouts.clear();
    if (m_window) {
        Cutouts::self()->registerWindow(m_window);
        m_cutouts = Cutouts::self()->cutouts(m_window);
    }

    refreshGeometries();
}

qreal CutoutsMargins::leftMargin() const
{
    return m_margins.left();
}

qreal CutoutsMargins::topMargin() const
{
    return m_margins.top();
}

qreal CutoutsMargins::rightMargin() const
{
    return m_margins.right();
}

qreal CutoutsMargins::bottomMargin() const
{
    return m_margins.bottom();
}

CutoutsMargins *CutoutsMargins::qmlAttachedProperties(QObject *object)
{
    return new CutoutsMargins(object);
}

void CutoutsMargins::connectAncestors(QQuickItem *item)
{
    if (!item) {
        return;
    }

    QQuickItem *ancestor = item;
    while (ancestor) {
        m_ancestors << ancestor;

        connect(ancestor, &QQuickItem::xChanged, this, &CutoutsMargins::refreshGeometries);
        connect(ancestor, &QQuickItem::yChanged, this, &CutoutsMargins::refreshGeometries);
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

            refreshGeometries();
        });

        ancestor = ancestor->parentItem();
    }
}

void CutoutsMargins::refreshGeometries()
{
    if (!m_parentItem || !m_parentItem->window()) {
        return;
    }

    const auto sceneRect = m_parentItem->mapRectToScene(m_parentItem->boundingRect());
    const QPointF center = sceneRect.center();

    QMarginsF margins;

    for (const auto &rect : std::as_const(m_cutouts)) {
        // Left edge
        if (rect.right() <= center.x()) {
            margins.setLeft(std::max(margins.left(), rect.right() - sceneRect.left()));
        }
        // Top edge
        if (rect.bottom() <= center.y()) {
            margins.setTop(std::max(margins.top(), rect.bottom() - sceneRect.top()));
        }
        // Right edge
        if (rect.left() >= center.x()) {
            margins.setRight(std::max(margins.right(), sceneRect.right() - rect.left()));
        }
        // Bottom edge
        if (rect.top() >= center.y()) {
            margins.setBottom(std::max(margins.bottom(), sceneRect.bottom() - rect.top()));
        }
    }

    if (m_margins.left() != margins.left()) {
        m_margins.setLeft(margins.left());
        Q_EMIT leftMarginChanged();
    }
    if (m_margins.top() != margins.top()) {
        m_margins.setTop(margins.top());
        Q_EMIT topMarginChanged();
    }
    if (m_margins.right() != margins.right()) {
        m_margins.setRight(margins.right());
        Q_EMIT rightMarginChanged();
    }
    if (m_margins.bottom() != margins.bottom()) {
        m_margins.setBottom(margins.bottom());
        Q_EMIT bottomMarginChanged();
    }
}

}
}

#include "moc_cutoutmargins_p.cpp"
