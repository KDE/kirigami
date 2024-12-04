/*
 * SPDX-FileCopyrightText: 2024 Nathan Misner <nathan@infochunk.com>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_SMOOTHSCROLLWATCHER_H
#define KIRIGAMI_SMOOTHSCROLLWATCHER_H

#include <QObject>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
/*
 * This class reports on the status of the SmoothScroll DBus interface,
 * which sends a message when the smooth scroll setting gets changed.
 */
class KIRIGAMIPLATFORM_EXPORT SmoothScrollWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged FINAL)

public:
    SmoothScrollWatcher(QObject *parent = nullptr);
    ~SmoothScrollWatcher();

    bool enabled() const;

    static SmoothScrollWatcher *self();

Q_SIGNALS:
    void enabledChanged(bool value);

private:
    bool m_enabled;

private Q_SLOTS:
    void setEnabled(bool value);
};

}
}

#endif // KIRIGAMI_SMOOTHSCROLLWATCHER_H
