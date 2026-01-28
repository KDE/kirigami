/*
 *  SPDX-FileCopyrightText: 2019 Björn Feber <bfeber@protonmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.controls as KC

/*!
  \qmltype ListSectionHeader
  \inqmlmodule org.kde.kirigami

  \brief A section delegate for the primitive ListView component.

  It's intended to make all listviews look coherent.

  Any additional content items will be positioned in a row at the trailing side
  of this component.

  Example usage:
  \code
  import QtQuick
  import QtQuick.Controls as QQC2
  import org.kde.kirigami as Kirigami

  ListView {
      section.delegate: Kirigami.ListSectionHeader {
          text: section

          QQC2.Button {
              text: "Button 1"
          }
          QQC2.Button {
              text: "Button 2"
          }
      }
  }
  \endcode
 */
QQC2.ItemDelegate {
    id: listSection

    /*!
      \brief This property sets the text of the ListView's section header.

      \a string label

      \deprecated[6.2] Use base type's AbstractButton::text property directly
     */
    @Deprecated { reason: "Use base type's AbstractButton::text property directly" }
    property alias label: listSection.text

    default property alias _contents: rowLayout.data

    hoverEnabled: false

    activeFocusOnTab: false

    icon {
        width: Platform.Units.iconSizes.smallMedium
        height: Platform.Units.iconSizes.smallMedium
    }

    // we do not need a background
    background: Item {}

    topPadding: Platform.Units.largeSpacing + Platform.Units.smallSpacing

    Accessible.role: Accessible.Heading

    contentItem: RowLayout {
        id: rowLayout
        spacing: Platform.Units.largeSpacing

        Primitives.Icon {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: listSection.icon.width
            implicitHeight: listSection.icon.height
            color: listSection.icon.color
            source: listSection.icon.name.length > 0 ? listSection.icon.name : listSection.icon.source
            visible: valid
        }
        KC.Heading {
            Layout.maximumWidth: rowLayout.width
            Layout.alignment: Qt.AlignVCenter

            opacity: 0.75
            level: 5
            type: KC.Heading.Primary
            text: listSection.text
            elide: Text.ElideRight

            // we override the Primary type's font weight (DemiBold) for Bold for contrast with small text
            font.weight: Font.Bold

            Accessible.ignored: true
        }

        Primitives.Separator {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Accessible.ignored: true
        }
    }
}
