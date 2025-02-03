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

  \brief A heading label used for subsections of texts.

  The characteristics of the text will be automatically set according to the
  Kirigami.Theme. Use this components for section titles or headings in your UI,
  for example page or section titles.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami
  [...]
  Column {
      Kirigami.Heading {
          text: "Apples in the sunlight"
          level: 2
      }
    [...]
  }
  \endcode

  The most important property is text, which applies to the text property of
  Label. See the Label component from QtQuick.Controls 2 and primitive QML Text
  element API for additional properties, methods and signals.

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

    opacity: type === Heading.Type.Secondary ? 0.7 : 1

    Accessible.role: Accessible.Heading
}
