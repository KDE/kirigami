/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef DISPLAYHINT_H
#define DISPLAYHINT_H

#include <QObject>
#include <QQmlEngine>

/*!
 * \qmltype DisplayHint
 * \inqmlmodule org.kde.kirigami.layouts
 *
 * \brief Hints for implementations using Actions indicating preferences about how to display the action.
 *
 * This is a singleton type.
 *
 * Possible hint values are:
 * \list
 * \li NoPreference: Indicates there is no specific preference.
 * \li IconOnly: Only display an icon for this Action
 * \li KeepVisible: Try to keep the action visible even when space constrained. Mutually exclusive with AlwaysHide, KeepVisible has priority.
 * \li AlwaysHide: If possible, hide the action in an overflow menu or similar location. Mutually exclusive with KeepVisible, KeepVisible has priority.
 * \li HideChildIndicator: When this action has children, do not display any indicator (like a menu arrow) for this action.
 * \endlist
 */
class DisplayHint : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    enum Hint : uint {
        NoPreference = 0,
        IconOnly = 1,
        KeepVisible = 2,
        AlwaysHide = 4,
        HideChildIndicator = 8,
    };
    Q_DECLARE_FLAGS(DisplayHints, Hint)
    Q_ENUM(Hint)
    Q_FLAG(DisplayHints)

    // Note: These functions are instance methods because they need to be
    // exposed to QML. Unfortunately static methods are not supported.

    /*!
     * \qmlmethod bool DisplayHint::displayHintSet(DisplayHints hints, Hint hint)
     *
     * Helper function to check if a certain display hint has been set.
     *
     * This function is mostly convenience to enforce certain behaviour of the
     * various display hints, primarily the mutual exclusivity of KeepVisible
     * and AlwaysHide.
     *
     * \a values The display hints to check.
     *
     * \a hint The display hint to check if it is set.
     *
     * Return \c true if the hint was set for this action, false if not.
     *
     * \since 2.14
     */
    Q_INVOKABLE bool displayHintSet(DisplayHints values, Hint hint);

    /*!
     * \qmlmethod bool DisplayHint::displayHintSet(QtObject hints, Hint hint)
     *
     * Check if a certain display hint has been set on an object.
     *
     * This overloads displayHintSet(DisplayHints, Hint) to accept a QObject
     * instance. This object is checked to see if it has a displayHint property
     * and if so, if that property has \a hint set.
     *
     * \a object The object to check.
     *
     * \a hint The hint to check for.
     *
     * Returns \c false if object is null, object has no displayHint property or
     *         the hint was not set. \c true if it has the property and the hint is
     *         set.
     */
    Q_INVOKABLE bool displayHintSet(QObject *object, Hint hint);

    /*!
     * Static version of displayHintSet(DisplayHints, Hint) that can be
     * called from C++ code.
     */
    static bool isDisplayHintSet(DisplayHints values, Hint hint);
};

Q_DECLARE_OPERATORS_FOR_FLAGS(DisplayHint::DisplayHints)

#endif // DISPLAYHINT_H
