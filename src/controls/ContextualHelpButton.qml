/*
   SPDX-FileCopyrightText: 2020 Felix Ernst <fe.a.ernst@gmail.com>
   SPDX-FileCopyrightText: 2024 Nate Graham <nate@kde.org>
   SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>

   SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
  \qmltype ContextualHelpButton
  \inqmlmodule org.kde.kirigami

  \brief An inline help button that shows a tooltip when clicked.

  Use this component when you want to explain details or usage of a feature of
  the UI, but the explanation is too long to fit in an inline label, and too
  important to put in a hover tooltip and risk the user missing it.

  \image ContextualHelpButton.png "Example of ContextualHelpButton usage"

  Example usage:
  \qml
  import QtQuick.Controls as QQC2
  import QtQuick.Layouts
  import org.kde.kirigami as Kirigami

  RowLayout {
      spacing: Kirigami.Units.smallSpacing

      QQC2.CheckBox {
          text: i18n("Allow screen tearing in fullscreen windows")
      }

      Kirigami.ContextualHelpButton {
          toolTipText: i18n("With most displays, screen tearing reduces latency at the cost of some visual fidelity at high framerates. Note that not all graphics drivers support this setting.")
      }
  }

  \endqml
 */

QQC2.ToolButton {
    id: root

    /*!
      \qmlproperty string ContextualHelpButton::toolTipText
     */
    property alias toolTipText: toolTip.text

    /*!
     */
    property bool toolTipVisible: false

    text: qsTr("Show Contextual Help")
    icon.name: "help-contextual-symbolic"
    display: QQC2.ToolButton.IconOnly
    
    Accessible.description: toolTipText

    onReleased: {
        toolTip.delay = toolTipVisible ? Kirigami.Units.toolTipDelay : 0;
        toolTipVisible = !toolTipVisible;
    }
    onActiveFocusChanged: {
        toolTip.delay = Kirigami.Units.toolTipDelay;
        toolTipVisible = false;
    }
    Layout.maximumHeight: parent?.height ?? -1

    QQC2.ToolTip {
        id: toolTip
        clip: true
        visible: root.hovered || root.toolTipVisible || toolTipHandler.hovered
        onVisibleChanged: {
            if (!visible && root.toolTipVisible) {
                root.toolTipVisible = false;
                delay = Kirigami.Units.toolTipDelay;
            }
        }
        timeout: -1 // Don't disappear while the user might still be reading it!

        HoverHandler {
            // Also keep the tooltip open while hovering it
            // Fixes the flickering when the popup covers the button
            id: toolTipHandler
            enabled: !root.toolTipVisible // Only if activated by hovering
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.WhatsThisCursor
        acceptedButtons: Qt.NoButton
    }
}
