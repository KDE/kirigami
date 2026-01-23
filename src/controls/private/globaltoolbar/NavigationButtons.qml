/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC
import QtQml
import QtQuick.Layouts
import org.kde.kirigami.controls as KC
import org.kde.kirigami.layouts as KL
import org.kde.kirigami.platform as Platform

Loader {
    id: root

    required property Item page
    required property KC.PageRow pageStack

    active: {
        if (!pageStack) {
            return false;
        }

        // We are in a layer, show buttons
        // page can be null when the nav buttons are in the breadcrumbs header
        if (page && page.QQC.StackView.view) {
            return true;
        }

        // The application doesn't want nav buttons
        if (pageStack.globalToolBar.showNavigationButtons === KC.ApplicationHeaderStyle.NoNavigationButtons) {
            return false
        }

        //Don't show back button on pinned pages
        if (page.KL.ColumnView.pinned && pageStack.columnView.columnResizeMode !== KL.ColumnView.SingleColumn) {
            return false;
        }

        const leadingPinned = page?.KL.ColumnView.view?.leadingVisibleItem?.KL.ColumnView.pinned && pageStack.columnView.columnResizeMode !== KL.ColumnView.SingleColumn
                            ? page.KL.ColumnView.view.leadingVisibleItem
                            : null;
        const leadingPinnedWidth = leadingPinned?.width ?? 0
        const firstIndex = leadingPinned ? leadingPinned.KL.ColumnView.index + 1 : 0

        // If we are on the first page and we don't want to show the forward button, don't
        // show the back button either
        if (!(pageStack.globalToolBar.showNavigationButtons & KC.ApplicationHeaderStyle.ShowForwardButton) &&
            page.KL.ColumnView.index === firstIndex) {
            return false;
        }

        // If we are in single page mode, always show if depth > 1
        if (pageStack.columnView.columnResizeMode === KL.ColumnView.SingleColumn) {
            return pageStack.depth > 1;
        }

        // Condition: the contents have to be bigger than what the ColumnView can show
        // The gridUnit wiggle room is used to not flicker the button visibility during an animated resize for instance due to a sidebar collapse
        const overflows = pageStack.columnView.contentWidth > pageStack.columnView.width + Platform.Units.gridUnit;

        // Index will be 0 at the first page in the row, -1 in a page belonging to a layer
        if (!page || page.KL.ColumnView.index <= firstIndex) {
            return overflows || pageStack.columnView.contentX > 0;
        }

        // Condition: the page previous of this one is at least half scrolled away
        const previousPage = pageStack.get(page.KL.ColumnView.index - 1);
        let firstVisible = false;
        if (LayoutMirroring.enabled) {
            firstVisible = pageStack.width - (page.x + page.width - pageStack.columnView.contentX - leadingPinnedWidth) < previousPage.width / 2;
        } else {
            firstVisible = previousPage.x - pageStack.columnView.contentX - leadingPinnedWidth < -previousPage.width / 2;
        }

        return overflows && firstVisible;
    }

    visible: active

    sourceComponent: RowLayout {
        id: layout

        spacing: Platform.Units.smallSpacing

        component NavButton: QQC.ToolButton {
            id: navButton
            display: QQC.ToolButton.IconOnly

            QQC.ToolTip {
                visible: navButton.hovered
                text: navButton.text
                delay: Platform.Units.toolTipDelay
                y: parent.height
            }
        }
        NavButton {
            icon.name: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")
            text: qsTr("Navigate Back")
            enabled: {
                let isScrolled = !LayoutMirroring.enabled ? root.pageStack.columnView.contentX > 0
                    : root.pageStack.columnView.contentWidth - root.pageStack.columnView.contentX !== root.pageStack.columnView.width
                return root.page.QQC.StackView.view || (root.pageStack.depth > 1 && isScrolled);
            }
            visible: root.page.QQC.StackView.view || root.pageStack.globalToolBar.showNavigationButtons & KC.ApplicationHeaderStyle.ShowBackButton
            onClicked: {
                // When we are in a layer, pressing back doesn't change  the index on the main ColumnView
                if (!root.page.QQC.StackView.view) {
                    root.pageStack.currentIndex = root.page.KL.ColumnView.index;
                }
                root.pageStack.goBack();
            }
        }
        NavButton {
            icon.name: (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")
            text: qsTr("Navigate Forward")
            enabled: root.pageStack.currentIndex < root.pageStack.depth - 1
            // Visible when the application enabled it *and* we are not in a layer
            visible: !root.page.QQC.StackView.view && root.pageStack.globalToolBar.showNavigationButtons & KC.ApplicationHeaderStyle.ShowForwardButton
            onClicked: {
                root.pageStack.currentIndex = root.page.KL.ColumnView.index;
                root.pageStack.goForward();
            }
        }
    }
}

