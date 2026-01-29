/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami.templates as KT
import org.kde.kirigami.private.polyfill

KT.NavigationTabBar {
    id: root

    // ensure that by default, we do not have unintended padding and spacing from the style
    spacing: 0
    topPadding: root.position === QQC.ToolBar.Header ? parent.SafeArea.margins.top : 0
    bottomPadding: root.position === QQC.ToolBar.Footer ? parent.SafeArea.margins.bottom : 0
    // Using Math.round() on horizontalPadding can cause the contentItem to jitter left and right when resizing the window.
    leftPadding: Math.floor(Math.max(0, width - root.maximumContentWidth) / 2) + parent.SafeArea.margins.left
    rightPadding: Math.floor(Math.max(0, width - root.maximumContentWidth) / 2) + parent.SafeArea.margins.right

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

}
