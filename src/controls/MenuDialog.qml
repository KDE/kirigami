/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.18 as Kirigami

/**
 * A dialog that prompts users with a context menu, with
 * list items that perform actions.
 * 
 * @see Dialog
 * @see PromptDialog
 * @see ScrollableDialog
 * 
 * Example usage:
 * 
 * @code{.qml}
 * Kirigami.MenuDialog {
 *     title: i18n("Track Options")
 *     
 *     actions: [
 *         Kirigami.Action {
 *             iconName: "media-playback-start"
 *             text: i18nc("Start playback of the selected track", "Play")
 *             tooltip: i18n("Start playback of the selected track")
 *         },
 *         Kirigami.Action {
 *             enabled: false
 *             iconName: "document-open-folder"
 *             text: i18nc("Show the file for this song in the file manager", "Show in folder")
 *             tooltip: i18n("Show the file for this song in the file manager")
 *         },
 *         Kirigami.Action {
 *             iconName: "documentinfo"
 *             text: i18nc("Show track metadata", "View details")
 *             tooltip: i18n("Show track metadata")
 *         },
 *         Kirigami.Action {
 *             iconName: "list-add"
 *             text: i18nc("Add the track to the queue, right after the current track", "Play next")
 *             tooltip: i18n("Add the track to the queue, right after the current track")
 *         },
 *         Kirigami.Action {
 *             iconName: "list-add"
 *             text: i18nc("Enqueue current track", "Add to queue")
 *             tooltip: i18n("Enqueue current track")
 *         }
 *     ]
 * }
 * @endcode
 * 
 * @inherit Dialog
 */
Kirigami.Dialog {
    
    /**
     * The list of actions to show in the context menu.
     */
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
