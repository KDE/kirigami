/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Kirigami.AbstractApplicationHeader {
    id: root
    // anchors.fill: parent
    property Item container
    property bool current

    minimumHeight: pageRow ? pageRow.globalToolBar.minimumHeight : Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2
    maximumHeight: (pageRow ? pageRow.globalToolBar.maximumHeight : minimumHeight) + root.topPadding + root.bottomPadding
    preferredHeight: (pageRow ? pageRow.globalToolBar.preferredHeight : minimumHeight) + root.topPadding + root.bottomPadding

    separatorVisible: pageRow ? pageRow.globalToolBar.separatorVisible : true

    Kirigami.Theme.colorSet: pageRow ? pageRow.globalToolBar.colorSet : Kirigami.Theme.Header

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
            if (page.x - pageStack.columnView.contentX < pageRow.globalToolBar.rightReservedSpace) {
                return pageRow.globalToolBar.rightReservedSpace;
            }
        } else {
            if (pageStack.width - (page.x + page.width - pageStack.columnView.contentX) < pageRow.globalToolBar.rightReservedSpace) {
                return pageRow.globalToolBar.rightReservedSpace;
            }
        }
        return 0;
    }
}
