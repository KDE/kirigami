/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml


/*!
  \qmltype IconPropertiesGroup
  \inqmlmodule org.kde.kirigami.primitives

  \brief An object to be used as a grouped property compatible with QtQuickControls "icon" grouped property.

  Kirigami components which expose an icon grouped property use this class.
  Use it if you are writing a component that exposes an icon that you wish to have an
  icon property compatible with QtQuickControls one, with name, source, color,
  width and height properties.

  \since 6.17
*/
QtObject {
    /*!
      \qmlproperty string name

      This property holds a freedesktop theme compatible name for the icon.
      It is the preferred source for the icon
    */
    property string name

    /*!
      \qmlproperty var source

      This property can hold a full path to the icon, a QImage or a QIcon representing
      the icon. Use this with care and prefer name when possible
     */
    property var source

    /*!
       \qmlproperty color color

       This property holds a color for the icon.
       Only monochrome svg icons can be dinamically recolored.
     */
    property color color: Qt.rgba(0, 0, 0, 0)

    /*!
       \qmlproperty real width

       This property holds the preferred width for the icon.
       This is a size hint for the icon. It depends from the control implementation
       how this is enforced or not.
     */
    property real width

    /*!
       \qmlproperty real width

       This property holds the preferred height for the icon.
       This is a size hint for the icon. It depends from the control implementation
       how this is enforced or not.
     */
    property real height

    /*!
      \qmlmethod IconPropertiesGroup IconPropertiesGroup::fromControlsIcon(var icon)

      This method is used to bind an icon from a QtQuickControls to an IconPropertiesGroup
      to have them to be kept in sync, use it as follows:

      \qml
      import QtQuick
      import QtQuick.Controls as QQC
      import org.kde.kirigami as Kirigami

      Item {
          Kirigami.PlaceholderMessage {
              icon: icon.fromControlsIcon(button.icon)
          }
          QQC.Button {
              id.button
          }
      }
      \endqml
     */
    function fromControlsIcon(icon) {
        name = Qt.binding(() => icon.name)
        source = Qt.binding(() => icon.source)
        color = Qt.binding(() => icon.color)
        width = Qt.binding(() => icon.width)
        height = Qt.binding(() => icon.height)
        return this
    }
}
