/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *  SPDX-FileCopyrightText: 2024 Akseli Lahtinen <akselmo@akselmo.dev>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

/*!
  \qmltype SelectableLabel
   \inqmlmodule org.kde.kirigami

  \brief This is a label which supports text selection.

  The label uses TextEdit component, which is wrapped inside a Control component.


  Example usage:
  \code
      Kirigami.SelectableLabel {
          text: "Label"
      }
  \endcode

  \sa https://bugreports.qt.io/browse/QTBUG-14077
  \since 5.95
 */
QQC2.Control {
    id: root

    //TODO KF7: Cleanup from unnecessary properties we dont need to expose for a label
    activeFocusOnTab: false

    padding: undefined
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined

    Accessible.name: textEdit.text
    Accessible.role: Accessible.StaticText
    Accessible.selectableText: true
    Accessible.editable: false

    /*!
     */
    property alias readOnly: textEdit.readOnly

    /*!
     */
    property alias selectByMouse: textEdit.selectByMouse

    /*!
     */
    property alias color: textEdit.color

    /*!
     */
    property alias selectedTextColor: textEdit.selectedTextColor

    /*!
     */
    property alias selectionColor: textEdit.selectionColor

    /*!
     */
    property alias text: textEdit.text

    /*!
     */
    property alias baseUrl: textEdit.baseUrl

    /*!
     */
    property var cursorShape

    /*!
     */
    property alias horizontalAlignment: textEdit.horizontalAlignment

    /*!
     */
    property alias verticalAlignment: textEdit.verticalAlignment

    /*!
     */
    property alias textFormat: textEdit.textFormat

    /*!
     */
    property alias wrapMode: textEdit.wrapMode

    /*!
     */
    property alias activeFocusOnPress: textEdit.activeFocusOnPress

    /*!
     */
    property alias cursorDelegate: textEdit.cursorDelegate

    /*!
     */
    property alias cursorPosition: textEdit.cursorPosition

    /*!
     */
    property alias cursorVisible: textEdit.cursorVisible

    /*!
     */
    property alias inputMethodHints: textEdit.inputMethodHints

    /*!
     */
    property alias mouseSelectionMode: textEdit.mouseSelectionMode

    /*!
     */
    property alias overwriteMode: textEdit.overwriteMode

    /*!
     */
    property alias persistentSelection: textEdit.persistentSelection

    /*!
     */
    property alias renderType: textEdit.renderType

    /*!
     */
    property alias selectByKeyboard: textEdit.selectByKeyboard

    /*!
     */
    property alias tabStopDistance: textEdit.tabStopDistance

    /*!
     */
    property alias textMargin: textEdit.textMargin

    /*!
     */
    readonly property alias canPaste: textEdit.canPaste

    /*!
     */
    readonly property alias canRedo: textEdit.canRedo

    /*!
     */
    readonly property alias canUndo: textEdit.canUndo

    /*!
     */
    readonly property alias inputMethodComposing: textEdit.inputMethodComposing

    /*!
     */
    readonly property alias length: textEdit.length

    /*!
     */
    readonly property alias lineCount: textEdit.lineCount

    /*!
     */
    readonly property alias selectionEnd: textEdit.selectionEnd

    /*!
     */
    readonly property alias selectionStart: textEdit.selectionStart

    /*!
     */
    readonly property alias contentHeight: textEdit.contentHeight

    /*!
     */
    readonly property alias contentWidth: textEdit.contentWidth

    /*!
     */
    readonly property alias hoveredLink: textEdit.hoveredLink

    /*!
     */
    readonly property alias preeditText: textEdit.preeditText

    /*!
     */
    readonly property alias selectedText: textEdit.selectedText

    /*!
     */
    readonly property alias cursorRectangle: textEdit.cursorRectangle

    /*!
     */
    readonly property alias cursorSelection: textEdit.cursorSelection

    /*!
     */
    readonly property alias effectiveHorizontalAlignment: textEdit.effectiveHorizontalAlignment

    /*!
     */
    readonly property alias textDocument: textEdit.textDocument

    /*!
     */
    signal editingFinished()

    /*!
     */
    signal clicked()

    /*!
     */
    signal linkActivated(string link)

    /*!
     */
    signal linkHovered(string link)

//BEGIN TextArea dummy entries
    property var flickable: undefined
    property var placeholderText: undefined
    property var placeholderTextColor: undefined

    signal pressAndHold(MouseEvent event)
    signal pressed(MouseEvent event)
    signal released(MouseEvent event)
//END TextArea dummy entries

    contentItem: TextEdit {
        id: textEdit

        property alias cursorShape: hoverHandler.cursorShape

        activeFocusOnTab: root.activeFocusOnTab
        color: Kirigami.Theme.textColor
        readOnly: true
        selectByMouse: true
        padding: 0
        selectedTextColor: Kirigami.Theme.highlightedTextColor
        selectionColor: Kirigami.Theme.highlightColor
        textFormat: TextEdit.AutoText
        verticalAlignment: TextEdit.AlignTop
        wrapMode: TextEdit.WordWrap
        font: root.font
        persistentSelection: contextMenu.visible

        onLinkActivated: root.linkActivated(textEdit.hoveredLink)
        onLinkHovered: root.linkHovered(textEdit.hoveredLink)
        onEditingFinished: root.editingFinished()

        HoverHandler {
            id: hoverHandler
            // By default HoverHandler accepts the left button while it shouldn't accept anything,
            // causing https://bugreports.qt.io/browse/QTBUG-106489.
            // Qt.NoButton unfortunately is not a valid value for acceptedButtons.
            // Disabling masks the problem, but
            // there is no proper workaround other than an upstream fix
            // See qqc2-desktop-style Label.qml
            enabled: false
            cursorShape: root.cursorShape ? root.cursorShape : (textEdit.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor)
        }

        TapHandler {
            // For custom click actions we want selection to be turned off
            enabled: !textEdit.selectByMouse

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
            acceptedButtons: Qt.LeftButton

            onTapped: root.clicked()
        }

        TapHandler {
            enabled: textEdit.selectByMouse

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
            acceptedButtons: Qt.RightButton

            onPressedChanged: if (pressed) {
                contextMenu.popup();
            }
        }

        QQC2.Menu {
            id: contextMenu
            QQC2.MenuItem {
                action: T.Action {
                    icon.name: "edit-copy-symbolic"
                    text: qsTr("Copy")
                    shortcut: StandardKey.Copy
                    enabled: root.visible && textEdit.selectedText.length > 0
                }
                onTriggered: {
                    textEdit.copy();
                    textEdit.deselect();
                }
            }
            QQC2.MenuSeparator {}
            QQC2.MenuItem {
                action: T.Action {
                    icon.name: "edit-select-all-symbolic"
                    text: qsTr("Select All")
                    shortcut: StandardKey.SelectAll
                    enabled: root.visible
                }
                onTriggered: {
                    textEdit.selectAll();
                }
            }
        }
    }
}
