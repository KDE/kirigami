/*
 *  SPDX-FileCopyrightText: 2022 Connor Carney <hello@connorcarney.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    id: testCase
    name: "FormLayout"

    width: 400
    height: 400
    visible: true

    when: windowShown

    Component {
        id: fractionalSizeRoundingComponent
        Window {
            property var item: fractionalSizeItem
            width: 600
            height: 400
            Kirigami.FormLayout {
                anchors.fill: parent
                Item {
                    id: fractionalSizeItem
                    implicitWidth: 160.375
                    implicitHeight: 17.001
                    Layout.fillWidth: true
                }
            }
        }
    }

    function test_fractional_width_rounding() {
        let window = createTemporaryObject(fractionalSizeRoundingComponent);
        let item = window.item;
        window.show();
        tryVerify(() => {return item.width >= item.implicitWidth}, 1000, "implicit width should not be rounded down");
        fuzzyCompare(item.width, item.implicitWidth, 1);

        window.close();
    }

    function test_fractional_height_rounding() {
        let window = createTemporaryObject(fractionalSizeRoundingComponent);
        let item = window.item;
        window.show();

        verify(item.height >= item.implicitHeight, "implicit height should not be rounded down");
        fuzzyCompare(item.height, item.implicitHeight, 1);

        window.close();
    }


    Component {
        id: dynamicBuddyFormComponent

        Kirigami.FormLayout {
            id: form

            readonly property string labelText: "You found me!"
            readonly property alias buddyColumn: buddyColumn
            readonly property alias target1: target1
            readonly property alias target2: target2
            readonly property alias target3: target3

            wideMode: true

            ColumnLayout {
                id: buddyColumn

                spacing: 0

                Kirigami.FormData.label: form.labelText

                Rectangle {
                    id: target1
                    implicitWidth: 100
                    implicitHeight: 100
                    color: "red"
                }
                Rectangle {
                    id: target2
                    implicitWidth: 100
                    implicitHeight: 100
                    color: "green"
                    Rectangle {
                        id: target3
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        implicitWidth: 100
                        implicitHeight: 100
                        color: "blue"
                    }
                }
            }
        }
    }

    function findChildLabel(parent: Item, text: string): Text {
        for (let i = 0; i < parent.children.length; i++) {
            const child = parent.children[i];
            if ((child instanceof Text) && (child.text === text)) {
                return child;
            } else {
                const label = findChildLabel(child, text);
                if (label !== null) {
                    return label;
                }
            }
        }
        return null;
    }

    function getYOffsetOfLabel(form: Kirigami.FormLayout, label: Item): real {
        return label.mapToItem(form, 0, 0).y;
    }

    function test_dynamicBuddyFor() {
        const form = createTemporaryObject(dynamicBuddyFormComponent, this);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);

        const label = findChildLabel(form, form.labelText);
        verify(label);

        form.buddyColumn.Kirigami.FormData.buddyFor = form.target1;
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.target1);
        wait(100); // Unfortunately, this is needed due to async timer-based updates of FormLayout
        const offset1 = getYOffsetOfLabel(form, label);

        form.buddyColumn.Kirigami.FormData.buddyFor = form.target2;
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.target2);
        wait(100);
        const offset2 = getYOffsetOfLabel(form, label);

        verify(offset1 < offset2);
    }

    function test_nestedBuddyNotSupported() {
        const form = createTemporaryObject(dynamicBuddyFormComponent, this);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);

        ignoreWarning(/FormData.buddyFor must be a direct child of the attachee.*/);
        form.buddyColumn.Kirigami.FormData.buddyFor = form.target3;
        // shouldn't change
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);
    }

    SignalSpy {
        id: buddyChangeSpy
        signalName: "buddyForChanged"
    }

    Component {
        id: buddyRepeaterFormComponent

        Kirigami.FormLayout {
            id: form

            readonly property string labelText: "You found me!"
            readonly property alias buddyColumn: buddyColumn
            property alias repeaterModel: repeater.model
            property Item buddyCreatedByRepeater

            wideMode: true

            ColumnLayout {
                id: buddyColumn

                spacing: 0

                Kirigami.FormData.label: form.labelText

                Repeater {
                    id: repeater

                    model: 0

                    Rectangle {
                        implicitWidth: 100
                        implicitHeight: 100
                        color: "red"
                    }

                    onItemAdded: (index, item) => {
                        form.buddyCreatedByRepeater = item;
                        buddyColumn.Kirigami.FormData.buddyFor = item;
                    }
                }
            }
        }
    }

    function test_buddyCreatedAndDestroyedByRepeater() {
        // The point is to test automatic destruction as done by a Repeater

        const form = createTemporaryObject(buddyRepeaterFormComponent, this);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);

        buddyChangeSpy.target = form.buddyColumn.Kirigami.FormData;
        buddyChangeSpy.clear();
        verify(buddyChangeSpy.valid);

        form.repeaterModel = 1;

        verify(form.buddyCreatedByRepeater);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyCreatedByRepeater);
        compare(buddyChangeSpy.count, 1);

        form.repeaterModel = 0;
        wait(100); // Give Repeater some time to react to model changes.

        verify(!form.buddyCreatedByRepeater);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);
        compare(buddyChangeSpy.count, 2);
    }

    Component {
        id: buddyComponentFormComponent

        Kirigami.FormLayout {
            id: form

            readonly property string labelText: "You found me!"
            readonly property alias buddyColumn: buddyColumn

            function addBuddyFromComponent(component: Component): Item {
                const buddy = component.createObject(buddyColumn);
                buddyColumn.Kirigami.FormData.buddyFor = buddy;
                return buddy;
            }

            wideMode: true

            ColumnLayout {
                id: buddyColumn

                spacing: 0

                Kirigami.FormData.label: form.labelText
            }
        }
    }

    Component {
        id: buddyComponent

        Rectangle {
            implicitWidth: 100
            implicitHeight: 100
            color: "red"
        }
    }

    function test_buddyCreatedAndDestroyedByComponent() {
        // The point is to test manual destruction as done by calling destroy()

        const form = createTemporaryObject(buddyComponentFormComponent, this);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);

        buddyChangeSpy.target = form.buddyColumn.Kirigami.FormData;
        buddyChangeSpy.clear();
        verify(buddyChangeSpy.valid);

        const buddy = form.addBuddyFromComponent(buddyComponent);
        verify(buddy);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, buddy);
        compare(buddyChangeSpy.count, 1);

        wait(100);

        buddy.destroy();

        wait(100);

        // should revert back to parent
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);
        compare(buddyChangeSpy.count, 2);
    }

    Component {
        id: enabledTestFormLayoutComponent

        Kirigami.FormLayout {
            property alias normalItem: normalItem
            property alias buddyRow: buddyRow
            property alias buddyItem: buddyItem

            // Normal case, direct item
            Item {
                id: normalItem
                Kirigami.FormData.label: "Normal case"
            }

            RowLayout {
                id: buddyRow
                Kirigami.FormData.label: "Buddy case"
                Kirigami.FormData.buddyFor: buddyItem

                Item {
                    id: buddyItem
                }
            }
        }
    }

    function test_enabledPropagation() {
        const form = createTemporaryObject(enabledTestFormLayoutComponent, this);

        const normalLabel = findChildLabel(form, "Normal case");
        verify(normalLabel.enabled);

        form.normalItem.enabled = false;
        verify(!normalLabel.enabled);

        const buddyLabel = findChildLabel(form, "Buddy case");
        verify(buddyLabel.enabled);

        form.buddyItem.enabled = false;
        verify(!buddyLabel.enabled);

        // Unset buddy, should be enabled again.
        form.buddyRow.Kirigami.FormData.buddyFor = null;
        verify(buddyLabel.enabled);
    }
}
