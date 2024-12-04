/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/*!
 * This example show how to do a sidebar of an application what gets covered by new layers that might get pushed
 * in the PageRow layer system.
 * When a drawer is in sidebar mode, when it goes modal (for instance when on mobile) will still behave like a drawer
 */
Kirigami.ApplicationWindow {
    id: root

    Kirigami.GlobalDrawer {
        id: drawer
        modal: false

        actions: [
            Kirigami.Action {
                text: "Push Layer"
                onTriggered: root.pageStack.layers.push(layerComponent)
            },
            Kirigami.Action {
                text: "Modal"
                checked: drawer.modal
                checkable: true
                onTriggered: drawer.modal = checked
            }
        ]
    }
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: mainPageComponent
    pageStack.leftSidebar: drawer

    Component {
        id: mainPageComponent
        Kirigami.ScrollablePage {
            title: "Hello"
            QQC2.Pane {
                anchors.fill: parent
                QQC2.Label {
                    text: "Main page: push a layer to cover both this and the sidebar"
                }
            }
        }
    }
    Component {
        id: layerComponent
        Kirigami.ScrollablePage {
            title: "Layer 1"
            QQC2.Pane {
                anchors.fill: parent
                QQC2.Label {
                    text: "Layer page: this should cover the whole window: main page and sidebar"
                }
            }
        }
    }
}
