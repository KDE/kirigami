/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *  SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "virtualkeyboardwatcher.h"

#ifdef KIRIGAMI_ENABLE_DBUS
#include "settings_interface.h"
#include <QDBusConnection>
#include <QDBusPendingCallWatcher>
#endif

#include "kirigamiplatform_logging.h"

using namespace Qt::Literals::StringLiterals;

namespace Kirigami
{
namespace Platform
{
Q_GLOBAL_STATIC(VirtualKeyboardWatcher, virtualKeyboardWatcherSelf)

class KIRIGAMIPLATFORM_NO_EXPORT VirtualKeyboardWatcher::Private
{
    static constexpr auto serviceName = "org.freedesktop.portal.Desktop"_L1;
    static constexpr auto objectName = "/org/freedesktop/portal/desktop"_L1;
    static constexpr auto interfaceName = "org.kde.kwin.VirtualKeyboard"_L1;

    static constexpr auto GROUP = "org.kde.VirtualKeyboard"_L1;
    static constexpr auto KEY_AVAILABLE = "available"_L1;
    static constexpr auto KEY_ENABLED = "enabled"_L1;
    static constexpr auto KEY_ACTIVE = "active"_L1;
    static constexpr auto KEY_VISIBLE = "visible"_L1;
    static constexpr auto KEY_WILL_SHOW_ON_ACTIVE = "willShowOnActive"_L1;

public:
    Private(VirtualKeyboardWatcher *qq)
        : q(qq)
    {
#ifdef KIRIGAMI_ENABLE_DBUS
        qDBusRegisterMetaType<VariantMapMap>();
        settingsInterface = new OrgFreedesktopPortalSettingsInterface(serviceName, objectName, QDBusConnection::sessionBus(), q);

        QObject::connect(settingsInterface,
                         &OrgFreedesktopPortalSettingsInterface::SettingChanged,
                         q,
                         [this](const QString &group, const QString &key, const QDBusVariant &value) {
                             if (group != GROUP) {
                                 return;
                             }

                             if (key == KEY_AVAILABLE) {
                                 available = value.variant().toBool();
                                 Q_EMIT q->availableChanged();
                             } else if (key == KEY_ENABLED) {
                                 enabled = value.variant().toBool();
                                 Q_EMIT q->enabledChanged();
                             } else if (key == KEY_ACTIVE) {
                                 active = value.variant().toBool();
                                 Q_EMIT q->activeChanged();
                             } else if (key == KEY_VISIBLE) {
                                 visible = value.variant().toBool();
                                 Q_EMIT q->visibleChanged();
                             } else if (key == KEY_WILL_SHOW_ON_ACTIVE) {
                                 willShowOnActive = value.variant().toBool();
                             }
                         });

        getAllProperties();
#endif
    }

    VirtualKeyboardWatcher *q;

#ifdef KIRIGAMI_ENABLE_DBUS
    void getAllProperties();
    void updateWillShowOnActive();

    OrgFreedesktopPortalSettingsInterface *settingsInterface = nullptr;

    QDBusPendingCallWatcher *willShowOnActiveCall = nullptr;
#endif

    bool available = false;
    bool enabled = false;
    bool active = false;
    bool visible = false;
    bool willShowOnActive = false;
};

VirtualKeyboardWatcher::VirtualKeyboardWatcher(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<Private>(this))
{
}

VirtualKeyboardWatcher::~VirtualKeyboardWatcher() = default;

bool VirtualKeyboardWatcher::available() const
{
    return d->available;
}

bool VirtualKeyboardWatcher::enabled() const
{
    return d->enabled;
}

bool VirtualKeyboardWatcher::active() const
{
    return d->active;
}

bool VirtualKeyboardWatcher::visible() const
{
    return d->visible;
}

bool VirtualKeyboardWatcher::willShowOnActive() const
{
#ifdef KIRIGAMI_ENABLE_DBUS
    d->updateWillShowOnActive();
#endif
    return d->willShowOnActive;
}

VirtualKeyboardWatcher *VirtualKeyboardWatcher::self()
{
    return virtualKeyboardWatcherSelf();
}

#ifdef KIRIGAMI_ENABLE_DBUS

void VirtualKeyboardWatcher::Private::updateWillShowOnActive()
{
    if (willShowOnActiveCall) {
        return;
    }

    willShowOnActiveCall = new QDBusPendingCallWatcher(settingsInterface->Read(GROUP, KEY_WILL_SHOW_ON_ACTIVE), q);
    connect(willShowOnActiveCall, &QDBusPendingCallWatcher::finished, q, [this](auto call) {
        QDBusPendingReply<QVariant> reply = *call;
        if (reply.isError()) {
            qCDebug(KirigamiPlatform) << reply.error().message();
        } else {
            if (reply.value().value<QDBusVariant>().variant().toBool() != willShowOnActive) {
                willShowOnActive = reply.value().value<QDBusVariant>().variant().toBool();
                Q_EMIT q->willShowOnActiveChanged();
            }
        }
        call->deleteLater();
        willShowOnActiveCall = nullptr;
    });
}

void VirtualKeyboardWatcher::Private::getAllProperties()
{
    auto call = new QDBusPendingCallWatcher(settingsInterface->ReadAll({GROUP}), q);
    connect(call, &QDBusPendingCallWatcher::finished, q, [this](auto call) {
        QDBusPendingReply<VariantMapMap> reply = *call;
        if (reply.isError()) {
            qCDebug(KirigamiPlatform) << reply.error().message();
        } else {
            const auto groupValues = reply.value().value(GROUP);
            available = groupValues.value(KEY_AVAILABLE).toBool();
            enabled = groupValues.value(KEY_ENABLED).toBool();
            active = groupValues.value(KEY_ACTIVE).toBool();
            visible = groupValues.value(KEY_VISIBLE).toBool();
            willShowOnActive = groupValues.value(KEY_WILL_SHOW_ON_ACTIVE).toBool();
        }
        call->deleteLater();

        Q_EMIT q->availableChanged();
        Q_EMIT q->enabledChanged();
        Q_EMIT q->activeChanged();
        Q_EMIT q->visibleChanged();
        Q_EMIT q->willShowOnActiveChanged();
    });
}

#endif

}
}

#include "moc_virtualkeyboardwatcher.cpp"
