/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami


/*!
    \qmltype FormAction
    \inqmlmodule org.kde.kirigami.forms

    \brief A specialized FormEntry that represents a single triggerable action.

    When an entry needs to represent a single action (like a single big button)
    using FormAction instead will present the user an entry styled according the
    Human Interface Guidelines instead of a plain button.
    Besides the usual title and subtitle it supports a main text, an icon, and an
    optional extra action icon to represent the kind of action that will be
    positioned after the main text (by default a right pointing arrow).

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
                icon.name: "user-identity"
                triggerIcon.name: "document-send"
                text: i18n("Submit")
            }
        }
    }
    \endqml

    \sa FormEntry
 */
FormEntry {
    id: root
    /*!
        \brief An icon for this action.

        Grouped property of an icon providing name and source.

        \sa AbstractButton
     */
    readonly property alias icon: iconProps

    /*!
        Main text for this action.
     */
    property alias text: mainLabel.text

    /*!
        \brief An extra decorative icon for this action, displayed after the text

        This can represent the kind of action this action item does, and by default will
        be a right-pointing arrow (or left on RTL layouts).
     */
    readonly property alias triggerIcon: triggerIconProps

    /*!
        This is emitted when the user trigger this entry either by clicking with the mouse
        or via a Keyboard shortcut.
     */
    signal clicked

    Kirigami.IconPropertiesGroup {
        id: iconProps
    }
    Kirigami.IconPropertiesGroup {
        id: triggerIconProps
        name: "go-next-symbolic"
    }
    leadingItems: Kirigami.Icon {
        Layout.fillHeight: true
        source: root.icon.name || root.icon.source
        color: root.icon.color
    }
    contentItem: QQC.Label {
        id: mainLabel
    }
    trailingItems: Kirigami.Icon {
        Layout.fillHeight: true
        Layout.maximumHeight: Kirigami.Units.iconSizes.smallMedium
        source: root.triggerIcon.name || root.triggerIcon.source
        color: root.triggerIcon.color
    }
}
