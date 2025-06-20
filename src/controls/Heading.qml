/*
 *  SPDX-FileCopyrightText: 2012 Sebastian Kügler <sebas@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/*!
  \qmltype Heading
  \inqmlmodule org.kde.kirigami

  \brief A pre-formatted label used for titles and section headers

  Use this component for titles and section headers. The characteristics of the
  text will be automatically set according to the \c Kirigami.Theme.

  The most important property is \l text; use this to set the heading text to
  be displayed.

  Example usage:
  \code
  import QtQuick.Layouts
  import QtQuick.Controls as QQC2
  import org.kde.kirigami as Kirigami
  [...]
  ColumnLayout {
      spacing: 0

      Kirigami.Heading {
          Layout.fillWidth: true
          wrapMode: Text.Wrap
          text: "Apples in the sunlight"
          level: 2
      }
      QQC2.Label {
          Layout.fillWidth: true
          wrapMode: Text.Wrap
          text: "And this is why apples are amazing: let me tell you a story about this one time I was napping below a tree…"
      }
    [...]
  }
  \endcode
 */
QQC2.Label {
    id: heading

    /*!
      \brief This property holds the level of the heading, which determines its size.

      This property holds the level, which determines how large the header is.

      Acceptable values range from 1 (big) to 5 (small).

      default: 1
     */
    property int level: 1

    /*!
      \brief This enumeration defines heading types.

      This enum helps with heading visibility (making it less or more important).
     */
    enum Type {
        Normal,
        Primary,
        Secondary
    }

    /*!
      \qmlproperty enumeration Heading::type
      \brief This property holds the heading type.

      The type of heading. This can be:
      \list
      \li Kirigami.Heading.Type.Normal: Create a normal heading (default).
      \li Kirigami.Heading.Type.Primary: Makes the heading more prominent. Useful
        when making the heading bigger is not enough.
      \li Kirigami.Heading.Type.Secondary: Makes the heading less prominent.
        Useful when an heading is for a less important section in an application.
      \endlist

      \since 5.82
     */
    property int type: Heading.Type.Normal

    font.pointSize: {
        let factor = 1;
        switch (heading.level) {
            case 1:
                factor = 1.35;
                break;
            case 2:
                factor = 1.20;
                break;
            case 3:
                factor = 1.15;
                break;
            case 4:
                factor = 1.10;
                break;
            default:
                break;
        }
        return Kirigami.Theme.defaultFont.pointSize * factor;
    }
    font.weight: type === Heading.Type.Primary ? Font.DemiBold : Font.Normal

    opacity: type === Heading.Type.Secondary ? 0.75 : 1

    Accessible.role: Accessible.Heading
}
