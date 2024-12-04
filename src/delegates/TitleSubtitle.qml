/*
 * SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.platform as Platform

/*!
  \qmltype TitleSubtitle
  \inqmlmodule org.kde.kirigami.delegates

  \brief A simple item containing a title and subtitle label.

  This is mainly intended as a replacement for a list delegate content item,
  but can be used as a replacement for other content items as well.

  When using it as a contentItem, make sure to bind the appropriate properties
  to those of the Control. Prefer binding to the Control's properties over
  setting the properties directly, as the Control's properties may affect other
  things like setting accessible names.

  Example usage as contentItem of an ItemDelegate:

  \qml
  ItemDelegate {
      id: delegate

      text: "Example"

      contentItem: Kirigami.TitleSubtitle {
          title: delegate.text
          subtitle: "This is an example."
          font: delegate.font
          selected: delegate.highlighted || delegate.down
      }
  }
  \endqml

  \sa IconTitleSubtitle
  \sa ItemDelegate
 */
Item {
    id: root

    /*!
      The title to display.
     */
    required property string title
    /*!
      The subtitle to display.
     */
    property string subtitle
    /*!
      The color to use for the title.

      By default this is Kirigami.Theme.textColor unless selected is true
      in which case this is Kirigami.Theme.highlightedTextColor.
     */
    property color color: selected ? Platform.Theme.highlightedTextColor : Platform.Theme.textColor
    /*!
      The color to use for the subtitle.

      By default this is color mixed with the background color.
     */
    property color subtitleColor: selected
        ? Platform.Theme.highlightedTextColor
        : Platform.ColorUtils.linearInterpolation(color, Platform.Theme.backgroundColor, 0.3)
    /*!
      The font used to display the title.
     */
    property font font: Platform.Theme.defaultFont
    /*!
      The font used to display the subtitle.
     */
    property font subtitleFont: Platform.Theme.smallFont
    /*!
      The text elision mode used for both the title and subtitle.
     */
    property int elide: Text.ElideRight
    /*!
      The text wrap mode used for both the title and subtitle.
     */
    property int wrapMode: Text.NoWrap
    /*!
      Make the implicit height use the subtitle's height even if no subtitle is set.
     */
    property bool reserveSpaceForSubtitle: false
    /*!
      Should this item be displayed in a selected style?
     */
    property bool selected: false
    /*!
      Is the subtitle visible?
     */
    // Note: Don't rely on subtitleItem.visible because visibility is an
    // implicitly propagated property, and we don't wanna re-layout on
    // hide/show events. Copy-paste its bound expression instead.
    readonly property bool subtitleVisible: subtitle.length > 0 || reserveSpaceForSubtitle
    /*!
      Is the title or subtitle truncated?
     */
    readonly property bool truncated: labelItem.truncated || subtitleItem.truncated

    /*!
      \brief Emitted when the user clicks on a link embedded in the text of the title or subtitle.
     */
    signal linkActivated(string link)

    /*!
      \brief Emitted when the user hovers on a link embedded in the text of the title or subtitle.
     */
    signal linkHovered(string link)

    implicitWidth: Math.max(labelItem.implicitWidth, subtitleItem.implicitWidth)
    implicitHeight: labelItem.implicitHeight + (subtitleVisible ? subtitleItem.implicitHeight : 0)

    Text {
        id: labelItem

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        // Switch off here as this is expected to be set in the base component.
        Accessible.ignored: true

        text: root.title
        color: root.color
        font: root.font
        elide: root.elide
        wrapMode: root.wrapMode

        onLinkActivated: link => root.linkActivated(link)
        onLinkHovered: link => root.linkHovered(link)

        // Work around Qt bug where left aligned text is not right aligned
        // in RTL mode unless horizontalAlignment is explicitly set.
        // https://bugreports.qt.io/browse/QTBUG-95873
        horizontalAlignment: Text.AlignLeft

        // Note: Can't do this through ordinary bindings as the order between
        // binding evaluation is not defined which leads to incorrect sizing or
        // the QML engine complaining about not being able to anchor to null items.
        states: State {
            // Note: Same thing about visibility as in subtitleVisible above.
            when: root.subtitle.length > 0
            AnchorChanges {
                target: labelItem
                anchors.verticalCenter: undefined
                anchors.bottom: subtitleItem.top
            }
        }
    }

    Text {
        id: subtitleItem

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        text: root.subtitle
        color: root.subtitleColor
        font: root.subtitleFont
        elide: root.elide
        wrapMode: root.wrapMode

        visible: text.length > 0

        onLinkActivated: link => root.linkActivated(link)
        onLinkHovered: link => root.linkHovered(link)

        // Work around Qt bug where left aligned text is not right aligned
        // in RTL mode unless horizontalAlignment is explicitly set.
        // https://bugreports.qt.io/browse/QTBUG-95873
        horizontalAlignment: Text.AlignLeft

        renderType: Text.NativeRendering
    }
}
