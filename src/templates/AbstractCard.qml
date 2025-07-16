/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/*!
  \qmltype AbstractCard
  \inqmlmodule org.kde.kirigami

  \brief The base item for all kinds of cards

  A card is a visual object that groups its contents into a logical unit,
  connecting them all together visually. Cards can be interactive and clickable,
  or visual only, purely used for grouping.

  AbstractCard is an empty card, providing just the styling and basic
  properties. Use an AbstractCard when you want the visual styling and grouping
  of a card, but plan to fill it with your own custom content layout. Content is
  organized into three properties: \c header, \c contentItem, and \c footer.

  The \l Card component provides a standard layout if your needs are less custom.

  \since 2.4
 */
T.ItemDelegate {
    id: root

//BEGIN properties
    /*!
      \qmlproperty Item header
      \brief This property holds an item that serves as a header.

      This item will be positioned on top if headerOrientation is Qt.Vertical
      or on the left if it is Qt.Horizontal.

      default: \c null; set something to make it the header.
     */
    property alias header: headerFooterLayout.header

    /*!
      \brief This property sets the card's orientation.
      \list
      \li Qt.Vertical: the header will be positioned on top
      \li Qt.Horizontal: the header will be positioned on the leading side
      \endlist

      default: \c Qt.Vertical
     */
    property int headerOrientation: Qt.Vertical

    /*!
      \qmlproperty Item footer
      \brief This property holds an item that serves as a footer.

      This item will be positioned at the bottom if headerOrientation is Qt.Vertical
      or on the right if it is Qt.Horizontal.

      default: \c null; set something to make it the footer.
     */
    property alias footer: headerFooterLayout.footer

    /*!
      \brief This property sets whether clicking or tapping on the card shows
      visual click feedback.

      Use this if you want the card to perform an action in its \c onClicked signal
      handler.

      default: \c false
     */
    property bool showClickFeedback: false

//END properties

    Layout.fillWidth: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            outerPaddingLayout.implicitWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             outerPaddingLayout.implicitHeight)

    hoverEnabled: !Kirigami.Settings.tabletMode && showClickFeedback

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    width: ListView.view ? ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin : undefined
    padding: Kirigami.Units.largeSpacing

    // Card component repurposes control's contentItem property, so it has to
    // reimplement content layout and its padding manually.
    Kirigami.Padding {
        id: outerPaddingLayout

        anchors.fill: parent

        topPadding: root.topPadding
        leftPadding: root.leftPadding
        rightPadding: root.rightPadding
        bottomPadding: root.bottomPadding

        contentItem: Kirigami.HeaderFooterLayout {
            id: headerFooterLayout

            contentItem: Kirigami.Padding {
                id: innerPaddingLayout

                contentItem: root.contentItem

                // Hide it altogether, so that vertical padding won't be
                // included in control's total implicit height.
                visible: contentItem !== null

                topPadding: headerFooterLayout.header ? Kirigami.Units.largeSpacing : 0
                bottomPadding: headerFooterLayout.footer ? Kirigami.Units.largeSpacing : 0
            }
        }
    }

    // HACK: A Control like this ItemDelegate tries to manage its
    // contentItem's positioning, so we need to override that. This is
    // equivalent to declaring x/y/width/height bindings in QQC2 style
    // implementations.
    Connections {
        target: root.contentItem

        function onXChanged() {
            root.contentItem.x = 0;
        }

        function onYChanged() {
            root.contentItem.y = Qt.binding(() => innerPaddingLayout.topPadding);
        }
    }
}
