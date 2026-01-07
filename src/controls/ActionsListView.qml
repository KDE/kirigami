/*
    SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Layouts

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

      QQC2.ButtonGroup {
          id: radioGroup
      }

      Kirigami.ActionsListView {
          actions: [
              Kirigami.Action {
                  icon.name: "checkmark"
                  text: qsTr("A normal action")
                  tooltip: qsTr("A normal action")
              },
              Kirigami.Action {
                  enabled: false
                  icon.name: "action-unavailable-symbolic"
                  text: qsTr("A disabled action")
                  tooltip: qsTr("A disabled action")
              },
              Kirigami.Action {
                  separator: true
              },
              Kirigami.Action {
                  QQC2.ButtonGroup.group: radioGroup
                  checked: true
                  checkable: true
                  autoExclusive: true
                  text: qsTr("Radio 1", "The first radio button")
                  tooltip: qsTr("Radio 1")
              },
              Kirigami.Action {
                  QQC2.ButtonGroup.group: radioGroup
                  checkable: true
                  autoExclusive: true
                  text: qsTr("Radio 2", "The second radio button")
                  tooltip: qsTr("Radio 2")
              },
              Kirigami.Action {
                  QQC2.ButtonGroup.group: radioGroup
                  checkable: true
                  autoExclusive: true
                  text: qsTr("Radio 3", "The third radio button")
                  tooltip: qsTr("Radio 3")
              },
              Kirigami.Action {
                  checkable: true
                  text: qsTr("Check button", "An example checkable button")
                  tooltip: qsTr("Check button")
              },
              Kirigami.Action {
                  separator: true
              },
              Kirigami.Action {
                  icon.name: "list-add"
                  text: qsTr("With Children", "I.e. an example where the item has child items")
                  tooltip: qsTr("With Children")
                  children: [
                      Kirigami.Action {
                          icon.name: "user"
                          text: qsTr("Child 1")
                          tooltip: qsTr("Child 1")
                      },
                      Kirigami.Action {
                          icon.name: "user"
                          text: qsTr("Child 2")
                          tooltip: qsTr("Child 2")
                      }
                  ]
              }
          ]

          onClicked: index => root.accept()
      }
  }
  \endqml

  \note Only 1 level of child actions are supported, if you want more you need to
  implement a custome delegate.

  \note It is not recommended to assign an onTriggered to an action with children.
  Instead it is expected that the children have the effects to be triggered.

  \warning Children are not supported on separator or checkable actions.

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

    delegate: ColumnLayout {
        id: delegateColumn
        required property T.Action modelData

        property bool expanded: false

        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        Loader {
            Layout.fillWidth: true

            sourceComponent: _private.delegateForAction(delegateColumn.modelData)
            onItemChanged: if (item) {
                item.delegate = delegateColumn;
                item.modelData = delegateColumn.modelData;
            }
        }
        Repeater {
            model: {
                if (!delegateColumn.expanded) {
                    return [];
                }
                return (delegateColumn.modelData as Kirigami.Action)?.children ?? [];
            }
            delegate: Loader {
                id: childLoader
                required property T.Action modelData
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.preferredHeight: active ? (item as Item).implicitHeight : 0

                sourceComponent: _private.delegateForAction(childLoader.modelData)
                onItemChanged: if (item) {
                    item.delegate = delegateColumn;
                    item.modelData = childLoader.modelData;
                }
            }
        }
    }

    Component {
        id: itemDelegate
        QQC2.ItemDelegate {
            id: item
            property Item delegate
            property T.Action modelData

            action: modelData
            visible: (modelData as Kirigami.Action)?.visible ?? true

            Component.onCompleted: (contentItem as GridLayout).columns = (contentItem as GridLayout).columns + 1
            contentItem.children: Kirigami.Icon {
                visible: (item.modelData as Kirigami.Action).children.length > 0
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: Kirigami.Units.iconSizes.small
                source: item.delegate.expanded ? "go-up" : "go-down"
            }

            onClicked: item.delegate.expanded = !item.delegate.expanded
        }
    }
    Component {
        id: checkDelegate
        QQC2.CheckDelegate {
            id: check
            property Item delegate
            property T.Action modelData

            action: modelData
            visible: (modelData as Kirigami.Action)?.visible ?? true

            onClicked: root.clicked(modelData)
        }
    }
    Component {
        id: radioDelegate
        QQC2.RadioDelegate {
            property Item delegate
            property T.Action modelData

            QQC2.ButtonGroup.group: modelData.QQC2.ButtonGroup.group

            action: modelData
            visible: (modelData as Kirigami.Action)?.visible ?? true

            onClicked: root.clicked(modelData)
        }
    }
    Component {
        id: separatorDelegate
        QQC2.Control {
            id: separatorControl
            property Item delegate
            property T.Action modelData
            padding: Kirigami.Units.largeSpacing
            contentItem: Kirigami.Separator {
                visible: (separatorControl.modelData as Kirigami.Action)?.visible ?? true
            }
        }
    }

    QtObject {
        id: _private

        function delegateForAction(action: T.Action) : Component {
            const kirigamiAction = action as Kirigami.Action;
            if (kirigamiAction && kirigamiAction.separator) {
                return separatorDelegate;
            } else if (kirigamiAction && kirigamiAction.displayComponent) {
                return kirigamiAction.displayComponent;
            } else if (action.checkable) {
                return kirigamiAction && kirigamiAction.autoExclusive ? radioDelegate : checkDelegate;
            }
            return itemDelegate
        }
    }
}
