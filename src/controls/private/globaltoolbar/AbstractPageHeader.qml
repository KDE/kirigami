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
    maximumHeight: pageRow ? pageRow.globalToolBar.maximumHeight : minimumHeight
    preferredHeight: pageRow ? pageRow.globalToolBar.preferredHeight : minimumHeight

    separatorVisible: pageRow ? pageRow.globalToolBar.separatorVisible : true

    Kirigami.Theme.colorSet: pageRow ? pageRow.globalToolBar.colorSet : Kirigami.Theme.Header

    readonly property Item __stackPage: pageRow?.items.indexOf(page) > -1 ? pageRow.columnView.parent : page
    Binding {
        target: root
        property: "leftPadding"

        when: false//__stackPage.QQC.StackView.status !== QQC.StackView.Deactivating

        restoreMode: Binding.RestoreNone
        value: {
            if (!pageRow) {
                return Kirigami.Units.smallSpacing
            }

            if (!pageRow.wideMode) {
                return Math.max(pageRow.globalToolBar.leftReservedSpace, pageRow.globalToolBar.titleLeftPadding)
            }

            let displacement = 0

            if (Qt.application.layoutDirection === Qt.RightToLeft) {
                displacement = (page.Kirigami.ScenePosition.x + page.width)
                                - (pageRow.Kirigami.ScenePosition.x + pageRow.width - pageRow.globalToolBar.leftReservedSpace)
            } else {
                displacement = pageRow.Kirigami.ScenePosition.x
                                - page.Kirigami.ScenePosition.x
                                + pageRow.globalToolBar.leftReservedSpace
            }

            return Math.max(pageRow.globalToolBar.titleLeftPadding,
                            Math.min(displacement,
                                     pageRow.globalToolBar.leftReservedSpace))
        }
    }

    rightPadding: {
        if (!pageRow) {
            return 0
        }

        if (!pageRow.wideMode) {
            return pageRow.globalToolBar.rightReservedSpace
        }

        let displacement = 0
        if (Qt.application.layoutDirection === Qt.RightToLeft) {
            displacement = pageRow.Kirigami.ScenePosition.x
                            - page.Kirigami.ScenePosition.x
                            + pageRow.globalToolBar.rightReservedSpace
        } else {
            displacement = -pageRow.width
                - pageRow.Kirigami.ScenePosition.x
                + page.width
                + page.Kirigami.ScenePosition.x
                + pageRow.globalToolBar.rightReservedSpace
        }

        return Math.max(0, displacement)
    }
}
