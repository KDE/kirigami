/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *  SPDX-FileCopyrightText: 2024 Akseli Lahtinen <akselmo@akselmo.dev>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami.platform as Platform
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
        color: Platform.Theme.textColor
        readOnly: true
        selectByMouse: true
        padding: 0
        selectedTextColor: Platform.Theme.highlightedTextColor
        selectionColor: Platform.Theme.highlightColor
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
            cursorShape: root.cursorShape ? root.cursorShape : (textEdit.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor)
        }

        TapHandler {
            id: leftClickAndPressTapHandler

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
                    enabled: root.visible && textEdit.selectedText.length > 0 && (textEdit.activeFocus || contextMenu.activeFocus)
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
                    enabled: root.visible && (textEdit.activeFocus || contextMenu.activeFocus)
                }
                onTriggered: {
                    textEdit.selectAll();
                }
            }
        }

        QQC2.ToolTip.delay: Platform.Units.toolTipDelay
        QQC2.ToolTip.visible: textEdit.hoveredLink

        Binding {
            id: toolTipXBinding

            // QQC2.ToolTip.toolTip is global and we don't own it. We need to make sure that our x and y bindings are active only when *we* are showing tooltip
            readonly property bool overrideToolTipCoordinates: textEdit.QQC2.ToolTip.toolTip.parent === textEdit
            // Cursor x position at which the tooltip is shown. Written once when tooltip is shown
            property int toolTipOriginX: 0

            target: textEdit.QQC2.ToolTip.toolTip
            property: "x"
            value: toolTipOriginX - Math.round(textEdit.QQC2.ToolTip.toolTip.implicitWidth / 2)
            when: overrideToolTipCoordinates
        }

        Binding {
            id: toolTipYBinding

            // Cursor y position at which the tooltip is shown. Written once when tooltip is shown
            property int toolTipOriginY: 0

            target: textEdit.QQC2.ToolTip.toolTip
            property: "y"
            value: toolTipOriginY - textEdit.QQC2.ToolTip.toolTip.implicitHeight - Platform.Units.gridUnit
            when: toolTipXBinding.overrideToolTipCoordinates
        }

        onHoveredLinkChanged: {
            if (textEdit.hoveredLink) {
                // Don't reset tooltip text when it's empty so that it doesn't disappear immediately while tooltip is fading out
                QQC2.ToolTip.text = textEdit.hoveredLink
                // hoverHandler.point.position is not updated yet when onHoveredLinkChanged is called, delay using callLater
                Qt.callLater(() => {
                    toolTipXBinding.toolTipOriginX = hoverHandler.point.position.x
                    toolTipYBinding.toolTipOriginY = hoverHandler.point.position.y
                })
            }
        }
    }
}
