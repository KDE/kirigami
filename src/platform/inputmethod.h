/*
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef INPUTMETHOD_H
#define INPUTMETHOD_H

#include <memory>

#include <QObject>
#include <qqmlregistration.h>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{

/*!
 * \qmltype InputMethod
 * \inqmlmodule org.kde.kirigami.platform
 *
 * \brief This exposes information about the current used input method.
 */
class KIRIGAMIPLATFORM_EXPORT InputMethod : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    InputMethod(QObject *parent = nullptr);
    ~InputMethod() override;

    /*!
     * \qmlproperty bool InputMethod::available
     *
     * \readonly
     *
     * Is an input method available?
     *
     * This will be true if there is an input method available. When it is
     * false it means there's no special input method configured and input
     * happens directly through keyboard events.
     */
    Q_PROPERTY(bool available READ available NOTIFY availableChanged FINAL)
    bool available() const;
    Q_SIGNAL void availableChanged();

    /*!
     * \qmlproperty bool InputMethod::enabled
     *
     * \readonly
     *
     * Is the current input method enabled?
     *
     * If this is false, that means the input method is available but not in use.
     */
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged FINAL)
    bool enabled() const;
    Q_SIGNAL void enabledChanged();

    /*!
     * \qmlproperty bool InputMethod::active
     *
     * \readonly
     *
     * Is the current input method active?
     *
     * What active means depends on the type of input method. In case of a
     * virtual keyboard for example, it would mean the virtual keyboard is
     * visible.
     */
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
    bool active() const;
    Q_SIGNAL void activeChanged();

    /*!
     * \qmlproperty bool InputMethod::visible
     *
     * \readonly
     *
     * Is the current input method visible?
     *
     * For some input methods this will match active however for others this
     * may differ.
     */
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged FINAL)
    bool visible() const;
    Q_SIGNAL void visibleChanged();

    /*!
     * \qmlproperty bool InputMethod::willShowOnActive
     *
     * \readonly
     *
     * Will the input method be shown when a text input field gains focus?
     *
     * This is intended to be used to decide whether to give an input field
     * default focus. For certain input methods, like virtual keyboards, it may
     * not be desirable to show it by default. For example, having a search
     * field focused on application startup may cause the virtual keyboard to
     * show, greatly reducing the available application space.
     */
    Q_PROPERTY(bool willShowOnActive READ willShowOnActive NOTIFY willShowOnActiveChanged FINAL)
    bool willShowOnActive() const;
    Q_SIGNAL void willShowOnActiveChanged();

private:
    class Private;
    const std::unique_ptr<Private> d;
};

}
}

#endif // INPUTMETHOD_H
