/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.18 as Kirigami

Kirigami.Dialog {
    
    property list<QtObject> actions
    padding: 0
    
    ColumnLayout {
        spacing: 0
        
        Repeater {
            model: actions
            
            delegate: Kirigami.BasicListItem {
                Layout.fillWidth: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 20
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                
                iconSize: Kirigami.Units.gridUnit
                leftPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                rightPadding: Kirigami.Units.largeSpacing + + Kirigami.Units.smallSpacing
                
                icon: modelData.icon.name
                text: modelData.text
                onClicked: modelData.trigger(this)
                
                enabled: modelData.enabled
                
                visible: modelData.visible
                
                Controls.ToolTip.visible: modelData.tooltip != "" && hoverHandler.hovered
                Controls.ToolTip.text: modelData.tooltip
                HoverHandler { id: hoverHandler }
            }
        }
    }
}
