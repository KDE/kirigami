/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.forms.private.templates as FT

FT.FormAction {
    id: root

    clickEnabled: true

    leadingItems: Primitives.Icon {
        Layout.fillHeight: true
        source: root.action.icon.name || root.action.icon.source
        color: root.action.icon.color
        Layout.preferredWidth: root.action.icon.width > 0 ? root.action.icon.width : Platform.Units.iconSizes.smallMedium
        Layout.preferredHeight: root.action.icon.height > 0 ? root.action.icon.height : Platform.Units.iconSizes.smallMedium
    }

    contentItem: QQC.Label {
        text: root.action.text
    }
}

