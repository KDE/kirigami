/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Material
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform

Rectangle {
    id: root

    required property T.AbstractButton control

    radius: height / 2
    color: control.checked ? Qt.alpha(control.Material.accent, control.enabled ? 0.16 : 0.08) : "transparent"

    Behavior on color {
        ColorAnimation { duration: Platform.Units.shortDuration }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Qt.alpha(root.control.Material.foreground,
            !root.control.enabled ? 0 : root.control.down || root.control.visualFocus ? 0.12 : root.control.hovered ? 0.08 : 0)
        border.width: root.control.visualFocus ? 2 : 0
        border.color: root.control.Material.accent

        Behavior on color {
            ColorAnimation { duration: Platform.Units.shortDuration }
        }
    }
}
