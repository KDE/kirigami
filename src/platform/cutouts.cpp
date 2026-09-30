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

Cutouts::Cutouts(QQuickItem *parent)
    : QQuickItem(parent)
    , m_cutoutsManager(new CutoutsManager)
{
    connectAncestors(this);
}

Cutouts::~Cutouts() = default;

QList<QRectF> Cutouts::cutouts() const
{
    return m_cutouts;
}

bool Cutouts::eventFilter(QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::PlatformSurface) {
        QPlatformSurfaceEvent *se = static_cast<QPlatformSurfaceEvent *>(event);
        if (se->surfaceEventType() == QPlatformSurfaceEvent::SurfaceCreated) {
            wl_surface *surface = surfaceForWindow(window());
            if (surface) {
                m_cutoutsWayland = new CutoutsWayland(m_cutoutsManager->get_cutouts(surface), this);
            }
        }
    }

    return QObject::eventFilter(watched, event);
}

void Cutouts::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if (change == QQuickItem::ItemSceneChange) {
        connect(window(), &QWindow::widthChanged, this, [this]() {
            m_cutouts = {{0, 0, 64, 24}, {window()->width() - 120, 0, 120, 24}};
            Q_EMIT cutoutsChanged();
            auto sceneRect = mapRectToScene(boundingRect());
            for (const auto rect : std::as_const(m_cutouts)) {
                if (rect.contains(sceneRect.center())) {
                    setImplicitWidth(rect.width());
                    setImplicitHeight(rect.height());
                    break;
                }
            }
        });
        m_cutouts = {{0, 0, 64, 24}, {window()->width() - 120, 0, 120, 24}};
        Q_EMIT cutoutsChanged();
    }

    QQuickItem::itemChange(change, value);
}

void Cutouts::connectAncestors(QQuickItem *item)
{
    if (!item) {
        return;
    }

    QQuickItem *ancestor = item;
    while (ancestor) {
        m_ancestors << ancestor;

        // connect(ancestor, &QQuickItem::xChanged, this, &ScenePositionAttached::xChanged);
        // connect(ancestor, &QQuickItem::yChanged, this, &ScenePositionAttached::yChanged);
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

            auto sceneRect = mapRectToScene(boundingRect());
            for (const auto rect : std::as_const(m_cutouts)) {
                if (rect.contains(sceneRect.center())) {
                    setImplicitWidth(rect.width());
                    setImplicitHeight(rect.height());
                    break;
                }
            }
        });

        ancestor = ancestor->parentItem();
    }
}

}
}

#include "moc_cutouts_p.cpp"
