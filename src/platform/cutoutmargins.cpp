/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "cutoutmargins_p.h"
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
    Q_OBJECT
public:
    CutoutsManager(QObject *parent = nullptr)
        : QWaylandClientExtensionTemplate<CutoutsManager>(1, parent)
    {
    }
};

class CutoutsWayland : public QObject, public QtWayland::xx_cutouts_v1
{
    Q_OBJECT
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

    QList<QRectF> cutouts() const
    {
        return m_cutouts;
    }

Q_SIGNALS:
    void cutoutsChanged();

protected:
    void xx_cutouts_v1_cutout_box(int32_t x, int32_t y, int32_t width, int32_t height, uint32_t type, uint32_t id) override
    {
        Q_UNUSED(type)
        Q_UNUSED(id)
        m_pendingCutouts.append(QRectF(x, y, width, height));
        qWarning() << "CUTOUT ARRIVED" << m_pendingCutouts;
    }

    void xx_cutouts_v1_configure() override
    {
        m_cutouts = m_pendingCutouts;
        m_pendingCutouts.clear();
        Q_EMIT cutoutsChanged();
    }

private:
    QList<QRectF> m_cutouts;
    QList<QRectF> m_pendingCutouts;
};

CutoutsMargins::CutoutsMargins(QObject *parent)
    : QObject(parent)
    , m_parentItem(qobject_cast<QQuickItem *>(parent))
    , m_cutoutsManager(new CutoutsManager(this))
{
    connect(m_cutoutsManager, &CutoutsManager::activeChanged, this, &CutoutsMargins::setupCutouts);

    if (m_parentItem) {
        connectAncestors(m_parentItem);
        connect(m_parentItem, &QQuickItem::widthChanged, this, &CutoutsMargins::refreshGeometries);
        connect(m_parentItem, &QQuickItem::heightChanged, this, &CutoutsMargins::refreshGeometries);
        connect(m_parentItem, &QQuickItem::windowChanged, this, &CutoutsMargins::handleWindowChanged);
        handleWindowChanged();
    }
}

CutoutsMargins::~CutoutsMargins() = default;

bool CutoutsMargins::eventFilter(QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::PlatformSurface) {
        QPlatformSurfaceEvent *se = static_cast<QPlatformSurfaceEvent *>(event);
        if (se->surfaceEventType() == QPlatformSurfaceEvent::SurfaceCreated) {
            connectToNativeSurface();
        }
    }

    return QObject::eventFilter(watched, event);
}

void CutoutsMargins::handleWindowChanged()
{
    QWindow *window = m_parentItem ? m_parentItem->window() : nullptr;
    if (window == m_window) {
        return;
    }

    if (m_window) {
        m_window->removeEventFilter(this);
    }

    if (m_native) {
        disconnect(m_native, nullptr, this, nullptr);
        m_native = nullptr;
    }

    delete m_cutoutsWayland;
    m_cutoutsWayland = nullptr;

    m_window = window;

    if (m_window) {
        m_window->installEventFilter(this);
        connectToNativeSurface();
    }

    refreshGeometries();
}

void CutoutsMargins::connectToNativeSurface()
{
    if (!m_window) {
        return;
    }

    auto native = m_window->nativeInterface<QNativeInterface::Private::QWaylandWindow>();
    if (!native || m_native == native) {
        return;
    }

    if (m_native) {
        disconnect(m_native, nullptr, this, nullptr);
    }
    m_native = native;

    connect(native, &QNativeInterface::Private::QWaylandWindow::surfaceRoleCreated, this, &CutoutsMargins::setupCutouts);

    connect(native, &QNativeInterface::Private::QWaylandWindow::surfaceRoleDestroyed, this, [this]() {
        delete m_cutoutsWayland;
        m_cutoutsWayland = nullptr;
        refreshGeometries();
    });

    // The role may have been created before we connected to the signal.
    setupCutouts();
}

void CutoutsMargins::setupCutouts()
{
    qWarning() << "SETTING UP";
    if (m_cutoutsWayland || !m_window || !m_cutoutsManager->isActive()) {
        return;
    }

    // The protocol requires the surface to have the xdg_toplevel role.
    wl_surface *surface = surfaceForWindow(m_window);
    if (!surface || !xdgToplevelForWindow(m_window)) {
        return;
    }

    m_cutoutsWayland = new CutoutsWayland(m_cutoutsManager->get_cutouts(surface), this);
    connect(m_cutoutsWayland, &CutoutsWayland::cutoutsChanged, this, &CutoutsMargins::refreshGeometries);
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

    m_cutouts = m_cutoutsWayland ? m_cutoutsWayland->cutouts() : QList<QRectF>();

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

#include "cutoutmargins.moc"
#include "moc_cutoutmargins_p.cpp"
