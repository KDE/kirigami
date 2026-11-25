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
import org.kde.kirigami.controls as KC
import org.kde.kirigami.private as KP
import org.kde.kirigami.forms.private.templates as FT

FT.FormAction {
    id: root

    clickEnabled: true

    QQC.ToolTip.visible: QQC.ToolTip.text.length > 0 && (root.hovered || root.visualFocus)
    QQC.ToolTip.text: {
        const kirigamiAction = root.action as KC.Action;
        if (kirigamiAction && KP.ActionHelper.hasUsefulToolTip(kirigamiAction.text, kirigamiAction.tooltip)) {
            return kirigamiAction.tooltip;
        }
        return "";
    }
    QQC.ToolTip.delay: Platform.Units.toolTipDelay

    leadingItems: Primitives.Icon {
        Layout.fillHeight: true
        source: root.action.icon.name || root.action.icon.source
        color: root.action.icon.color
        visible: valid
        Layout.preferredWidth: root.action.icon.width > 0 ? root.action.icon.width : Platform.Units.iconSizes.smallMedium
        Layout.preferredHeight: root.action.icon.height > 0 ? root.action.icon.height : Platform.Units.iconSizes.smallMedium
    }

    contentItem: QQC.Label {
        Layout.fillWidth: true
        text: root.action.text
        enabled: root.action.enabled
    }
}

