/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/*!
  \qmltype LinkButton
  \inqmlmodule org.kde.kirigami
  \brief A button that looks like a link.

  It uses the link color settings and triggers an action when clicked.

  Maps to the Command Link in the HIG:
  \l https://develop.kde.org/hig/components/navigation/commandlink/

  \since 5.52
 */
QQC2.Label {
    id: control

    /*!
      \qmlproperty Action action
      An action that will be triggered when the button is clicked
     */
    property T.Action action

    /*!
      \qmlproperty Qt::MouseButtons LinkButton::acceptedButtons
      \brief This property holds the mouse buttons that the mouse area reacts to.
      \sa MouseArea::acceptedButtons
     */
    property alias acceptedButtons: area.acceptedButtons

    /*!
      \qmlproperty MouseArea LinkButton::mouseArea
      \brief This property holds the mouse area element covering the button.
     */
    property alias mouseArea: area

    /*!
      This property holds the normal color of the link when not pressed
      or disabled.

      default: Kirigami.Theme.linkColor
     */
    property color normalColor: Kirigami.Theme.linkColor

    /*!
      This property holds the color of the link while pressed.

      default: Whatever the normal color is set to, but 200% darker
     */
    property color pressedColor: Qt.darker(normalColor)

    /*!
      This property holds the color of the link when disabled.

      default: Kirigami.Theme.textColor
     */
    property color disabledColor: Kirigami.Theme.textColor

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked({ button: Qt.LeftButton })

    text: action?.text ?? ""
    enabled: action?.enabled ?? true

    onClicked: action?.trigger()

    font.bold: activeFocus
    font.underline: enabled
    color: if (!enabled) {
        return control.disabledColor;
    } else if (area.containsPress) {
        return control.pressedColor;
    } else {
        return control.normalColor;
    }
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight

    signal pressed(var mouse)
    signal clicked(var mouse)

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            control.clicked({ button: Qt.LeftButton });
            event.accepted = true;
            break;
        case Qt.Key_Menu:
            control.pressed({ button: Qt.RightButton });
            event.accepted = true;
            break;
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => control.clicked(mouse)
        onPressed: mouse => control.pressed(mouse)
    }
}
