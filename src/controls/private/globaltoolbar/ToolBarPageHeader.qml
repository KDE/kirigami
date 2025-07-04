/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQml
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

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

    leftPadding: {
        // We are in a layer, show buttons
        // page can be null when the nav buttons are in the breadcrumbs header
        if (page.QQC.StackView.view ||
            // If we are in single page mode, always show if depth > 1
            pageStack.columnView.columnResizeMode === Kirigami.ColumnView.SingleColumn ||
            // First page in the row
            page.Kirigami.ColumnView.index <= 0) {
            return pageRow.globalToolBar.leftReservedSpace;
        }

        // Condition: the page previous of this one is at least half scrolled away
        const previousPage = pageStack.get(page.Kirigami.ColumnView.index - 1);
        if (Qt.application.layoutDirection === Qt.RightToLeft) {
            if (pageStack.width - (page.x + page.width - pageStack.columnView.contentX) < previousPage.width / 2) {
                return pageRow.globalToolBar.leftReservedSpace;
            }
        } else {
            if (previousPage.x - pageStack.columnView.contentX < -previousPage.width / 2) {
                return pageRow.globalToolBar.leftReservedSpace;
            }
        }

        return 0;
    }

    rightPadding: {
        if (Qt.application.layoutDirection === Qt.RightToLeft) {
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

        NavigationButtons {
            id: navButtons
            page: root.page
            pageStack: root.pageRow
        }

        Loader {
            id: titleLoader

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: item?.Layout.fillWidth ?? false
            Layout.minimumWidth: item?.Layout.minimumWidth ?? -1
            Layout.preferredWidth: item?.Layout.preferredWidth ?? -1
            Layout.maximumWidth: item?.Layout.maximumWidth ?? -1
            Layout.leftMargin: navButtons.visible || root.leftPadding > pageRow.globalToolBar.titleLeftPadding ? 0 : pageRow.globalToolBar.titleLeftPadding

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

            actions: page.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                     ? (page?.actions ?? [])
                     : []
        }
    }
}
