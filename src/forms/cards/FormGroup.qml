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
    implicitHeight: layout.implicitHeight

    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    property alias __assignedWidthForLabels: innerLayout.__assignedWidthForLabels

    Kirigami.HeaderFooterLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        header: Kirigami.Heading {
            level: 5
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: Kirigami.AbstractCard {
            padding: 0
            implicitWidth: innerLayout.implicitWidth + __assignedWidthForLabels
            contentItem: ColumnLayout {
                id: innerLayout
                property real labelWidth: 0
                property real __assignedWidthForLabels: 0
                onImplicitWidthChanged: {
                    let w = 0;
                    for (let entry of children) {
                        w = Math.max(w, entry?.__textLabelWidth ?? 0);
                    }
                    labelWidth = w;
                }
                spacing: 0
            }
        }
    }
}
