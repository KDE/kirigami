/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 640
    height: 480
    visible: true

    pageStack.initialPage: Kirigami.Page {
        actions: [
            Kirigami.Action { text: "One" },
            Kirigami.Action {
                displayHint: Kirigami.DisplayHint.ShowAsGroup
                Kirigami.Action { text: "S1"; checkable: true }
                Kirigami.Action { text: "S2"; checkable: true }
                Kirigami.Action { text: "S3"; checkable: true }
            },
            Kirigami.Action { text: "Three" }
        ]
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing

            QQC.Label {
                text: "Not checkable: the actions behave like push buttons."
            }
            Kirigami.SegmentedControl {
                Layout.alignment: Qt.AlignHCenter

                actions: [
                    Kirigami.Action { text: "One" },
                    Kirigami.Action { text: "Two" },
                    Kirigami.Action { text: "Three"}
                ]
            }

            QQC.Label {
                text: "Checkable: each action can be toggled independently."
            }
            Kirigami.SegmentedControl {
                Layout.alignment: Qt.AlignHCenter

                Kirigami.Action { text: "One"; checkable: true }
                Kirigami.Action { text: "Two"; checkable: true }
                Kirigami.Action { text: "Three"; checkable: true }
            }

            QQC.Label {
                text: "Exclusive: only one action can be checked at a time."
            }
            Kirigami.SegmentedControl {
                Layout.alignment: Qt.AlignHCenter

                exclusive: true

                Kirigami.Action { text: "One"; checkable: true }
                Kirigami.Action { text: "Two"; checkable: true }
                Kirigami.Action { text: "Three"; checkable: true }
            }

            QQC.Label {
                text: "Segmented control with a custom delegate"
            }
            Kirigami.SegmentedControl {
                id: segment
                Layout.alignment: Qt.AlignHCenter

                exclusive: true
                property int zoom: 100

                Kirigami.Action {
                    text: "Zoom Out"
                    icon.name: "zoom-out-symbolic"
                    displayHint: Kirigami.DisplayHint.IconOnly
                    onTriggered: segment.zoom = Math.max(0, segment.zoom - 10)
                }
                Kirigami.Action {
                    displayComponent: QQC.TextField {
                        Layout.fillWidth: false
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                        text: segment.zoom + "%"
                        inputMask: "000%"
                        validator: RegularExpressionValidator {
                            regularExpression: /[0-9]+%/
                        }
                        onAccepted: {
                            const cleaned = String(text).replace(/%/g, '').trim();
                            print(cleaned)
                            const num = Number(cleaned);
                            if (Number.isFinite(num)) {
                                segment.zoom = Math.min(200, Math.max(0, num));
                            }
                        }
                    }
                }
                Kirigami.Action {
                    text: "Zoom In"
                    icon.name: "zoom-in-symbolic"
                    displayHint: Kirigami.DisplayHint.IconOnly
                    onTriggered: segment.zoom = Math.min(200, segment.zoom + 10)
                }
            }
        }
    }
}
