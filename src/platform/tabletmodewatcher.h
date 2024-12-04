/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_TABLETMODEWATCHER_H
#define KIRIGAMI_TABLETMODEWATCHER_H

#include <QEvent>
#include <QObject>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
class TabletModeWatcherPrivate;

/*!
 * \class Kirigami::Platform::TabletModeChangedEvent
 * \inmodule KirigamiPlatform
 * \inheaderfile Kirigami/Platform/TabletModeWatcher
 *
 * \brief Event sent by TabletModeWatcher when the tablet mode changes.
 *
 * \sa TabletModeWatcher
 */
class KIRIGAMIPLATFORM_EXPORT TabletModeChangedEvent : public QEvent
{
public:
    TabletModeChangedEvent(bool tablet)
        : QEvent(TabletModeChangedEvent::type)
        , tabletMode(tablet)
    {
    }

    bool tabletMode = false;

    inline static QEvent::Type type = QEvent::None;
};

/*!
 * \class Kirigami::Platform::TabletModeWatcher
 * \inmodule KirigamiPlatform
 * \inheaderfile Kirigami/Platform/TabletModeWatcher
 *
 * \brief This class reports on the status of certain transformable
 * devices which can be both tablets and laptops at the same time,
 * with a detachable keyboard.
 *
 * It reports whether the device supports a tablet mode and if
 * the device is currently in such mode or not, emitting a signal
 * when the user switches.
 */
class KIRIGAMIPLATFORM_EXPORT TabletModeWatcher : public QObject
{
    Q_OBJECT

    /*!
     * \property Kirigami::Platform::TabletModeWatcher::tabletModeAvailable
     *
     * \c true if the device supports a tablet mode and has a switch
     * to report when the device has been transformed.
     *
     * For debug purposes, if either the environment variable QT_QUICK_CONTROLS_MOBILE
     * or KDE_KIRIGAMI_TABLET_MODE are set to true, tabletModeAvailable will be true
     */
    Q_PROPERTY(bool tabletModeAvailable READ isTabletModeAvailable NOTIFY tabletModeAvailableChanged FINAL)

    /*!
     * \property Kirigami::Platform::TabletModeWatcher::tabletMode
     *
     * \c true if the machine is now in tablet mode, such as the
     * laptop keyboard flipped away or detached.
     *
     * Note that this doesn't mean exactly a tablet form factor, but
     * that the preferred input mode for the device is the touch screen
     * and that pointer and keyboard are either secondary or not available.
     *
     * For debug purposes, if either the environment variable QT_QUICK_CONTROLS_MOBILE
     * or KDE_KIRIGAMI_TABLET_MODE are set to true, tabletMode will be true
     */
    Q_PROPERTY(bool tabletMode READ isTabletMode NOTIFY tabletModeChanged FINAL)

public:
    ~TabletModeWatcher() override;
    static TabletModeWatcher *self();

    bool isTabletModeAvailable() const;

    bool isTabletMode() const;

    /*!
     * Register an arbitrary QObject to send events from this.
     * At the moment only one event will be sent: TabletModeChangedEvent
     */
    void addWatcher(QObject *watcher);

    /*!
     * Unsubscribe watcher from receiving events from TabletModeWatcher.
     */
    void removeWatcher(QObject *watcher);

Q_SIGNALS:
    void tabletModeAvailableChanged(bool tabletModeAvailable);
    void tabletModeChanged(bool tabletMode);

private:
    KIRIGAMIPLATFORM_NO_EXPORT explicit TabletModeWatcher(QObject *parent = nullptr);
    TabletModeWatcherPrivate *d;
    friend class TabletModeWatcherSingleton;
};

}
}

#endif // KIRIGAMI_TABLETMODEWATCHER
