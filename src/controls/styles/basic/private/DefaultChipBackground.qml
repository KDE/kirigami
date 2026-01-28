// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT

Rectangle {

    /*!
      \brief This property holds the chip's default background color.
     */
    property color defaultColor: Platform.Theme.backgroundColor

    /*!
      \brief This property holds the color of the Chip's background when it is being pressed.
      \sa QtQuick.AbstractButton::down
     */
    property color pressedColor: Qt.rgba(Platform.Theme.highlightColor.r, Platform.Theme.highlightColor.g, Platform.Theme.highlightColor.b, 0.3)

    /*!
      \brief This property holds the color of the Chip's background when it is checked.
      \sa QtQuick.AbstractButton::checked
     */
    property color checkedColor: Qt.rgba(Platform.Theme.highlightColor.r, Platform.Theme.highlightColor.g, Platform.Theme.highlightColor.b, 0.2)

    /*!
      \brief This property holds the chip's default border color.
     */
    property color defaultBorderColor: Platform.ColorUtils.linearInterpolation(Platform.Theme.backgroundColor, Platform.Theme.textColor, Platform.Theme.frameContrast)

    /*!
      \brief This property holds the color of the Chip's border when it is checked.
      \sa QtQuick.AbstractButton::checked
     */
    property color checkedBorderColor: Qt.rgba(Platform.Theme.highlightColor.r, Platform.Theme.highlightColor.g, Platform.Theme.highlightColor.b, 0.9)

    /*!
      \brief This property holds the color of the Chip's border when it is being pressed.
      \sa QtQuick.AbstractButton::down
     */
    property color pressedBorderColor: Qt.rgba(Platform.Theme.highlightColor.r, Platform.Theme.highlightColor.g, Platform.Theme.highlightColor.b, 0.7)

    /*!
     * \brief This property holds the color of the Chip's border when it is hovered.
     * \sa QtQuick.Control::hovered
     */
    property color hoveredBorderColor: Platform.Theme.hoverColor

    Platform.Theme.colorSet: Platform.Theme.Header
    Platform.Theme.inherit: false

    color: {
        const chip = parent as KT.Chip
        if (chip.down) {
            return pressedColor
        } else if (chip.checked) {
            return checkedColor
        } else {
            return defaultColor
        }
    }
    border.color: {
        const chip = parent as KT.Chip
        if (chip.down) {
            return pressedBorderColor
        } else if (chip.checked) {
            return checkedBorderColor
        } else if (chip.hovered) {
            return hoveredBorderColor
        } else {
            return defaultBorderColor
        }
    }
    border.width: 1
    radius: Platform.Units.cornerRadius
}
