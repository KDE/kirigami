/*
 * SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.templates.private as KTP

/*!
  \qmltype IconTitleSubtitle
  \inqmlmodule org.kde.kirigami.delegates

  \brief A simple item containing an icon, title and subtitle.

  This is an extension of TitleSubtitle that adds an icon to the side.
  It is intended as a contentItem for ItemDelegate and related controls.

  When using it as a contentItem, make sure to bind the appropriate properties
  to those of the Control. Prefer binding to the Control's properties over
  setting the properties directly, as the Control's properties may affect other
  things like setting accessible names.

  This (and TitleSubtitle) can be combined with other controls in a layout to
  create complex content items for controls.

  Example usage creating a CheckDelegate with an extra button on the side:

  \qml
  CheckDelegate {
      id: delegate

      text: "Example"
      icon.name: "document-new"

      contentItem: RowLayout {
          spacing: Kirigami.Units.smallSpacing

          Kirigami.IconTitleSubtitle {
              Layout.fillWidth: true

              icon: icon.fromControlsIcon(delegate.icon)
              title: delegate.text
              selected: delegate.highlighted || delegate.down
              font: delegate.font
          }

          Button {
              icon.name: "document-open"
              text: "Extra Action"
          }
      }
  }
  \endqml

  \sa TitleSubtitle
  \sa ItemDelegate
 */
Item {
    id: root

    /*!
      The title to display.
     */
    required property string title
    /*!
      \qmlproperty string subtitle
      The subtitle to display.
     */
    property alias subtitle: titleSubtitle.subtitle
    /*!
      \qmlproperty color color
      The color to use for the title.

      By default this is `Kirigami.Theme.textColor` unless `selected` is true
      in which case this is `Kirigami.Theme.highlightedTextColor`.
     */
    property alias color: titleSubtitle.color
    /*!
      \qmlproperty color subtitleColor

      The color to use for the subtitle.

      By default this is color mixed with the background color.
     */
    property alias subtitleColor: titleSubtitle.subtitleColor
    /*!
      \qmlproperty font font
      The font used to display the title.
     */
    property alias font: titleSubtitle.font
    /*!
      \qmlproperty font subtitleFont
      The font used to display the subtitle.
     */
    property alias subtitleFont: titleSubtitle.subtitleFont
    /*!
      \qmlproperty bool reserveSpaceForSubtitle
      Make the implicit height use the subtitle's height even if no subtitle is set.
     */
    property alias reserveSpaceForSubtitle: titleSubtitle.reserveSpaceForSubtitle
    /*!
      \qmlproperty bool selected
      Should this item be displayed in a selected style?
     */
    property alias selected: titleSubtitle.selected
    /*!
      \qmlproperty int elide
      The text elision mode used for both the title and subtitle.
     */
    property alias elide: titleSubtitle.elide
    /*!
      \qmlproperty int wrapMode
      The text wrap mode used for both the title and subtitle.
     */
    property alias wrapMode: titleSubtitle.wrapMode
    /*!
      \qmlproperty bool truncated
      Is the title or subtitle truncated?
     */
    property alias truncated: titleSubtitle.truncated

    /*!
      \qmlproperty string icon.name
      \qmlproperty var icon.source
      \qmlproperty color icon.color
      \qmlproperty real icon.width
      \qmlproperty real icon.height
      \qmlproperty function icon.fromControlsIcon

      Grouped property for icon properties.

      \note By default, IconTitleSubtitle will reserve the space for the icon,
      even if it is not set. To remove that space, set `icon.width` to 0.

      \include iconpropertiesgroup.qdocinc grouped-properties
     */
    property KTP.IconPropertiesGroup icon: KTP.IconPropertiesGroup {
        width: titleSubtitle.subtitleVisible ? Platform.Units.iconSizes.medium : Platform.Units.iconSizes.smallMedium
        height: width
    }

    /*!
      \brief Emitted when the user clicks on a link embedded in the text of the title or subtitle.
     */
    signal linkActivated(string link)

    /*!
      \brief Emitted when the user hovers on a link embedded in the text of the title or subtitle.
     */
    signal linkHovered(string link)

    implicitWidth: iconItem.implicitWidth + titleSubtitle.anchors.leftMargin + titleSubtitle.implicitWidth
    implicitHeight: Math.max(iconItem.implicitHeight, titleSubtitle.implicitHeight)

    Primitives.Icon {
        id: iconItem

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        source: root.icon.name.length > 0 ? root.icon.name : root.icon.source
        implicitWidth: root.icon.width
        implicitHeight: root.icon.height
        selected: root.selected
        color: root.icon.color
    }

    TitleSubtitle {
        id: titleSubtitle

        anchors {
            left: iconItem.right
            leftMargin: root.icon.width > 0 ? Platform.Units.mediumSpacing : 0
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        title: root.title

        onLinkActivated: link => root.linkActivated(link)
        onLinkHovered: link => root.linkHovered(link)
    }
}
