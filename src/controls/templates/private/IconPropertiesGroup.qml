/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml

/**
 * \brief Group of icon properties.
 *
 * This is a subset of those used in QQC2, Kirigami.Action still needs the full one as needs 100% api compatibility
 */
QtObject {
    /**
     * \brief This property holds icon name.
     *
     * The icon will be loaded from the platform theme. If the icon is found
     * in the theme, it will always be used; even if icon.source is also set.
     * If the icon is not found, icon.source will be used instead.
     */
    property string name

    /**
     * \brief This property holds the icon source.
     *
     * The icon will be loaded as a regular image.
     *
     * \sa QtQuick.Image::source
     */
    property var source

    /**
     * \brief This property holds the icon tint color.
     *
     * The icon is tinted with the specified color, unless the color is set to "transparent".
     */
    property color color: Qt.rgba(0, 0, 0, 0)

    /**
     * This property holds the width of the icon.
     */
    property real width

    /**
     * This property holds the height of the icon.
     */
    property real height

    /**
     * Bind this icon to all matching properties of a Controls icon group.
     *
     * This function automatically binds all properties to matching properties
     * of a controls icon group, since we cannot just reuse the Controls icon
     * group.
     *
     * To use it, you can assign the result to an IconPropertiesGroup, like so:
     * `icon: icon.fromControlsIcon(control.icon)`.
     */
    function fromControlsIcon(icon) {
        name = Qt.binding(() => icon.name)
        source = Qt.binding(() => icon.source)
        color = Qt.binding(() => icon.color)
        width = Qt.binding(() => icon.width)
        height = Qt.binding(() => icon.height)
        return this
    }
}
