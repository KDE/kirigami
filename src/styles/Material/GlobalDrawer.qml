// SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.kde.kirigami.controls as KC
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform

KT.GlobalDrawer {
    id: root

    collapsedSize: Platform.Units.largeSpacing * 10
    preferredSize: Platform.Units.gridUnit * 18

    _actionSpacing: collapsed ? Platform.Units.smallSpacing : 0

    header: Item {
        visible: root.title.length > 0 || Boolean(root.titleIcon)
        implicitWidth: headerLayout.implicitWidth + (root.collapsed ? 0 : Platform.Units.largeSpacing * 4)
        implicitHeight: Math.max(Platform.Units.largeSpacing * 6, headerLayout.implicitHeight)

        RowLayout {
            id: headerLayout

            anchors.fill: parent
            anchors.leftMargin: root.collapsed ? 0 : Platform.Units.largeSpacing * 2
            anchors.rightMargin: root.collapsed ? 0 : Platform.Units.largeSpacing * 2
            spacing: Platform.Units.largeSpacing * 2

            Item {
                visible: Boolean(root.titleIcon)
                implicitWidth: Platform.Units.iconSizes.smallMedium
                implicitHeight: Platform.Units.iconSizes.medium
                Layout.alignment: Qt.AlignCenter

                Primitives.Icon {
                    anchors.centerIn: parent
                    source: root.titleIcon
                    implicitWidth: Platform.Units.iconSizes.medium
                    implicitHeight: Platform.Units.iconSizes.medium
                }
            }

            KC.Heading {
                text: root.title
                visible: !root.collapsed
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
