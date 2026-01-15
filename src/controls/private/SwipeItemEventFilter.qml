/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.platform as Platform


MouseArea {
    id: swipeFilter
    anchors {
        right: parent.right
        top: parent.top
        bottom: parent.bottom
    }

    z: 99999
    property Item currentItem
    property real peek

    preventStealing: true
    width: Platform.Units.gridUnit
    onPressed: mouse => {
        const mapped = mapToItem(parent.flickableItem.contentItem, mouse.x, mouse.y);
        currentItem = parent.flickableItem.itemAt(mapped.x, mapped.y);
    }
    onPositionChanged: mouse => {
        const mapped = mapToItem(parent.flickableItem.contentItem, mouse.x, mouse.y);
        currentItem = parent.flickableItem.itemAt(mapped.x, mapped.y);
        peek = 1 - mapped.x / parent.flickableItem.contentItem.width;
    }
}
