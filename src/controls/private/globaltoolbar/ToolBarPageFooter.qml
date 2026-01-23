/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform

QQC2.ToolBar {
    id: root
    position: QQC2.ToolBar.Footer

    NumberAnimation {
        id: appearAnim
        target: root
        property: "height"
        duration: Platform.Units.longDuration
        easing.type: Easing.InOutQuad
    }

    Connections {
        target: applicationWindow()
        function onControlsVisibleChanged() {
            if (applicationWindow().controlsVisible) {
                appearAnim.from = 0;
                appearAnim.to = root.implicitHeight;
            } else {
                appearAnim.from = root.implicitHeight;
                appearAnim.to = 0;
            }
            appearAnim.restart();
        }
    }

    contentItem: KC.ActionToolBar {
        display: QQC2.Button.TextUnderIcon
        position: QQC2.ToolBar.Footer
        alignment: Qt.AlignCenter
        actions: root.parent.page.actions
    }
}
