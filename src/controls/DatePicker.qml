/*
 *  SPDX-FileCopyrightText: 2026 James Graham <james.h.graham@protonmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.templates as KT

KT.DatePicker {
    id: root

    onCurrentDateChanged: if (viewLoader.item) {
        viewLoader.item.positionAtDate(currentDate)
    }

    implicitWidth: implicitContentWidth
    implicitHeight: implicitContentHeight

    contentItem: ColumnLayout {
        RowLayout {
            id: headerRow
            readonly property real minHeight: Math.max(dateRow.implicitHeight, navRow.implicitHeight)
            // FIXME: This really wants to be a SegmentedButton bu theat isn't in Kirigami yet
            // change when available https://invent.kde.org/frameworks/kirigami/-/merge_requests/2243
            RowLayout {
                id: dateRow
                Layout.minimumHeight: headerRow.minHeight
                spacing: 0
                QQC2.AbstractButton {
                    id: monthButton
                    Layout.fillHeight: true
                    readonly property bool highlightBackground: down || checked
                    readonly property bool highlightBorder: enabled && down || checked || visualFocus || hovered
                    leftPadding: Platform.Units.largeSpacing
                    rightPadding: Platform.Units.largeSpacing
                    topPadding: Platform.Units.mediumSpacing
                    bottomPadding: Platform.Units.mediumSpacing

                    onClicked: root.currentPeriod = DatePicker.Period.Month

                    contentItem: QQC2.Label {
                        text: Qt.locale().monthName(root.currentDate.getMonth())
                    }
                    background: Primitives.ShadowedRectangle {
                        color: if (monthButton.highlightBackground) {
                            return Qt.alpha(Platform.Theme.highlightColor, 0.3);
                        } else {
                            return Platform.Theme.alternateBackgroundColor;
                        }
                        corners {
                            topLeftRadius: Platform.Units.cornerRadius
                            bottomLeftRadius: Platform.Units.cornerRadius
                            bottomRightRadius: 0
                            topRightRadius: 0
                        }
                        shadow {
                            size: radius * 2
                            color: Qt.rgba(0, 0, 0, 0.3)
                            yOffset: 1
                        }
                        border {
                            width: 1
                            color: if (monthButton.highlightBorder) {
                                return Platform.Theme.focusColor
                            } else {
                                return Platform.ColorUtils.linearInterpolation(Platform.Theme.backgroundColor, Platform.Theme.textColor, Platform.Theme.frameContrast);
                            }
                        }
                    }
                }
                QQC2.AbstractButton {
                    id: yearButton
                    Layout.fillHeight: true
                    readonly property bool highlightBackground: down || checked
                    readonly property bool highlightBorder: enabled && down || checked || visualFocus || hovered
                    leftPadding: Platform.Units.largeSpacing
                    rightPadding: Platform.Units.largeSpacing
                    topPadding: Platform.Units.mediumSpacing
                    bottomPadding: Platform.Units.mediumSpacing

                    onClicked: root.currentPeriod = DatePicker.Period.Year

                    contentItem: QQC2.Label {
                        text: root.currentDate.getFullYear()
                    }
                    background: Primitives.ShadowedRectangle {
                        color: if (yearButton.highlightBackground) {
                            return Qt.alpha(Platform.Theme.highlightColor, 0.3);
                        } else {
                            return Platform.Theme.alternateBackgroundColor;
                        }
                        corners {
                            topLeftRadius: 0
                            bottomLeftRadius: 0
                            bottomRightRadius: Platform.Units.cornerRadius
                            topRightRadius: Platform.Units.cornerRadius
                        }
                        shadow {
                            size: radius * 2
                            color: Qt.rgba(0, 0, 0, 0.3)
                            yOffset: 1
                        }
                        border {
                            width: 1
                            color: if (yearButton.highlightBorder) {
                                return Platform.Theme.focusColor
                            } else {
                                return Platform.ColorUtils.linearInterpolation(Platform.Theme.backgroundColor, Platform.Theme.textColor, Platform.Theme.frameContrast);
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.minimumWidth: Platform.Units.gridUnit
            }
            // FIXME: This really wants to be a SegmentedButton bu theat isn't in Kirigami yet
            // change when available https://invent.kde.org/frameworks/kirigami/-/merge_requests/2243
            RowLayout {
                id: navRow
                Layout.minimumHeight: headerRow.minHeight
                spacing: 0
                QQC2.AbstractButton {
                    id: previousButton
                    Layout.fillHeight: true
                    readonly property bool highlightBackground: down || checked
                    readonly property bool highlightBorder: enabled && down || checked || visualFocus || hovered
                    leftPadding: Platform.Units.largeSpacing
                    rightPadding: Platform.Units.largeSpacing
                    topPadding: Platform.Units.mediumSpacing
                    bottomPadding: Platform.Units.mediumSpacing

                    onClicked: root.decrementCurrentDate(root.currentPeriod === DatePicker.Period.Year ? DatePicker.Period.Year : DatePicker.Period.Month)

                    contentItem: Primitives.Icon {
                        source: "go-previous-symbolic"
                        implicitWidth: Platform.Units.iconSizes.small
                        implicitHeight: Platform.Units.iconSizes.small
                    }
                    background: Primitives.ShadowedRectangle {
                        color: if (previousButton.highlightBackground) {
                            return Qt.alpha(Platform.Theme.highlightColor, 0.3);
                        } else {
                            return Platform.Theme.alternateBackgroundColor;
                        }
                        corners {
                            topLeftRadius: Platform.Units.cornerRadius
                            bottomLeftRadius: Platform.Units.cornerRadius
                            bottomRightRadius: 0
                            topRightRadius: 0
                        }
                        shadow {
                            size: radius * 2
                            color: Qt.rgba(0, 0, 0, 0.3)
                            yOffset: 1
                        }
                        border {
                            width: 1
                            color: if (previousButton.highlightBorder) {
                                return Platform.Theme.focusColor
                            } else {
                                return Platform.ColorUtils.linearInterpolation(Platform.Theme.backgroundColor, Platform.Theme.textColor, Platform.Theme.frameContrast);
                            }
                        }
                    }
                }
                QQC2.AbstractButton {
                    id: resetDateButton
                    Layout.fillHeight: true
                    readonly property bool highlightBackground: down || checked
                    readonly property bool highlightBorder: enabled && down || checked || visualFocus || hovered
                    leftPadding: Platform.Units.largeSpacing
                    rightPadding: Platform.Units.largeSpacing
                    topPadding: Platform.Units.mediumSpacing
                    bottomPadding: Platform.Units.mediumSpacing

                    onClicked: if (_private.sameDay(root.initialDate, root.currentDate)) {
                        viewLoader.item.positionAtDate(currentDate)
                    } else {
                        root.currentDate = root.initialDate
                    }

                    contentItem: Primitives.Icon {
                        source: "go-jump-today-symbolic"
                        implicitWidth: Platform.Units.iconSizes.small
                        implicitHeight: Platform.Units.iconSizes.small
                    }
                    background: Primitives.ShadowedRectangle {
                        color: if (resetDateButton.highlightBackground) {
                            return Qt.alpha(Platform.Theme.highlightColor, 0.3);
                        } else {
                            return Platform.Theme.alternateBackgroundColor;
                        }
                        shadow {
                            size: radius * 2
                            color: Qt.rgba(0, 0, 0, 0.3)
                            yOffset: 1
                        }
                        border {
                            width: 1
                            color: if (resetDateButton.highlightBorder) {
                                return Platform.Theme.focusColor
                            } else {
                                return Platform.ColorUtils.linearInterpolation(Platform.Theme.backgroundColor, Platform.Theme.textColor, Platform.Theme.frameContrast);
                            }
                        }
                    }
                }
                QQC2.AbstractButton {
                    id:nextButton
                    Layout.fillHeight: true
                    readonly property bool highlightBackground: down || checked
                    readonly property bool highlightBorder: enabled && down || checked || visualFocus || hovered
                    leftPadding: Platform.Units.largeSpacing
                    rightPadding: Platform.Units.largeSpacing
                    topPadding: Platform.Units.mediumSpacing
                    bottomPadding: Platform.Units.mediumSpacing

                    onClicked: root.incrementCurrentDate(root.currentPeriod === DatePicker.Period.Year ? DatePicker.Period.Year : DatePicker.Period.Month)

                    contentItem: Primitives.Icon {
                        source: "go-next-symbolic"
                        implicitWidth: Platform.Units.iconSizes.small
                        implicitHeight: Platform.Units.iconSizes.small
                    }
                    background: Primitives.ShadowedRectangle {
                        color: if (nextButton.highlightBackground) {
                            return Qt.alpha(Platform.Theme.highlightColor, 0.3);
                        } else {
                            return Platform.Theme.alternateBackgroundColor;
                        }
                        corners {
                            topLeftRadius: 0
                            bottomLeftRadius: 0
                            bottomRightRadius: Platform.Units.cornerRadius
                            topRightRadius: Platform.Units.cornerRadius
                        }
                        shadow {
                            size: radius * 2
                            color: Qt.rgba(0, 0, 0, 0.3)
                            yOffset: 1
                        }
                        border {
                            width: 1
                            color: if (nextButton.highlightBorder) {
                                return Platform.Theme.focusColor
                            } else {
                                return Platform.ColorUtils.linearInterpolation(Platform.Theme.backgroundColor, Platform.Theme.textColor, Platform.Theme.frameContrast);
                            }
                        }
                    }
                }
            }
        }
        Loader {
            id: viewLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: {
                switch (root.currentPeriod) {
                    case DatePicker.Period.Day:
                        return dayView;
                    case DatePicker.Period.Month:
                    case DatePicker.Period.Year:
                        return monthYearView;
                }
            }
        }
    }

    Component {
        id: dayView
        GridLayout {
            id: dayViewGrid
            property bool updateDate: false

            function positionAtDate(date): void {
                const newIndex = monthModel.indexOf(date);
                if (newIndex === monthList.currentIndex) {
                    return;
                }
                monthList.positionViewAtIndex(newIndex, ListView.Center);
                monthList.currentIndex = newIndex;
            }

            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2

            Component.onCompleted: {
                dayViewGrid.positionAtDate(root.currentDate);
                updateDate = true;
            }

            QQC2.DayOfWeekRow {
                Layout.fillWidth: true
                Layout.column: root.showWeekNumbers ? 1 : 0
                Layout.columnSpan: root.showWeekNumbers ? 1 : 2
                locale: (monthList.currentItem as QQC2.MonthGrid)?.locale ?? Qt.locale()
            }
            QQC2.WeekNumberColumn {
                Layout.fillHeight: true
                visible: root.showWeekNumbers
                locale: (monthList.currentItem as QQC2.MonthGrid)?.locale ?? Qt.locale()
                month: monthList.currentItem?.month ?? 0
                year: monthList.currentItem?.year ?? 0
            }
            ListView {
                id: monthList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.columnSpan: root.showWeekNumbers ? 1 : 2

                implicitWidth: Platform.Units.gridUnit * 12
                implicitHeight: Platform.Units.gridUnit * 12
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                clip: true

                onCurrentIndexChanged: if (dayViewGrid.updateDate) {
                    root.currentDate.setFullYear(currentItem.year, currentItem.month)
                }

                model: QQC2.CalendarModel {
                    id: monthModel
                    from: root.from
                    to: root.to
                }
                delegate: Item {
                    id: monthDelegate
                    required property int month
                    required property int year
                    implicitWidth: ListView.view.width
                    implicitHeight: ListView.view.height
                    QQC2.MonthGrid {
                        id: monthGrid
                        anchors.fill: parent
                        month: monthDelegate.month
                        year: monthDelegate.year

                        onClicked: (date) => {
                            root.currentDate = date;
                            root.clicked(date);
                        }
                    }
                }
            }
        }
    }

    Component {
        id: monthYearView
        GridView {
            id: monthYearViewGrid
            property bool updateDate: false

            function positionAtDate(date): void {
                const newIndex = root.currentPeriod === DatePicker.Period.Month ? date.getMonth() : date.getFullYear() - root.from.getFullYear();
                positionViewAtIndex(newIndex, GridView.Center);
                currentIndex = newIndex;
            }

            Layout.fillWidth: true
            Layout.fillHeight: true

            Component.onCompleted: {
                positionAtDate(root.currentDate);
                updateDate = true;
            }

            onCountChanged: if (updateDate) {
                positionAtDate(root.currentDate)
            }

            implicitWidth: Platform.Units.gridUnit * 12
            implicitHeight: Platform.Units.gridUnit * 12
            cellWidth: Math.floor(width / 3)
            cellHeight: Math.floor(height / 4)
            snapMode: GridView.SnapToRow
            clip: true

            model: root.currentPeriod === DatePicker.Period.Month ? 12 : root.to.getFullYear() - root.from.getFullYear()
            delegate: QQC2.ItemDelegate {
                id: monthDelegate
                required property int index
                width: GridView.view.cellWidth
                height: GridView.view.cellHeight
                leftPadding: Platform.Units.largeSpacing
                rightPadding: Platform.Units.largeSpacing
                topPadding: Platform.Units.largeSpacing
                bottomPadding: Platform.Units.largeSpacing

                highlighted: root.currentPeriod === DatePicker.Period.Month ? new Date().getMonth() === monthDelegate.index : new Date().getFullYear() === monthDelegate.index + root.from.getFullYear()

                onClicked: {
                    root.currentPeriod === DatePicker.Period.Month ? root.currentDate.setMonth(index) : root.currentDate.setFullYear(index + root.from.getFullYear());
                    root.currentPeriod = DatePicker.Period.Day;
                }

                contentItem: QQC2.Label {
                    id: monthLabel
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: root.currentPeriod === DatePicker.Period.Month ? Qt.locale().monthName(monthDelegate.index) : monthDelegate.index + root.from.getFullYear()
                }
            }
        }
    }

    QtObject {
        id: _private
        function sameDay(a, b): bool {
            return a.getFullYear() === b.getFullYear() &&
            a.getMonth() === b.getMonth() &&
            a.getDate() === b.getDate();
        }
    }
}
