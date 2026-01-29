/* SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/*!
  \qmltype NavigationTabButton
  \inqmlmodule org.kde.kirigami.templates

  \brief Template for navigation buttons to be used for the NavigationTabBar component.

  \since 5.87
 */
T.TabButton {
    id: control

    /*!
      \brief This property tells the index of this tab within the tab bar.
     */
    readonly property int tabIndex: {
        let tabIdx = 0
        for (const child of parent.children) {
            if (child === this) {
                return tabIdx
            }
            // Checking for AbstractButtons because any AbstractButton can act as a tab
            if (child instanceof T.AbstractButton) {
                ++tabIdx
            }
        }
        return -1
    }

    QQC2.ToolTip.text: (control.action as Kirigami.Action)?.tooltip ?? ""
    QQC2.ToolTip.visible: (Kirigami.Settings.tabletMode ? pressed : hovered) && QQC2.ToolTip.text.length > 0
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
    Kirigami.MnemonicData.label: text

    Accessible.description: Kirigami.MnemonicData.plainTextLabel
    Accessible.onPressAction: control.animateClick()

    Shortcut {
        //in case of explicit & the button manages it by itself
        enabled: !(RegExp(/\&[^\&]/).test(control.text))
        sequence: control.Kirigami.MnemonicData.sequence
        onActivated: control.animateClick()
    }
}
