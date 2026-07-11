/*
 *  SPDX-FileCopyrightText: 2026 James Graham <james.h.graham@protonmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami.controls as KirigamiControls
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import QtTest

TestCase {
    id: root

    name: "ActionListViewTest"
    visible: true
    when: windowShown

    width: 300
    height: 500

    Component {
        id: actionsListViewComponent
        KirigamiControls.ActionsListView {
            width: Platform.Units.gridUnit * 20
            height: 500

            actions: [
                KirigamiControls.Action {
                    icon.name: "checkmark"
                    text: qsTr("A normal action")
                    tooltip: qsTr("A normal action")
                },
                KirigamiControls.Action {
                    enabled: false
                    icon.name: "action-unavailable-symbolic"
                    text: qsTr("A disabled action")
                    tooltip: qsTr("A disabled action")
                },
                KirigamiControls.Action {
                    separator: true
                },
                KirigamiControls.Action {
                    checked: true
                    checkable: true
                    autoExclusive: true
                    text: qsTr("Radio 1", "The first radio button")
                    tooltip: qsTr("Radio 1")
                },
                KirigamiControls.Action {
                    checkable: true
                    autoExclusive: true
                    text: qsTr("Radio 2", "The second radio button")
                    tooltip: qsTr("Radio 2")
                },
                KirigamiControls.Action {
                    checkable: true
                    autoExclusive: true
                    text: qsTr("Radio 3", "The third radio button")
                    tooltip: qsTr("Radio 3")
                },
                KirigamiControls.Action {
                    checkable: true
                    text: qsTr("Check button", "An example checkable button")
                    tooltip: qsTr("Check button")
                },
                KirigamiControls.Action {
                    displayComponent: QQC2.Label {
                        leftPadding: Platform.Units.smallSpacing
                        rightPadding: Platform.Units.smallSpacing
                        text: qsTr("This is a custom displayComponent component from the action with a red background")
                        wrapMode: Text.Wrap
                        background: Rectangle {
                            color: "red"
                        }
                    }
                },
                KirigamiControls.Action {
                    separator: true
                },
                KirigamiControls.Action {
                    icon.name: "list-add"
                    text: qsTr("With Children", "I.e. an example where the item has child items")
                    tooltip: qsTr("With Children")
                    children: [
                        KirigamiControls.Action {
                            icon.name: "user"
                            text: qsTr("Child 1")
                            tooltip: qsTr("Child 1")
                        },
                        KirigamiControls.Action {
                            icon.name: "user"
                            text: qsTr("Child 2")
                            tooltip: qsTr("Child 2")
                        }
                    ]
                }
            ]
        }
    }

    function test_list() {
        const actionListView = createTemporaryObject(actionsListViewComponent, root);
        verify(actionListView);

        compare(actionListView.count, 10);
        for (var i = 0; i < actionListView.count; i++)  {
            compare(actionListView.itemAtIndex(i).modelData, actionListView.actions[i]);
        }

        // Make sure that the delegates all have the right types
        compare(actionListView.itemAtIndex(0).children[0].item instanceof QQC2.ItemDelegate, true);
        compare(actionListView.itemAtIndex(1).children[0].item instanceof QQC2.ItemDelegate, true);
        compare(actionListView.itemAtIndex(2).children[0].item instanceof QQC2.Control, true);
        compare(actionListView.itemAtIndex(2).children[0].item.contentItem instanceof Primitives.Separator, true);
        compare(actionListView.itemAtIndex(3).children[0].item instanceof QQC2.RadioDelegate, true);
        compare(actionListView.itemAtIndex(4).children[0].item instanceof QQC2.RadioDelegate, true);
        compare(actionListView.itemAtIndex(5).children[0].item instanceof QQC2.RadioDelegate, true);
        compare(actionListView.itemAtIndex(6).children[0].item instanceof QQC2.CheckDelegate, true);
        compare(actionListView.itemAtIndex(7).children[0].item instanceof QQC2.Label, true);
        compare(actionListView.itemAtIndex(8).children[0].item instanceof QQC2.Control, true);
        compare(actionListView.itemAtIndex(8).children[0].item.contentItem instanceof Primitives.Separator, true);
        compare(actionListView.itemAtIndex(9).children[0].item instanceof QQC2.ItemDelegate, true);

        // Check the children are created when the parent is clicked
        let childrenRepeater = undefined;
        for (var i = 0; i < actionListView.itemAtIndex(9).children.length; i++)  {
            if (actionListView.itemAtIndex(9).children[i] instanceof Repeater) {
                childrenRepeater = actionListView.itemAtIndex(9).children[i];
            }
        }
        mouseClick(actionListView.itemAtIndex(9).children[0], Qt.LeftButton);
        compare(childrenRepeater.count, 2);
    }
}
