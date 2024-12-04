/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
  \qmltype CardsLayout
  \inqmlmodule org.kde.kirigami

  \brief A GridLayout optimized for showing one or two columns of cards,
  depending on the available space.

  It Should be used when the cards are not instantiated by a model or by a
  model which has always very few items.

  They are presented as a grid of two columns which will remain
  centered if the application is really wide, or become a single
  column if there is not enough space for two columns,
  such as a mobile phone screen.

  A CardsLayout should always be contained within a ColumnLayout.

  \since 2.4
 */
GridLayout {
    /*!
      \brief This property holds the maximum number of columns.

      This layout will never lay out the items in more columns than maximumColumns

      default: 2

      \since 2.5
     */
    property int maximumColumns: 2

    /*!
      \brief This property holds the maximum width the columns may have.

      The cards will never become wider than this size; when the GridLayout is wider than
      maximumColumnWidth, it will switch from one to two columns.

      If the default needs to be overridden for some reason,
      it is advised to express this unit as a multiple
      of Kirigami.Units.gridUnit.

      default: 20 * Kirigami.Units.gridUnit
     */
    property int maximumColumnWidth: Kirigami.Units.gridUnit * 20

    /*!
      \brief This property holds the minimum width the columns may have.

      The layout will try to dispose of items
      in a number of columns that will respect this size constraint.

      default: 12 * Kirigami.Units.gridUnit

      \since 2.5
     */
    property int minimumColumnWidth: Kirigami.Units.gridUnit * 12

    columns: Math.max(1, Math.min(maximumColumns > 0 ? maximumColumns : Infinity,
                                  Math.floor(width/minimumColumnWidth),
                                  Math.ceil(width/maximumColumnWidth)));

    rowSpacing: Kirigami.Units.largeSpacing
    columnSpacing: Kirigami.Units.largeSpacing


    // NOTE: this default width which defaults to 2 columns is just to remove a binding loop on columns
    width: maximumColumnWidth*2 + Kirigami.Units.largeSpacing
    // same computation of columns, but on the parent size
    Layout.preferredWidth: maximumColumnWidth * Math.max(1, Math.min(maximumColumns > 0 ? maximumColumns : Infinity,
                                  Math.floor(parent.width/minimumColumnWidth),
                                  Math.ceil(parent.width/maximumColumnWidth))) + Kirigami.Units.largeSpacing * (columns - 1)

    Layout.maximumWidth: Layout.preferredWidth
    Layout.alignment: Qt.AlignHCenter

    Component.onCompleted: childrenChanged()
    onChildrenChanged: {
        for (const child of children) {
            child.Layout.fillHeight = true;
        }
    }
}
