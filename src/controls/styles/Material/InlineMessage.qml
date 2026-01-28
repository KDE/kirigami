/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT

KT.InlineMessage {
    id: root

    // a rectangle padded with anchors.margins is used to simulate a border
    padding: bgFillRect.anchors.margins + Kirigami.Units.smallSpacing

    background: Kirigami.ShadowedRectangle {
        id: bgBorderRect

        color: switch (root.type) {
            case Kirigami.MessageType.Positive: return Kirigami.Theme.positiveTextColor;
            case Kirigami.MessageType.Warning: return Kirigami.Theme.neutralTextColor;
            case Kirigami.MessageType.Error: return Kirigami.Theme.negativeTextColor;
            default: return Kirigami.Theme.activeTextColor;
        }

        radius: Kirigami.Units.cornerRadius
        shadow.size: 12
        shadow.xOffset: 0
        shadow.yOffset: 1
        shadow.color: Qt.rgba(0, 0, 0, 0.5)

        Rectangle {
            id: bgFillRect

            anchors.fill: parent
            anchors.margins: 1

            color: Kirigami.Theme.backgroundColor

            radius: bgBorderRect.radius
        }

        Rectangle {
            anchors.fill: bgFillRect

            color: bgBorderRect.color

            opacity: 0.20

            radius: bgFillRect.radius
        }
    }
}
