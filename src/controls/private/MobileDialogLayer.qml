/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

QQC2.Dialog {
    id: dialog

    clip: true
    modal: true

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    header: KC.AbstractApplicationHeader {
        pageRow: null
        page: null

        minimumHeight: Platform.Units.gridUnit * 1.6
        maximumHeight: Platform.Units.gridUnit * 1.6
        preferredHeight: Platform.Units.gridUnit * 1.6

        Keys.onEscapePressed: event => {
            if (dialog.opened) {
                dialog.close();
            } else {
                event.accepted = false;
            }
        }

        contentItem: RowLayout {
            width: parent.width
            KC.Heading {
                Layout.leftMargin: Platform.Units.largeSpacing
                text: dialog.title
                elide: Text.ElideRight
            }
            Item {
                Layout.fillWidth: true
            }
            Primitives.Icon {
                id: closeIcon
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Platform.Units.largeSpacing
                Layout.preferredHeight: Platform.Units.iconSizes.smallMedium
                Layout.preferredWidth: Platform.Units.iconSizes.smallMedium
                source: closeMouseArea.containsMouse ? "window-close" : "window-close-symbolic"
                active: closeMouseArea.containsMouse
                MouseArea {
                    id: closeMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: mouse => dialog.close();
                }
            }
        }
    }

    contentItem: QQC2.Control {
        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
    }
}
