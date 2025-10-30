/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Item {
    id: root
    default property alias entries: layout.data
    Accessible.role: Accessible.Form

    implicitWidth: layout.implicitWidth + Kirigami.Units.largeSpacing * 2
    implicitHeight: layout.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing
        width: Math.min(implicitWidth, parent.width, Kirigami.Units.gridUnit * 32)
    }
}
