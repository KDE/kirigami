/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQml
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Loader {
    id: root

    required property Item page
    required property Kirigami.PageRow pageStack

    active: {
        if (!pageStack) {
            return false;
        }
        // The application doesn't want nav buttons
        if (pageStack.globalToolBar.showNavigationButtons === Kirigami.ApplicationHeaderStyle.NoNavigationButtons) {
            return false
        }

        // We are in a layer, show buttons
        // page can be null when the nav buttons are in the breadcrumbs header
        if (page && page.QQC.StackView.view) {
            return true;
        }

        // If we are in single page mode, always show if depth > 1
        if (pageStack.columnView.columnResizeMode === Kirigami.ColumnView.SingleColumn) {
            return pageStack.depth > 1;
        }

        // Condition: the contents have to be bigger than what the ColumnView can show
        // The gridUnit wiggle room is used to not flicker the button visibility during an animated resize for instance due to a sidebar collapse
        const overflows = pageStack.columnView.contentWidth > pageStack.columnView.width + Kirigami.Units.gridUnit;

        // Index will be 0 at the first page in the row, -1 in a page belonging to a layer
        if (!page || page.Kirigami.ColumnView.index <= 0) {
            return overflows;
        }

        // Condition: the page previous of this one is at least half scrolled away
        const previousPage = pageStack.get(page.Kirigami.ColumnView.index - 1);
        let firstVisible = false;
        if (Qt.application.layoutDirection === Qt.RightToLeft) {
            firstVisible = pageStack.width - (page.x + page.width - pageStack.columnView.contentX) < previousPage.width / 2;
        } else {
            firstVisible = previousPage.x - pageStack.columnView.contentX < -previousPage.width / 2;
        }

        return overflows && firstVisible;
    }

    visible: active

    sourceComponent: RowLayout {
        id: layout

        spacing: Kirigami.Units.smallSpacing

        component NavButton: QQC.ToolButton {
            display: QQC.ToolButton.IconOnly

            QQC.ToolTip {
                visible: parent.hovered
                text: parent.text
                delay: Kirigami.Units.toolTipDelay
                y: parent.height
            }
        }
        NavButton {
            icon.name: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")
            text: qsTr("Navigate Back")
            enabled: page.QQC.StackView.view || (pageStack.depth > 1 && pageStack.currentIndex > 0);
            visible: pageStack.globalToolBar.showNavigationButtons & Kirigami.ApplicationHeaderStyle.ShowBackButton
            onClicked: pageStack.goBack();
        }
        NavButton {
            icon.name: (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")
            text: qsTr("Navigate Forward")
            enabled: pageStack.currentIndex < pageStack.depth - 1
            // Visible when the application enabled it *and* we are not in a layer
            visible: !page.QQC.StackView.view && pageStack.globalToolBar.showNavigationButtons & Kirigami.ApplicationHeaderStyle.ShowForwardButton
            onClicked: pageStack.goForward();
        }
    }
}

