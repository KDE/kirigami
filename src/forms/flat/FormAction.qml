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
    property alias icon: mainButton.icon
    property alias text: mainButton.text
    readonly property alias triggerIcon: triggerIconProps

    signal clicked

    Kirigami.IconPropertiesGroup {
        id: triggerIconProps
    }
    contentItem: QQC.Button {
        id: mainButton
        onClicked: root.clicked()
    }
    trailingItems: Kirigami.Icon {
        Layout.fillHeight: true
        Layout.maximumHeight: Kirigami.Units.iconSizes.smallMedium
        source: root.triggerIcon.name || root.triggerIcon.source
        color: root.triggerIcon.color
        visible: valid
    }
}
