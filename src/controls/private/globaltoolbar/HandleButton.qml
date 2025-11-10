/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT


QQC.ToolButton {
    property KT.OverlayDrawer drawer

    icon.name: (drawer?.visible) ? (drawer?.handleOpenIcon.name) : (drawer?.handleClosedIcon.name)
    icon.source: (drawer?.visible) ? (drawer?.handleOpenIcon.source) : (drawer?.handleClosedIcon.source)

    onClicked: {
        if (!drawer) {
            return;
        }
        if (drawer.visible) {
            drawer.close();
        } else {
            drawer.open();
        }
        print(width," ",height)
    }

    QQC.ToolTip {
        visible: parent.hovered
        text: QQC.ApplicationWindow.window?.globalDrawer.handleClosedToolTip
        delay: Kirigami.Units.toolTipDelay
        y: parent.height
    }
}
