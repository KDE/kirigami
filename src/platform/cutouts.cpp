/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "cutouts_p.h"
#include "helpers.h"

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

Cutouts *Cutouts::s_cutouts = nullptr;

class CutoutsManager : public QWaylandClientExtensionTemplate<CutoutsManager>, public QtWayland::xx_cutouts_manager_v1
{
    Q_OBJECT
public:
    CutoutsManager(QObject *parent = nullptr)
        : QWaylandClientExtensionTemplate<CutoutsManager>(1)
    {
        Q_UNUSED(parent)
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

Cutouts::Cutouts(QObject *parent)
    : QObject(parent)
    , m_cutoutsManager(new CutoutsManager(this))
{
    connect(m_cutoutsManager, &CutoutsManager::activeChanged, this, [this]() {
        for (auto w : m_cutoutsWayland.keys()) {
            setupCutouts(w);
        }
    });
}

Cutouts::~Cutouts() = default;

Cutouts *Cutouts::self()
{
    if (!s_cutouts) {
        s_cutouts = new Cutouts;
    }

    return s_cutouts;
}

QList<QRectF> Cutouts::cutouts(QWindow *window)
{
    if (!m_cutoutsWayland.value(window)) {
        return {};
    }
    return m_cutoutsWayland.value(window)->cutouts();
}

void Cutouts::registerWindow(QWindow *window)
{
    if (!window || m_cutoutsWayland.value(window)) {
        return;
    }

    window->installEventFilter(this);

    auto native = window->nativeInterface<QNativeInterface::Private::QWaylandWindow>();
    if (!native) {
        return;
    }

    m_cutoutsWayland[window] = nullptr;

    connect(native, &QNativeInterface::Private::QWaylandWindow::surfaceRoleCreated, this, [this, window]() {
        setupCutouts(window);
    });

    connect(native, &QNativeInterface::Private::QWaylandWindow::surfaceRoleDestroyed, this, [this, window]() {
        delete m_cutoutsWayland.value(window);
        m_cutoutsWayland[window] = nullptr;
        Q_EMIT cutoutsChanged(window, {});
    });

    connect(native, &QObject::destroyed, this, [this, window]() {
        delete m_cutoutsWayland.value(window);
        m_cutoutsWayland.remove(window);
        Q_EMIT cutoutsChanged(window, {});
    });

    // The role may have been created before we connected to the signal.
    setupCutouts(window);
}

void Cutouts::setupCutouts(QWindow *window)
{
    if (m_cutoutsWayland.value(window) != nullptr || !window || !m_cutoutsManager->isActive()) {
        return;
    }

    // The protocol requires the surface to have the xdg_toplevel role.
    wl_surface *surface = surfaceForWindow(window);
    if (!surface || !xdgToplevelForWindow(window)) {
        return;
    }

    m_cutoutsWayland[window] = new CutoutsWayland(m_cutoutsManager->get_cutouts(surface), this);
    connect(m_cutoutsWayland[window], &CutoutsWayland::cutoutsChanged, this, [this, window]() {
        Q_ASSERT(m_cutoutsWayland.contains(window));
        Q_EMIT cutoutsChanged(window, m_cutoutsWayland[window]->cutouts());
    });
}
/*
bool Cutouts::eventFilter(QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::PlatformSurface) {
        QPlatformSurfaceEvent *se = static_cast<QPlatformSurfaceEvent *>(event);
        if (se->surfaceEventType() == QPlatformSurfaceEvent::SurfaceCreated) {
            connectToNativeSurface();
        }
    }

    return QObject::eventFilter(watched, event);
}
*/

}
}

#include "cutouts.moc"
#include "moc_cutouts_p.cpp"
