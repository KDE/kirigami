/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.18 as Kirigami

AbstractButton {
    id: root
    
    property alias corners: background.corners
    
    background: Kirigami.ShadowedRectangle {
        id: background
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        Kirigami.Theme.inherit: false
        color: {
            if (root.down) {
                let avg = (Kirigami.Theme.backgroundColor.r + Kirigami.Theme.backgroundColor.g + Kirigami.Theme.backgroundColor.b) / 3;
                // sample down
                avg = Math.max(0, (avg - 0.8) * 5);
                return Qt.darker(Kirigami.Theme.backgroundColor, 1.1 + 0.4 * (1 - avg));
            } else if (hoverHandler.hovered) {
                return Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
            } else {
                return Kirigami.Theme.backgroundColor
            }
        }
        
        // keyboard selection
        //Rectangle {
            //color: "transparent"
            //visible: root.activeFocus
            //border.color: Kirigami.Theme.highlightColor
            //opacity: 0.5
            //border.width: 1
            //anchors.fill: parent
            //anchors.margins: Kirigami.Units.smallSpacing
            //radius: Kirigami.Units.smallSpacing
        //}
    }
    
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    
    contentItem: Item {
        implicitHeight: row.height + Kirigami.Units.smallSpacing
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 0
            
            Kirigami.Icon {
                Layout.preferredHeight: label.height
                Layout.preferredWidth: height
                Layout.rightMargin: Kirigami.Units.smallSpacing
                visible: root.icon.name
                source: root.icon.name
            }
            Label {
                id: label
                text: root.text
            }
        }
        
        HoverHandler {
            id: hoverHandler
        }
    }
}
