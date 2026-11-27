/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KC
import org.kde.kirigami.layouts as KL


/*!
  \qmltype GridFormGroup
  \inqmlmodule org.kde.kirigami.forms

  \brief A container class for related rorm entries. When there is enough horizontal space, it will
  show the entries in a two columns grid.

  Use this group when you want to have controls in two columns, they will be represented as a grid of little cards.
  This element should always be positioned in a Form. It is used to group together
  related form controls, to separate different settings categories.

  A FormGroup should contain only elements of type FormEntry or FormSeparator (or derivates)

  Example usage:
  \qml
  import QtQuick.Controls as QQC
  import org.kde.kirigami as Kirigami

  Kirigami.Form {
    Kirigami.GridFormGroup {
        title: "Theme Options"
        Kirigami.FormEntry {
            title: "Colors"
            contentItem: QQC.CheckBox {
                text: "Dark Theme"
            }
        }
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "High Contrast"
            }
        }
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
        ...
    }
  }
  \endqml
  \sa Form
  \sa FormEntry
  \sa FormGroup
  \since 6.24
*/
FormGroup {
    id: root

    Layout.fillWidth: true

    /*!
      \brief How many columns the grid has in this moment.
     */
    readonly property int columns: cardsLayout.columns

    /*!
      \brief How many columns the grid is allowed to have at max
     */
    readonly property alias maximumColumns: cardsLayout.maximumColumns

    default property alias entries: cardsLayout.data
    implicitWidth: Math.max(Platform.Units.gridUnit * 30, layout.implicitWidth - Layout.leftMargin - Layout.rightMargin)
    implicitHeight: layout.implicitHeight

    // Internal
    readonly property real __maxTextLabelWidth: 0
    // Internal
    property alias __assignedWidthForLabels: cardsLayout.__assignedWidthForLabels
    // Internal
    readonly property real __formSpacing: root.parent?.spacing ?? Platform.Units.largeSpacing + Platform.Units.smallSpacing

    KL.HeaderFooterLayout {
        id: layout
        anchors {
            fill: parent
            leftMargin: compactMargins ? -Platform.Units.largeSpacing : 0
            rightMargin: compactMargins ? -Platform.Units.largeSpacing : 0
        }

        property bool compactMargins: parentLayout.width >= parentLayout.parent.width
        property ColumnLayout parentLayout: root.parent as ColumnLayout

        spacing: Platform.Units.smallSpacing

        header: KC.Heading {
            level: 5
            leftPadding: Platform.Units.cornerRadius + (layout.compactMargins ? Platform.Units.largeSpacing : 0)
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }

        contentItem: KC.CardsLayout {
            id: cardsLayout
            property real __assignedWidthForLabels: 0

            function updateSpacersVisibility() {
                for(const entry of children) {
                    if (entry instanceof FormSeparator) {
                        entry.visible = columns === 1;
                    }
                }
            }
            rowSpacing: columns === 1 ? 0 : Platform.Units.largeSpacing
            onChildrenChanged: updateSpacersVisibility()
            onColumnsChanged: updateSpacersVisibility()
        }
    }

    property Item background  // TODO: make this a Control? I don't like contentItem being accessible

    Binding {
        when: root.background !== null
        root.background {
            parent: root
            z: -1
            anchors.fill: root.background.parent
            anchors.leftMargin: layout.anchors.leftMargin
            anchors.rightMargin: layout.anchors.rightMargin
        }
    }
}
