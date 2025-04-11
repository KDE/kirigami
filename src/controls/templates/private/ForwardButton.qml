/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.ToolButton {
    id: button

    icon.name: (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")

    enabled: applicationWindow().pageStack.currentIndex < applicationWindow().pageStack.depth-1

    // The gridUnit wiggle room is used to not flicker the button visibility during an animated resize for instance due to a sidebar collapse
    property bool __active: {
        const pageStack = applicationWindow().pageStack;
        const showNavButtons = globalToolBar?.showNavigationButtons ?? Kirigami.ApplicationHeaderStyle.NoNavigationButtons;
        return pageStack.layers.depth === 1 && pageStack.contentItem.contentWidth > pageStack.width + Kirigami.Units.gridUnit && (showNavButtons & Kirigami.ApplicationHeaderStyle.ShowForwardButton);
    }
    opacity: __active
    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    visible: opacity > 0.01
    Layout.rightMargin: __active ? 0 : -width

    onClicked: applicationWindow().pageStack.goForward();

    text: qsTr("Navigate Forward")
    display: QQC2.ToolButton.IconOnly

    QQC2.ToolTip {
        visible: button.hovered
        text: button.text
        delay: Kirigami.Units.toolTipDelay
        y: button.height
    }
}
