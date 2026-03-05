/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
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
    leftPadding: internal.horizontalPadding + (LayoutMirroring.enabled ? internal.extraTrailingPadding : 0)
    rightPadding: internal.horizontalPadding + (LayoutMirroring.enabled ? 0 : internal.extraTrailingPadding)
    bottomPadding: padding

    QtObject {
        id: internal

        readonly property bool labelVisible: root.text.length > 0

        // Extra horizontal padding looks better when pill-shaped with icons and long labels
        readonly property int horizontalPadding: root.pillShaped && labelVisible && root.text.length > 2 ? (padding + Platform.Units.smallSpacing) : padding
        readonly property int extraTrailingPadding: root.pillShaped && icon.visible && labelVisible ? Platform.Units.smallSpacing : 0
    }

    background: Rectangle {
        color: root.backgroundColor
        radius: root.pillShaped ? root.implicitHeight / 2 : Platform.Units.cornerRadius
    }
}
