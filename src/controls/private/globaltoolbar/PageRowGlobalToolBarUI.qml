/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.templates as KT

KC.AbstractApplicationHeader {
    id: header
    readonly property int leftReservedSpace: {
        let space = Platform.Units.smallSpacing;
        if (leftHandleAnchor.visible) {
            space += leftHandleAnchor.width;
        }
        return space
    }
    readonly property int rightReservedSpace: rightHandleAnchor.visible ? rightHandleAnchor.width + Platform.Units.smallSpacing : 0

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
        const style = item?.globalToolBarStyle ?? KC.ApplicationHeaderStyle.None;
        return globalToolBar.canContainHandles || style === KC.ApplicationHeaderStyle.ToolBar;
    }

    Primitives.AlignedSize.height: visible ? implicitHeight : 0
    minimumHeight: globalToolBar.minimumHeight
    preferredHeight: globalToolBar.preferredHeight
    maximumHeight: globalToolBar.maximumHeight
    separatorVisible: globalToolBar.separatorVisible
    background.visible: breadcrumbLoader.active
    Platform.Theme.colorSet: globalToolBar.colorSet

    Item {
        id: leftHandleAnchor
        anchors.left: parent.left
        visible: header.__shouldHandleAnchorBeVisible(leftHandleAnchor, "globalDrawer", "leadingVisibleItem")

        width: height
        height: parent.height
    }

    Item {
        id: rightHandleAnchor
        visible: header.__shouldHandleAnchorBeVisible(rightHandleAnchor, "contextDrawer", "trailingVisibleItem")

        width: height
        height: parent.height
    }

    Loader {
        id: breadcrumbLoader
        anchors.fill: parent

        property KC.PageRow pageRow: root

        asynchronous: true

        active: header.layerIsMainRow
            && globalToolBar.actualStyle === KC.ApplicationHeaderStyle.Breadcrumb
            && header.currentItem
            && header.currentItem.globalToolBarStyle !== KC.ApplicationHeaderStyle.None

        source: Qt.resolvedUrl("BreadcrumbControl.qml")
    }
}
