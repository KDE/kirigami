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

    MouseArea {
        anchors {
            fill: parent
            leftMargin: -Kirigami.Units.smallSpacing
            rightMargin: -Kirigami.Units.smallSpacing
        }
        visible: column.Kirigami.ColumnView.interactiveResize && (column.Kirigami.ColumnView.view?.columnResizeMode === Kirigami.ColumnView.DynamicColumns ?? false)
        cursorShape: Qt.SizeHorCursor
        property real oldMouseX
        onPressed: mouse => {
            oldMouseX = mapToItem(null, mouse.x, 0).x
        }
        onPositionChanged: mouse => {
            const newX = mapToItem(null, mouse.x, 0).x;
            const view = column.Kirigami.ColumnView.view;
            let leadingColumn = column;
            let trailingColumn = column;

            if (separator.state === "trailing") {
                trailingColumn = view.contentChildren[column.Kirigami.ColumnView.index + 1]
            } else {
                leadingColumn = view.contentChildren[column.Kirigami.ColumnView.index - 1]
            }

            let leadingWidth = leadingColumn.implicitWidth;
            let trailingWidth = trailingColumn.implicitWidth;
            if (leadingWidth <= 0) {
                leadingWidth = leadingColumn.width;
            }
            if (trailingWidth <= 0) {
                trailingWidth = trailingColumn.width;
            }

            let diff = newX - oldMouseX;
            if (LayoutMirroring.enabled) {
                diff *= -1;
            }

            // Minimum and maximum widths for the leading column
            let leadingMinimumWidth = leadingColumn.Kirigami.ColumnView.minimumWidth;
            if (leadingMinimumWidth < 0) {
                leadingMinimumWidth = Kirigami.Units.gridUnit * 8;
            }
            let leadingMaximumWidth = leadingColumn.Kirigami.ColumnView.maximumWidth;
            if (leadingMaximumWidth < 0) {
                leadingMaximumWidth = leadingWidth + trailingWidth - leadingMinimumWidth;
            }

            // Minimum and maximum widths for the trailing column
            let trailingMinimumWidth = trailingColumn.Kirigami.ColumnView.minimumWidth;
            if (trailingMinimumWidth < 0) {
                trailingMinimumWidth = Kirigami.Units.gridUnit * 8;
            }
            let trailingMaximumWidth = trailingColumn.Kirigami.ColumnView.maximumWidth;
            if (trailingMaximumWidth < 0) {
                trailingMaximumWidth = leadingWidth + trailingWidth - trailingMinimumWidth;
            }

            if (diff < 0) {
                if (leadingColumn.Kirigami.ColumnView.fillWidth) {
                    leadingColumn.Kirigami.ColumnView.reservedSpace = Math.max(
                        trailingMinimumWidth,
                        leadingColumn.Kirigami.ColumnView.reservedSpace + diff);
                } else {
                    leadingColumn.implicitWidth = Math.min(leadingMaximumWidth, Math.max(leadingMinimumWidth, leadingWidth + diff));
                }
                if (trailingColumn.Kirigami.ColumnView.fillWidth) {
                    trailingColumn.Kirigami.ColumnView.reservedSpace = Math.max(
                        leadingMinimumWidth,
                        trailingColumn.Kirigami.ColumnView.reservedSpace + diff);
                } else {
                    trailingColumn.implicitWidth += (leadingWidth - leadingColumn.implicitWidth);
                }
            } else {
                if (trailingColumn.Kirigami.ColumnView.fillWidth) {
                    trailingColumn.Kirigami.ColumnView.reservedSpace = Math.min(
                        leadingMaximumWidth,
                        trailingColumn.Kirigami.ColumnView.reservedSpace + diff);
                } else {
                    trailingColumn.implicitWidth = Math.max(trailingMinimumWidth, trailingWidth - diff);
                }
                if (leadingColumn.Kirigami.ColumnView.fillWidth) {
                    leadingColumn.Kirigami.ColumnView.reservedSpace = Math.min(
                        trailingMaximumWidth,                        leadingColumn.Kirigami.ColumnView.reservedSpace + diff);
                } else {
                    leadingColumn.implicitWidth = Math.min(leadingMaximumWidth, leadingWidth + diff);
                }
            }
            oldMouseX = newX;
        }
    }
}
