/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

FormEntry {
    id: root

    required property T.Action action
    readonly property Primitives.IconPropertiesGroup triggerIcon: Primitives.IconPropertiesGroup {
        id: triggerIconProps
    }
    contentItem: QQC.Button {
        icon {
            name: root.action.icon.name
            source: root.action.icon.source
            color: root.action.icon.color
            width: root.action.icon.width
            height: root.action.icon.height
        }
        text: root.action.text
        onClicked: {
            root.clicked();
            root.action.trigger();
        }
    }
    trailingItems: Primitives.Icon {
        Layout.fillHeight: true
        Layout.maximumHeight: triggerIconProps.height <= 0 ? Platform.Units.iconSizes.smallMedium : Infinity
        source: root.triggerIcon.name || root.triggerIcon.source
        color: root.triggerIcon.color
        Layout.preferredWidth: triggerIconProps.width > 0 ? triggerIconProps.width : -1
        Layout.preferredHeight: triggerIconProps.height > 0 ? triggerIconProps.height : -1
    }
}
