/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.forms as Forms


/*!
  \qmltype FormAction
  \inqmlmodule org.kde.kirigami.forms

  \brief A specialized FormEntry for a big clickable action

  This component is used when the Form needs entries that represent a big clickable
  action: they will act like a single big button and is controlled by its Action property.
  Never override the contentItem property for a FormAction.

  Example usage:
  \qml
  import QtQuick.Controls as QQC
  import org.kde.kirigami as Kirigami

  Kirigami.Form {
    Kirigami.FormGroup {
        title: "When Offline:"
        Kirigami.FormAction {
            action: Kirigami.Action {
                icon.name: "offline-settings"
                text: "Offline Settings"
                onTriggered: { Code to open that settings page here }
            }
        }
        ...
    }
  }
  \endqml
  \sa FormEntry
  \since 6.24
*/
Forms.FormEntry { // Needs to be instantiated from the global forms import in order to resolve to the proper style
    id: root

    /*!
      \brief The main action for this Entry

      FormAction acts like a big button that represents and triggers it.
      The action icon and text properties will be displayed to the user in this control,
      and clicking anywhere on it will trigger the action.
     */
    required property T.Action action

    /*!
      An icon to be displayed on the rightof this FormEntry which represents what kind of
      action this is. By default is "go-next-symbolic", which suggests this action is opening something
      else or that is going to replace the PAge it's in.
     */
    readonly property Primitives.IconPropertiesGroup triggerIcon: Primitives.IconPropertiesGroup {
        name: "go-next-symbolic"
    }

    onClicked: action.trigger(root)

    trailingItems: Primitives.Icon {
        Layout.fillHeight: true
        Layout.maximumHeight: root.triggerIcon.height <= 0 ? Platform.Units.iconSizes.smallMedium : Infinity
        source: root.triggerIcon.name || root.triggerIcon.source
        color: root.triggerIcon.color
        Layout.preferredWidth: root.triggerIcon.width > 0 ? root.triggerIcon.width : -1
        Layout.preferredHeight: root.triggerIcon.height > 0 ? root.triggerIcon.height : -1
    }
}
