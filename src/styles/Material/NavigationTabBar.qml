/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Material
import org.kde.kirigami.templates as KT

KT.NavigationTabBar {
    id: root

    // Reset the ToolBar's primary-colored background to the inherited surface.
    Material.background: undefined

    spacing: 0
    topPadding: position === ToolBar.Header && parent ? parent.SafeArea.margins.top : 0
    bottomPadding: position === ToolBar.Footer && parent ? parent.SafeArea.margins.bottom : 0
    leftPadding: Math.floor(Math.max(0, width - maximumContentWidth) / 2) + (parent ? parent.SafeArea.margins.left : 0)
    rightPadding: Math.floor(Math.max(0, width - maximumContentWidth) / 2) + (parent ? parent.SafeArea.margins.right : 0)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth)
    implicitHeight: Math.max(implicitBackgroundHeight, contentHeight) + topPadding + bottomPadding

    background: Rectangle {
        implicitHeight: 64
        color: Qt.tint(root.Material.backgroundColor, Qt.alpha(root.Material.primary, 0.05))
    }
}
