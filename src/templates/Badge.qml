/*
 *  SPDX-FileCopyrightText: 2025-2026 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
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
      type: Kirigami.BadgeType.Positive
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
      type: Kirigami.BadgeType.Negative
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

  \since 6.25
 */

T.Control {
    id: root

    /*!
     \qmlproperty string icon.name
     \qmlproperty var icon.source
     \qmlproperty color icon.color
     \qmlproperty real icon.width
     \qmlproperty real icon.height
     \qmlproperty function icon.fromControlsIcon

     This grouped property determines the appearance of the optional icon.
     note that the \c color property is ignored.

     If you pass an icon name ending in "-symbolic", the icon will be
     masked and re-colored to match the text color.

     The default is to display no icon.

     \include iconpropertiesgroup.qdocinc grouped-properties
     */
    property Primitives.IconPropertiesGroup icon: Primitives.IconPropertiesGroup {
        width: Kirigami.Units.iconSizes.sizeForLabels
        height: Kirigami.Units.iconSizes.sizeForLabels
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


     The default is Kirigami.BadgeType.Information, which produces a
     soft blue background with the Breeze color scheme.
     */
    property int type: Kirigami.BadgeType.Information

    /*!
     \qmlproperty color backgroundColor

     This property determines the color of the badge background.

     The default value is a 20% opacity version of a color from the
     color scheme, chosen by consulting the \c type. This color can
     be overridden, but avoid doing this unless necessary, and in
     that case, also set \c textColor to something more appropriate.

     \since 6.25
     */
    property color backgroundColor: {
        let bgcolor;
        switch (type) {
            case Kirigami.BadgeType.Positive:
                bgcolor = Kirigami.Theme.positiveTextColor;
                break;
            case Kirigami.BadgeType.Warning:
                bgcolor = Kirigami.Theme.neutralTextColor;
                break;
            case Kirigami.BadgeType.Error:
                bgcolor = Kirigami.Theme.negativeTextColor;
                break;
            default:
                bgcolor = Kirigami.Theme.activeTextColor;
                break;
        }
        // TODO: use an unmodified color from the color scheme once
        // any of them both look good and are appropriate for this
        // purpose.
        return Qt.alpha(bgcolor, 0.2);
    }

    /*!
     \qmlproperty color textColor

     This property determines the color of the badge's text. If the badge is
     displaying an icon with a name ending in "-symbolic", the icon will be
     masked and re-colored to match this color, too.

     The default value is \c Kirigami.Theme.textColor slightly tinted with
     the background color.

     Avoid changing this unless you've also changed \c backgroundColor to
     something that won't work with the standard text color.

     \since 6.25
     */
    // 0.17 is the lowest we can go and still achieve WCAG AAA contrast ratio with the default colors
    property color textColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, backgroundColor, 0.17)

    /*!
     \qmlproperty bool pillShaped

     This property holds whether the badge is "pill-shaped", meaning its border
     radius should be exactly half its height rather than the standard border
     radius value. The badge enters this state when its label text is a single
     line or not set, so the theme can style it appropriately to look sleeker.

     \since 6.25
     */
    readonly property bool pillShaped: text.length === 0 || label.lineCount === 1

    implicitHeight: Math.round(implicitContentHeight + topPadding + bottomPadding)
    // Make sure it's a perfect square/circle if it would be slightly shorter than that
    implicitWidth: Math.round(Math.max(implicitContentHeight + topPadding + bottomPadding, implicitContentWidth + leftPadding + rightPadding))

    spacing: Kirigami.Units.smallSpacing

    font.bold: true
    font.pointSize: Kirigami.Theme.smallFont.pointSize
    font.family: Kirigami.Theme.smallFont.family

    Accessible.name: label.text

    contentItem: RowLayout {
        spacing: root.spacing

        Kirigami.Icon {
            id: icon

            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            Layout.alignment: root.pillShaped ? Qt.AlignHCenter : Qt.AlignTop

            visible: source.length > 0

            source: root.icon.name || root.icon.source || ""

            isMask: root.icon.name.endsWith("-symbolic")
            color: root.textColor

        }

        QQC2.Label {
            id: label

            Layout.fillWidth: true

            visible: text.length > 0

            text: root.text
            color: root.textColor
            font.bold: root.font.bold
            font.pointSize: root.font.pointSize
            font.family: root.font.family

            wrapMode: Text.Wrap
            horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
            textFormat: Text.PlainText
        }
    }
}
