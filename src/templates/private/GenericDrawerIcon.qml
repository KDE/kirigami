/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    width: height
    height: Kirigami.Units.iconSizes.smallMedium
    property Kirigami.OverlayDrawer drawer
    property color color: Kirigami.Theme.textColor
    opacity: 0.8
    layer.enabled: true

    Kirigami.Icon {
        selected: drawer.handle.pressed
        opacity: 1 - drawer.position
        anchors.fill: parent
        source: drawer.handleClosedIcon.name ? drawer.handleClosedIcon.name : drawer.handleClosedIcon.source
        color: drawer.handleClosedIcon.color
    }
    Kirigami.Icon {
        selected: drawer.handle.pressed
        opacity: drawer.position
        anchors.fill: parent
        source: drawer.handleOpenIcon.name ? drawer.handleOpenIcon.name : drawer.handleOpenIcon.source
        color: drawer.handleOpenIcon.color
    }
}

