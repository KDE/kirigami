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

    visible: (column.Kirigami.ColumnView.view?.separatorVisible ?? false) && (column.Kirigami.ColumnView.view?.columnResizeMode !== Kirigami.ColumnView.SingleColumn ?? false)

    SeparatorHandle {
        id: leftHandle
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        leadingColumn: LayoutMirroring.enabled ? column : previousColumn
        trailingColumn: LayoutMirroring.enabled ? nextColumn : column
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
        leadingColumn: LayoutMirroring.enabled ? previousColumn : column
        trailingColumn: LayoutMirroring.enabled ? column : nextColumn
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
                if (leadingColumn?.Kirigami.ColumnView.interactiveResizeEnabled ?? false) {
                    return true;
                }
                if (trailingColumn?.Kirigami.ColumnView.interactiveResizeEnabled ?? false) {
                    return true;
                }
                return false;
            }
            cursorShape: Qt.SplitHCursor
            onPressed: mouse => {
                if (leadingColumn) {
                    leadingColumn.Kirigami.ColumnView.interactiveResizing = true;
                }
                if (trailingColumn) {
                    trailingColumn.Kirigami.ColumnView.interactiveResizing = true;
                }
            }
            onReleased: {
                if (leadingColumn) {
                    leadingColumn.Kirigami.ColumnView.interactiveResizing = false;
                }
                if (trailingColumn) {
                    trailingColumn.Kirigami.ColumnView.interactiveResizing = false;
                }
            }
            onCanceled: {
                if (leadingColumn) {
                    leadingColumn.Kirigami.ColumnView.interactiveResizing = false;
                }
                if (trailingColumn) {
                    trailingColumn.Kirigami.ColumnView.interactiveResizing = false;
                }
            }
            onPositionChanged: mouse => {
                const newX = mapToItem(null, mouse.x, 0).x;
                const leadingX = leadingColumn?.mapToItem(null, 0, 0).x ?? 0;
                const trailingX = trailingColumn?.mapToItem(null, 0, 0).x ?? 0;
                const view = column.Kirigami.ColumnView.view;

                let leadingWidth = leadingColumn.width;
                let trailingWidth = trailingColumn.width;

                // Minimum and maximum widths for the leading column
                let leadingMinimumWidth = leadingColumn.Kirigami.ColumnView.minimumWidth;
                if (leadingColumn.Kirigami.ColumnView.fillWidth) {
                    leadingMinimumWidth = view.columnWidth;
                } else if (leadingMinimumWidth < 0) {
                    leadingMinimumWidth = Kirigami.Units.gridUnit * 8;
                }

                // Minimum and maximum widths for the trailing column
                let trailingMinimumWidth = trailingColumn.Kirigami.ColumnView.minimumWidth;
                if (trailingColumn.Kirigami.ColumnView.fillWidth) {
                    trailingMinimumWidth = view.columnWidth;
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


                if (!leadingColumn.Kirigami.ColumnView.fillWidth) {
                    leadingColumn.implicitWidth = Math.max(leadingMinimumWidth,
                                                        Math.min(leadingMaximumWidth,
                                                                 newX - leadingX));
                }
                if (!trailingColumn.Kirigami.ColumnView.fillWidth) {
                    trailingColumn.implicitWidth = Math.max(trailingMinimumWidth,
                                                        Math.min(trailingMaximumWidth,
                                                                 trailingX + trailingColumn.width - newX));
                }
            }
        }
    }
}
