// SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl\carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT

KT.AvatarButton {
    id: root

    contentItem: Avatar {
        id: avatar
        name: root.name
        source: root.source
        cache: root.cache
        asynchronous: root.asynchronous
        sourceSize: root.sourceSize
        color: root.color
        icon {
          name: root.icon.name
          source: root.icon.source
          width: root.icon.width
          height: root.icon.height
          color: root.icon.color
        }
    }

    background: Rectangle {
        radius: height
        color: Platform.Theme.focusColor
        visible: root.visualFocus || root.down
    }
}
