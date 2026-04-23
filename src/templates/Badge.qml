/*
 *  SPDX-FileCopyrightText: 2025-2026 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

/*!
  \qmltype Badge
  \inqmlmodule org.kde.kirigami
  \inherits QQC2.Control

  \brief A badge with a colored background.

  Useful for badging something in an attention-getting way to indicate a
  non-default status. Supports both text and an icon, both optional.

  If the badge has no text or has single-line text, it will have a highly
  rounded, pill-shaped appearance. Otherwise it will be a rounded rectangle.

  Typical implementation:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Badge {
      text: i18nc("@info badge text", "New!")
      type: Kirigami.Badge.Type.Positive
  }
  \endqml

  Implemented as a number badge:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Badge {
      text: 25
  }
  \endqml

  Implemented as a warning with a re-colored icon:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Badge {
      icon.name: "edit-bomb-symbolic"
      text: i18nc("@info badge text", "The computer is about to explode")
      type: Kirigami.Badge.Type.Negative
  }
  \endqml

  Implemented with a custom color and non-recolored icon:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Badge {
      icon.name: "applications-science"
      text: i18nc("@info badge text", "Science")
      customColor: Kirigami.Theme.visitedLinkColor
  }
  \endqml

  \since 6.25
 */

T.Control {
    id: root

    enum Type {
        Information,
        Positive,
        Warning,
        Error
    }

    /*!
     \qmlproperty string icon.name
     \qmlproperty var icon.source
     \qmlproperty color icon.color
     \qmlproperty real icon.width
     \qmlproperty real icon.height
     \qmlproperty function icon.fromControlsIcon

     This grouped property determines the appearance of the optional icon.

     If you set the \c color property or pass an icon name ending in
     "-symbolic", the icon will be masked and re-colored to match the text
     color.

     The default is to display no icon.

     \include iconpropertiesgroup.qdocinc grouped-properties
     */
    property Primitives.IconPropertiesGroup icon: Primitives.IconPropertiesGroup {
        width: Platform.Units.iconSizes.sizeForLabels
        height: Platform.Units.iconSizes.sizeForLabels
        color: "transparent"
    }

    /*!
     \qmlproperty string text

     This property determines the label text in the badge. Long text will
     wrap, but try to minimize text length anyway. The label is limited to
     plain text.

     The default value is an empty string, i.e. no text.

     \since 6.25
     */
    property string text

    /*!
     \qmlproperty enumeration Badge::type

     This property holds the badge type, which affects the badge's
     default background color.

     One of
     \list
     \li Information
     \li Positive
     \li Warning
     \li Error
     \endlist

     The default is Kirigami.Badge.Type.Information, which the implementation
     should use to produce a soft blue background with the Breeze color
     scheme.
     */
    property int type: Badge.Type.Information

    /*!
     \qmlproperty color customColor

     When set, this property overrides the default background color that was
     chosen by the implementation based on the \c type property.

     The implementation should set a legible text color for whatever
     color is chosen here. For maximum control over the text color,
     also set \c customTextColor.

     \since 6.25
     */
    property color customColor: "transparent"

    /*!
     \qmlproperty color customTextColor

     When set, this property overrides the default text color that was
     chosen by the implementation based on the \c type or \c customTextColor
     properties.

     \since 6.25
     */
    property color customTextColor: "transparent"

    implicitHeight: Math.round(implicitContentHeight + topPadding + bottomPadding)
    // Make sure it's a perfect square/circle if it would be slightly shorter than that
    implicitWidth: Math.round(Math.max(implicitContentHeight + topPadding + bottomPadding, implicitContentWidth + leftPadding + rightPadding))

    Accessible.name: text
}
