/*
 * SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_VIRTUALKEYBOARDWATCHER
#define KIRIGAMI_VIRTUALKEYBOARDWATCHER

#include <memory>

#include <QObject>

#include "kirigami2_export.h"

namespace Kirigami
{
/**
 * @class VirtualKeyboardWatcher virtualkeyboardwatcher.h <Kirigami/VirtualKeyboardWatcher>
 *
 * This class reports on the status of KWin's VirtualKeyboard DBus interface.
 *
 * @since 5.91
 */
class KIRIGAMI2_EXPORT VirtualKeyboardWatcher : public QObject
{
    Q_OBJECT

public:
    VirtualKeyboardWatcher(QObject *parent = nullptr);
    ~VirtualKeyboardWatcher();

    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    bool available() const;
    Q_SIGNAL void availableChanged();

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    bool enabled() const;
    Q_SIGNAL void enabledChanged();

    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    bool active() const;
    Q_SIGNAL void activeChanged();

    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    bool visible() const;
    Q_SIGNAL void visibleChanged();

    Q_PROPERTY(bool willShowOnActive READ willShowOnActive NOTIFY willShowOnActiveChanged)
    bool willShowOnActive() const;
    Q_SIGNAL void willShowOnActiveChanged();

    static VirtualKeyboardWatcher *self();

private:
    class Private;
    const std::unique_ptr<Private> d;
};

}

#endif // KIRIGAMI_VIRTUALKEYBOARDWATCHER
