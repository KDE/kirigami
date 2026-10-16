/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.templates as KT

KT.Avatar {
    id: root

    background: Rectangle {
        visible: !root.__showImage
        anchors.fill: parent
        radius: root.radius

        border.width: 1.25
        border.color: root.color
        color: Platform.ColorUtils.tintWithAlpha(Platform.Theme.backgroundColor, border.color, 0.07)
    }
}
