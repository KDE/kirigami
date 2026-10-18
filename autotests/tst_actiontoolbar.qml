/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtTest
import org.kde.kirigami as Kirigami

// TODO: Find a nicer way to handle this
import "../src/controls/private" as KirigamiPrivate

TestCase {
    id: testCase
    name: "ActionToolBarTest"

    width: 800
    height: 400
    visible: true

    when: windowShown

    // These buttons are required for getting the right metrics.
    // Since ActionToolBar bases all sizing on button sizes, we need to be able
    // to verify that layouting does the right thing.
    property ToolButton iconButton: KirigamiPrivate.PrivateActionToolButton {
        display: Button.IconOnly
        action: Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
        font.pointSize: 10
    }
    property ToolButton textButton: KirigamiPrivate.PrivateActionToolButton {
        display: Button.TextOnly
        action: Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
        font.pointSize: 10
    }
    property ToolButton textIconButton: KirigamiPrivate.PrivateActionToolButton {
        action: Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
        font.pointSize: 10
    }
    property TextField textField: TextField { font.pointSize: 10 }

    Component {
        id: single
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: multiple
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: iconOnly
        Kirigami.ActionToolBar {
            display: Button.IconOnly
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: qtActions
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Action { icon.name: "document-new"; text: "Test Action" },
                Action { icon.name: "document-new"; text: "Test Action" },
                Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: mixed
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayHint: Kirigami.DisplayHint.IconOnly },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayComponent: TextField { } },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayHint: Kirigami.DisplayHint.AlwaysHide },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayHint: Kirigami.DisplayHint.KeepVisible }
            ]
        }
    }

    function test_layout_data() {
        return [
            // One action
            // Full window width, should just display a toolbutton
            { tag: "single_full", component: single, width: testCase.width, expected: testCase.textIconButton.width },
            // Small width, should display the overflow button
            { tag: "single_min", component: single, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display a single toolbutton
            { tag: "single_half", component: single, width: testCase.width / 2, expected: testCase.textIconButton.width },
            // Multiple actions
            // Full window width, should display as many buttons as there are actions
            { tag: "multi_full", component: multiple, width: testCase.width,
                expected: testCase.textIconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "multi_min", component: multiple, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display one action and overflow button
            { tag: "multi_small", component: multiple,
                width: testCase.textIconButton.width * 2 + testCase.iconButton.width + Kirigami.Units.smallSpacing * 3,
                expected: testCase.textIconButton.width * 2 + testCase.iconButton.width + Kirigami.Units.smallSpacing * 2 },
            // Multiple actions, display set to icon only
            // Full window width, should display as many icon-only buttons as there are actions
            { tag: "icon_full", component: iconOnly, width: testCase.width,
                expected: testCase.iconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "icon_min", component: iconOnly, width: 50, expected: testCase.iconButton.width },
            // Quarter window width, should display one icon-only button and the overflow button
            { tag: "icon_small", component: iconOnly, width: testCase.iconButton.width * 4,
                expected: testCase.iconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // QtQuick Controls actions
            // Full window width, should display as many buttons as there are actions
            { tag: "qt_full", component: qtActions, width: testCase.width,
                expected: testCase.textIconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "qt_min", component: qtActions, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display one action and overflow button
            { tag: "qt_small", component: qtActions,
                width: testCase.textIconButton.width * 2 + testCase.iconButton.width + Kirigami.Units.smallSpacing * 3,
                expected: testCase.textIconButton.width * 2 + testCase.iconButton.width + Kirigami.Units.smallSpacing * 2 },
            // Mix of different display hints, displayComponent and normal actions.
            // Full window width, should display everything, but one action is collapsed to icon
            { tag: "mixed", component: mixed, width: testCase.width,
                expected: testCase.textIconButton.width * 2 + testCase.iconButton.width * 2 + testCase.textField.width + Kirigami.Units.smallSpacing * 4 }
        ]
    }

    // Test layouting of ActionToolBar
    //
    // ActionToolBar has some pretty complex behaviour, which generally boils down to it trying
    // to fit as many visible actions as possible and placing the hidden ones in an overflow menu.
    // This test, along with the data above, verifies that that this behaviour is correct.
    function test_layout(data) {
        var toolbar = createTemporaryObject(data.component, testCase, {width: data.width})

        verify(toolbar)
        verify(waitForRendering(toolbar))

        while (toolbar.visibleWidth == 0) {
            // The toolbar creates its delegates asynchronously during "idle
            // time", this means we need to wait for a bit so the toolbar has
            // the time to do that. As long as it has not finished creation, the
            // toolbar will have a visibleWidth of 0, so we can use that to
            // determine when it is done.
            wait(50)
        }

        compare(toolbar.visibleWidth, data.expected)
    }

    Component {
        id: heightMode

        Kirigami.ActionToolBar {
            id: heightModeToolBar
            font.pointSize: 10

            property real customHeight: 50

            actions: [
                Kirigami.Action {
                    displayComponent: Button {
                        objectName: "tall"
                        implicitHeight: heightModeToolBar.customHeight
                        implicitWidth: 50
                    }
                },
                Kirigami.Action {
                    displayComponent: Button {
                        objectName: "short"
                        implicitHeight: 25
                        implicitWidth: 50
                    }
                }
            ]
        }
    }

    function getChild(toolbar, objectName) {
        let c = toolbar.children[0].children
        for (let i in c) {
            if (c[i].objectName === objectName) {
                return c[i]
            }
        }
        return -1
    }

    function test_height() {
        var toolbar = createTemporaryObject(heightMode, testCase, {width: testCase.width})

        verify(toolbar)
        verify(waitForRendering(toolbar))

        while (toolbar.visibleWidth == 0) {
            // Same as above
            wait(50)
        }

        compare(toolbar.implicitHeight, 50)
        compare(toolbar.height, 50)

        toolbar.customHeight = 100

        // Changing the delegate height will trigger the internal layout to
        // relayout, which is done in polish. This is not signaled to the
        // parent toolbar, so we need to wait on the contentItem here.
        verify(isPolishScheduled(toolbar.contentItem))
        verify(waitForItemPolished(toolbar.contentItem))

        // Implicit height changes should propagate to the layout's height as
        // long as that doesn't have an explicit height set.
        compare(toolbar.implicitHeight, 100)
        compare(toolbar.height, 100)

        // This should be the default, but make sure to set it regardless
        toolbar.heightMode = Kirigami.ToolBarLayout.ConstrainIfLarger
        toolbar.height = 50

        // Find the actual child items so we can check their properties
        let t = getChild(toolbar, "tall");
        let s = getChild(toolbar, "short");

        // waitForItemPolished doesn't wait long enough and waitForRendering
        // waits too long, so just wait an arbitrary amount of time...
        wait(50)

        // ConstrainIfLarger should reduce the height of the first, but not touch the second
        compare(t.height, 50)
        compare(t.y, 0)
        compare(s.height, 25)
        compare(s.y, 13) // Should be centered and rounded

        // AlwaysCenter should not touch any item's height, only make sure they are centered
        toolbar.heightMode = Kirigami.ToolBarLayout.AlwaysCenter

        wait(50)

        compare(t.height, 100)
        compare(t.y, -25)
        compare(s.height, 25)
        compare(s.y, 13)

        // AlwaysFill should make sure each item has the same height as the toolbar
        toolbar.heightMode = Kirigami.ToolBarLayout.AlwaysFill

        wait(50)

        compare(t.height, 50)
        compare(t.y, 0)
        compare(s.height, 50)
        compare(s.y, 0)

        // Unconstraining the toolbar should reset its height to the maximum
        // implicit height and set any children to that same value as heightMode
        // is still AlwaysFill.
        toolbar.height = undefined

        wait(50)

        compare(toolbar.height, 100)
        compare(t.height, 100)
        compare(s.height, 100)
    }

    Component {
        id: toolbarComponent
        Kirigami.ToolBarLayout {
            fullDelegate: Item {}
            iconDelegate: Item {}
            separatorDelegate: Item {}
            moreButton: Item {}
        }
    }

    Component {
        id: actionComponent
        Kirigami.Action {}
    }

    function test_dynamicActions() {
        const toolbar = createTemporaryObject(toolbarComponent, this);
        verify(toolbar);

        const actionA = createTemporaryObject(actionComponent, this, { text: "Action A" });
        verify(actionA)
        toolbar.actions.push(actionA);
        waitForPolish(toolbar);
        actionA.destroy();
        wait(1500); // Let it destroy, and let toolBarLayout's throttle timer expire

        const actionB = createTemporaryObject(actionComponent, this, { text: "Action B" });
        verify(actionB)

        // should not crash
        toolbar.actions.push(actionB);
        waitForPolish(toolbar);
    }

    function test_duplicateDynamicAction() {
        const toolbar = createTemporaryObject(toolbarComponent, this);
        verify(toolbar);

        const actionA = createTemporaryObject(actionComponent, this, { text: "Action A" });
        verify(actionA)
        toolbar.actions.push(actionA);
        toolbar.actions.push(actionA);
        waitForPolish(toolbar);
        actionA.destroy();
        wait(1500); // Let it destroy, and let toolBarLayout's throttle timer expire

        const actionB = createTemporaryObject(actionComponent, this, { text: "Action B" });
        verify(actionB)

        // should not crash
        toolbar.actions.push(actionB);
        waitForPolish(toolbar);
    }

    Component {
        id: droppedToolBarLoader
        Loader {
            sourceComponent: Kirigami.ActionToolBar {
                actions: [
                    Kirigami.Action { text: "Shown" },
                    Kirigami.Action { text: "Hidden"; displayHint: Kirigami.DisplayHint.AlwaysHide }
                ]
            }
        }
    }

    // A toolbar that a Loader drops while its delegates are still being created, as a page header
    // does when it is rebuilt, stops creating them without errors.
    function test_droppedWhileCreatingDelegates() {
        failOnWarning(/Could not create delegate/);
        failOnWarning(/invalid context/);
        const loader = createTemporaryObject(droppedToolBarLoader, this);
        verify(loader.item);
        loader.active = false;
        wait(500); // Let the pending delegate creation run
    }
}
