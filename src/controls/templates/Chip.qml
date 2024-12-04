// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Templates as T

/*!
  \qmltype Chip
  \inqmlmodule org.kde.kirigami

  \brief A compact element that represents an attribute, action, or filter.

  Should be used in a group of multiple elements. e.g when displaying tags in a image viewer.

  Example usage:
  \qml
  import org.kde.kirigami as Kirigami

  Flow {
      Repeater {
          model: chipsModel

          Kirigami.Chip {
              text: model.text
              icon.name: "tag-symbolic"
              closable: model.closable
              onClicked: {
                  [...]
              }
              onRemoved: {
                  [...]
              }
          }
      }
  }
  \endqml

  \since 2.19
 */
T.AbstractButton {
    id: chip

    // TODO qdoc this should be a property of the template
    /*!
      \qmlproperty Label Chip::labelItem
      \brief This property holds the label item; used for accessing the usual Text properties.
    */

    /*!
      \brief This property holds whether or not to display a close button.

      default: \c true
     */
    property bool closable: true

    /*!
      \brief This property holds whether the icon should be masked or not. This controls the Kirigami.Icon.isMask property.

      default: \c false
     */
    property bool iconMask: false

    /*!
      \brief This signal is emitted when the close button has been clicked.
     */
    signal removed()
}
