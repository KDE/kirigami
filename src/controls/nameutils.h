// SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
// SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
//
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QColor>
#include <QObject>
#include <QVariant>
#include <qqmlregistration.h>

/*!
 * \qmltype PagePool
 * \inqmlmodule org.kde.kirigami.controls
 *
 * \brief Some utilities for processing names.
 *
 * Given a string, typically a person name, this can extract
 * initials or assign a color for the name, useful for avatars.
 *
 * \sa Avatar
 */
class NameUtils : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    /*!
     * \qmlmethod string NameUtils::initialsFromString(string name)
     *
     * Extract suitable initials from a name, for instance the first letter
     * of the name plus the first letter of the surname
     */
    Q_INVOKABLE QString initialsFromString(const QString &name);

    /*!
     * \qmlmethod color NameUtils::colorsFromString(string name)
     *
     * Give a possible color for the string, use to have avatars of discernable colors
     */
    Q_INVOKABLE QColor colorsFromString(const QString &name);

    /*!
     * \qmlmethod bool NameUtils::isStringUnsuitableForInitials(string name)
     *
     * Returns true if the string is not suitablefor initials, such as if is in parts of Unicode
     * this class doesn't understand
     */
    Q_INVOKABLE bool isStringUnsuitableForInitials(const QString &name);
};
