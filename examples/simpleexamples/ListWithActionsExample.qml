/*
 *  SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    pageStack.initialPage: page

    ListModel {
        id: dragonModel
        ListElement {
            name: "Dragon Konqi"
            title: "A very cool dragon"
        }
        ListElement {
            name: "Dragon Kanqi"
            title: "A very fierce dragon"
        }
        ListElement {
            name: "Dragon Klinqli"
            title: "A very chill dragon"
        }
        ListElement {
            name: "Dragon Klynqi"
            title: "A very sleepy dragon"
        }
        ListElement {
            name: "Dragon Könqi"
            title: "A very hungry dragon"
        }
    }


    Component {
        id: page

        Kirigami.ScrollablePage {
            title: "Here Be Dragons"
            ListView {
                model: dragonModel
                anchors.fill: parent
                delegate: QQC2.ItemDelegate {
                    id: itemDelegate
                    Kirigami.Theme.useAlternateBackgroundColor: true
                    width: parent.width

                    contentItem: Kirigami.TitleSubtitleWithActions {
                        title: model.name
                        subtitle: model.title
                        elide: Text.ElideRight
                        selected: itemDelegate.pressed || itemDelegate.highlighted
                        actions: [
                            Kirigami.Action {
                                icon.name: "edit-entry-symbolic"
                                text: "Modify dragon…"
                                onTriggered: console.warn("Hi!")
                                tooltip: text
                            },
                            Kirigami.Action {
                                icon.name: "edit-delete-remove-symbolic"
                                text: "Remove dragon…"
                                onTriggered: console.warn("Bye!")
                                tooltip: text
                                displayHint: Kirigami.DisplayHint.IconOnly
                            }
                        ]
                    }
                }
            }
        }
    }
}
