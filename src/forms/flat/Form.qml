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

    implicitWidth: layout.implicitWidth + Kirigami.Units.smallSpacing * 2
    implicitHeight: layout.implicitHeight + Kirigami.Units.smallSpacing * 2

    property bool __collapsed: false

    onWidthChanged: layout.relayoutLabels()

    ColumnLayout {
        id: layout
        property real labelWidth: 0
        onImplicitWidthChanged: relayoutLabels()
        function relayoutLabels() {
            let w = 0;
            for (let entry of children) {
                w = Math.max(w, entry?.__maxTextLabelWidth ?? 0);
            }
            labelWidth = w;
            for (let entry of children) {
                if ("__assignedWidthForLabels" in entry) {
                    entry.__assignedWidthForLabels = w;
                }
            }

            __collapsed = implicitWidth > root.width;
        }
        anchors.centerIn: parent

        width: __collapsed
                ? Math.min(implicitWidth, parent.width, Kirigami.Units.gridUnit * 28)
                : Math.min(implicitWidth, parent.width)
        spacing: Kirigami.Units.largeSpacing * 4 + Kirigami.Units.smallSpacing
    }
}
