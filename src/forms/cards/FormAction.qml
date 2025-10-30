/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

FormEntry {
    id: root
    readonly property alias icon: iconProps
    property alias text: mainLabel.text
    readonly property alias triggerIcon: triggerIconProps

    Kirigami.IconPropertiesGroup {
        id: iconProps
    }
    Kirigami.IconPropertiesGroup {
        id: triggerIconProps
        name: "go-next-symbolic"
    }
    leadingItems: Kirigami.Icon {
        Layout.fillHeight: true
        source: root.icon.name || root.icon.source
        color: root.icon.color
    }
    contentItem: QQC.Label {
        id: mainLabel
    }
    trailingItems: Kirigami.Icon {
        Layout.fillHeight: true
        Layout.maximumHeight: Kirigami.Units.iconSizes.smallMedium
        source: root.triggerIcon.name || root.triggerIcon.source
        color: root.triggerIcon.color
    }
}
