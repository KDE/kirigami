/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick

/*!
  \qmltype FormSeparator
  \inqmlmodule org.kde.kirigami.forms

  \brief An item used to ssepare entries within a FormGroup

  This component is used when it's needed to separe entries within a FormGroup
  for clarity, for instance if is needed to have separate subcategories within a FormGroup.

  Example usage:
  \qml
  import QtQuick.Controls as QQC
  import org.kde.kirigami as Kirigami

  Kirigami.Form {
    Kirigami.FormGroup {
        title: "Theme Options"
        Kirigami.FormEntry {
            title: "Subsection 1"
            contentItem: QQC.CheckBox {
                text: "Dark Theme"
            }
        }
        Kirigami.FormSeparator {}
        Kirigami.FormEntry {
            title: "Subsection 2"
            contentItem: QQC.CheckBox {
                text: "High Contrast"
            }
        }
        ...
    }
  }
  \endqml
  \sa FormEntry
  \sa FormGroup
  \since 6.24
*/
Item {}
