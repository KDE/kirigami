/*
 *  SPDX-FileCopyrightText: 2025-2026 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT


KT.Badge {
    id: root

    padding: Platform.Units.smallSpacing
    topPadding: padding
    // Extra horizontal padding looks better when pill-shaped with icons and long labels
    horizontalPadding: root.pillShaped && !internal.circular && internal.labelVisible ? (padding + Platform.Units.smallSpacing) : padding
    leftPadding: horizontalPadding + (LayoutMirroring.enabled ? internal.extraTrailingPadding : 0)
    rightPadding: horizontalPadding + (LayoutMirroring.enabled ? 0 : internal.extraTrailingPadding)
    bottomPadding: padding

    QtObject {
        id: internal

        readonly property bool labelVisible: root.text.length > 0
        readonly property bool circular: root.implicitContentWidth + root.padding * 2 <= root.implicitHeight
        readonly property int extraTrailingPadding: root.pillShaped && icon.visible && labelVisible ? Platform.Units.smallSpacing : 0
    }

    // Match styling of Kirigami.InlineMessage
    background: Rectangle {
        border.width: 1
        border.color: Qt.alpha(root.backgroundColor, 1)
        color: root.backgroundColor
        radius: root.pillShaped ? root.height / 2 : Platform.Units.cornerRadius
    }
}
