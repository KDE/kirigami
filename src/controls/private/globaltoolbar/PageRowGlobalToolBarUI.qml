/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../templates" as KT
import "../../templates/private" as TP
import "../" as P

Kirigami.AbstractApplicationHeader {
    id: header
    readonly property int leftReservedSpace: {
        let space = Kirigami.Units.smallSpacing;
        if (leftHandleAnchor.visible) {
            space += leftHandleAnchor.width;
        }
        if (menuButton.visible) {
            space += menuButton.width;
        }
        return space
    }
    readonly property int rightReservedSpace: rightHandleAnchor.visible ? rightHandleAnchor.width + Kirigami.Units.smallSpacing : 0

    readonly property alias leftHandleAnchor: leftHandleAnchor
    readonly property alias rightHandleAnchor: rightHandleAnchor

    readonly property bool breadcrumbVisible: layerIsMainRow && breadcrumbLoader.active
    readonly property bool layerIsMainRow: (root.layers.currentItem.hasOwnProperty("columnView")) ? root.layers.currentItem.columnView === root.columnView : false
    readonly property Item currentItem: layerIsMainRow ? root.columnView : root.layers.currentItem

    function __shouldHandleAnchorBeVisible(handleAnchor: Item, drawerProperty: string, itemProperty: string): bool {
        if (typeof applicationWindow === "undefined") {
            return false;
        }
        const w = applicationWindow();
        if (!w) {
            return false;
        }
        const drawer = w[drawerProperty] as KT.OverlayDrawer;
        if (!drawer || !drawer.enabled || !drawer.handleVisible || drawer.handle.handleAnchor !== handleAnchor) {
            return false;
        }
        const item = breadcrumbLoader.pageRow?.[itemProperty] as Item;
        const style = item?.globalToolBarStyle ?? Kirigami.ApplicationHeaderStyle.None;
        return globalToolBar.canContainHandles || style === Kirigami.ApplicationHeaderStyle.ToolBar;
    }

    height: visible ? implicitHeight : 0
    minimumHeight: globalToolBar.minimumHeight + header.topPadding + header.bottomPadding
    preferredHeight: globalToolBar.preferredHeight + header.topPadding + header.bottomPadding
    maximumHeight: globalToolBar.maximumHeight + header.topPadding + header.bottomPadding
    separatorVisible: globalToolBar.separatorVisible

    Kirigami.Theme.colorSet: globalToolBar.colorSet

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredWidth: applicationWindow().pageStack.globalToolBar.leftReservedSpace
            visible: applicationWindow().pageStack !== root
        }

        Item {
            id: leftHandleAnchor
            visible: header.__shouldHandleAnchorBeVisible(leftHandleAnchor, "globalDrawer", "leadingVisibleItem")

            Layout.preferredHeight: menuButton.implicitHeight
            Layout.preferredWidth: height
        }

        P.PrivateActionToolButton {
            id: menuButton
            visible: !Kirigami.Settings.isMobile && applicationWindow().globalDrawer && "isMenu" in applicationWindow().globalDrawer && applicationWindow().globalDrawer.isMenu
            icon.name: "open-menu-symbolic"
            showMenuArrow: false

            Layout.leftMargin: Kirigami.Units.smallSpacing

            action: Kirigami.Action {
                children: applicationWindow().globalDrawer && applicationWindow().globalDrawer.actions ? applicationWindow().globalDrawer.actions : []
                tooltip: checked ? qsTr("Close menu") : qsTr("Open menu")
            }
            Accessible.name: action.tooltip

            Connections {
                // Only target the GlobalDrawer when it *is* a GlobalDrawer, since
                // it can be something else, and that something else probably
                // doesn't have an isMenuChanged() signal.
                target: applicationWindow().globalDrawer as Kirigami.GlobalDrawer
                function onIsMenuChanged() {
                    if (!applicationWindow().globalDrawer.isMenu && menuButton.menu) {
                        menuButton.menu.dismiss()
                    }
                }
            }
        }

        Loader {
            id: breadcrumbLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: -1
            Layout.preferredHeight: -1
            property Kirigami.PageRow pageRow: root

            asynchronous: true

            active: layerIsMainRow
                && globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.Breadcrumb
                && header.currentItem
                && header.currentItem.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.None

            source: Qt.resolvedUrl("BreadcrumbControl.qml")
        }

        Item {
            id: rightHandleAnchor
            visible: header.__shouldHandleAnchorBeVisible(rightHandleAnchor, "contextDrawer", "trailingVisibleItem")

            Layout.preferredHeight: menuButton.implicitHeight
            Layout.preferredWidth: height
        }
    }
    background.opacity: breadcrumbLoader.active ? 1 : 0
}
