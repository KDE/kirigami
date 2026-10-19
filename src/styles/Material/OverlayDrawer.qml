/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Material
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform

KT.OverlayDrawer {
    id: root

    leftPadding: Platform.Units.largeSpacing + (edge === Qt.LeftEdge ? parent?.SafeArea.margins.left ?? 0 : 0)
    rightPadding: Platform.Units.largeSpacing + (edge === Qt.RightEdge ? parent?.SafeArea.margins.right ?? 0 : 0)
    topPadding: Platform.Units.largeSpacing + (parent?.SafeArea.margins.top ?? 0)
    bottomPadding: Platform.Units.largeSpacing + (parent?.SafeArea.margins.bottom ?? 0)

    background: Rectangle {
        color: Qt.tint(root.Material.backgroundColor, Qt.alpha(root.Material.primary, 0.05))
        topLeftRadius: root.modal && root.edge !== Qt.LeftEdge && root.edge !== Qt.TopEdge ? Platform.Units.largeSpacing * 2 : 0
        topRightRadius: root.modal && root.edge !== Qt.RightEdge && root.edge !== Qt.TopEdge ? Platform.Units.largeSpacing * 2 : 0
        bottomLeftRadius: root.modal && root.edge !== Qt.LeftEdge && root.edge !== Qt.BottomEdge ? Platform.Units.largeSpacing * 2 : 0
        bottomRightRadius: root.modal && root.edge !== Qt.RightEdge && root.edge !== Qt.BottomEdge ? Platform.Units.largeSpacing * 2 : 0
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.32)
    }
}
