/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.MenuItem {
    visible: !(action instanceof Kirigami.Action) || action.visible
    height: visible ? implicitHeight : 0

    QQC2.ToolTip.text: (action instanceof Kirigami.Action) ? action.tooltip : ""
    QQC2.ToolTip.visible: hovered && QQC2.ToolTip.text.length > 0
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
}
