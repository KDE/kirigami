/*
 *  SPDX-FileCopyrightText: 2023 Connor Carney <hello@connorcarney.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import QtQuick.Shapes as QQShapes

/*!
  \brief A pull-down to refresh indicator that can be added to any Flickable or ScrollablePage.
  \internal
 */
Item {
    id: root

    //BEGIN properties
    /*!
      \brief The flickable that this indicator is attached to.

      If this is not set, the indicator will search for a Flickable in its parent chain.
     */
    property Flickable flickable: {
        let candidate = parent
        while (candidate) {
            if (candidate instanceof Flickable) {
                return candidate
            } else if (candidate instanceof Kirigami.ScrollablePage) {
                return candidate.flickable
            }
            candidate = candidate.parent
        }
        return null;
    }

    /*!
      \brief Whether to show the busy indicator at the top of the flickable

      This should be set to true whenever a refresh is in progress. It should typically
      be set to true whe triggered() is emitted, and set to false when the refresh is
      complete. This is not done automatically because the refresh may be triggered
      from outside the indicator.
     */
    property bool active: false

    /*!
      \brief How far the flickable has been pulled down, between 0 (not at all) and 1 (where a refresh is triggered).
     */
    readonly property real progress: !refreshing ? Math.min(-Math.min(flickable?.verticalOvershoot ?? 0, 0) / indicatorContainer.height, 1) : 0

    /*!
      \brief Time to wait after the flickable has been pulled down before triggering a refresh

      This gives the user a chance to back out of the refresh if they release the flickable
      before the refreshDelay has elapsed.
     */
    property int refreshDelay: 500

    /*!
      \brief emitted when the flickable is pulled down far enough to trigger a refresh
     */
    signal triggered()
    //END properties

    Item {
        id: indicatorContainer
        parent: root.flickable
        anchors {
            bottom: parent?.contentItem?.top
            bottomMargin: root.flickable.topMargin
        }

        width: flickable?.width
        height: Kirigami.Units.gridUnit * 4
        QQC2.BusyIndicator {
            id: busyIndicator
            z: 1
            anchors.centerIn: parent
            running: root.active
            visible: root.active
            // Android busywidget QQC seems to be broken at custom sizes
        }
        QQShapes.Shape {
            id: spinnerProgress
            anchors {
                fill: busyIndicator
                margins: Kirigami.Units.smallSpacing
            }
            visible: !root.active && root.progress > 0
            QQShapes.ShapePath {
                strokeWidth: Kirigami.Units.smallSpacing
                strokeColor: Kirigami.Theme.highlightColor
                fillColor: "transparent"
                PathAngleArc {
                    centerX: spinnerProgress.width / 2
                    centerY: spinnerProgress.height / 2
                    radiusX: spinnerProgress.width / 2 - Kirigami.Units.smallSpacing / 2
                    radiusY: spinnerProgress.height / 2 - Kirigami.Units.smallSpacing / 2
                    startAngle: 0
                    sweepAngle: 360 * root.progress
                }
            }
        }
    }

    onProgressChanged: {
        if (!root.active && root.progress >= 1) {
            refreshTriggerTimer.running = true;
        } else {
            refreshTriggerTimer.running = false;
        }
    }


    states: [
        State {
            name: "active"
            when: root.active
            PropertyChanges {
                target: indicatorContainer
                anchors.bottomMargin: root.flickable.topMargin - indicatorContainer.height
            }
            PropertyChanges {
                target: root.flickable
                explicit: true

                // this is not a loop because of explicit:true above
                // It adds the height of the indicator to the topMargin of the flickable
                // when we enter the active state; the change is automatically reversed
                // when returning to the base state.
                topMargin: indicatorContainer.height + root.flickable.topMargin
            }
        }
    ]

    transitions: [
        Transition {
            from: ""
            to: "active"
            enabled: root.flickable.verticalOvershoot >= 0
            reversible: true
            NumberAnimation {
                target: root.flickable
                properties: "topMargin"
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
        }
    ]

    Timer {
        id: refreshTriggerTimer
        interval: root.refreshDelay
        onTriggered: {
            if (!root.active && root.progress >= 1) {
                root.triggered()
            }
        }
    }

}
