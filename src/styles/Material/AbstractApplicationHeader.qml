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

    preferredHeight: pageRow ? pageRow.globalToolBar.preferredHeight : Platform.Units.largeSpacing * 8
    maximumHeight: pageRow ? pageRow.globalToolBar.maximumHeight : preferredHeight

    leftPadding: Platform.Units.largeSpacing
    rightPadding: Platform.Units.largeSpacing
    topPadding: Platform.Units.largeSpacing + (pageRow ? pageRow.SafeArea.margins.top : 0)
    bottomPadding: Platform.Units.largeSpacing

    background: Rectangle {
        color: Qt.tint(root.Material.backgroundColor, Qt.alpha(root.Material.primary, 0.05))
    }
}
