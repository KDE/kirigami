/*
    SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

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
      \qmlproperty list<Action> actionsviewcontext menu.

      \since 6.17
     */
    property list<T.Action> actions

    /*!
      \qmlsignal clicked(T.Action action)
      \brief Signal emitted when one of the action items is clicked.

      The action value is the action of the clicked item.

      \since 6.17
     */
    signal clicked(T.Action action)

    implicitWidth: contentWidth
    implicitHeight: contentHeight
    clip: true

    model: root.actions

    delegate: Loader {
        id: loader
        required property T.Action modelData
        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        sourceComponent: {
            const isKirigamiAction = modelData instanceof Kirigami.Action;
            if (isKirigamiAction && modelData.separator) {
                return separatorDelegate;
            } else if (isKirigamiAction && modelData.displayComponent) {
                return modelData.displayComponent;
            } else if (isKirigamiAction && modelData.checkable) {
                return modelData.autoExclusive ? radioDelegate : checkDelegate;
            }
            return itemDelegate
        }
        onSourceComponentChanged: if (item) {
            item.modelData = modelData;
        }
    }

    Component {
        id: itemDelegate
        QQC2.ItemDelegate {
            property T.Action modelData

            action: modelData
            visible: modelData instanceof Kirigami.Action ? modelData.visible : true

            onClicked: _private.click(modelData)
        }
    }
    Component {
        id: checkDelegate
        QQC2.CheckDelegate {
            property T.Action modelData

            action: modelData
            visible: modelData instanceof Kirigami.Action ? modelData.visible : true

            onClicked: _private.click(modelData)
        }
    }
    Component {
        id: radioDelegate
        QQC2.RadioDelegate {
            property T.Action modelData

            action: modelData
            visible: modelData instanceof Kirigami.Action ? modelData.visible : true

            onClicked: _private.click(modelData)
        }
    }
    Component {
        id: separatorDelegate
        QQC2.Control {
            property T.Action modelData
            padding: Kirigami.Units.largeSpacing
            contentItem: Kirigami.Separator {
                visible: modelData instanceof Kirigami.Action ? modelData.visible : true
            }
        }
    }

    QtObject {
        id: _private

        function click(action: T.Action) {
            if (action instanceof Kirigami.Action && action.children.length > 0) {
                let dialog = Qt.createComponent(Qt.resolvedUrl("private/ChildrenDialog.qml")).createObject(root, {
                    title: action.text,
                    actions: action.children
                });
                dialog.clicked.connect(action => root.clicked(action));
                dialog.open();
                return;
            }
            root.clicked(action)
        }
    }
}
