/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT
import "../" as P

Kirigami.AbstractApplicationHeader {
    id: header
    readonly property int leftReservedSpace: {return 0
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

    Kirigami.AlignedSize.height: visible ? implicitHeight : 0
    minimumHeight: globalToolBar.minimumHeight + header.topPadding + header.bottomPadding
    preferredHeight: globalToolBar.preferredHeight + header.topPadding + header.bottomPadding
    maximumHeight: globalToolBar.maximumHeight + header.topPadding + header.bottomPadding
    separatorVisible: globalToolBar.separatorVisible

    Kirigami.Theme.colorSet: globalToolBar.colorSet

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

        property Kirigami.PageRow pageRow: root

        asynchronous: true

        active: layerIsMainRow
            && globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.Breadcrumb
            && header.currentItem
            && header.currentItem.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.None

        source: Qt.resolvedUrl("BreadcrumbControl.qml")
    }

    background.opacity: breadcrumbLoader.active ? 1 : 0
}
