/*
 *  SPDX-FileCopyrightText: 2026 Ramil Nurmanov <ramil2004nur@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Window
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: testCase
    name: "ListItemDragHandle"
    width: 300
    height: 300
    when: windowShown

    Component {
        id: signalSpy
        SignalSpy {}
    }

    // The fixture lives in the TestCase's own window rather than in a separate
    // Window: QtQuickTest delivers key events to QGuiApplication::focusWindow(),
    // and on CI (Xvfb, no window manager) activation of a secondary window races
    // with stale focus events, so key clicks could land in the wrong window.
    Component {
        id: fixtureComponent
        Item {
            id: fixture

            property alias list: list
            property alias model: listModel
            property alias sink: sink

            width: 300
            height: 300

            ListModel {
                id: listModel
                ListElement { label: "a" }
                ListElement { label: "b" }
                ListElement { label: "c" }
                ListElement { label: "d" }
            }

            Item {
                id: sink
                width: 1
                height: 1
                activeFocusOnTab: true
            }

            ListView {
                id: list
                anchors.fill: parent
                model: listModel

                delegate: Item {
                    id: delegateRoot

                    required property int index
                    required property string label

                    readonly property alias handle: handle

                    width: list.width
                    implicitHeight: 40

                    Item {
                        id: row
                        anchors.fill: parent

                        Kirigami.ListItemDragHandle {
                            id: handle
                            listItem: row
                            listView: list
                            onMoveRequested: (oldIndex, newIndex) => listModel.move(oldIndex, newIndex, 1)
                        }
                    }
                }
            }
        }
    }

    function order(model): string {
        let out = "";
        for (let i = 0; i < model.count; ++i) {
            out += model.get(i).label;
        }
        return out;
    }

    function handleAt(fixture, i): Item {
        return fixture.list.itemAtIndex(i).handle;
    }

    function makeFixture(): Item {
        const fixture = createTemporaryObject(fixtureComponent, testCase);
        verify(fixture);
        const window = testCase.Window.window;
        window.requestActivate();
        tryVerify(() => window.active && Qt.application.state === Qt.ApplicationActive);
        tryVerify(() => fixture.list.itemAtIndex(fixture.model.count - 1) !== null);
        return fixture;
    }

    function focusHandleAt(fixture, i): Item {
        const handle = handleAt(fixture, i);
        handle.forceActiveFocus();
        tryVerify(() => handle.activeFocus && testCase.Window.activeFocusItem === handle);
        return handle;
    }

    function enterReorderMode(handle) {
        keyClick(Qt.Key_Space);
        verify(handle.reorderModeActive);
    }

    function test_arrowsAreInertWithoutReorderMode() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 0);
        const spy = createTemporaryObject(signalSpy, this, { target: handle, signalName: "moveRequested" });

        keyClick(Qt.Key_Down);
        keyClick(Qt.Key_Up);

        verify(!handle.reorderModeActive);
        compare(spy.count, 0);
        compare(order(fixture.model), "abcd");
    }

    function test_spaceTogglesReorderMode() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 0);

        verify(!handle.reorderModeActive);
        keyClick(Qt.Key_Space);
        verify(handle.reorderModeActive);
        keyClick(Qt.Key_Space);
        verify(!handle.reorderModeActive);
    }

    function test_escapeLeavesReorderMode() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 0);

        enterReorderMode(handle);
        keyClick(Qt.Key_Escape);
        verify(!handle.reorderModeActive);
    }

    function test_focusLossLeavesReorderMode() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 0);

        enterReorderMode(handle);
        fixture.sink.forceActiveFocus();
        tryVerify(() => !handle.reorderModeActive);
    }

    function test_moveDownEmitsMoveRequested() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 0);
        enterReorderMode(handle);
        const spy = createTemporaryObject(signalSpy, this, { target: handle, signalName: "moveRequested" });

        keyClick(Qt.Key_Down);

        compare(spy.count, 1);
        compare(spy.signalArguments[0][0], 0);
        compare(spy.signalArguments[0][1], 1);
        compare(order(fixture.model), "bacd");
        verify(handle.reorderModeActive);
    }

    function test_moveUpEmitsMoveRequested() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 2);
        enterReorderMode(handle);
        const spy = createTemporaryObject(signalSpy, this, { target: handle, signalName: "moveRequested" });

        keyClick(Qt.Key_Up);

        compare(spy.count, 1);
        compare(spy.signalArguments[0][0], 2);
        compare(spy.signalArguments[0][1], 1);
        compare(order(fixture.model), "acbd");
    }

    function test_upOnFirstItemIsNoOp() {
        const fixture = makeFixture();
        const handle = focusHandleAt(fixture, 0);
        enterReorderMode(handle);
        const spy = createTemporaryObject(signalSpy, this, { target: handle, signalName: "moveRequested" });

        keyClick(Qt.Key_Up);

        compare(spy.count, 0);
        compare(order(fixture.model), "abcd");
        verify(handle.activeFocus);
        verify(handle.reorderModeActive);
    }

    function test_downOnLastItemIsNoOp() {
        const fixture = makeFixture();
        const last = fixture.model.count - 1;
        const handle = focusHandleAt(fixture, last);
        enterReorderMode(handle);
        const spy = createTemporaryObject(signalSpy, this, { target: handle, signalName: "moveRequested" });

        keyClick(Qt.Key_Down);

        compare(spy.count, 0);
        compare(order(fixture.model), "abcd");
        verify(handle.activeFocus);
        verify(handle.reorderModeActive);
    }

    function test_focusableByDefault() {
        const fixture = makeFixture();
        verify(handleAt(fixture, 0).activeFocusOnTab);
    }

    function test_accessible() {
        const fixture = makeFixture();
        const handle = handleAt(fixture, 0);
        compare(handle.Accessible.role, Accessible.Grip);
        // The accessible name comes from the button text, but Qt only applies it
        // while an accessibility client is active, so check the text itself.
        verify(handle.text.length > 0);
        verify(handle.Accessible.checkable);
        compare(handle.Accessible.checked, false);
    }
}
