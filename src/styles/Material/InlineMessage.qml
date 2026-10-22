/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Kai Uwe Broulik <kde@privat.broulik.de>
 *  SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Material
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT

KT.InlineMessage {
    id: root

    readonly property int _severityColor: {
        switch (type) {
        case KC.MessageType.Positive:
            return Material.Green;
        case KC.MessageType.Warning:
            return Material.Orange;
        case KC.MessageType.Error:
            return Material.Red;
        default:
            return Material.LightBlue;
        }
    }
    readonly property bool _dark: Material.theme === Material.Dark
    readonly property color _iconColor: Material.color(_severityColor, _dark ? Material.Shade200 : Material.Shade700)

    leftInset: Platform.Units.largeSpacing
    rightInset: Platform.Units.largeSpacing
    leftPadding: leftInset + Platform.Units.largeSpacing
    rightPadding: rightInset + Platform.Units.largeSpacing
    verticalPadding: Platform.Units.smallSpacing * 2

    Platform.Theme.inherit: false
    Platform.Theme.textColor: Material.color(_severityColor, _dark ? Material.Shade100 : Material.Shade900)
    icon.color: _iconColor

    background: Rectangle {
        border.width: 0
        color: Qt.tint(root.Material.background, Qt.alpha(root._iconColor, 0.12))
        radius: Platform.Units.cornerRadius
    }
}
