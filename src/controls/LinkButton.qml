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
 * \brief A button that looks like a link.
 *
 * It uses the link color settings and triggers an action when clicked.
 *
 * Maps to the Command Link in the HIG:
 * https://develop.kde.org/hig/components/navigation/commandlink/
 *
 * @since 5.52
 * @since org.kde.kirigami 2.6
 * @inherit QtQuick.Controls.Label
 */
QQC2.Label {
    id: control

    property T.Action action

    /*!
     * \brief This property holds the mouse buttons that the mouse area reacts to.
     * \sa QtQuick.MouseArea::acceptedButtons
     * @property Qt::MouseButtons acceptedButtons
     */
    property alias acceptedButtons: area.acceptedButtons

    /*!
     * \brief This property holds the mouse area element covering the button.
     * @property MouseArea area
     */
    property alias mouseArea: area

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked({ button: Qt.LeftButton })

    text: action?.text ?? ""
    enabled: action?.enabled ?? true

    onClicked: action?.trigger()

    font.bold: activeFocus
    font.underline: enabled
    color: enabled ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
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
