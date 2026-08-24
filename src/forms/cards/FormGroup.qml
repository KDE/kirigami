/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.forms.private.templates as FT

FT.FormGroup {
    id: root

    Layout.fillWidth: true

    default property alias entries: innerLayout.data
    // remove the margins in order to not have relayouting loops
    implicitWidth: Math.max(Platform.Units.gridUnit * 30, layout.implicitWidth - Layout.leftMargin - Layout.rightMargin)
    implicitHeight: layout.implicitHeight

    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    property alias __assignedWidthForLabels: innerLayout.__assignedWidthForLabels

    KirigamiLayouts.HeaderFooterLayout {
        id: layout
        anchors.fill: parent
        property bool compactMargins: parentLayout.width >= parentLayout.parent.width
        property ColumnLayout parentLayout: root.parent
        spacing: Platform.Units.smallSpacing

        header: KC.Heading {
            level: 5
            leftPadding: Platform.Units.cornerRadius + (layout.compactMargins ? Platform.Units.largeSpacing : 0)
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: KC.AbstractCard {
            padding: 0
            implicitWidth: innerLayout.implicitWidth + __assignedWidthForLabels
            rightInset: layout.compactMargins ? -Platform.Units.largeSpacing : 0
            leftInset: rightInset
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
