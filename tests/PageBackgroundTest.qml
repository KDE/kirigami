/*
 *  SPDX-FileCopyrightText: 2026 Filip Fila
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

// Pages get their background from the style;
// The style and the app are free to use something that isn't a solid color
// Push different kinds of pages and check push and pop transitions
// To test qqc2-desktop-style use: qml6 --apptype widget PageBackgroundTest.qml

Kirigami.ApplicationWindow {
    id: root

    width: Kirigami.Units.gridUnit * 22
    height: Kirigami.Units.gridUnit * 30

    // NOTE: Only visible through the pages that have no background
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0; color: Kirigami.Theme.highlightColor }
            GradientStop { position: 1; color: Kirigami.Theme.backgroundColor }
        }
    }

    pageStack.initialPage: pageComponent

    Component {
        id: itemBackground

        // An Item rather than a Rectangle, so it has no color property
        Item {
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Kirigami.Theme.backgroundColor }
                    GradientStop { position: 1; color: Kirigami.Theme.positiveBackgroundColor }
                }
            }
        }
    }

    Component {
        id: pageComponent

        Kirigami.Page {
            id: page

            // 0: background from the style, 1: Item background, 2: no background
            property int mode: 0

            title: ["Background from the style", "Item background", "No background"][mode]

            Component.onCompleted: {
                if (mode === 1) {
                    background = itemBackground.createObject(page);
                } else if (mode === 2) {
                    background = null;
                }
            }

            Column {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Button {
                    text: "Push a page with the background from the style"
                    onClicked: root.pageStack.push(pageComponent, {mode: 0})
                }
                QQC2.Button {
                    text: "Push a page with an Item as background"
                    onClicked: root.pageStack.push(pageComponent, {mode: 1})
                }
                QQC2.Button {
                    text: "Push a page without background"
                    onClicked: root.pageStack.push(pageComponent, {mode: 2})
                }
                QQC2.Button {
                    text: "Push a layer with an Item as background"
                    onClicked: root.pageStack.layers.push(pageComponent, {mode: 1})
                }
                QQC2.Button {
                    text: "Pop"
                    // Popping the only page would leave the window empty
                    enabled: root.pageStack.layers.depth > 1 || root.pageStack.depth > 1
                    onClicked: {
                        if (root.pageStack.layers.depth > 1) {
                            root.pageStack.layers.pop();
                        } else {
                            root.pageStack.pop();
                        }
                    }
                }
            }
        }
    }
}
