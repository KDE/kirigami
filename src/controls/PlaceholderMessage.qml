/*
 *  SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "private" as P

/*!
  \qmltype PlaceholderMessage
  \inqmlmodule org.kde.kirigami

  \brief A placeholder message indicating that a view is empty.

  The message comprises a label with text, an optional explanation below the main text,
  an optional icon above all the text, and an optional button below all the text which
  can be used to easily show the user what to do next to add content to the view.

  The explanatory text is selectable and can contain clickable links. In this latter
  case, client code must implement an \c onLinkactivated: signal handler or the links
  will not work.

  The top-level component is a ColumnLayout, so additional components items can
  simply be added as child items and they will be positioned sanely.

  Example usage:

  Used as a "this view is empty" message:
  \qml
  import org.kde.kirigami as Kirigami

  ListView {
      id: listView
      model: [...]
      delegate: [...]

      Kirigami.PlaceholderMessage {
          anchors.centerIn: parent
          width: parent.width - (Kirigami.Units.largeSpacing * 4)

          visible: listView.count === 0

          text: "There are no items in this list"
      }
  }
  \endqml

  Used as a "here's how to proceed" message:
  \qml
  import org.kde.kirigami as Kirigami

  ListView {
      id: listView
      model: [...]
      delegate: [...]

      Kirigami.PlaceholderMessage {
          anchors.centerIn: parent
          width: parent.width - (Kirigami.Units.largeSpacing * 4)

          visible: listView.count === 0

          text: "Add an item to proceed"

          helpfulAction: Kirigami.Action {
              icon.name: "list-add"
              text: "Add item..."
              onTriggered: {
                  [...]
              }
          }
      }
      [...]
  }
  \endqml

  Used as a "there was a problem here" message:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Page {
      id: root
      readonly property bool networkConnected: [...]

      Kirigami.PlaceholderMessage {
          anchors.centerIn: parent
          width: parent.width - (Kirigami.Units.largeSpacing * 4)

          visible: root.networkConnected

          icon.name: "network-disconnect"
          text: "Unable to load content"
          explanation: "Please try again later."
                       " Visit <a href="https://foo.com/com>this link</a> for more details."
          onLinkActivated: link => Qt.openUrlExternally(link)
      }
  }
  \endqml

  Used as a "Here's what you do next" button:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Page {
      id: root

      Kirigami.PlaceholderMessage {
          anchors.centerIn: parent
          width: parent.width - (Kirigami.Units.largeSpacing * 4)

          visible: root.loading

          helpfulAction: Kirigami.Action {
              icon.name: "list-add"
              text: "Add item..."
              onTriggered: {
                  [...]
              }
          }
      }
  }
  \endqml
 */
ColumnLayout {
    id: root

    enum Type {
        Actionable,
        Informational
    }

//BEGIN properties
    /*!
      \qmlproperty enumeration PlaceholderMessage::type

      \brief This property holds the PlaceholderMessage type.

      The type of the message. This can be:
      \list
      \li Kirigami.PlaceholderMessage.Type.Actionable: Makes it more attention-getting. Useful when the user is expected to interact with the message.
      \li Kirigami.PlaceholderMessage.Type.Informational: Makes it less prominent. Useful when the message in only informational.
      \endlist
      default: if a helpfulAction is provided this will be of type Actionable otherwise of type Informational.

      \since 5.94
     */
    property int type: actionButton.action?.enabled
        ? PlaceholderMessage.Type.Actionable
        : PlaceholderMessage.Type.Informational

    /*!
      \brief This property holds the text to show in the placeholder label.

      Optional; if not defined, the message will have no large text label
      text. If both text and explanation are omitted, the message will have
      no text and only an icon, action button, and/or other custom content.

      \since 5.70
     */
    property string text

    /*!
      \brief This property holds the smaller explanatory text to show below the larger title-style text

      Useful for providing a user-friendly explanation on how to proceed.

      Optional; if not defined, the message will have no supplementary
      explanatory text.

      \since 5.80
     */
    property string explanation

    /*!
      \qmlproperty string PlaceholderMessage::icon.name
      \qmlproperty string PlaceholderMessage::icon.source
      \qmlproperty int PlaceholderMessage::icon.width
      \qmlproperty int PlaceholderMessage::icon.height
      \qmlproperty color PlaceholderMessage::icon.color

      \brief This property provides an icon to display above the top text label.

      \note It accepts icon.name and icon.source to set the icon source.
      It is suggested to use icon.name.

      Optional; if undefined, the message will have no icon.
      Falls back to \c undefined if the specified icon is not valid or cannot
      be loaded.

      \since 5.70
     */
    readonly property P.ActionIconGroup icon: P.ActionIconGroup {
        width: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        height: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        color: Kirigami.Theme.textColor
    }

    /*!
      \qmlproperty QtQuick.Controls.Action PlaceholderMessage::helpfulAction

      \brief This property holds an action that helps the user proceed.

      Typically used to guide the user to the next step for adding
      content or items to an empty view.

      Optional; if undefined, no button will appear below the text label.

      \since 5.70
     */
    property alias helpfulAction: actionButton.action

    /*!
      \qmlproperty string PlaceholderMessage::hoveredLink

      This property holds the link embedded in the explanatory message text that
      the user is hovering over.
     */
    readonly property alias hoveredLink: label.hoveredLink

    /*!
      This signal is emitted when a link is hovered in the explanatory message
      text.

      \a link The hovered link.
     */
    signal linkHovered(string link)

    /*!
      This signal is emitted when a link is clicked or tapped in the explanatory
      message text.

      \a link The clicked or tapped link.
     */
    signal linkActivated(string link)
//END properties

    spacing: Kirigami.Units.largeSpacing

    Component.onCompleted: _announce();
    onVisibleChanged: {
        _announce();
    }
    function _announce()
    {
        if (visible && Accessible.announce) {
            // Accessible.announce was added in Qt 6.8.0
            if (root.text.length > 0)
                Accessible.announce(root.text);
            if (root.explanation.length > 0)
                Accessible.announce(root.explanation);
        }
    }

    Kirigami.Icon {
        visible: source !== undefined
        opacity: root.type === PlaceholderMessage.Type.Actionable ? 1 : 0.5

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.icon.width
        Layout.preferredHeight: root.icon.height

        color: root.icon.color

        source: {
            if (root.icon.source.length > 0) {
                return root.icon.source
            } else if (root.icon.name.length > 0) {
                return root.icon.name
            }
            return undefined
        }
    }

    Kirigami.Heading {
        text: root.text
        visible: text.length > 0

        type: Kirigami.Heading.Primary
        opacity: root.type === PlaceholderMessage.Type.Actionable ? 1 : 0.65


        Layout.fillWidth: true
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        wrapMode: Text.WordWrap
    }

    Kirigami.SelectableLabel {
        id: label

        text: root.explanation
        visible:  root.explanation.length > 0
        opacity: root.type === PlaceholderMessage.Type.Actionable ? 1 : 0.65

        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap

        Layout.fillWidth: true

        onLinkHovered: link => root.linkHovered(link)
        onLinkActivated: link => root.linkActivated(link)
    }

    QQC2.Button {
        id: actionButton

        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Kirigami.Units.gridUnit

        visible: action?.enabled ?? false
    }
}
