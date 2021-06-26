/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.18 as Kirigami

/**
 * A dialog where the contents are in a scrollable ScrollView.
 * 
 * @see Dialog
 * @see PromptDialog
 * @see MenuDialog
 * 
 * Example usage:
 * 
 * @code{.qml}
 * Kirigami.ScrollableDialog {
 *     id: scrollableDialog
 *     title: i18n("Select Number")
 *     
 *     ListView {
 *         implicitWidth: Kirigami.Units.gridUnit * 16
 *         implicitHeight: Kirigami.Units.gridUnit * 16
 *         
 *         model: 100
 *         delegate: Controls.RadioDelegate {
 *             topPadding: Kirigami.Units.smallSpacing * 2
 *             bottomPadding: Kirigami.Units.smallSpacing * 2
 *             implicitWidth: Kirigami.Units.gridUnit * 16
 *             text: modelData
 *         }
 *     }
 * }
 * @endcode
 * 
 * @inherit Dialog
 */
Kirigami.Dialog {
    id: root
    
    default property Item mainItem
    
    padding: 0
    
    contentItem: Controls.ScrollView {
        id: scrollView
        implicitWidth: root.mainItem.implicitWidth
        contentHeight: root.mainItem.implicitHeight
        contentItem: root.mainItem
        
        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
    }
}
