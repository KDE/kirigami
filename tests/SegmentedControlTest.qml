/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 640
    height: 480
    visible: true

    pageStack.initialPage: Kirigami.Page {
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing

            // Not checkable: the actions behave like push buttons.
            Kirigami.SegmentedControl {
                Layout.alignment: Qt.AlignHCenter

                actions: [
                    Kirigami.Action { text: "One" },
                    Kirigami.Action { text: "Two" },
                    Kirigami.Action { text: "Three" }
                ]
            }

            // Checkable: each action can be toggled independently.
            Kirigami.SegmentedControl {
                Layout.alignment: Qt.AlignHCenter

                actions: [
                    Kirigami.Action { text: "One"; checkable: true },
                    Kirigami.Action { text: "Two"; checkable: true },
                    Kirigami.Action { text: "Three"; checkable: true }
                ]
            }

            // Exclusive: only one action can be checked at a time.
            Kirigami.SegmentedControl {
                Layout.alignment: Qt.AlignHCenter

                exclusive: true

                actions: [
                    Kirigami.Action { text: "One"; checkable: true },
                    Kirigami.Action { text: "Two"; checkable: true },
                    Kirigami.Action { text: "Three"; checkable: true }
                ]
            }
        }
    }
}
