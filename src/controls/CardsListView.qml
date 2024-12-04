/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

/*!
  \qmltype CardsListView
  \inqmlmodule org.kde.kirigami

  \brief A ListView that can have AbstractCard as its delegate.

  This control will automatically assign the proper spacings
  and margins around the cards adhering to the design guidelines.

  CardsListView should be used only with cards which can look good at any
  horizontal size, so it is recommended to directly use AbstractCard with an
  appropriate layout inside, because they are stretching for the whole list width.

  Therefore, it is discouraged to use it with the Card type.

  The choice between using this view with AbstractCard or a normal ListView
  is purely a choice based on aesthetics alone.

  It is recommended to use default values.

  \since 2.4
 */
ListView {
    id: root
    spacing: Kirigami.Units.largeSpacing * 2
    topMargin: headerPositioning !== ListView.InlineHeader ? spacing : 0
    rightMargin: Kirigami.Units.largeSpacing * 2
    leftMargin: Kirigami.Units.largeSpacing * 2
    reuseItems: true

    headerPositioning: ListView.OverlayHeader

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) {
            positionViewAtBeginning();
            currentIndex = 0;
            event.accepted = true;
        }
        else if (event.key === Qt.Key_End) {
            positionViewAtEnd();
            currentIndex = count - 1;
            event.accepted = true;
        }
    }
}
