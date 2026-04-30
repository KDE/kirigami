/*
 *  SPDX-FileCopyrightText: 2022 Connor Carney <hello@connorcarney.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    id: testCase
    name: "Forms"

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
            Kirigami.Form {
                anchors.fill: parent
                Kirigami.FormGroup {
                    Kirigami.FormEntry {
                        contentItem: Item {
                            id: fractionalSizeItem
                            Layout.minimumWidth: 160.375
                            implicitHeight: 17.001
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: multipleElementsComponent
        Window {
            id: rootWindow
            property var item: formLayout
            property var expectedMinimumSize: 200
            width: 600
            height: 400
            Kirigami.Form {
                id: formLayout
                anchors.fill: parent
                Kirigami.FormGroup {
                    Repeater {
                        model: 200
                        Kirigami.FormEntry {
                            contentItem: Item {
                                implicitWidth: rootWindow.expectedMinimumSize
                                implicitHeight: 20
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    function test_quick_relayout() {
        let window = createTemporaryObject(multipleElementsComponent);
        let item = window.item;
        window.show();

        verify(item.implicitWidth >= window.expectedMinimumSize, "implicit width of layout should match the implicit width of the elements within upon component creation");

        window.close();
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

        Kirigami.Form {
            id: form

            readonly property string labelText: "You found me!"
            readonly property alias buddyColumn: buddyColumn
            readonly property alias target1: target1
            readonly property alias target2: target2
            readonly property alias target3: target3

            Kirigami.FormGroup {
                Kirigami.FormEntry {
                    title: form.labelText
                    contentItem: ColumnLayout {
                        id: buddyColumn

                        spacing: 0

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

    function getYOffsetOfLabel(form: Kirigami.Form, label: Item): real {
        return label.mapToItem(form, 0, 0).y;
    }

    function test_dynamicBuddyFor() {
        const form = createTemporaryObject(dynamicBuddyFormComponent, this);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);

        const label = findChildLabel(form, form.labelText);
        verify(label);

        form.buddyColumn.Kirigami.FormData.buddyFor = form.target1;
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.target1);
        waitForRendering(form)
        const offset1 = getYOffsetOfLabel(form, label);

        form.buddyColumn.Kirigami.FormData.buddyFor = form.target2;
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.target2);
        waitForRendering(form)
        const offset2 = getYOffsetOfLabel(form, label);

        verify(offset1 < offset2);
    }

    SignalSpy {
        id: buddyChangeSpy
        signalName: "buddyForChanged"
    }

    Component {
        id: buddyRepeaterFormComponent

        Kirigami.Form {
            id: form

            readonly property string labelText: "You found me!"
            readonly property alias buddyColumn: buddyColumn
            property alias repeaterModel: repeater.model
            property Item buddyCreatedByRepeater

            Kirigami.FormGroup {
                Kirigami.FormEntry {
                    contentItem: ColumnLayout {
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
        waitForRendering(form)

        verify(!form.buddyCreatedByRepeater);
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);
        compare(buddyChangeSpy.count, 2);
    }

    Component {
        id: buddyComponentFormComponent

        Kirigami.Form {
            id: form

            readonly property string labelText: "You found me!"
            readonly property alias buddyColumn: buddyColumn

            function addBuddyFromComponent(component: Component): Item {
                const buddy = component.createObject(buddyColumn) as Item;
                buddyColumn.Kirigami.FormData.buddyFor = buddy;
                return buddy;
            }

            Kirigami.FormGroup {
                Kirigami.FormEntry {
                    contentItem: ColumnLayout {
                        id: buddyColumn

                        spacing: 0

                        // Kirigami.FormData.label can be used in place of FormEntry.title
                        Kirigami.FormData.label: form.labelText
                    }
                }
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

        waitForRendering(form)

        buddy.destroy();

        waitForRendering(form)

        // should revert back to parent
        compare(form.buddyColumn.Kirigami.FormData.buddyFor, form.buddyColumn);
        compare(buddyChangeSpy.count, 2);
    }

    Component {
        id: formAlignmentGroupTest

        ColumnLayout {
            property alias form1: form1
            property alias form2: form2
            property alias group1: group1
            property alias group2: group2
            property alias entry1: entry1
            property alias entry2: entry2
            property alias form2entry1: form2entry1
            property alias form2entry2: form2entry2

            Kirigami.FormAlignmentGroup {
                id: alignmentGroup
            }
            Kirigami.Form {
                id: form1
                Layout.fillWidth: true
                Kirigami.FormAlignmentGroup.group: alignmentGroup
                Kirigami.FormGroup {
                    id: group1
                    // Normal case, direct item
                    Kirigami.FormEntry {
                        id: entry1
                        title: "First label"
                        contentItem: Rectangle {
                            color: "red"
                            implicitWidth: 100
                            implicitHeight: 20
                        }
                    }
                    Kirigami.FormEntry {
                        id: entry2
                        title: "Second label"
                        contentItem: Rectangle {
                            color: "blue"
                            implicitWidth: 200
                            implicitHeight: 20
                        }
                    }
                }
            }
            Kirigami.Form {
                id: form2
                Layout.fillWidth: true
                Kirigami.FormAlignmentGroup.group: alignmentGroup
                Kirigami.FormGroup {
                    id: group2
                    // Normal case, direct item
                    Kirigami.FormEntry {
                        id: form2entry1
                        title: "Second Form First label"
                        contentItem: Rectangle {
                            color: "green"
                            implicitWidth: 50
                            implicitHeight: 20
                        }
                    }
                    Kirigami.FormEntry {
                        id: form2entry2
                        title: "Second Form Second label"
                        contentItem: Rectangle {
                            color: "yellow"
                            implicitWidth: 250
                            implicitHeight: 20
                        }
                    }
                }
            }
        }
    }

    function test_formAlignment() {
        const layout = createTemporaryObject(formAlignmentGroupTest, this);
        waitForRendering(layout)
        compare(layout.group1.width, layout.group2.width)
        compare(layout.entry1.Kirigami.ScenePosition.x, layout.entry2.Kirigami.ScenePosition.x)
        compare(layout.entry1.Kirigami.ScenePosition.x, layout.form2entry1.Kirigami.ScenePosition.x)
        compare(layout.entry1.Kirigami.ScenePosition.x, layout.form2entry2.Kirigami.ScenePosition.x)
    }
}
