/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

/*!
  \qmltype FormGroup
  \inqmlmodule org.kde.kirigami.forms

  \brief The container class that identifies a container of related controls in a form.

  This element should always be positioned in a Form. It is used to group together
  related form controls, to separate different settings categories.
  Every form should always have at least one FormGroup.

  A FormGroup should contain only elements of type FormEntry or FormSeparator (or derivates)

  Example usage:
  \qml
  import QtQuick.Controls as QQC
  import org.kde.kirigami as Kirigami

  Kirigami.Form {
    Kirigami.FormGroup {
        title: "Global Settings"
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "Show Sidebar"
            }
        }
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "Auto Save"
            }
        }
    }
    Kirigami.FormGroup {
        title: "Theme Options"
        Kirigami.FormEntry {
            title: "Colors"
            contentItem: QQC.CheckBox {
                text: "Dark Theme"
            }
        }
        Kirigami.FormSeparator {}
        Kirigami.FormEntry {
            contentItem: QQC.CheckBox {
                text: "High Contrast"
            }
        }
        ...
    }
  }
  \endqml
  \sa Form
  \sa FormEntry
  \since 6.24
*/
import QtQuick

Item {
    id: root

    /*!
      \brief Group title.

      If set, a title will be displayed on top of the form section, useful
      for semantically group different settings categories
     */
    property string title
}
