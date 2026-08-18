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
    Layout.topMargin: separator.visible ? Platform.Units.largeSpacing * 3 : 0

    // Don't document this, should never be used directly
    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight + layout.y

    // Internal
    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    // Internal
    property real __assignedWidthForLabels: 0

    Primitives.Separator {
        id: separator
        visible: root.parent.visibleChildren[0] !== root && title.length === 0
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Platform.Units.largeSpacing
            rightMargin: Platform.Units.largeSpacing
            topMargin: -Platform.Units.largeSpacing - Platform.Units.smallSpacing
        }
    }

    KirigamiLayouts.HeaderFooterLayout {
        id: layout
        anchors {
            fill: parent
            topMargin: separator.visible ? Platform.Units.largeSpacing : 0
        }
        spacing: Platform.Units.smallSpacing

        header: KirigamiControls.Heading {
            level: 3
            horizontalAlignment: Text.AlignHCenter
            type: KirigamiControls.Heading.Primary
            visible: text.length > 0
            text: root.title
        }
        contentItem: Item {
            implicitWidth: innerLayout.implicitWidthWithInvisible + __assignedWidthForLabels
            implicitHeight: innerLayout.implicitHeight
            ColumnLayout {
                id: innerLayout
                anchors.fill: parent
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
                children: root.entries
            }
        }
    }
}
