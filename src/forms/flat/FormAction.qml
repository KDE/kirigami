/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KC
import org.kde.kirigami.private as KP
import org.kde.kirigami.forms.private.templates as FT

FT.FormAction {
    id: root

    triggerIcon.name: ""

    contentItem: QQC.Button {
        icon {
            name: root.action.icon.name
            source: root.action.icon.source
            color: root.action.icon.color
            width: root.action.icon.width
            height: root.action.icon.height
        }
        text: root.action.text
        enabled: root.action.enabled

        QQC.ToolTip.visible: QQC.ToolTip.text.length > 0 && (hovered || visualFocus)
        QQC.ToolTip.text: {
            const kirigamiAction = root.action as KC.Action;
            if (kirigamiAction && KP.ActionHelper.hasUsefulToolTip(kirigamiAction.text, kirigamiAction.tooltip)) {
                return kirigamiAction.tooltip;
            }
            return "";
        }
        QQC.ToolTip.delay: Platform.Units.toolTipDelay
        onClicked: {
            root.clicked();
        }
    }
}
