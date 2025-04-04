/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    readonly property Component leadingSeparator: Kirigami.Separator {
        property Item column
        property bool inToolBar
        property Kirigami.ColumnView view

        // positioning trick to hide the very first separator
        visible: {
            if (!view || !view.separatorVisible) {
                return false;
            }

            return view && (LayoutMirroring.enabled
                ? view.contentX + view.width > column.x + column.width
                : view.contentX < column.x);
        }

        anchors.top: column.top
        anchors.left: column.left
        anchors.bottom: column.bottom
        anchors.topMargin: inToolBar ? Kirigami.Units.largeSpacing : 0
        anchors.bottomMargin: inToolBar ? Kirigami.Units.largeSpacing : 0
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false
    }

    readonly property Component trailingSeparator: Kirigami.Separator {
        property Item column

        anchors.top: column.top
        anchors.right: column.right
        anchors.bottom: column.bottom
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false
    }
}
