/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.layouts as KirigamiLayouts

/*!
  \qmltype FormEntry
  \inqmlmodule org.kde.kirigami.forms

  \brief The base type of all Form entries

  This element should always be positioned in a FormGroup.
  It is The base for all the items livinging in a Form and will take
  care of common styling and behaviors, like positioning of titles and subtitles,
  background and what happens when the item is clicked even outside the contentItem.

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
  \sa FormGroup
  \since 6.24
*/
Item {
    id: root

    /*!
      \brief Entry title.

      If set, a title will be displayed nearby the contentItem, either on top or on the left,
      Depending from the style or form factor. Use this when the contentItem appearance doesn't
      provide enough explanation on what it does.
     */
    property string title: contentItem?.KirigamiLayouts.FormData.label

    /*!
      \brief Extra subtitle.

      If set a subtitle (potentially on multiple lines) will be displayed under the contentItem.
      Use this for form entries with a more technical meaning that need more explanation or
      entries that contain a potentially dangerous action.
      */
    property string subtitle

    /*!
      \brief The main contents of this entry.

      The contentItem is what contains the main contents of the entry, which are usually a
      simple Control such as a CheckBox, a TextField and so on.
      If is needed to have more than one control, set a layout as contentItem, such as
      a RowLayout, GridLAyout and so on.
      */
    property Item contentItem

    /*!
      \brief Items to be positioned before the contentItem

      a list of items to be laid out before the contentItem (at the left on LTR locales)
      for instance a big icon, that will cover the cumulative height of the title, contentItem and subtitle.
     */
    property list<Item> leadingItems

    /*!
      \brief Items to be positioned after the contentItem

      a list of items to be laid out after the contentItem (at the right on LTR locales)
      for instance a ContextualHelpButton, that will cover the cumulative height of the title, contentItem and subtitle.
     */
    property list<Item> trailingItems

    /*!
      Emitted when the user clicks or taps over this Entry.
     */
    signal clicked
}
