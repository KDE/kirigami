/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 700
    height: 600

    Kirigami.FormLayout {
        anchors.fill: parent

        Item {
            Kirigami.FormData.label: "Number badges"
            Kirigami.FormData.isSection: true
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Short number badge:"
            text: "1"
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Medium number badge:"
            text: "25"
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Large number badge:"
            text: "999"
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Very large number badge:"
            text: "99,999"
        }

        Item {
            Kirigami.FormData.label: "Primarily text badges"
            Kirigami.FormData.isSection: true
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Default background and text color:"
            text: "New!"
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Super compact version with custom background color:"
            text: "Integrated GPU"
            padding: 0
            backgroundColor: Kirigami.Theme.visitedLinkBackgroundColor
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Icon + label with custom background color:"
            icon.name: "lock"
            text: "Encrypted for your convenience"
            backgroundColor: Kirigami.Theme.positiveBackgroundColor
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Icon + label with custom background and text color:"
            text: "Favorite"
            icon.name: "favorite-favorited-symbolic"
            backgroundColor: Kirigami.Theme.visitedLinkColor
            textColor: Kirigami.Theme.highlightedTextColor
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Awkwardly long string, bounded length:"
            Layout.maximumWidth: 150
            text: "Your computer is about to explode; please calmly proceed to the nearest exit"
            backgroundColor: Kirigami.Theme.negativeBackgroundColor
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Icon + awkwardly long string, bounded length:"
            Layout.maximumWidth: 150
            icon.name: "edit-bomb"
            text: "Your computer is about to explode; please calmly proceed to the nearest exit"
            backgroundColor: Kirigami.Theme.negativeBackgroundColor
        }

        Item {
            Kirigami.FormData.label: "Icons-only badges"
            Kirigami.FormData.isSection: true
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Symbolic icon, should be tinted with background color:"
            icon.name: "edit-bomb-symbolic"
            backgroundColor: Kirigami.Theme.negativeBackgroundColor
        }
        Kirigami.Badge {
            Kirigami.FormData.label: "Non-symbolic icon, should look colorful:"
            icon.name: "kde"
            backgroundColor: Kirigami.Theme.activeBackgroundColor
        }
    }
}
