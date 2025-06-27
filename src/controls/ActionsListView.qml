/*
    SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQml.Models
// HACK: QtQml.Models stabilised in 6.9, this can go when support is not longer needed
import Qt.labs.qmlmodels

import org.kde.kirigami as Kirigami

/*!
  \qmltype ActionsListView
  \inqmlmodule org.kde.kirigami

  \brief A control to visualize an array of actions as a list.

  Example usage:
  \qml
  QQC2.Dialog {
      id: root
      title: i18n("Track Options")

      width: Kirigami.Units.gridUnit * 24
      padding: 1 // To avoid covering the border

      contentItem: QQC2.ScrollView {
          Kirigami.ActionsListView {
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

              onClicked: index => root.accept()
          }
      }
  }
  \endqml

  \since 6.17
 */
ListView {
    id: root

    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the actions displayed in the context menu.

      \since 6.17
     */
    property list<T.Action> actions

    /*!
      \qmlsignal clicked(int index)
      \brief Signal emitted when one of the action items is clicked.

      The index value is the index of the clicked item.

      \since 6.17
     */
    signal clicked(int index)

    clip: true

    model: root.actions

    delegate: DelegateChooser {
        role: "checkable"

        DelegateChoice {
            roleValue: "true"
            QQC2.CheckDelegate {
                required property int index
                required property T.Action modelData

                width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin

                action: modelData
                visible: modelData instanceof Kirigami.Action ? modelData.visible : true

                onClicked: root.clicked(index)
            }
        }
        DelegateChoice {
            roleValue: "false"
            QQC2.ItemDelegate {
                required property int index
                required property T.Action modelData

                width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin

                action: modelData
                visible: modelData instanceof Kirigami.Action ? modelData.visible : true

                onClicked: root.clicked(index)
            }
        }
    }
}
