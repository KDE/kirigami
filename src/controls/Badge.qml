/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.primitives as Primitives

/*!
  \qmltype Badge
  \inqmlmodule org.kde.kirigami
  \inherits QQC2.Control

  \brief A badge with a colored background.

  Useful for badging something in an attention-getting way to indicate a
  non-default status. Supports both text and an icon — both optional.

  If the badge has no text or has single-line text, it will have a highly
  rounded, pill-shaped appearance. Otherwise it will be a rounded rectangle.

  Typical implementation:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Badge {
      text: i18nc("@info badge text", "New!")
      backgroundColor: Kirigami.Theme.positiveBackgroundColor
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
      backgroundColor: Kirigami.Theme.negativeBackgroundColor
  }
  \endqml

  Implemented with custom background and foreground colors and non-recolored icon:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Badge {
      icon.name: "applications-science"
      text: i18nc("@info badge text", "Science")
      backgroundColor: Kirigami.Theme.visitedLinkColor
      textColor: Kirigami.Theme.highlightedTextColor
  }
  \endqml

  \since 6.21
 */

QQC2.Control {
    id: root

    /*!
     \qmlproperty string icon.name
     \qmlproperty var icon.source
     \qmlproperty color icon.color
     \qmlproperty real icon.width
     \qmlproperty real icon.height
     \qmlproperty function icon.fromControlsIcon

     This grouped property holds the description of an optional icon.
     note that the \c width, \c height, and \c color properties will be
     ignored.

     If you pass an icon name ending in "-symbolic", the icon will be
     re-colored to match the text color.

     The default is to display no icon.

     \include iconpropertiesgroup.qdocinc grouped-properties
     */
    property Primitives.IconPropertiesGroup icon: Primitives.IconPropertiesGroup {}

    /*!
     \qmlproperty string text

     This property determines the label text in the badge. Long text will
     wrap, but try to minimize text length anyway. The label islimited to
     plain text.

     The default value is an empty string, i.e. no text.

     \since 6.21
     */
    property string text: ""

    /*!
     \qmlproperty color backgroundColor

     This property determines the color of the badge background.

     The default value is \c Kirigami.Theme.activeBackgroundColor.

     Prefer using colors from the theme with "background" in their names, since
     the foreground text uses the default text color (slightly tinted with the
     background color) which is intended to be used on top of a background color.
     If you use a different type of color for the background, set \c textColor
     to something more appropriate.

     \since 6.21
     */
    property color backgroundColor: Kirigami.Theme.activeBackgroundColor

    /*!
     \qmlproperty color textColor

     This property determines the color of the badge's text. If the badge is
     displaying an icon with a name ending in "-symbolic", the icon will be
     re-colored to match this color, too.

     The default value is \c Kirigami.Theme.textColor slightly tinted with
     the background color.

     Avoid changing this unless you've also changed \c backgroundColor to
     something that won't work with the standard text color.

     \since 6.21
     */
    // 0.17 is the lowest we can go and still achieve WCAG AAA contrast ratio with the default colors
    property color textColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, backgroundColor, 0.17)

    // Be pill-shaped when not very tall, because it looks great
    readonly property bool ___pillShaped: !label.visible || label.lineCount === 1
    // Extra horizontal padding looks better when pill-shaped with icons and long labels
    readonly property int ___horizontalPadding: ___pillShaped && label.visible && label.text.length > 2 ? (padding + Kirigami.Units.smallSpacing) : padding
    readonly property int ___extraTrailingPadding: ___pillShaped && icon.visible && label.visible ? Kirigami.Units.smallSpacing : 0

    padding: Kirigami.Units.smallSpacing
    topPadding: padding
    leftPadding: ___horizontalPadding + (LayoutMirroring.enabled ? ___extraTrailingPadding : 0)
    rightPadding: ___horizontalPadding + (LayoutMirroring.enabled ? 0 : ___extraTrailingPadding)
    bottomPadding: padding

    implicitHeight: Math.round(implicitContentHeight + topPadding + bottomPadding)
    // Make sure it's a perfect square/circle if it would be slightly shorter than that
    implicitWidth: Math.round(Math.max(implicitContentHeight + topPadding + bottomPadding, implicitContentWidth + leftPadding + rightPadding))

    Accessible.name: label.text

    contentItem: RowLayout {
        id: layout
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            id: icon

            readonly property int size: Kirigami.Units.iconSizes.sizeForLabels

            Layout.preferredWidth: size
            Layout.preferredHeight: size
            Layout.alignment: ___pillShaped ? Qt.AlignHCenter : Qt.AlignTop

            visible: source.length > 0

            source: {
                if (root.icon.name) {
                    return root.icon.name;
                } else if (root.icon.source) {
                    return root.icon.source;
                } else {
                     return "";
                }
            }

            isMask: root.icon.name.endsWith("-symbolic")
            color: root.textColor

        }

        QQC2.Label {
            id: label
            Layout.fillWidth: true

            visible: text.length > 0

            text: root.text
            color: root.textColor
            font.bold: true
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            font.family: Kirigami.Theme.smallFont.family

            wrapMode: Text.Wrap
            horizontalAlignment: icon.visible ? Text.AlignLeft : Text.AlignHCenter
            textFormat: Text.PlainText
        }
    }

    background: Rectangle {
        color: root.backgroundColor
        radius: ___pillShaped ? root.implicitHeight / 2 : Kirigami.Units.cornerRadius
    }
}
