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

    Layout.fillWidth: true

    property string title
    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight + layout.y

    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    property real __assignedWidthForLabels: 0

    Kirigami.Separator {
        id: separator
        visible: root.y > 0 && title.length === 0
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
            topMargin: -Kirigami.Units.largeSpacing - Kirigami.Units.smallSpacing
        }
    }

    Kirigami.HeaderFooterLayout {
        id: layout
        anchors {
            fill: parent
            topMargin: separator.visible ? Kirigami.Units.largeSpacing : 0
        }
        spacing: Kirigami.Units.smallSpacing

        header: Kirigami.Heading {
            level: 4
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: Item {
            implicitWidth: innerLayout.implicitWidth + __assignedWidthForLabels//+ innerLayout.labelWidth
            implicitHeight: innerLayout.implicitHeight
            ColumnLayout {
                id: innerLayout
                anchors {
                    fill: parent
                    leftMargin: root.parent.parent.__collapsed ? 0 : root.__assignedWidthForLabels
                }
                property real labelWidth: 0
                onImplicitWidthChanged: {
                    let w = 0;
                    for (let entry of children) {
                        w = Math.max(w, entry?.__textLabelWidth ?? 0);
                    }
                    labelWidth = w;
                }
                spacing: Kirigami.Units.smallSpacing
            }
        }
    }
}
