/*
    SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

/*!
  \qmltype ActionListContent
  \inqmlmodule org.kde.kirigami.dialogs

  \brief A control to visualize an array of actions as a list.

  Example usage:
  \qml
  QQC2.Dialog {
      id: root
      title: i18n("Track Options")

      QQC2.ScrollView {
          KirigamiDialogs.ActionListContent {
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

              onClicked: index => root.close()
          }
      }
  }
  \endqml
 */
ListView {
    id: root

    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the actions displayed in the context menu.
     */
    property list<QQC2.Action> actions

    /*!
      \qmlsignal clicked(int index)
      \brief Signal emitted when one of the action items is clicked.

      The index value is the index of the clicked item.
     */
    signal clicked(int index)

    model: root.actions

    delegate: QQC2.ItemDelegate {
        required property int index
        required property QQC2.Action modelData

        width: ListView.view.width

        action: modelData
        visible: !(modelData instanceof Kirigami.Action) || modelData.visible

        horizontalPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

        onClicked: root.clicked(index)
    }
}
