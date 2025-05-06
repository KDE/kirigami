/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Separator {
    id: separator
    property Item column
    readonly property bool inToolBar: parent !== column

    anchors {
        topMargin: inToolBar ? Kirigami.Units.largeSpacing : 0
        bottomMargin: inToolBar ? Kirigami.Units.largeSpacing : 0
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.Header
    Kirigami.Theme.inherit: false

    states: [
        State {
            name: "leading"
            AnchorChanges {
                target: separator
                anchors {
                    top: parent.top
                    right: parent.left
                    bottom: parent.bottom
                }
            }
            PropertyChanges {
                target: separator
                visible: column.Kirigami.ColumnView.pinned
            }
        },
        State {
            name: "trailing"
            AnchorChanges {
                target: separator
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }
            }
            PropertyChanges {
                target: separator
                visible: column.Kirigami.ColumnView.pinned || (column.Kirigami.ColumnView.index < column.Kirigami.ColumnView.view?.count - 1 ?? false)
            }
        }
    ]
}
