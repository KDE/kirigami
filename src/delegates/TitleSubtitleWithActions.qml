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
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
\qmltype TitleSubtitleWithActions
\inqmlmodule org.kde.kirigami.delegates

\brief A simple title delegate that has trailing actions.

This is meant to be used in lists for items that have actions.
For example lists of usernames, with any related actions after them,
such as rename and delete actions.

Example usage as contentItem of an ItemDelegate:

\qml
ItemDelegate {
    id: itemDelegate
    icon: "user"
    text: i18nc("@title:row", "Konqi")
    readonly property string subtitle: i18nc("@label", "The Konqueror")
    Accessible.description: subtitle
    Kirigami.Theme.useAlternateBackgroundColor: true

    onClicked: [...]

    contentItem: Kirigami.TitleSubtitleWithActions {
        title: itemDelegate.title
        subtitle: itemDelegate.subtitle
        elide: Text.ElideRight
        selected: itemDelegate.pressed || itemDelegate.highlighted
        actions: [
            Kirigami.Action {
                icon.name: "edit-entry-symbolic"
                text: i18nc("@action:button", "Modify user…")
                onTriggered: [...]
                tooltip: text
            },
            Kirigami.Action {
                icon.name: "edit-delete-remove-symbolic"
                text: i18nc("@action:button", "Remove user…")
                onTriggered: [...]
                tooltip: text
                displayHint: Kirigami.DisplayHint.IconOnly
            }
        ]
    }
}
\endqml

\sa IconTitleSubtitle
\sa TitleSubtitle
\sa ActionToolBar
\since 6.22
*/

Item {
    id: root

    /*!
        \qmlproperty list<Action> TitleSubtitleWithActions::actions

        \brief This property holds a list of visible actions.

        These actions will be given to ActionToolBar.
        To make an action be icons-only, set
        \c displayHint: Kirigami.DisplayHint.IconOnly on it.

        Empty by default, so no actions will be present.

        \sa ActionToolBar
     */
    property list<T.Action> actions

    /*!
        The title to display.
     */
    required property string title

    /*!
        The subtitle to display.

        default: Empty \c string, so no subtitle is shown
     */
    property string subtitle

    /*!
        Should this item be displayed in a selected style?

        default: \c false
     */
    property bool selected: false

    /*!
        The text elision mode used for both the title and subtitle.
        \qmlproperty enumeration TitleSubtitleWithActions::elide

        default: \c Text.ElideRight
     */
    property int elide: Text.ElideRight

    /*!
        This property determines how the icon and text are displayed within the button.
        \qmlproperty enumeration TitleSubtitleWithActions::displayHint

        Permitted values are:
        \list
        \li Button.IconOnly
        \li Button.TextOnly
        \li Button.TextBesideIcon
        \li Button.TextUnderIcon
        \endlist

        default: \c Button.TextBesideIcon

        \sa ActionToolBar
        \sa AbstractButton
    */
    property alias displayHint: actionToolBar.display

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.fill: root
        spacing: Kirigami.Units.smallSpacing

        Kirigami.TitleSubtitle {
            id: titleSubtitle
            Layout.fillWidth: true
            Layout.maximumWidth: Math.ceil(implicitWidth)
            Layout.alignment: Qt.AlignLeft
            title: root.title
            subtitle: root.subtitle
            elide: root.elide
            selected: root.selected
        }

        Kirigami.ActionToolBar {
            id: actionToolBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            actions: root.actions
            alignment: Qt.AlignRight
            flat: false
        }
    }
}
