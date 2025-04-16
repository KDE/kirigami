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

    leftPadding: pageRow.globalToolBar.titleLeftPadding
    readonly property Item __stackPage: pageRow?.items.indexOf(page) > -1 ? pageRow.columnView.parent : page
    Binding {
        target: root
        property: "leftPadding"

        when: false && __stackPage.QQC.StackView.status !== QQC.StackView.Deactivating

        restoreMode: Binding.RestoreNone
        value: pageRow
            ? Math.min(
                width / 2,
                Math.max(
                    (page.title.length > 0 ? pageRow.globalToolBar.titleLeftPadding : 0),
                    Qt.application.layoutDirection === Qt.LeftToRight
                        ? Math.min(pageRow.globalToolBar.leftReservedSpace,
                            pageRow.Kirigami.ScenePosition.x
                            - page.Kirigami.ScenePosition.x
                            + pageRow.globalToolBar.leftReservedSpace)
                            + Kirigami.Units.smallSpacing
                        : Math.min(pageRow.globalToolBar.leftReservedSpace,
                            -pageRow.width
                            + pageRow.Kirigami.ScenePosition.x
                            + page.Kirigami.ScenePosition.x
                            + page.width
                            + pageRow.globalToolBar.leftReservedSpace)
                            + Kirigami.Units.smallSpacing))
            : Kirigami.Units.smallSpacing
    }
}
