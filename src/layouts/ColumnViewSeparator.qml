/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.platform as Platform

Item {
    id: separator
    anchors.fill: parent

    readonly property bool isSeparator: true
    property Item previousColumn
    property Item column
    property Item nextColumn
    readonly property bool inToolBar: parent !== column

    visible: (column.KirigamiLayouts.ColumnView.view?.separatorVisible ?? false) && (column.KirigamiLayouts.ColumnView.view?.columnResizeMode !== KirigamiLayouts.ColumnView.SingleColumn ?? false)

    SeparatorHandle {
        id: leftHandle
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        leadingColumn: LayoutMirroring.enabled ? separator.column : separator.previousColumn
        trailingColumn: LayoutMirroring.enabled ? separator.nextColumn : separator.column
        // If this handle touched the left ColumnView edge, hide it
        visible: leadingColumn && trailingColumn && separator.column.KirigamiLayouts.ColumnView.view?.leadingVisibleItem !== separator.column
    }

    SeparatorHandle {
        id: rightHandle
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: -1
        }
        leadingColumn: LayoutMirroring.enabled ? separator.previousColumn : separator.column
        trailingColumn: LayoutMirroring.enabled ? separator.column : separator.nextColumn
        visible: leadingColumn && trailingColumn && separator.column.KirigamiLayouts.ColumnView.view?.leadingVisibleItem !== separator.previousColumn
    }

    component SeparatorHandle: Primitives.Separator {
        id: handle

        property Item leadingColumn
        property Item trailingColumn

        Platform.Theme.colorSet: Platform.Theme.Header
        Platform.Theme.inherit: false

        visible: leadingColumn && trailingColumn

        MouseArea {
            anchors {
                fill: parent
                leftMargin: -Platform.Units.smallSpacing
                rightMargin: -Platform.Units.smallSpacing
            }

            visible: {
                if (!separator.column.KirigamiLayouts.ColumnView.view?.columnResizeMode === KirigamiLayouts.ColumnView.DynamicColumns ?? false) {
                    return false;
                }
                if (handle.leadingColumn?.KirigamiLayouts.ColumnView.interactiveResizeEnabled ?? false) {
                    return true;
                }
                if (handle.trailingColumn?.KirigamiLayouts.ColumnView.interactiveResizeEnabled ?? false) {
                    return true;
                }
                return false;
            }
            cursorShape: Qt.SplitHCursor
            onPressed: mouse => {
                if (handle.leadingColumn) {
                    handle.leadingColumn.KirigamiLayouts.ColumnView.interactiveResizing = true;
                }
                if (handle.trailingColumn) {
                    handle.trailingColumn.KirigamiLayouts.ColumnView.interactiveResizing = true;
                }
            }
            onReleased: {
                if (handle.leadingColumn) {
                    handle.leadingColumn.KirigamiLayouts.ColumnView.interactiveResizing = false;
                }
                if (handle.trailingColumn) {
                    handle.trailingColumn.KirigamiLayouts.ColumnView.interactiveResizing = false;
                }
            }
            onCanceled: {
                if (handle.leadingColumn) {
                    handle.leadingColumn.KirigamiLayouts.ColumnView.interactiveResizing = false;
                }
                if (handle.trailingColumn) {
                    handle.trailingColumn.KirigamiLayouts.ColumnView.interactiveResizing = false;
                }
            }
            onPositionChanged: mouse => {
                const newX = mapToItem(null, mouse.x, 0).x;
                const leadingX = handle.leadingColumn?.mapToItem(null, 0, 0).x ?? 0;
                const trailingX = handle.trailingColumn?.mapToItem(null, 0, 0).x ?? 0;
                const view = separator.column.KirigamiLayouts.ColumnView.view;

                let leadingWidth = handle.leadingColumn.width;
                let trailingWidth = handle.trailingColumn.width;

                // Minimum and maximum widths for the leading column
                let leadingMinimumWidth = handle.leadingColumn.KirigamiLayouts.ColumnView.minimumWidth;
                if (handle.leadingColumn.KirigamiLayouts.ColumnView.fillWidth) {
                    leadingMinimumWidth = view.columnWidth;
                }
                if (leadingMinimumWidth < 0) {
                    leadingMinimumWidth = Platform.Units.gridUnit * 8;
                }

                // Minimum and maximum widths for the trailing column
                let trailingMinimumWidth = handle.trailingColumn.KirigamiLayouts.ColumnView.minimumWidth;
                if (handle.trailingColumn.KirigamiLayouts.ColumnView.fillWidth) {
                    trailingMinimumWidth = view.columnWidth;
                }
                if (trailingMinimumWidth < 0) {
                    trailingMinimumWidth = Platform.Units.gridUnit * 8;
                }

                let leadingMaximumWidth = handle.leadingColumn.KirigamiLayouts.ColumnView.maximumWidth;
                if (leadingMaximumWidth < 0) {
                    leadingMaximumWidth = leadingWidth + trailingWidth - trailingMinimumWidth;
                }


                let trailingMaximumWidth = handle.trailingColumn.KirigamiLayouts.ColumnView.maximumWidth;
                if (trailingMaximumWidth < 0) {
                    trailingMaximumWidth = leadingWidth + trailingWidth - leadingMinimumWidth;
                }


                if (!handle.leadingColumn.KirigamiLayouts.ColumnView.fillWidth) {
                    handle.leadingColumn.KirigamiLayouts.ColumnView.preferredWidth = Math.max(leadingMinimumWidth,
                                                        Math.min(leadingMaximumWidth,
                                                                 newX - leadingX));
                }
                if (!handle.trailingColumn.KirigamiLayouts.ColumnView.fillWidth) {
                    handle.trailingColumn.KirigamiLayouts.ColumnView.preferredWidth = Math.max(trailingMinimumWidth,
                                                        Math.min(trailingMaximumWidth,
                                                                 trailingX + handle.trailingColumn.width - newX));
                }
            }
        }
    }
}
