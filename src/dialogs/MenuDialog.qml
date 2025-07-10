/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2

import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KirigamiDialogs

/*!
  \qmltype MenuDialog
  \inqmlmodule org.kde.kirigami.dialogs

  \brief A dialog that prompts users with a context menu, with
  list items that perform actions.

  Example usage:
  \qml
  Kirigami.MenuDialog {
      title: i18n("Track Options")

      actions: [
          Kirigami.Action {
              icon.name: "media-playback-start"
              text: i18nc("Start playback of the selected track", "Play")
              tooltip: i18n("Start playback of the selected track")
          },
          Kirigami.Action {
              enabled: false
              icon.name: "document-open-folder"
              text: i18nc("Show the file for this song in the file manager", "Show in folder")
              tooltip: i18n("Show the file for this song in the file manager")
          },
          Kirigami.Action {
              icon.name: "documentinfo"
              text: i18nc("Show track metadata", "View details")
              tooltip: i18n("Show track metadata")
          },
          Kirigami.Action {
              icon.name: "list-add"
              text: i18nc("Add the track to the queue, right after the current track", "Play next")
              tooltip: i18n("Add the track to the queue, right after the current track")
          },
          Kirigami.Action {
              icon.name: "list-add"
              text: i18nc("Enqueue current track", "Add to queue")
              tooltip: i18n("Enqueue current track")
          }
      ]
  }
  \endqml

  \sa Dialog
  \sa PromptDialog
 */
KirigamiDialogs.Dialog {
    id: root

    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the actions displayed in the context menu.
     */
    property list<T.Action> actions

    /*!
      \qmlproperty Item MenuDialog::contentHeader

      \brief This property holds the content header, which appears above the actions.
      but below the header bar.
     */
    property alias contentHeader: columnHeader.contentItem

    /*!
      \qmlproperty Control MenuDialog::contentHeaderControl

      \brief This property holds the content header.

      This makes it possible to access its internal properties to, for example, change its padding:
      contentHeaderControl.topPadding
     */
    property Item contentHeaderControl: QQC2.Control {
        id: columnHeader
        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
    }

    preferredWidth: Kirigami.Units.gridUnit * 20
    padding: 0

    Kirigami.ActionsListView {
        id: content
        actions: root.actions

        onClicked: action => root.accept()

        header: columnHeader

        footer: Item {
            height: Kirigami.Units.cornerRadius
        }
    }

    standardButtons: QQC2.DialogButtonBox.NoButton
    showCloseButton: true
}
