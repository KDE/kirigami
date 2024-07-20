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

/*!
 * An inline message item with support for informational, positive,
 * warning and error types, and with support for associated actions.
 *
 * InlineMessage can be used to give information to the user or
 * interact with the user, without requiring the use of a dialog.
 *
 * The InlineMessage item is hidden by default. It also manages its
 * height (and implicitHeight) during an animated reveal when shown.
 * You should avoid setting height on an InlineMessage unless it is
 * already visible.
 *
 * Optionally an icon can be set, defaulting to an icon appropriate
 * to the message type otherwise.
 *
 * Optionally a close button can be shown.
 *
 * Actions are added from left to right. If more actions are set than
 * can fit, an overflow menu is provided.
 *
 * Example usage:
 * \code
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.InlineMessage {
 *     type: Kirigami.MessageType.Error
 *
 *     text: i18n("My error message")
 *
 *     actions: [
 *         Kirigami.Action {
 *             icon.name: "list-add"
 *             text: i18n("Add")
 *             onTriggered: source => {
 *                 // do stuff
 *             }
 *         },
 *         Kirigami.Action {
 *             icon.name: "edit"
 *             text: i18n("Edit")
 *             onTriggered: source => {
 *                 // do stuff
 *             }
 *         }
 *     ]
 * }
 * \endcode
 * @inherit org::kde::kirigami::templates::InlineMessage
 * @since 5.45
 */
KT.InlineMessage {
    id: root

    // a rectangle padded with anchors.margins is used to simulate a border
    leftPadding: bgFillRect.anchors.leftMargin + Kirigami.Units.smallSpacing
    topPadding: bgFillRect.anchors.topMargin + Kirigami.Units.smallSpacing
    rightPadding: bgFillRect.anchors.rightMargin + Kirigami.Units.smallSpacing
    bottomPadding: bgFillRect.anchors.bottomMargin + Kirigami.Units.smallSpacing

    background: Rectangle {
        id: bgBorderRect

        color: switch (root.type) {
            case Kirigami.MessageType.Positive: return Kirigami.Theme.positiveTextColor;
            case Kirigami.MessageType.Warning: return Kirigami.Theme.neutralTextColor;
            case Kirigami.MessageType.Error: return Kirigami.Theme.negativeTextColor;
            default: return Kirigami.Theme.activeTextColor;
        }

        radius: root.position === KT.InlineMessage.Position.Inline ? Kirigami.Units.cornerRadius : 0

        Rectangle {
            id: bgFillRect

            anchors.fill: parent
            anchors {
                leftMargin: root.position === KT.InlineMessage.Position.Inline ? 1 : 0
                topMargin: root.position === KT.InlineMessage.Position.Header ? 0 : 1
                rightMargin: root.position === KT.InlineMessage.Position.Inline ? 1 : 0
                bottomMargin: root.position === KT.InlineMessage.Position.Footer ? 0 : 1
            }

            color: Kirigami.Theme.backgroundColor

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
