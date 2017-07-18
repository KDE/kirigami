/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0

/**
 * Graphical representatrion of an Icon
 * @inherit QtQuick.Item
 */
Item {
    id: root
    /**
     * source: string
     * It can be any string Image would recognize as source, or a system-wide icon
     * name that would be defined in a desktop icon theme, such as "go-up"
     */
    property string source

    /**
     * smooth: bool
     * render smoothly
     */
    property alias smooth: image.smooth

    /**
     * active: bool
     * the icon is in an active state, such as under the umouse
     */
    property bool active: false

    /**
     * valid: bool
     * if true the icon loaded correctly
     */
    property bool valid: image.status == Image.Ready 

    /**
     * The icon is in a "selected" status, which usually means its color scheme
     * is inverted and is over a colored background
     */
    property bool selected: false

    implicitWidth: image.source != "" ? Units.iconSizes.smallMedium : 0
    implicitHeight: image.source != "" ? Units.iconSizes.smallMedium : 0

    Image {
        id: image
        anchors.fill: parent
        source: root.source != "" ? (root.source.indexOf(".") === -1 ? "./icons/" + root.source + ".svg" : root.source) : root.source
        sourceSize.width: root.width
        sourceSize.height: root.height
        fillMode: Image.PreserveAspectCrop
    }
    ColorOverlay {

        anchors.fill: parent
        source: image
        color: root.selected ? Theme.highlightedTextColor : Theme.textColor
        cached: true
        visible: root.enabled && root.valid
    }
}
