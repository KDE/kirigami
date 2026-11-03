/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "cutouts_p.h"
#include "helpers.h"

#ifdef KIRIGAMI_ENABLE_DBUS
#include <QDBusConnection>
#endif

#include "kirigamiplatform_logging.h"
#include "qwayland-xx-cutouts-v1.h"
#include <QPlatformSurfaceEvent>
#include <QQuickWindow>
#include <QtWaylandClient/QWaylandClientExtension>
#include <QtWaylandClient/QWaylandClientExtensionTemplate>

namespace Kirigami
{
namespace Platform
{

class CutoutsManager : public QWaylandClientExtensionTemplate<CutoutsManager>, public QtWayland::xx_cutouts_manager_v1
{
public:
    CutoutsManager()
        : QWaylandClientExtensionTemplate<CutoutsManager>(1)
    {
        initialize();
    }
};

class CutoutsWayland : public QObject, public QtWayland::xx_cutouts_v1
{
public:
    CutoutsWayland(struct ::xx_cutouts_v1 *object, QObject *parent)
        : QObject(parent)
        , QtWayland::xx_cutouts_v1(object)
    {
    }

    ~CutoutsWayland() override
    {
        if (isQpaAlive()) {
            destroy();
        }
    }

protected:
    void xx_cutouts_v1_cutout_box(int32_t x, int32_t y, int32_t width, int32_t height, uint32_t type, uint32_t id) override
    {
        m_cutouts[id] = QRect(x, y, width, height);
        qWarning() << "NEW BOX" << id << m_cutouts[id];
    }

private:
    QHash<uint32_t, QRect> m_cutouts;
};

CutoutsMargins::CutoutsMargins(QObject *parent)
    : QObject(parent)
    , m_parentItem(qobject_cast<QQuickItem *>(parent))
{
    if (m_parentItem) {
        connectAncestors(m_parentItem);
        connect(m_parentItem, &QQuickItem::widthChanged, this, &CutoutsMargins::refreshGeometries);
        connect(m_parentItem, &QQuickItem::heightChanged, this, &CutoutsMargins::refreshGeometries);
    }
}

CutoutsMargins::~CutoutsMargins() = default;

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

    m_cutouts = {{0.0, 0.0, 64.0, 24.0}, {m_parentItem->window()->width() - 120.0, 0.0, 120.0, 24.0}};

    const auto sceneRect = m_parentItem->mapRectToScene(m_parentItem->boundingRect());
    const QPointF center = sceneRect.center();

    QMarginsF margins;

    for (const auto rect : m_cutouts) {
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
        if (rect.top() >= center.x()) {
            margins.setBottom(std::max(margins.top(), sceneRect.bottom() - rect.bottom()));
        }
    }

    if (m_margins.left() != margins.left()) {
        m_margins.setLeft(margins.left());
        Q_EMIT leftMarginChanged();
    }
    if (m_margins.top() != margins.top()) {
        m_margins.setLeft(margins.top());
        Q_EMIT topMarginChanged();
    }
    if (m_margins.right() != margins.right()) {
        m_margins.setLeft(margins.right());
        Q_EMIT rightMarginChanged();
    }
    if (m_margins.bottom() != margins.bottom()) {
        m_margins.setLeft(margins.bottom());
        Q_EMIT bottomMarginChanged();
    }
}

}
}

#include "moc_cutouts_p.cpp"
