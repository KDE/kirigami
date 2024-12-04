
/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
import QtQuick
import org.kde.kirigami as Kirigami

/*!
  \brief This is the default background for Cards.

  It provides background feedback on hover and click events, border customizability, and the ability to change the radius of each individual corner.

  \internal
 */
Kirigami.ShadowedRectangle {
    id: root

//BEGIN properties
    /*!
      \brief This property sets whether there should be a background change on a click event.

      default: false
     */
    property bool clickFeedback: false

    /*!
      \brief This property sets whether there should be a background change on a click event.

      default: false
     */
    property bool hoverFeedback: false

    /*!
      \brief This property holds the card's normal background color.

      default: Kirigami.Theme.backgroundColor
     */
    property color defaultColor: Kirigami.Theme.backgroundColor

    /*!
      \brief This property holds the color displayed when a click event is triggered.
      \sa DefaultCardBackground::clickFeedback
     */
    property color pressedColor: Kirigami.ColorUtils.tintWithAlpha(
                                     defaultColor,
                                     Kirigami.Theme.highlightColor, 0.3)

    /*!
      \brief This property holds the color displayed when a hover event is triggered.
      \sa DefaultCardBackground::hoverFeedback
     */
    property color hoverColor: Kirigami.ColorUtils.tintWithAlpha(
                                   defaultColor,
                                   Kirigami.Theme.highlightColor, 0.1)

    /*!
      \brief This property holds the border width which is displayed at the edge of DefaultCardBackground.

      default: 1
     */
    property int borderWidth: 1

    /*!
      \brief This property holds the border color which is displayed at the edge of DefaultCardBackground.
     */
    property color borderColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)

//END properties

    color: {
        if (root.parent.checked || (root.clickFeedback && (root.parent.down || root.parent.highlighted)))
            return root.pressedColor
        else if (root.hoverFeedback && root.parent.hovered)
            return root.hoverColor
        return root.defaultColor
    }

    radius: Kirigami.Units.cornerRadius

    border {
        width: root.borderWidth
        color: root.borderColor
    }
    shadow {
        size: Kirigami.Units.gridUnit
        color: Qt.rgba(0, 0, 0, 0.05)
        yOffset: 2
    }

    // basic drop shadow
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Math.round(Kirigami.Units.smallSpacing / 4)

        radius: root.radius
        height: root.height
        color: Qt.darker(Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.6), 1.1)
        visible: !root.clickFeedback || !root.parent.down

        z: -1
    }
}
