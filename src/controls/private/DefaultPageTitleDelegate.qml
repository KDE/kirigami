/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
 * This component is used as a default representation for a page title within
 * page's header/toolbar. It is just a Heading item with shrinking + eliding
 * behavior.
 *
 * \internal
 */
Item {
    property alias text: heading.text

    Layout.fillWidth: true
    Layout.minimumWidth: 0
    Layout.maximumWidth: implicitWidth

    implicitWidth: Math.ceil(heading.implicitWidth)
    implicitHeight: Math.ceil(heading.implicitHeight)

    Kirigami.Heading {
        id: heading

        anchors.fill: parent
        maximumLineCount: 1
        elide: Text.ElideRight
        textFormat: Text.PlainText
    }
}
