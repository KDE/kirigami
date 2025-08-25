/*
 *  SPDX-FileCopyrightText: 2019 Carl-Lucien Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/*!
  \qmltype ActionTextField
  \inqmlmodule org.kde.kirigami

  \brief An advanced control to create custom textfields with inline buttons

  ActionTextField can display inline action buttons on the leading or trailing
  sides, and is used as the base class for other kinds of specialized text
  fields, including \l SearchField and \l PasswordField.

  Each action's \c {text} property will be displayed in a tooltip on hover.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  Kirigami.ActionTextField {
      id: inputField

      placeholderText: i18n("Enter name")

      rightActions: Kirigami.Action {
          icon.name: "edit-clear"
          visible: inputField.text.length > 0
          onTriggered: {
              inputField.clear();
              inputField.accepted();
          }
      }

      onAccepted: console.log("Entered text is " + inputField.text);
  }
  \endcode

  \since 5.56
 */
QQC2.TextField {
    id: root

    /*!
      \qmlproperty keysequence ActionTextField::focusSequence
      This property holds a shortcut sequence that will focus the text field.
      \since 5.56

      By default no shortcut is set.
     */
    property alias focusSequence: focusShortcut.sequence

    /*!
     \qmlproperty list<keysequence> ActionTextField::focusSequences
     This property holds multiple shortcut sequences that will focus the text field.
     \since 6.18

     By default no shortcut is set.
     */
    property alias focusSequences: focusShortcut.sequences

    /*!
      \qmlproperty list<Action> leftActions

      This property holds a list of actions that will be displayed on the
      leading side of the text field.

      By default this list is empty.

      \since 5.56
     */
    property list<T.Action> leftActions

    /*!
      \qmlproperty list<Action> rightActions

      This property holds a list of actions that will be displayed on the
      trailing side of the text field.

      By default this list is empty.

      \since 5.56
     */
    property list<T.Action> rightActions

    property alias _leftActionsRow: leftActionsRow
    property alias _rightActionsRow: rightActionsRow

    hoverEnabled: true

    horizontalAlignment: Qt.AlignLeft
    LayoutMirroring.enabled: Application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    leftPadding: Kirigami.Units.smallSpacing + (LayoutMirroring.enabled ? rightActionsRow : leftActionsRow).width
    rightPadding: Kirigami.Units.smallSpacing + (LayoutMirroring.enabled ? leftActionsRow : rightActionsRow).width

    Behavior on leftPadding {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on rightPadding {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Shortcut {
        id: focusShortcut
        enabled: root.visible && root.enabled
        onActivated: {
            root.forceActiveFocus(Qt.ShortcutFocusReason)
            root.selectAll()
        }
    }

    QQC2.ToolTip {
        visible: focusShortcut.nativeText.length > 0 && root.text.length === 0 && root.hovered
        text: focusShortcut.nativeText
    }

    component InlineActionIcon: Kirigami.Icon {
        id: iconDelegate

        required property T.Action modelData

        implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
        implicitHeight: Kirigami.Units.iconSizes.sizeForLabels

        anchors.verticalCenter: parent?.verticalCenter

        source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
        visible: !(modelData instanceof Kirigami.Action) || modelData.visible
        active: actionArea.containsPress || actionArea.activeFocus
        enabled: modelData.enabled

        MouseArea {
            id: actionArea

            anchors.fill: parent
            activeFocusOnTab: true
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Accessible.name: iconDelegate.modelData.text
            Accessible.role: Accessible.Button

            Keys.onPressed: event => {
                switch (event.key) {
                    case Qt.Key_Space:
                    case Qt.Key_Enter:
                    case Qt.Key_Return:
                    case Qt.Key_Select:
                        clicked(null);
                        event.accepted = true;
                        break;
                }
            }
            onClicked: mouse => iconDelegate.modelData.trigger()
        }

        QQC2.ToolTip {
            visible: (actionArea.containsMouse || actionArea.activeFocus) && (iconDelegate.modelData.text.length > 0)
            text: iconDelegate.modelData.text
        }
    }

    Row {
        id: leftActionsRow
        padding: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        layoutDirection: Qt.LeftToRight
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.top: parent.top
        anchors.topMargin: parent.topPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.bottomPadding
        Repeater {
            model: root.leftActions
            InlineActionIcon { }
        }
    }

    Row {
        id: rightActionsRow
        padding: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        layoutDirection: Qt.RightToLeft
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.smallSpacing
        anchors.top: parent.top
        anchors.topMargin: parent.topPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.bottomPadding
        Repeater {
            model: root.rightActions
            InlineActionIcon { }
        }
    }
}
