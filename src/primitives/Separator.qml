/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick

import org.kde.kirigami.platform as Platform

/**
 * @brief A visual separator.
 *
 * Useful for splitting one set of items from another.
 *
 * @inherit QtQuick.Rectangle
 */
Rectangle {
    id: root
    implicitHeight: 1
    implicitWidth: 1
    Accessible.role: Accessible.Separator
    Accessible.focusable: false

    enum Weight {
        Light,
        Normal
    }

    /**
     * @brief This property holds the visual weight of the separator.
     *
     * Weight options:
     * * ``Kirigami.Separator.Weight.Light``
     * * ``Kirigami.Separator.Weight.Normal``
     *
     * default: ``Kirigami.Separator.Weight.Normal``
     *
     * @since 5.72
     * @since org.kde.kirigami 2.12
     */
    property int weight: Separator.Weight.Normal

    /* TODO: If we get a separator color role, change this to
     * mix weights lower than Normal with the background color
     * and mix weights higher than Normal with the text color.
     */
    color: Platform.ColorUtils.linearInterpolation(
        Platform.Theme.backgroundColor,
        Platform.Theme.textColor,
        weight === Separator.Weight.Light ? Platform.Theme.lightFrameContrast : Platform.Theme.frameContrast
    )
    antialiasing: true
}
