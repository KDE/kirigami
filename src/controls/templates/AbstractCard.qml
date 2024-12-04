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

  \brief AbstractCard is the base for cards.

  A Card is a visual object that serves as an entry point for more detailed information.

  An AbstractCard is empty, providing just the look and the base properties and signals
  for an ItemDelegate. It can be filled with any custom layout of items,
  its content is organized in 3 properties: header, contentItem and footer.

  Use this only when you need particular custom contents. For a standard layout
  for cards, use the Card component.

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
     */
    property alias header: headerFooterLayout.header

    /*!
      \brief This property sets the card's orientation.
      \list
      \li Qt.Vertical: the header will be positioned on top
      \li Qt.Horizontal: the header will be positioned on the left (or right if an RTL layout is used)
      \endlist

      default: Qt.Vertical
     */
    property int headerOrientation: Qt.Vertical

    /*!
      \qmlproperty Item footer
      \brief This property holds an item that serves as a footer.

      This item will be positioned at the bottom if headerOrientation is Qt.Vertical
      or on the right if it is Qt.Horizontal.
     */
    property alias footer: headerFooterLayout.footer

    /*!
      \brief This property sets whether clicking or tapping on the card area shows a visual click feedback.

      Use this if you want to do an action in the onClicked signal handler of the card.

      default: false
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
