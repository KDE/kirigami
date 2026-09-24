/*
 *    SPDX-FileCopyrightText: 2026 James Graham <james.h.graham@protonmail.com>
 *    SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

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
  implement a custom delegate.

  \note It is not recommended to assign an onTriggered to an action with children.
  Instead it is expected that the children have the effects to be triggered.

  \warning Children are not supported on separator or checkable actions.

  \since 6.17
 */
ListView {
    id: root

    /*!
      \qmlproperty list<Action> actions
      \brief The list of actions to visualize in the view.

      \since 6.17
     */
    property list<T.Action> actions

    /*!
      \qmlproperty Component itemDelegate
      \brief The delegate to use for most actions.

      \since 6.17
     */
    property Component itemDelegate

    /*!
      \qmlproperty Component checkDelegate
      \brief The delegate to use for checkable actions.

      \since 6.17
     */
    property Component checkDelegate

    /*!
      \qmlproperty Component radioDelegate
      \brief The delegate to use for checkable exclusive action groups.

      \since 6.17
     */
    property Component radioDelegate

    /*!
      \qmlproperty Component separatorDelegate

      The delegate to use for separator actions.

      \since 6.17
     */
    property Component separatorDelegate

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
}
