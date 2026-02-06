/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform

/*!
  \qmltype Form
  \inqmlmodule org.kde.kirigami.forms

  \brief The base class for Form conforming to the
  Kirigami Human Interface Guidelines.

  This is the base element for forms, used for instance in settings pages.
  We usually have a Page that contains a single Form,
  which in turn contains one or more FormGroup, each formGroup containing one or more FormEntry.

  Example usage:
  \qml
  import QtQuick.Controls as QQC
  import org.kde.kirigami as Kirigami

  Kirigami.Form {
    Kirigami.FormGroup {
        title: "Global Settings"
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "Show Sidebar"
            }
        }
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "Auto Save"
            }
        }
    }
    Kirigami.FormGroup {
        title: "Theme Options"
        Kirigami.FormEntry {
            title: "Colors"
            contentItem: QQC.CheckBox {
                text: "Dark Theme"
            }
        }
        Kirigami.FormSeparator {}
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "High Contrast"
            }
        }
        ...
    }
  }
  \endqml
  \sa FormGroup
  \sa FormEntry
  \since 6.24
*/
Item {
    id: root
    // Implementation detail, don't document
    default property alias entries: layout.data
    Accessible.role: Accessible.Form

    implicitWidth: layout.implicitWidth + Platform.Units.smallSpacing * 2
    implicitHeight: layout.implicitHeight + Platform.Units.smallSpacing * 2

    // Internal, don't document
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
                ? Math.min(implicitWidth, parent.width, Platform.Units.gridUnit * 30)
                : Math.min(implicitWidth, parent.width)
        spacing: Platform.Units.largeSpacing
    }
}
