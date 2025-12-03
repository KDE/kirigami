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
import ".." as KP

Kirigami.AbstractApplicationHeader {
    id: root

    // pageRow.globalToolBar.*Height already include the paddings
    minimumHeight: pageRow ? pageRow.globalToolBar.minimumHeight : Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2
    maximumHeight: pageRow ? pageRow.globalToolBar.maximumHeight : minimumHeight
    preferredHeight: pageRow ? pageRow.globalToolBar.preferredHeight : minimumHeight

    separatorVisible: pageRow ? pageRow.globalToolBar.separatorVisible : true

    Kirigami.Theme.colorSet: pageRow ? pageRow.globalToolBar.colorSet : Kirigami.Theme.Header

    implicitWidth: layout.implicitWidth + Kirigami.Units.smallSpacing * 2
    implicitHeight: Math.max(titleLoader.implicitHeight, toolBar.implicitHeight) + Kirigami.Units.smallSpacing * 2

    onActiveFocusChanged: if (activeFocus && toolBar.actions.length > 0) {
        toolBar.contentItem.visibleChildren[0].forceActiveFocus(Qt.TabFocusReason)
    }

    leftPadding: Kirigami.Units.mediumSpacing
    rightPadding: Kirigami.Units.mediumSpacing

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
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Separator {
            id: separator
            Layout.fillHeight: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            // This must appear at the control edges, disregarding the padding
            Layout.leftMargin: -root.leftPadding
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            Kirigami.Theme.inherit: false
            visible: pageRow?.separatorVisible && !navButtons.visible && page?.Kirigami.ColumnView.view?.leadingVisibleItem !== page
        }

        HandleButton {
            id: leadingHandle
            drawer: QQC.ApplicationWindow.window?.globalDrawer ?? null
            visible: {
                if (!root.pageRow) {
                    return false;
                }
                let firstVisible = false;
                const previousPage = root.pageRow.get(page.Kirigami.ColumnView.index - 1);
                if (previousPage) {
                    firstVisible = previousPage.x - root.pageRow.columnView.contentX < -previousPage.width / 2;
                } else {
                    firstVisible = true;
                }

                return drawer !== null
                    && ((drawer.handleVisible && drawer.enabled) || (drawer?.isMenu ?? false))
                    && (root.pageRow.columnView.columnResizeMode === Kirigami.ColumnView.SingleColumn
                    || firstVisible);
            }
        }

        NavigationButtons {
            id: navButtons
            page: root.page
            pageStack: root.pageRow
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
                if (!(item instanceof KP.DefaultPageTitleDelegate)) {
                    return 0;
                }
                if (!pageRow || navButtons.visible || leadingHandle.visible) {
                    return  0;
                } else if (separator.visible) {
                    return pageRow.globalToolBar.titleLeftPadding - layout.spacing - root.leftPadding;
                }
                return pageRow.globalToolBar.titleLeftPadding - root.leftPadding;
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

        HandleButton {
            drawer: QQC.ApplicationWindow.window?.contextDrawer ?? null
            visible: drawer !== null
                    && drawer.handleVisible && drawer.enabled
                    && (pageStack.columnView.columnResizeMode === Kirigami.ColumnView.SingleColumn
                    || page.Kirigami.ColumnView.view.trailingVisibleItem === page)
        }
    }
}
