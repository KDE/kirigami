/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.controls as KirigamiControls
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.forms.private.templates as FT


FT.FormGroup {
    id: root

    Layout.fillWidth: true

    // Don't document this, should never be used directly
    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // Internal
    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    // Internal
    property real __assignedWidthForLabels: 0
    // Internal
    readonly property real __formSpacing: root.parent?.spacing ?? Platform.Units.largeSpacing + Platform.Units.smallSpacing


    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: root.__formSpacing
        Primitives.Separator {
            visible: root.parent?.visibleChildren[0] !== root && root.title.length === 0
            Layout.fillWidth: true
            Layout.topMargin: root.__formSpacing
            Layout.margins: Platform.Units.largeSpacing
        }
        KirigamiControls.Heading {
            Layout.fillWidth: true
            level: 3
            horizontalAlignment: Text.AlignHCenter
            type: KirigamiControls.Heading.Primary
            visible: text.length > 0
            text: root.title
        }
        ColumnLayout {
            id: innerLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: innerLayout.implicitWidthWithInvisible + root.__assignedWidthForLabels
            Layout.preferredHeight: innerLayout.implicitHeight
            property real labelWidth: 0
            // Consider also invisible items when
            property real implicitWidthWithInvisible: 0
            onImplicitWidthChanged: {
                let w = 0;
                implicitWidthWithInvisible = 0
                for (let entry of children) {
                    w = Math.max(w, entry?.__textLabelWidth ?? 0);
                    implicitWidthWithInvisible = Math.max(implicitWidthWithInvisible, entry.implicitWidth, entry.Layout.preferredWidth)
                }
                labelWidth = w;
            }
            spacing: Platform.Units.smallSpacing
        }
    }
}
