/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: separator
    anchors.fill: parent

    readonly property bool isSeparator: true
    property Item previousColumn
    property Item column
    property Item nextColumn
    readonly property bool inToolBar: parent !== column

    SeparatorHandle {
        id: leftHandle
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        leadingColumn: previousColumn
        trailingColumn: column
    }

    Kirigami.Separator {
        anchors {
            left: parent.left
            bottom: leftHandle.top
            bottomMargin: Kirigami.Units.largeSpacing
        }
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false
        visible: column.Kirigami.ColumnView.globalHeader.visible && leftHandle.visible
        height: column.Kirigami.ColumnView.globalHeader.height - Kirigami.Units.largeSpacing * 2
    }

    SeparatorHandle {
        id: rightHandle
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: -1
        }
        leadingColumn: column
        trailingColumn: nextColumn
    }

    Kirigami.Separator {
        anchors {
            bottom: rightHandle.top
            right: parent.right
            rightMargin: -1
            bottomMargin: Kirigami.Units.largeSpacing
        }
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false
        visible: column.Kirigami.ColumnView.globalHeader.visible && rightHandle.visible
        height: column.Kirigami.ColumnView.globalHeader.height - Kirigami.Units.largeSpacing * 2
    }

    component SeparatorHandle: Kirigami.Separator {
        property Item leadingColumn
        property Item trailingColumn

        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false

        visible: leadingColumn && trailingColumn

        MouseArea {
            anchors {
                fill: parent
                leftMargin: -Kirigami.Units.smallSpacing
                rightMargin: -Kirigami.Units.smallSpacing
            }

            visible: {
                if (!column.Kirigami.ColumnView.view?.columnResizeMode === Kirigami.ColumnView.DynamicColumns ?? false) {
                    return false;
                }
                if (leadingColumn?.Kirigami.ColumnView.interactiveResize ?? false) {
                    return true;
                }
                if (trailingColumn?.Kirigami.ColumnView.interactiveResize ?? false) {
                    return true;
                }
                return false;
            }
            cursorShape: Qt.SplitHCursor
            property real oldMouseX
            onPressed: mouse => {
                oldMouseX = mapToItem(null, mouse.x, 0).x
            }
            onPositionChanged: mouse => {
                const newX = mapToItem(null, mouse.x, 0).x;
                const view = column.Kirigami.ColumnView.view;

                let leadingWidth = leadingColumn.implicitWidth;
                if (leadingWidth <= 0) {
                    leadingWidth = leadingColumn.width;
                }
                let trailingWidth = trailingColumn.implicitWidth;
                if (trailingWidth <= 0) {
                    trailingWidth = trailingColumn.width;
                }

                let diff = newX - oldMouseX;
                if (LayoutMirroring.enabled) {
                    diff *= -1;
                }

                // Minimum and maximum widths for the leading column
                let leadingMinimumWidth = leadingColumn.Kirigami.ColumnView.minimumWidth;
                if (leadingColumn.Kirigami.ColumnView.fillWidth) {
                    leadingMinimumWidth = leadingColumn.Kirigami.ColumnView.view.columnWidth;
                } else if (leadingMinimumWidth < 0) {
                    leadingMinimumWidth = Kirigami.Units.gridUnit * 8;
                }

                // Minimum and maximum widths for the trailing column
                let trailingMinimumWidth = trailingColumn.Kirigami.ColumnView.minimumWidth;
                if (trailingColumn.Kirigami.ColumnView.fillWidth) {
                    trailingMinimumWidth = trailingColumn.Kirigami.ColumnView.view.columnWidth;
                } else if (trailingMinimumWidth < 0) {
                    trailingMinimumWidth = Kirigami.Units.gridUnit * 8;
                }

                let leadingMaximumWidth = leadingColumn.Kirigami.ColumnView.maximumWidth;
                if (leadingMaximumWidth < 0) {
                    leadingMaximumWidth = leadingWidth + trailingWidth - trailingMinimumWidth;
                }


                let trailingMaximumWidth = trailingColumn.Kirigami.ColumnView.maximumWidth;
                if (trailingMaximumWidth < 0) {
                    trailingMaximumWidth = leadingWidth + trailingWidth - leadingMinimumWidth;
                }

                if (diff < 0) {
                    if (!leadingColumn.Kirigami.ColumnView.fillWidth) {
                        leadingColumn.implicitWidth = Math.min(leadingMaximumWidth, Math.max(leadingMinimumWidth, leadingWidth + diff));
                    }
                    if (!trailingColumn.Kirigami.ColumnView.fillWidth) {
                        trailingColumn.implicitWidth = Math.min(trailingMaximumWidth, Math.max(trailingMinimumWidth, trailingWidth - diff));
                    }
                } else {
                    if (!leadingColumn.Kirigami.ColumnView.fillWidth) {
                        leadingColumn.implicitWidth = Math.min(leadingMaximumWidth, leadingWidth + diff);
                    }
                    if (!trailingColumn.Kirigami.ColumnView.fillWidth) {
                        trailingColumn.implicitWidth = Math.max(trailingMinimumWidth, trailingWidth - diff);
                    }
                }
                oldMouseX = newX;
            }
        }
    }
}
