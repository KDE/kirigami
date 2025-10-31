/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami


/*!
    \qmltype FormAction
    \inqmlmodule org.kde.kirigami.forms

    \brief A specialized FormEntry that represents a single triggerable action.

    When an entry needs to represent a single action (like a single big button)
    using FormAction instead will present the user an entry styled according the
    Human Interface Guidelines instead of a plain button.
    Besides the usual title and subtitle it needs an Action to be assigned to,
    which will provide the main icon and the main text of the entry, as well the
    handlling code.

    It is possible to assign also an optional extra action icon to represent
    the kind of action, and will be positioned after the main text
    (by default a right pointing arrow and a left-pointing arrow on RTL layouts).

    Example usage:

    \qml
    import QtQuick.Controls as QQC
    import org.kde.kirigami.forms as KF

    KF.Form {
        KF.FormGroup {
            title: i18n("Section1")
            KF.FormEntry {
                title: i18n("Name:")
                contentItem: QQC.TextField {}
            }
            KF.FormAction {
                title: i18n("Save Changes:")
                triggerIcon.name: "document-send"
                action: Kirigami.Action {
                    icon.name: "user-identity"
                    text: i18n("Submit")
                    onTriggered: {
                        // Handling code here
                    }
                }
            }
        }
    }
    \endqml

    \sa Action
    \sa FormEntry
 */
FormEntry {
    id: root

    /*!
        \brief The Action this entry is associated with

        This mandatory property defines the actyion for this entry: the Icon and Text for this entry will
        be displayed to the user and when the entry is triggered with either a click or a keyboard shortcut,
        the Action will be triggered
     */
    required property T.Action action

    /*!
        \brief An extra decorative icon for this action, displayed after the text

        This can represent the kind of action this action item does, and by default will
        be a right-pointing arrow (or left on RTL layouts).
     */
    readonly property alias triggerIcon: triggerIconProps


    Kirigami.IconPropertiesGroup {
        id: iconProps
    }
    Kirigami.IconPropertiesGroup {
        id: triggerIconProps
        name: "go-next-symbolic"
    }
    leadingItems: Kirigami.Icon {
        Layout.fillHeight: true
        source: root.action.icon.name || root.action.icon.source
        color: root.action.icon.color
        Layout.preferredWidth: root.action.icon.width > 0 ? root.action.icon.width : -1
        Layout.preferredHeight: root.action.icon.height > 0 ? root.action.icon.height : -1
    }
    contentItem: QQC.Label {
        text: root.action.text
    }
    trailingItems: Kirigami.Icon {
        Layout.fillHeight: true
        Layout.maximumHeight: triggerIconProps.height <= 0 ? Kirigami.Units.iconSizes.smallMedium : Infinity
        source: root.triggerIcon.name || root.triggerIcon.source
        color: root.triggerIcon.color
        Layout.preferredWidth: triggerIconProps.width > 0 ? triggerIconProps.width : -1
        Layout.preferredHeight: triggerIconProps.height > 0 ? triggerIconProps.height : -1
    }
}
