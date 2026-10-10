/*
 * SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 * SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
 * SPDX-FileCopyrightText: 2026 Nate Graham <nate@kde.org>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import org.kde.kirigami.controls as KirigamiControls
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

/*!
\qmltype IconTitleSubtitleWithActions
\inqmlmodule org.kde.kirigami.delegates

\brief A delegate that can show an icon, title, subtitle, and trailing
action buttons.

This is meant to be used in lists for items that have actions where an
icon is also useful. If you don't need an icon, use \c TitleSubtitleWithActions
instead.

Example usage as contentItem of an ItemDelegate:

\qml
ItemDelegate {
    id: itemDelegate

    icon.name: "user"
    text: i18nc("@title:row", "Konqi")
    readonly property string subtitle: i18nc("@label", "The Konqueror")
    Accessible.description: subtitle

    Kirigami.Theme.useAlternateBackgroundColor: true

    onClicked: [...]

    contentItem: Kirigami.IconTitleSubtitleWithActions {
        icon.name: itemDelegate.icon
        title: itemDelegate.title
        subtitle: itemDelegate.subtitle

        elide: Text.ElideRight
        selected: itemDelegate.pressed || itemDelegate.highlighted

        actions: [
            Kirigami.Action {
                icon.name: "edit-entry-symbolic"
                text: i18nc("@action:button", "Modify user…")

                onTriggered: [...]
            },
            Kirigami.Action {
                icon.name: "edit-delete-remove-symbolic"
                text: i18nc("@action:button", "Remove user…")
                tooltip: text

                displayHint: Kirigami.DisplayHint.IconOnly

                onTriggered: [...]
            }
        ]
    }
}
\endqml

\sa TitleSubtitleWithActions
\sa IconTitleSubtitle
\sa TitleSubtitle
\sa ActionToolBar
\since 6.32
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

    /*!
     The title to display.
     */
    required property string title
    /*!
     \qmlproperty string subtitle
     The subtitle to display.
     */
    property alias subtitle: titleSubtitle.subtitle
    /*!
     \qmlproperty color color
     The color to use for the title.

     By default this is `Kirigami.Theme.textColor` unless `selected` is true
     in which case this is `Kirigami.Theme.highlightedTextColor`.
     */
    property alias color: titleSubtitle.color
    /*!
     \qmlproperty color subtitleColor

     The color to use for the subtitle.

     By default this is color mixed with the background color.
     */
    property alias subtitleColor: titleSubtitle.subtitleColor
    /*!
     \qmlproperty font font
     The font used to display the title.
     */
    property alias font: titleSubtitle.font
    /*!
     \qmlproperty font subtitleFont
     The font used to display the subtitle.
     */
    property alias subtitleFont: titleSubtitle.subtitleFont
    /*!
     \qmlproperty bool reserveSpaceForSubtitle
     Make the implicit height use the subtitle's height even if no subtitle is set.
     */
    property alias reserveSpaceForSubtitle: titleSubtitle.reserveSpaceForSubtitle
    /*!
     \qmlproperty bool selected
     Should this item be displayed in a selected style?
     */
    property alias selected: titleSubtitle.selected
    /*!
     \qmlproperty int elide
     The text elision mode used for both the title and subtitle.
     */
    property alias elide: titleSubtitle.elide
    /*!
     \qmlproperty int wrapMode
     The text wrap mode used for both the title and subtitle.
     */
    property alias wrapMode: titleSubtitle.wrapMode
    /*!
     \qmlproperty bool truncated
     Is the title or subtitle truncated?
     */
    property alias truncated: titleSubtitle.truncated

    /*!
     \qmlproperty string icon.name
     \qmlproperty var icon.source
     \qmlproperty color icon.color
     \qmlproperty real icon.width
     \qmlproperty real icon.height
     \qmlproperty function icon.fromControlsIcon

     Grouped property for icon properties.

     \note By default, IconTitleSubtitle will reserve the space for the icon,
     even if it is not set. To remove that space, set `icon.width` to 0.

     \include iconpropertiesgroup.qdocinc grouped-properties
     */
    property Primitives.IconPropertiesGroup icon: Primitives.IconPropertiesGroup {
        width: titleSubtitle.subtitleVisible ? Platform.Units.iconSizes.medium : Platform.Units.iconSizes.smallMedium
        height: width
    }

    /*!
     * The way the text property for the title and subtitle should be displayed.
     */
    property alias textFormat: titleSubtitle.textFormat

    /*!
     \brief Emitted when the user clicks on a \a link embedded in the text of the title or subtitle.
     */
    signal linkActivated(string link)

    /*!
     \brief Emitted when the user hovers on a \a link embedded in the text of the title or subtitle.
     */
    signal linkHovered(string link)

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout

        anchors {
            left: root.left
            right: root.right
            verticalCenter: root.verticalCenter
        }

        spacing: Platform.Units.smallSpacing

        IconTitleSubtitle {
            id: titleSubtitle

            readonly property bool subtitleVisible: root.subtitle.length > 0 || root.reserveSpaceForSubtitle

            Layout.fillWidth: true
            Layout.maximumWidth: Math.ceil(implicitWidth)
            Layout.alignment: Qt.AlignVCenter

            icon: icon.fromControlsIcon(root.icon)
            title: root.title

            onLinkActivated: link => root.linkActivated(link)
            onLinkHovered: link => root.linkHovered(link)
        }

        KirigamiControls.ActionToolBar {
            id: actionToolBar

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            actions: root.actions
            alignment: Qt.AlignRight
            flat: false // flat is only for window toolbars
        }
    }
}
