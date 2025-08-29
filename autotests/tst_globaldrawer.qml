/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import QtTest

// Inline components are needed because ApplicationItem and
// ApplicationWindow types expect themselves to be top-level components.
TestCase {
    name: "GlobalDrawerHeader"
    visible: true
    when: windowShown

    width: 500
    height: 500

    component AppItemComponent : Kirigami.ApplicationWindow {
        id: app

        property alias headerItem: headerItem
        property alias topItem: topItem
        property alias sidebarSizeItem: sidebarSizeItemDelegate

        width: 500
        height: 500
        visible: true

        globalDrawer: Kirigami.GlobalDrawer {
            drawerOpen: true

            header: Rectangle {
                id: headerItem
                implicitHeight: 50
                implicitWidth: 50
                color: "red"
                radius: 20 // to see its bounds
            }

            actions: [
                Kirigami.Action {
                    text: "View"
                    icon.name: "view-list-icons"
                    Kirigami.Action {
                        text: "action 1"
                    }
                    Kirigami.Action {
                        text: "action 2"
                    }
                    Kirigami.Action {
                        text: "action 3"
                    }
                },
                Kirigami.Action {
                    text: "Sync"
                    icon.name: "folder-sync"
                }
            ]

            // Create some item which we can use to measure actual header height
            Rectangle {
                id: topItem
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "green"
                radius: 20 // to see its bounds
            }
        }

        pageStack.initialPage: startPage
        Kirigami.Page {
            id: startPage
            QQC2.ItemDelegate {
                id: sidebarSizeItemDelegate
                icon.name: "go-back"
            }
        }
    }

    Component {
        id: pageComponent
        Kirigami.Page {
            title: "Layer 1"
        }
    }

    Component {
        id: appItemComponent
        AppItemComponent {}
    }

    function test_headerItemVisibility() {
        if (Qt.platform.os === "unix") {
            skip("On FreeBSD Qt 6.5 fails deep inside generated MOC code for `drawerOpen: true` binding");
        }
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);
        const { headerItem, topItem } = app;

        compare(app.globalDrawer.parent, app.T.Overlay.overlay);

        waitForRendering(app.globalDrawer.contentItem);

        const overlay = T.Overlay.overlay;
        verify(headerItem.height !== 0);

        // Due to margins, position won't be exactly zero...
        const position = topItem.mapToItem(overlay, 0, 0);
        verify(position.y > 0);
        const oldY = position.y;

        // ...but with visible header it would be greater than with invisible.
        headerItem.visible = false;
        tryVerify(() => {
            const position = topItem.mapToItem(overlay, 0, 0);
            return position.y < oldY;
        });

        // And now return it back to where we started.
        headerItem.visible = true;
        tryVerify(() => {
            const position = topItem.mapToItem(overlay, 0, 0);
            return position.y === oldY;
        });
    }

    component AppItemLoaderComponent : Kirigami.ApplicationItem {
        globalDrawer: globalDrawerLoader.item
        contextDrawer: contextDrawerLoader.item

        Loader {
            id: globalDrawerLoader
            active: true
            sourceComponent: Kirigami.GlobalDrawer {}
        }
        Loader {
            id: contextDrawerLoader
            active: true
            sourceComponent: Kirigami.ContextDrawer {}
        }
    }

    Component {
        id: appItemLoaderComponent
        AppItemLoaderComponent {}
    }

    component AppWindowLoaderComponent : Kirigami.ApplicationWindow {
        globalDrawer: globalDrawerLoader.item
        contextDrawer: contextDrawerLoader.item

        Loader {
            id: globalDrawerLoader
            active: true
            sourceComponent: Kirigami.GlobalDrawer {}
        }
        Loader {
            id: contextDrawerLoader
            active: true
            sourceComponent: Kirigami.ContextDrawer {}
        }
    }

    Component {
        id: appWindowLoaderComponent
        AppWindowLoaderComponent {}
    }

    function test_reparentingFromLoader_data() {
        return [
            { tag: "item", component: appItemLoaderComponent },
            { tag: "window", component: appWindowLoaderComponent },
        ];
    }

    function test_reparentingFromLoader({ component }) {
        const app = createTemporaryObject(component, this);
        verify(app);

        compare(app.globalDrawer.parent, app.T.Overlay.overlay);
        compare(app.contextDrawer.parent, app.T.Overlay.overlay);
    }

    function test_collapsedColumnSize() {
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);
        app.globalDrawer.open();
        app.globalDrawer.collapsible = true;
        app.globalDrawer.collapsed = true;
        tryVerify(() => {return app.globalDrawer.width == app.sidebarSizeItem.implicitWidth + app.globalDrawer.leftPadding + app.globalDrawer.rightPadding});
        verify(app.globalDrawer.width  > 0);
    }

    function test_pageRowSidebar() {
        const app = createTemporaryObject(appItemComponent, this);
        verify(app)
        compare(app.pageStack.columnView.x, 0);
        app.pageStack.leftSidebar = app.globalDrawer
        app.globalDrawer.modal = false;
        compare(app.pageStack.columnView.x, app.globalDrawer.width);
        verify(app.globalDrawer.visible);
        // Test basic show/hide
        app.globalDrawer.close();
        tryVerify(() => {return !app.globalDrawer.visible});
        app.globalDrawer.open();
        tryVerify(() => {return app.globalDrawer.visible});

        // When we push a new layer, the drawer must become invisible
        app.pageStack.layers.push(pageComponent);
        tryVerify(() => {return !app.globalDrawer.visible});
        // And get back visible on pop
        app.pageStack.layers.pop()
        tryVerify(() => {return app.globalDrawer.visible});

        // Push a layer with the drawer closed
        app.globalDrawer.close();
        tryVerify(() => {return !app.globalDrawer.visible});
        app.pageStack.layers.push(pageComponent);
        tryVerify(() => {return !app.globalDrawer.visible});

        // Opening it should stay invisible
        app.globalDrawer.open()
        tryVerify(() => {return !app.globalDrawer.visible});
        // But when popping it will become visible again as we asked for it
        app.pageStack.layers.pop()
        tryVerify(() => {return app.globalDrawer.visible});
    }
}
