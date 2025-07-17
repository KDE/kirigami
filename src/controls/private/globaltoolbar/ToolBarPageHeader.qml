/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Window
import QtQml
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT

Kirigami.AbstractApplicationHeader {
    id: root

    minimumHeight: pageRow ? pageRow.globalToolBar.minimumHeight : Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2
    maximumHeight: (pageRow ? pageRow.globalToolBar.maximumHeight : minimumHeight) + root.topPadding + root.bottomPadding
    preferredHeight: (pageRow ? pageRow.globalToolBar.preferredHeight : minimumHeight) + root.topPadding + root.bottomPadding

    separatorVisible: pageRow ? pageRow.globalToolBar.separatorVisible : true

    Kirigami.Theme.colorSet: pageRow ? pageRow.globalToolBar.colorSet : Kirigami.Theme.Header

    implicitWidth: layout.implicitWidth + Kirigami.Units.smallSpacing * 2
    implicitHeight: Math.max(titleLoader.implicitHeight, toolBar.implicitHeight) + Kirigami.Units.smallSpacing * 2

    onActiveFocusChanged: if (activeFocus && toolBar.actions.length > 0) {
        toolBar.contentItem.visibleChildren[0].forceActiveFocus(Qt.TabFocusReason)
    }

    rightPadding: {
        if (page?.Kirigami.ColumnView.view?.columnResizeMode === Kirigami.ColumnView.SingleColumn) {
            return pageRow.globalToolBar.rightReservedSpace
        }
        if (LayoutMirroring.enabled) {
            return Math.max(0, (pageRow.Kirigami.ScenePosition.x + pageRow.globalToolBar.rightReservedSpace) - page.Kirigami.ScenePosition.x);
        } else {
            return Math.max(0, (page.Kirigami.ScenePosition.x + page.width) - (pageRow.Kirigami.ScenePosition.x + pageRow.width - pageRow.globalToolBar.rightReservedSpace));
        }
        return 0;
    }


    MouseArea {
        anchors.fill: parent
        onPressed: mouse => {
            page.forceActiveFocus()
            mouse.accepted = false
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.rightMargin: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Separator {
            id: separator
            Layout.fillHeight: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            Kirigami.Theme.inherit: false
            visible: pageRow?.separatorVisible && !navButtons.visible && page?.Kirigami.ColumnView.view?.leadingVisibleItem !== page
        }

        Item {
            id: leftHandleSpacer
            visible: {
                const drawer = applicationWindow().globalDrawer as KT.OverlayDrawer;
                if (!drawer || (!drawer.isMenu && (!drawer.enabled || !drawer.handleVisible))) {
                    return false;
                }
                if (page.Kirigami.ColumnView.index <= 0) {
                    return true;
                }
                const previousPage = root.pageRow.get(page.Kirigami.ColumnView.index - 1);
                if (LayoutMirroring.enabled) {
                    if (root.pageRow.width - (page.x + page.width - root.pageRow.columnView.contentX) < previousPage.width / 2) {
                        return true;
                    }
                } else {
                    if (previousPage.x - root.pageRow.columnView.contentX < -previousPage.width / 2) {
                        return true;
                    }
                }
                return false;
            }

            Layout.preferredWidth: pageRow.globalToolBar.leftReservedSpace
            Layout.fillHeight: true
        }

        NavigationButtons {
            id: navButtons
            page: root.page
            pageStack: root.pageRow
            Layout.leftMargin: !leftHandleSpacer.visible ? Kirigami.Units.smallSpacing : 0
        }

        Loader {
            id: titleLoader
            // Don't need space on the first item
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: item?.Layout.fillWidth ?? false
            Layout.minimumWidth: item?.Layout.minimumWidth ?? -1
            Layout.preferredWidth: item?.Layout.preferredWidth ?? -1
            Layout.maximumWidth: item?.Layout.maximumWidth ?? -1
            Layout.leftMargin: {
                if (navButtons.visible || leftHandleSpacer.visible) {
                    return 0;
                } else if (separator.visible) {
                    return pageRow.globalToolBar.titleLeftPadding - layout.spacing;
                }
                return pageRow.globalToolBar.titleLeftPadding;
            }

            // Don't load async to prevent jumpy behaviour on slower devices as it loads in.
            // If the title delegate really needs to load async, it should be its responsibility to do it itself.
            asynchronous: false
            sourceComponent: page?.titleDelegate ?? null
        }

        Kirigami.ActionToolBar {
            id: toolBar

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            alignment: pageRow?.globalToolBar.toolbarActionAlignment ?? Qt.AlignRight
            heightMode: pageRow?.globalToolBar.toolbarActionHeightMode ?? Kirigami.ToolBarLayout.ConstrainIfLarger

            actions: page && page.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar ? page?.actions : []
        }
    }
}
