/* SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root

   pageStack.defaultColumnWidth: Kirigami.Units.gridUnit * 12

    Kirigami.Page {
        id: page1
        title: "Page 1"
    }
    Kirigami.Page {
        id: page2
        title: "Page 2"
    }
    Kirigami.Page {
        id: page3
        title: "Page 3"
    }
    Kirigami.Page {
        id: page4
        title: "Page 4"
        visible: false
    }

    Item {
        id: appStates
        states: [
            State {
                when: navTabBar.currentIndex === 0
                PropertyChanges {
                    target: root.pageStack
                    items: [page1,page2,page3]
                }
                PropertyChanges {
                    target: page1.Kirigami.ColumnView
                    fillWidth: false
                }
                PropertyChanges {
                    target: page2.Kirigami.ColumnView
                    fillWidth: true
                    reservedSpace: pageStack.defaultColumnWidth*2
                }
                PropertyChanges {
                    target: page3.Kirigami.ColumnView
                    fillWidth: false
                }
            },
            State {
                when: navTabBar.currentIndex === 1
                PropertyChanges {
                    target: root.pageStack
                    items: [page1,page3]
                }
                PropertyChanges {
                    target: page1.Kirigami.ColumnView
                    fillWidth: false
                }
                PropertyChanges {
                    target: page3.Kirigami.ColumnView
                    fillWidth: true
                    reservedSpace: page1.width
                }

            },
            State {
                when: navTabBar.currentIndex === 2
                PropertyChanges {
                    target: root.pageStack
                    items: [page3,page2]
                }
                PropertyChanges {
                    target: page2.Kirigami.ColumnView
                    fillWidth: false
                }
                PropertyChanges {
                    target: page2.Kirigami.ColumnView
                    fillWidth: true
                    reservedSpace: pageStack.defaultColumnWidth
                }
            },
            State {
                when: navTabBar.currentIndex === 3
                PropertyChanges {
                    target: root.pageStack
                    items: [page4,page1]
                }
                PropertyChanges {
                    target: page4.Kirigami.ColumnView
                    fillWidth: false
                }
                PropertyChanges {
                    target: page1.Kirigami.ColumnView
                    fillWidth: true
                    reservedSpace: pageStack.defaultColumnWidth
                }
            }
        ]
    }

    footer: Kirigami.NavigationTabBar {
        id: navTabBar

        currentIndex: 0

        actions: [
            Kirigami.Action {
                text: "State 1"
            },
            Kirigami.Action {
                text: "State2"
            },
            Kirigami.Action {
                text: "State3"
            },
            Kirigami.Action {
                text: "State4"
            }
        ]
    }
}
