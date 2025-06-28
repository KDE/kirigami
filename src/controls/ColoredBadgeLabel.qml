/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/*!
  \qmltype ColoredBadgeLabel
  \inqmlmodule org.kde.kirigami
  \inherits QQC2.Label

  \brief Text badge with a colored background.

  Useful for badging something in an attention-getting way to indicate a
  non-default status.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  Kirigami.ColoredBadgeLabel {
      text: i18n("New!")
      compact: false
      backgroundColor: Kirigami.Theme.positiveBackgroundColor
  }
  \endcode

  \since 6.16
 */

QQC2.Label {
    id: root

    /*!
     \ *qmlproperty bool compact

     This property determines the size of the background relative to the text.
     When true, the badge background will hug the text closely; otherwise, the
     background will be larger than the text.

     The default is false.

     \since 6.16
     */
    property bool compact: false

    /*!
     \ **qmlproperty color backgroundColor

     This property determines the color of the badge background.

     The default is \c Kirigami.Theme.activeBackgroundColor.

     Prefer using "background" colors from the theme, since the foreground text
     uses the default text color which is intended to be used on top of a
     background color. If you use a different type of color for the background,
     choose a more appropriate foreground color for the label too.

     \since 6.16
     */
    property color backgroundColor: Kirigami.Theme.activeBackgroundColor

    /*!
     \ ***qmlproperty int backgroundRadius

     This property determines the corner radius of the badge background.

     The default is \c Kirigami.Units.cornerRadius.

     Don't override this without a very good reason; e.g. to force the
     background to be completely round if you want a circular badge.

     \since 6.16
     */
    property int backgroundRadius: Kirigami.Units.cornerRadius

    padding: compact ? Kirigami.Units.smallSpacing / 2 : Kirigami.Units.mediumSpacing

    font.bold: true
    font.pointSize: compact ? Kirigami.Theme.smallFont.pointSize : Kirigami.Theme.defaultFont.pointSize
    font.family: compact ? Kirigami.Theme.smallFont.family : Kirigami.Theme.defaultFont.family

    wrapMode: Text.Wrap
    horizontalAlignment: Text.AlignHCenter
    textFormat: Text.PlainText

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        Kirigami.Theme.inherit: false

        color: root.backgroundColor
        radius: root.backgroundRadius
    }
}
