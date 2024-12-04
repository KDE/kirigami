/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

//TODO KF6: how much is this used? can be removed?
/*!
  \qmltype FlexColumn
  \inqmlmodule org.kde.kirigami

  \brief FlexColumn is a column that grows in width to a fixed cap.
 */
ColumnLayout {
    id: __outer

    default property alias columnChildren: __inner.children

    /*!
      \brief This property holds the column's offset from the cross axis.

      Note that padding is applied on both sides
      when the column is aligned to a centered cross axis.

      default: Kirigami.Units.largeSpacing
     */
    property real padding: Kirigami.Units.largeSpacing

    /*!
      \brief This property holds maximum column width.

      default: Kirigami.Units.gridUnit * 50
     */
    property real maximumWidth: Kirigami.Units.gridUnit * 50

    /*!
      \brief This property sets column's alignment when it hits its maximum width.

      default: Qt.AlignHCenter | Qt.AlignTop

      \sa Qt.Alignment
     */
    property int alignment: Qt.AlignHCenter | Qt.AlignTop

    /*!
      \brief This property holds the inner column's width.
     */
    property real innerWidth: __inner.width

    Layout.fillWidth: true
    Layout.fillHeight: true

    enum CrossAxis {
        Left,
        Center,
        Right
    }

    ColumnLayout {
        id: __inner
        spacing: __outer.spacing
        Layout.maximumWidth: __outer.maximumWidth
        Layout.leftMargin: __outer.alignment & Qt.AlignLeft || __outer.alignment & Qt.AlignHCenter ? __outer.padding : 0
        Layout.rightMargin: __outer.alignment & Qt.AlignRight || __outer.alignment & Qt.AlignHCenter ? __outer.padding : 0
        Layout.alignment: __outer.alignment
    }
}
