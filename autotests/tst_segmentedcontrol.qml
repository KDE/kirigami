/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: root

    name: "SegmentedControl"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Component {
        id: segmentedControlComponent
        Kirigami.SegmentedControl {}
    }

    Component {
        id: actionComponent
        Kirigami.Action {}
    }

    function createAction(checkable) {
        return createTemporaryObject(actionComponent, root, {
            text: "Action",
            checkable: checkable,
        });
    }

    function createControl(checkable, exclusive) {
        const control = createTemporaryObject(segmentedControlComponent, root, {
            width: 400,
            height: 60,
        });
        verify(control);
        control.actions = [createAction(checkable), createAction(checkable), createAction(checkable)];
        control.exclusive = exclusive;
        // The buttons are laid out by the internal RowLayout, wait for it.
        waitForItemPolished(control.contentItem);
        return control;
    }

    function controlButtons(control) {
        return control.contentItem.children.filter((child) => child.checkable !== undefined);
    }

    function test_notCheckable() {
        const control = createControl(false, false);
        const buttons = controlButtons(control);
        compare(buttons.length, 3);
        for (const button of buttons) {
            verify(!button.checkable);
        }
        // Clicking a non-checkable button must not leave it checked.
        mouseClick(buttons[0]);
        verify(!buttons[0].checked);
    }

    function test_checkable() {
        const control = createControl(true, false);
        const buttons = controlButtons(control);
        compare(buttons.length, 3);
        for (const button of buttons) {
            verify(button.checkable);
        }
        // Several buttons can be checked at once.
        mouseClick(buttons[0]);
        verify(buttons[0].checked);
        mouseClick(buttons[1]);
        verify(buttons[0].checked);
        verify(buttons[1].checked);
        // And they can be unchecked again.
        mouseClick(buttons[0]);
        verify(!buttons[0].checked);
        verify(buttons[1].checked);
    }

    function test_exclusive() {
        const control = createControl(true, true);
        const buttons = controlButtons(control);
        compare(buttons.length, 3);
        // Only one button can be checked at a time.
        mouseClick(buttons[0]);
        verify(buttons[0].checked);
        verify(!buttons[1].checked);
        mouseClick(buttons[1]);
        verify(!buttons[0].checked);
        verify(buttons[1].checked);
        verify(!buttons[2].checked);
        mouseClick(buttons[2]);
        verify(!buttons[0].checked);
        verify(!buttons[1].checked);
        verify(buttons[2].checked);
    }
}
