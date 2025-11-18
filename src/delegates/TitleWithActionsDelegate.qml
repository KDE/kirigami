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
 \ *qmltype TitleWithActionsDelegate
 \inqmlmodule org.kde.kirigami.delegates

 \brief A simple title delegate that has trailing actions

 This is meant to be used in lists for items that have actions.
For example lists of usernames, with any related actions after them,
such as rename and delete actions.

Example usage as contentItem of an ItemDelegate:

\qml
Kirigami.TitleWithActionsDelegate {
    title: "This is item title"
    subtitle: "This is subtitle"
    elide: Text.ElideRight
    selected: parent.highlighted
    actions: [
        Kirigami.Action {
            text: i18n("Copy")
            icon.name: "edit-copy"
            shortcut: StandardKey.Copy
            onTriggered: {
                console.warn("Copy!")
            }
        },
        Kirigami.Action {
            text: i18n("Delete")
            icon.name: "delete-symbolic"
            shortcut: StandardKey.Copy
            onTriggered: {
                console.warn("Delete!")
            }
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

    implicitHeight: layout.implicitHeight

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

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: root.actions

                delegate: QQC2.Button {
                    Layout.alignment: Qt.AlignRight
                    required property T.Action modelData
                    action: modelData
                    display: QQC2.Button.IconOnly
                }
            }
        }
    }
}
