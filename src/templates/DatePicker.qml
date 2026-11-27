/*
 *  SPDX-FileCopyrightText: 2026 James Graham <james.h.graham@protonmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick
import QtQuick.Templates as T

/*!
  \qmltype DatePicker
  \inqmlmodule org.kde.kirigami
  \inherits Control

  \brief A control to display a calendar from which a date can be picked.

  What the picker shows depends on the \c currentPeriod:
  \list
  \li Day: The whole month containing the day of the \c currentDate.
  \li Month: All months will be visible all the time.
  \li Year: The year of the \c currentDate will be visible in a grid with nearby years.
  \endlist
 */
T.Control {
    id: root

    /*!
      \brief This date the picker starts at.

      Defaults to the current date.
     */
    property date initialDate: new Date()

    /*!
      \brief This current date the picker is at.
     */
    property date currentDate: initialDate

    /*!
      \brief This earliest date the picker can show.
     */
    property date from: new Date(1970, 0, 1)

    /*!
      \brief This latest date the picker can show.
     */
    property date to: new Date(2050, 11, 31)

    /*!
      \brief Whether week numbers should be shown in \c DatePicker::Period::Day mode.
     */
    property bool showWeekNumbers: false

    enum Period {
        Day,
        Month,
        Year
    }

    /*!
      \qmlproperty enumeration DatePicker::Period

      \brief This property holds the current view being shown.

      The view can be:
      \list
      \li DatePicker.Period.Day: The \c DatePicker shows the days of a single month.
      \li DatePicker.Period.Month: The \c DatePicker shows the a list of months.
      \li DatePicker.Period.Year: The \c DatePicker shows a list of years.
      \endlist

      \default DatePicker.View.Day
     */
    property int currentPeriod: DatePicker.Period.Day

    /*!
      \brief Increment the \c currentDate by the given \c DatePicker::Period.
     */
    function incrementCurrentDate(period): void {
        let newDate = currentDate;
        switch (period) {
            case DatePicker.Period.Day:
            case DatePicker.Period.Month:
                newDate.setMonth(newDate.getMonth() + 1);
                break;
            case DatePicker.Period.Year:
                newDate.setFullYear(newDate.getFullYear() + 1);
                break;
            default:
                console.warn("incrementCurrentDate called with invalid period.")
        }
        if (newDate > root.to) {
            newDate = root.to;
        }
        currentDate = newDate;
    }

    /*!
      \brief Decrement the \c currentDate by the given \c DatePicker::Period.
     */
    function decrementCurrentDate(period): void {
        let newDate = currentDate;
        switch (period) {
            case DatePicker.Period.Day:
            case DatePicker.Period.Month:
                newDate.setMonth(newDate.getMonth() - 1);
                break;
            case DatePicker.Period.Year:
                newDate.setFullYear(newDate.getFullYear() - 1);
                break;
            default:
                console.warn("incrementCurrentDate called with invalid period.")
        }
        if (newDate < root.from) {
            newDate = root.from;
        }
        currentDate = newDate;
    }

    /*!
      \brief This signal is emitted when any item in the picker is clicked.

      The date is the \c currentDate when after the click is resolved, i.e. after
      the date is modified to the clicked day/month/year.
     */
    signal clicked(date: date)
}
