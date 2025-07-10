/*
    SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

QQC2.Dialog {
    id: root

    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the actions displayed in the dialog.

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
    onClicked: accept()

    x: Math.round((parent.width - width) / 2)
    width: Math.min(Window.window?.width ?? Infinity - Kirigami.Units.largeSpacing * 2, Kirigami.Units.gridUnit * 20, parent?.width ?? Infinity)
    padding: 1
    clip: true

    contentItem: Kirigami.ActionsListView {
        // ensure view colour scheme, and background color
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        actions: root.actions
        onClicked: action => root.clicked(action)

        footer: Item {
            height: Kirigami.Units.cornerRadius / 4
        }
    }
}
