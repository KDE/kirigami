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
    Layout.leftMargin: layout.compactMargins ? -Platform.Units.gridUnit : 0
    Layout.rightMargin: layout.compactMargins ? -Platform.Units.gridUnit : 0

    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    property alias __assignedWidthForLabels: innerLayout.__assignedWidthForLabels

    clip: layout.compactMargins

    KirigamiLayouts.HeaderFooterLayout {
        id: layout
        anchors {
            fill: parent
            leftMargin: layout.compactMargins ? -Platform.Units.cornerRadius : 0
            rightMargin:layout.compactMargins ?  -Platform.Units.cornerRadius : 0
        }
        property bool compactMargins: parentLayout.width >= parentLayout.parent.width
        property ColumnLayout parentLayout: root.parent
        spacing: Platform.Units.smallSpacing

        header: KC.Heading {
            level: 5
            leftPadding: Platform.Units.gridUnit + Platform.Units.cornerRadius
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: KC.AbstractCard {
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
