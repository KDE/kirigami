/*
 * SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 * SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
 \ *qmltype TitleSubtitleWithActions
 \inqmlmodule org.kde.kirigami.delegates

 \brief A simple title delegate that has trailing actions.

 This is meant to be used in lists for items that have actions.
 For example lists of usernames, with any related actions after them,
 such as rename and delete actions.

 Example usage as contentItem of an ItemDelegate:

\qml
Kirigami.TitleSubtitleWithActions {
    anchors.fill: parent
    anchors.margins: Kirigami.Units.largeSpacing
    title: model.userName
    elide: Text.ElideRight
    selected: itemDelegate.highlighted
    actions: [
        Kirigami.Action {
            icon.name: "edit-entry-symbolic"
            text: i18nc("@action:button", "Modify user…")
            onTriggered: {
                root.modifyUser(model.userName);
            }
            tooltip: text
        },
        Kirigami.Action {
            icon.name: "edit-delete-remove-symbolic"
            text: i18nc("@action:button", "Remove user…")
            onTriggered: {
                root.deleteUser(model.userName);
            }
            tooltip: text
        }
    ]
}
\endqml

\sa IconTitleSubtitle
\sa TitleSubtitle
*/

Item {
    id: root

    /*!
     * List of actions to show as icons-only buttons.
     */
    property list<T.Action> actions

    /*!
        The title to display.
     */
    required property string title

    /*!
        The subtitle to display.
     */
    property string subtitle

    /*!
        Should this item be displayed in a selected style?
     */
    property bool selected

    /*!
        The text elision mode used for both the title and subtitle.
     */
    property var elide: Text.ElideRight

    RowLayout {
        id: layout
        anchors.fill: root
        spacing: Kirigami.Units.smallSpacing

        Kirigami.TitleSubtitle {
            Layout.alignment: Qt.AlignLeft
            title: root.title
            subtitle: root.subtitle
            elide: root.elide
            selected: root.selected
        }

        Kirigami.ActionToolBar {
            Layout.fillHeight: true
            actions: root.actions
            alignment: Qt.AlignRight
        }
    }
}
