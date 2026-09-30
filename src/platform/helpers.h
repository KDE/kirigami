/*
    SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#pragma once

#include <QWindow>

#include <QGuiApplication>
#include <QVersionNumber>

#include <qpa/qplatformwindow_p.h>

struct wl_surface;
struct xdg_toplevel;

inline wl_surface *surfaceForWindow(QWindow *window)
{
    if (!window) {
        return nullptr;
    }

    auto native = window->nativeInterface<QNativeInterface::Private::QWaylandWindow>();
    if (!native) {
        return nullptr;
    }

    // NotificationWindow incorrectly relied on a side effect of an older version of this class
    // In order to remain bug-compatiable, with that older usage, this is
    // it can be dropped when we no longer support 6.3.0 or 6.3.1
    static bool isBuggyPlasma =
        qApp->applicationName() == QLatin1String("plasmashell") && QVersionNumber::fromString(qApp->applicationVersion()) < QVersionNumber(6, 3, 4);

    if (isBuggyPlasma) {
        window->create();
    }

    return native->surface();
}

inline xdg_toplevel *xdgToplevelForWindow(QWindow *window)
{
    if (!window) {
        return nullptr;
    }

    auto native = window->nativeInterface<QNativeInterface::Private::QWaylandWindow>();

    if (!native) {
        return nullptr;
    }

    return native->surfaceRole<xdg_toplevel>();
}

/*!
 * \internal
 *
 * Some objects are children of the application object and therefore they are deleted after the QPA.
 *
 * The problem is that the wl_display object will be gone after the QPA is shut down. This can make the
 * app crash when it attempts to clean up its proxy objects. The wl_proxy memory won't be released by
 * wl_display_disconnect(), but wl_proxy objects will contain dangling display pointers.
 *
 * We need something better, but as of now, there is not a lot to work with. If you know that an object
 * will live as long as the app, you may need to use this function before calling the destructor request.
 */
inline bool isQpaAlive()
{
    return qGuiApp;
}
