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
import org.kde.kirigami.controls as KC
import org.kde.kirigami.layouts as KL
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.templates as KT
import ".." as KP

KC.AbstractApplicationHeader {
    id: root

    // pageRow.globalToolBar.*Height already include the paddings
    minimumHeight: pageRow ? pageRow.globalToolBar.minimumHeight : Platform.Units.iconSizes.medium + Platform.Units.smallSpacing * 2
    maximumHeight: pageRow ? pageRow.globalToolBar.maximumHeight : minimumHeight
    preferredHeight: pageRow ? pageRow.globalToolBar.preferredHeight : minimumHeight

    separatorVisible: pageRow ? pageRow.globalToolBar.separatorVisible : true

    Platform.Theme.colorSet: pageRow ? pageRow.globalToolBar.colorSet : Platform.Theme.Header

    implicitWidth: layout.implicitWidth + Platform.Units.smallSpacing * 2
    implicitHeight: Math.max(titleLoader.implicitHeight, toolBar.implicitHeight) + Platform.Units.smallSpacing * 2

    onActiveFocusChanged: if (activeFocus && toolBar.actions.length > 0) {
        toolBar.contentItem.visibleChildren[0].forceActiveFocus(Qt.TabFocusReason)
    }

    leftPadding: Platform.Units.mediumSpacing
    rightPadding: Platform.Units.mediumSpacing

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => {
            root.page.forceActiveFocus()
            mouse.accepted = false
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: Platform.Units.smallSpacing

        Primitives.Separator {
            id: separator
            Layout.fillHeight: true
            Layout.topMargin: Platform.Units.largeSpacing
            Layout.bottomMargin: Platform.Units.largeSpacing
            // This must appear at the control edges, disregarding the padding
            Layout.leftMargin: -root.leftPadding
            Platform.Theme.colorSet: Platform.Theme.Header
            Platform.Theme.inherit: false
            visible: root.pageRow?.separatorVisible && !navButtons.visible && root.page?.KL.ColumnView.view?.leadingVisibleItem !== root.page
        }

        HandleButton {
            id: leadingHandle
            drawer: QQC.ApplicationWindow.window?.globalDrawer ?? null
            visible: {
                if (!root.pageRow) {
                    return false;
                }
                let firstVisible = false;
                const previousPage = root.pageRow.get(root.page.KL.ColumnView.index - 1);
                if (previousPage) {
                    firstVisible = previousPage.x - root.pageRow.columnView.contentX < -previousPage.width / 2;
                } else {
                    firstVisible = true;
                }

                return drawer !== null
                    && ((drawer.handleVisible && drawer.enabled) || ((drawer as KC.GlobalDrawer)?.isMenu ?? false))
                    && (root.pageRow.columnView.columnResizeMode === KL.ColumnView.SingleColumn
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
            Layout.fillWidth: (item as Item)?.Layout.fillWidth ?? false
            Layout.minimumWidth: (item as Item)?.Layout.minimumWidth ?? -1
            Layout.preferredWidth: (item as Item)?.Layout.preferredWidth ?? -1
            Layout.maximumWidth: (item as Item)?.Layout.maximumWidth ?? -1
            Layout.leftMargin: {
                if (!(item instanceof KP.DefaultPageTitleDelegate)) {
                    return 0;
                }
                if (!root.pageRow || navButtons.visible || leadingHandle.visible) {
                    return  0;
                } else if (separator.visible) {
                    return root.pageRow.globalToolBar.titleLeftPadding - layout.spacing - root.leftPadding;
                }
                return root.pageRow.globalToolBar.titleLeftPadding - root.leftPadding;
            }

            // Don't load async to prevent jumpy behaviour on slower devices as it loads in.
            // If the title delegate really needs to load async, it should be its responsibility to do it itself.
            asynchronous: false
            sourceComponent: root.page?.titleDelegate ?? null
        }

        KC.ActionToolBar {
            id: toolBar

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            alignment: root.pageRow?.globalToolBar.toolbarActionAlignment ?? Qt.AlignRight
            heightMode: root.pageRow?.globalToolBar.toolbarActionHeightMode ?? KL.ToolBarLayout.ConstrainIfLarger

            actions: root.page && root.page.globalToolBarStyle === KC.ApplicationHeaderStyle.ToolBar ? root.page?.actions : []
        }

        HandleButton {
            drawer: QQC.ApplicationWindow.window?.contextDrawer ?? null
            visible: drawer !== null
                    && drawer.handleVisible && drawer.enabled
                    && (pageStack.columnView.columnResizeMode === KL.ColumnView.SingleColumn
                    || root.page.KL.ColumnView.view?.trailingVisibleItem === root.page)
        }
    }
}
