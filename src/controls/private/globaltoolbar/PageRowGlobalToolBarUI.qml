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
    readonly property int leftReservedSpace: (buttonsLayout.visible && buttonsLayout.visibleChildren.length > 0 ? buttonsLayout.width + Kirigami.Units.smallSpacing : 0) // Take into account the layout margins the nav buttons have
        + (leftHandleAnchor.visible ? leftHandleAnchor.width : 0)
        + (menuButton.visible ? menuButton.width : 0)
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
    minimumHeight: globalToolBar.minimumHeight
    preferredHeight: globalToolBar.preferredHeight
    maximumHeight: globalToolBar.maximumHeight
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

            Layout.preferredHeight: Math.max(backButton.implicitHeight, parent.height)
            Layout.preferredWidth: height
        }

        P.PrivateActionToolButton {
            id: menuButton
            visible: !Kirigami.Settings.isMobile && applicationWindow().globalDrawer && "isMenu" in applicationWindow().globalDrawer && applicationWindow().globalDrawer.isMenu
            icon.name: "open-menu-symbolic"
            showMenuArrow: false

            Layout.preferredHeight: Math.min(backButton.implicitHeight, parent.height)
            Layout.preferredWidth: height
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

        RowLayout {
            id: buttonsLayout
            Layout.fillHeight: true
            Layout.preferredHeight: Math.max(backButton.visible ? backButton.implicitHeight : 0, forwardButton.visible ? forwardButton.implicitHeight : 0)

            Layout.leftMargin: leftHandleAnchor.visible ? Kirigami.Units.smallSpacing : 0

            visible: (globalToolBar.showNavigationButtons !== Kirigami.ApplicationHeaderStyle.NoNavigationButtons || applicationWindow().pageStack.layers.depth > 1 && !(applicationWindow().pageStack.layers.currentItem instanceof Kirigami.PageRow || header.layerIsMainRow))
                && globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None

            Layout.maximumWidth: visibleChildren.length > 0 ? Layout.preferredWidth : 0

            TP.BackButton {
                id: backButton
                Layout.leftMargin: leftHandleAnchor.visible ? 0 : Kirigami.Units.smallSpacing
                Layout.minimumWidth: implicitHeight
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: buttonsLayout.height
            }
            TP.ForwardButton {
                id: forwardButton
                Layout.minimumWidth: implicitHeight
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: buttonsLayout.height
            }
        }

        QQC2.ToolSeparator {
            visible: (menuButton.visible || (buttonsLayout.visible && buttonsLayout.visibleChildren.length > 0)) && breadcrumbVisible && pageRow.depth > 1
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

            Layout.preferredHeight: Math.max(backButton.implicitHeight, parent.height)
            Layout.preferredWidth: height
        }
    }
    background.opacity: breadcrumbLoader.active ? 1 : 0
}
