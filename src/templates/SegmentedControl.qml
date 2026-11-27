/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC

/*!
  \qmltype SegmentedControl
  \inqmlmodule org.kde.kirigami
  \inherits Control

  \brief A control that Shows a series of buttons representing actions.
  If the style allows, they will look joined as a single segmented button.

  \since 6.33
 */
T.Control {
    id: root

    /*!
      \brief A list of QML Actions that will be represented as buttons
    */
    default property alias actions: actionGroup.actions

    /*!
      \brief If true all the checkable buttons in the control will be exclusive and only one of them
      will be checked at any time
    */
    property alias exclusive: actionGroup.exclusive

    /*!
      \brief This property holds the currently selected action in an exclusive group, or \b null if there is none or the group is non-exclusive.
    property alias checkedAction: actionGroup.checkedAction
    */
    property alias checkedAction: actionGroup.checkedAction

    signal triggered(action: T.Action)

    implicitWidth: contentItem.implicitWidth
    implicitHeight: contentItem.implicitHeight

    QQC.ActionGroup {
        id: actionGroup
        exclusive: false
        onTriggered: (action) => root.triggered(action)
    }
}
