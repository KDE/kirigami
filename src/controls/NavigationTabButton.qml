/* SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami.controls as KC
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

    // FIXME: all those internal properties should go, and the button should style itself in a more standard way
    // probably similar to view items
    readonly property color __foregroundColor: Platform.Theme.textColor
    readonly property color __highlightForegroundColor: Platform.Theme.textColor

    readonly property color __pressedColor: Qt.alpha(Platform.Theme.highlightColor, 0.3)
    readonly property color __hoverSelectColor: Qt.alpha(Platform.Theme.highlightColor, 0.2)
    readonly property color __borderColor: Platform.Theme.highlightColor
    readonly property color __selectedOutlineBorderColor: Qt.alpha(__borderColor, 0.5)

    readonly property real __verticalMargins: (display === T.AbstractButton.TextBesideIcon) ? Platform.Units.largeSpacing : 0

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    display: T.AbstractButton.TextUnderIcon

    Platform.Theme.colorSet: Platform.Theme.Window
    Platform.Theme.inherit: false

    hoverEnabled: true

    padding: Platform.Units.smallSpacing
    spacing: Platform.Units.smallSpacing

    leftInset: Platform.Units.smallSpacing
    rightInset: Platform.Units.smallSpacing
    topInset: Platform.Units.smallSpacing
    bottomInset: Platform.Units.smallSpacing

    icon.height: display === T.AbstractButton.TextBesideIcon ? Platform.Units.iconSizes.small : Platform.Units.iconSizes.smallMedium
    icon.width: display === T.AbstractButton.TextBesideIcon ? Platform.Units.iconSizes.small : Platform.Units.iconSizes.smallMedium
    icon.color: checked ? __highlightForegroundColor : __foregroundColor

    QQC2.ToolTip.text: (control.action as KC.Action)?.tooltip ?? ""
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

    background: Item {
        Platform.Theme.colorSet: Platform.Theme.Button
        Platform.Theme.inherit: false

        implicitHeight: control.display === T.AbstractButton.TextBesideIcon ? 0 : Platform.Units.gridUnit * 3

        // Outline for keyboard navigation
        Rectangle {
            id: outline
            anchors.fill: buttonBackground
            anchors.margins: -2 // Needs to lie outside of the button border, and not overlap into the button

            radius: Platform.Units.cornerRadius
            color: 'transparent'

            border.color: control.visualFocus ? control.__selectedOutlineBorderColor : "transparent"
            border.width: 3
        }

        Rectangle {
            id: buttonBackground
            anchors.fill: parent

            radius: Platform.Units.cornerRadius
            color: control.down ? control.__pressedColor : (control.checked || control.hovered ? control.__hoverSelectColor : "transparent")

            border.color: (control.checked || control.down) ? control.__borderColor : color
            border.width: 1

            Behavior on color { ColorAnimation { duration: Platform.Units.shortDuration } }
            Behavior on border.color { ColorAnimation { duration: Platform.Units.shortDuration } }
        }
    }

    contentItem: GridLayout {
        columnSpacing: 0
        rowSpacing: (label.visible && label.lineCount > 1) ? 0 : control.spacing

        // if this is a row or a column
        columns: control.display !== T.AbstractButton.TextBesideIcon ? 1 : 2

        Primitives.Icon {
            id: icon
            source: control.icon.name || control.icon.source
            visible: (control.icon.name.length > 0 || control.icon.source.toString().length > 0) && control.display !== T.AbstractButton.TextOnly
            color: control.icon.color

            Layout.topMargin: control.__verticalMargins
            Layout.bottomMargin: control.__verticalMargins
            Layout.leftMargin: (control.display === T.AbstractButton.TextBesideIcon) ? Platform.Units.gridUnit : 0
            Layout.rightMargin: (control.display === T.AbstractButton.TextBesideIcon) ? Platform.Units.gridUnit : 0

            Layout.alignment: {
                if (control.display === T.AbstractButton.TextBesideIcon) {
                    // row layout
                    return Qt.AlignVCenter | Qt.AlignRight;
                } else {
                    // column layout
                    return Qt.AlignHCenter | ((!label.visible || label.lineCount > 1) ? Qt.AlignVCenter : Qt.AlignBottom);
                }
            }
            implicitHeight: source ? control.icon.height : 0
            implicitWidth: source ? control.icon.width : 0

            Behavior on color { ColorAnimation { duration: Platform.Units.shortDuration } }
        }
        QQC2.Label {
            id: label

            text: control.Primitives.MnemonicData.richTextLabel
            Accessible.name: control.Primitives.MnemonicData.plainTextLabel
            horizontalAlignment: (control.display === T.AbstractButton.TextBesideIcon) ? Text.AlignLeft : Text.AlignHCenter

            visible: control.display !== T.AbstractButton.IconOnly
            wrapMode: Text.Wrap
            elide: Text.ElideMiddle
            color: control.checked ? control.__highlightForegroundColor : control.__foregroundColor

            font.pointSize: !icon.visible && control.display === T.AbstractButton.TextUnderIcon
                    ? Platform.Theme.defaultFont.pointSize * 1.20 // 1.20 is equivalent to level 2 heading
                    : Platform.Theme.defaultFont.pointSize

            Behavior on color { ColorAnimation { duration: Platform.Units.shortDuration } }

            Layout.topMargin: control.__verticalMargins
            Layout.bottomMargin: control.__verticalMargins

            Layout.alignment: {
                if (control.display === T.AbstractButton.TextBesideIcon) {
                    // row layout
                    return Qt.AlignVCenter | Qt.AlignLeft;
                } else {
                    // column layout
                    return icon.visible ? Qt.AlignHCenter | Qt.AlignTop : Qt.AlignCenter;
                }
            }

            Layout.fillWidth: true

            Accessible.ignored: true
        }
    }
}
