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
  \qmltype FormGroup
  \inqmlmodule org.kde.kirigami.forms

  \brief The container class that identifies a container of related controls in a form.

  This element should always be positioned in a Form. It is used to group together
  related form controls, to separate different settings categories.
  Every form should always have at least one FormGroup.

  A FormGroup should contain only elements of type FormEntry or FormSeparator (or derivates)

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
  \sa Form
  \sa FormEntry
  \since 6.24
*/
FormGroup {
    id: root

    default property alias data: cardsLayout.data
    property alias children: cardsLayout.children
    property alias visibleChildren: cardsLayout.visibleChildren

    Layout.fillWidth: true
    implicitWidth: cardsLayout.implicitWidth
    implicitHeight: cardsLayout.implicitHeight

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
