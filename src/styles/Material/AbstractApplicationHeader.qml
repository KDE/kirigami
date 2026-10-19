/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Material
import org.kde.kirigami.templates as T
import org.kde.kirigami.platform as Platform

T.AbstractApplicationHeader {
    id: root

    readonly property bool scrolled: root.page?.flickable ? !root.page.flickable.atYBeginning : false
    readonly property color pageBackgroundColor: (root.page?.background as Rectangle)?.color
        ?? (root.page ? root.page.Material.backgroundColor : root.Material.backgroundColor)

    preferredHeight: pageRow ? pageRow.globalToolBar.preferredHeight : Platform.Units.largeSpacing * 8
    maximumHeight: pageRow ? pageRow.globalToolBar.maximumHeight : preferredHeight

    leftPadding: Platform.Units.largeSpacing
    rightPadding: Platform.Units.largeSpacing
    topPadding: Platform.Units.largeSpacing + (pageRow ? pageRow.SafeArea.margins.top : 0)
    bottomPadding: Platform.Units.largeSpacing

    background: Rectangle {
        color: root.scrolled
            ? root.Material.color(root.Material.background, root.Material.Shade50)
            : root.pageBackgroundColor
    }
}
