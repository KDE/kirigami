/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.18 as Kirigami

/**
 * A simple dialog to quickly prompt a user with information,
 * and possibly perform an action.
 * 
 * @see Dialog
 * @see MenuDialog
 * @see ScrollableDialog
 * 
 * Example usage:
 * 
 * @code{.qml}
 * Kirigami.PromptDialog {
 *     title: "Reset settings?"
 *     subtitle: "The stored settings for the application will be deleted, with the defaults restored."
 *     footerActions: Kirigami.Dialog.Actions.Ok | Kirigami.Dialog.Actions.Cancel
 *     
 *     onAccepted: console.log("Reset")
 *     onRejected: console.log("Cancelled")
 * }
 * @endcode
 * 
 * @inherit Dialog
 */
Kirigami.Dialog {
    default property QtObject item
    
    /**
     * The text to use in the dialog's contents.
     */
    property string subtitle: ""
    
    padding: 0 // we want content padding, not padding on the scrollview
    preferredWidth: Kirigami.Units.gridUnit * 18
    
    Controls.Control {
        topPadding: Kirigami.Units.largeSpacing
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        
        contentItem: Controls.Label {
            text: subtitle
            wrapMode: Controls.Label.Wrap
        }
    }
}
