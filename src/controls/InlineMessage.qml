/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT

KT.InlineMessage {
    id: root

    // a rectangle padded with anchors.margins is used to simulate a border
    leftPadding: bgFillRect.anchors.leftMargin + Platform.Units.smallSpacing
    topPadding: bgFillRect.anchors.topMargin + Platform.Units.smallSpacing
    rightPadding: bgFillRect.anchors.rightMargin + Platform.Units.smallSpacing
    bottomPadding: bgFillRect.anchors.bottomMargin + Platform.Units.smallSpacing

    background: Rectangle {
        id: bgBorderRect

        color: switch (root.type) {
            case KC.MessageType.Positive: return Platform.Theme.positiveTextColor;
            case KC.MessageType.Warning: return Platform.Theme.neutralTextColor;
            case KC.MessageType.Error: return Platform.Theme.negativeTextColor;
            default: return Platform.Theme.activeTextColor;
        }

        radius: root.position === KT.InlineMessage.Position.Inline ? Platform.Units.cornerRadius : 0

        Rectangle {
            id: bgFillRect

            anchors.fill: parent
            anchors {
                leftMargin: root.position === KT.InlineMessage.Position.Inline ? 1 : 0
                topMargin: root.position === KT.InlineMessage.Position.Header ? 0 : 1
                rightMargin: root.position === KT.InlineMessage.Position.Inline ? 1 : 0
                bottomMargin: root.position === KT.InlineMessage.Position.Footer ? 0 : 1
            }

            color: Platform.Theme.backgroundColor

            radius: bgBorderRect.radius * 0.60
        }

        Rectangle {
            anchors.fill: bgFillRect

            color: bgBorderRect.color

            opacity: 0.20

            radius: bgFillRect.radius
        }
    }
}
