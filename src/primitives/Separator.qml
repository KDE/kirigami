/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick

import org.kde.kirigami.platform as Platform

/*!
  \qmltype Separator
  \inqmlmodule org.kde.kirigami.primitives

  \brief A visual separator.

  Useful for splitting one set of items from another.

 */
Rectangle {
    id: root
    implicitHeight: 1
    implicitWidth: 1
    Accessible.role: Accessible.Separator

    enum Weight {
        Light,
        Normal
    }

    /*!
      TODO qdoc enum

      \brief This property holds the visual weight of the separator.

      Weight options:
      \list
      \li Kirigami.Separator.Weight.Light
      \li Kirigami.Separator.Weight.Normal
      \endlist

      default: Kirigami.Separator.Weight.Normal

      \since 5.72
     */
    property int weight: Separator.Weight.Normal

    /* TODO: If we get a separator color role, change this to
     * mix weights lower than Normal with the background color
     * and mix weights higher than Normal with the text color.
     */
    color: Platform.ColorUtils.linearInterpolation(
        Platform.Theme.backgroundColor,
        Platform.Theme.textColor,
        weight === Separator.Weight.Light ? Platform.Theme.lightFrameContrast : Platform.Theme.frameContrast
    )
}
