/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.private as KP

QQC2.MenuItem {
    visible: (action as KC.Action)?.visible ?? true
    autoExclusive: (action as KC.Action)?.autoExclusive ?? false
    height: visible ? implicitHeight : 0

    QQC2.ToolTip.text: {
        const kirigamiAction = action as KC.Action;
        if (kirigamiAction) {
            const toolTip = kirigamiAction.tooltip;
            if (toolTip && KP.ActionHelper.hasUsefulToolTip(kirigamiAction.text, toolTip)) {
                return toolTip;
            }
        }
        return "";
    }
    QQC2.ToolTip.visible: hovered && QQC2.ToolTip.text.length > 0
    QQC2.ToolTip.delay: Platform.Units.toolTipDelay

    Accessible.onPressAction: action.trigger()
}
