/*
 * SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_VIRTUALKEYBOARDWATCHER_H
#define KIRIGAMI_VIRTUALKEYBOARDWATCHER_H

#include <memory>

#include <QObject>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
/*!
 * @class VirtualKeyboardWatcher virtualkeyboardwatcher.h <Kirigami/VirtualKeyboardWatcher>
 *
 * This class reports on the status of KWin's VirtualKeyboard DBus interface.
 *
 * @since 5.91
 */
class KIRIGAMIPLATFORM_EXPORT VirtualKeyboardWatcher : public QObject
{
    Q_OBJECT

public:
    VirtualKeyboardWatcher(QObject *parent = nullptr);
    ~VirtualKeyboardWatcher();

    Q_PROPERTY(bool available READ available NOTIFY availableChanged FINAL)
    bool available() const;
    Q_SIGNAL void availableChanged();

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged FINAL)
    bool enabled() const;
    Q_SIGNAL void enabledChanged();

    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
    bool active() const;
    Q_SIGNAL void activeChanged();

    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged FINAL)
    bool visible() const;
    Q_SIGNAL void visibleChanged();

    Q_PROPERTY(bool willShowOnActive READ willShowOnActive NOTIFY willShowOnActiveChanged FINAL)
    bool willShowOnActive() const;
    Q_SIGNAL void willShowOnActiveChanged();

    static VirtualKeyboardWatcher *self();

private:
    class Private;
    const std::unique_ptr<Private> d;
};

}
}

#endif // KIRIGAMI_VIRTUALKEYBOARDWATCHER
