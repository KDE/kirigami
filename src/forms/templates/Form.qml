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

    /*!
      If for some implementation reason multiple Forms have to appear
      on the same page, they can have each other in twinForms,
      so they will vertically align with each other perfectly
     */
    property list<Item> twinForms

    // Implementation detail, don't document
    default property alias entries: layout.data
    Accessible.role: Accessible.Form

    implicitWidth: layout.implicitWidth + Platform.Units.smallSpacing * 2
    implicitHeight: layout.implicitHeight + Platform.Units.smallSpacing * 2

    // Internal, don't document
    property bool __collapsed: false

    onWidthChanged: layout.relayoutLabels()

    onTwinFormsChanged: {
        for (const form of twinForms) {
            if (!(form instanceof Form)) {
                continue;
            }
            if (!(root in form.children[0].reverseTwins)) {
                form.children[0].reverseTwins.push(root)
                Qt.callLater(() => form.children[0].reverseTwinsChanged());
            }
        }
    }

    Component.onDestruction: {
        for (const form of twinForms) {
            const child = form.children[0];
            child.reverseTwins = child.reverseTwins.filter(value => value !== root);
        }
    }

    ColumnLayout {
        id: layout
        property real labelWidth: 0
        property real twinImplicitWidth: 0
        property var reverseTwins: []
        onReverseTwinsChanged: relayoutLabels()
        onImplicitWidthChanged: relayoutLabels()
        function relayoutLabels() {
            let w = 0;
            for (let entry of children) {
                w = Math.max(w, entry?.__maxTextLabelWidth ?? 0);
            }
            for (let form of root.twinForms) {
                if (!(form instanceof Form)) {
                    continue;
                }
                for (let entry of form.entries) {
                    w = Math.max(w, entry?.__maxTextLabelWidth ?? 0);
                }
            }
            for (let form of reverseTwins) {
                if (!(form instanceof Form)) {
                    continue;
                }
                for (let entry of form.entries) {
                    w = Math.max(w, entry?.__maxTextLabelWidth ?? 0);
                }
            }

            labelWidth = w;
            for (let entry of children) {
                if ("__assignedWidthForLabels" in entry) {
                    entry.__assignedWidthForLabels = w;
                }
            }

            for (let form of root.twinForms) {
                if (!(form instanceof Form)) {
                    continue;
                }
                twinImplicitWidth = Math.max(twinImplicitWidth, form.children[0]?.implicitWidth);
            }
            for (let form of reverseTwins) {
                if (!(form instanceof Form)) {
                    continue;
                }
                twinImplicitWidth = Math.max(twinImplicitWidth, form.children[0]?.implicitWidth);
            }

            root.__collapsed = Math.max(implicitWidth, twinImplicitWidth) > root.width;
        }
        anchors.centerIn: parent

        width: root.__collapsed
                ? Math.min(implicitWidth, parent.width, Platform.Units.gridUnit * 30)
                : Math.min(Math.max(implicitWidth, twinImplicitWidth), parent.width)
        spacing: Platform.Units.largeSpacing + Platform.Units.smallSpacing
    }
}
