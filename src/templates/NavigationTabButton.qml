/* SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-FileCopyrightText: 2026 Akseli Lahtinen <akselmo@akselmo.dev>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami.controls as Controls
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

/*!
  \qmltype NavigationTabButton
  \inqmlmodule org.kde.kirigami

  \brief Navigation buttons to be used for the NavigationTabBar component.

  It supplies its own padding, and also supports using the AbstractButton::display property to be used in column lists.

  Alternative way to the actions property on NavigationTabBar, as it can be used
  with Repeater to generate buttons from models.

  Example usage:
  \code
  Kirigami.NavigationTabBar {
       id: navTabBar
       Kirigami.NavigationTabButton {
           visible: true
           icon.name: "document-save"
           text: `test ${tabIndex + 1}`
           QQC2.ButtonGroup.group: navTabBar.tabGroup
       }
       Kirigami.NavigationTabButton {
           visible: false
           icon.name: "document-send"
           text: `test ${tabIndex + 1}`
           QQC2.ButtonGroup.group: navTabBar.tabGroup
       }
       actions: [
           Kirigami.Action {
               visible: true
               icon.name: "edit-copy"
               icon.height: 32
               icon.width: 32
               text: `test 3`
               checked: true
           },
           Kirigami.Action {
               visible: true
               icon.name: "edit-cut"
               text: `test 4`
               checkable: true
           },
           Kirigami.Action {
               visible: false
               icon.name: "edit-paste"
               text: `test 5`
           },
           Kirigami.Action {
               visible: true
               icon.source: "../logo.png"
               text: `test 6`
               checkable: true
           }
       ]
   }
  \endcode

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

    QQC2.ToolTip.text: (control.action as Controls.Action)?.tooltip ?? ""
    QQC2.ToolTip.visible: (Platform.Settings.tabletMode ? pressed : hovered) && QQC2.ToolTip.text.length > 0
    QQC2.ToolTip.delay: Platform.Units.toolTipDelay

    Primitives.MnemonicData.enabled: enabled && visible
    Primitives.MnemonicData.controlType: Primitives.MnemonicData.MenuItem
    Primitives.MnemonicData.label: text

    Accessible.description: Primitives.MnemonicData.plainTextLabel
    Accessible.onPressAction: control.animateClick()

    Shortcut {
        //in case of explicit & the button manages it by itself
        enabled: !(RegExp(/\&[^\&]/).test(control.text))
        sequence: control.Primitives.MnemonicData.sequence
        onActivated: control.animateClick()
    }
}
