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

    icon.name: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")

    enabled: {
        const pageStack = applicationWindow().pageStack;

        if (pageStack.layers.depth > 1) {
            return true;
        }

        if (pageStack.depth > 1) {
            if (pageStack.currentIndex > 0) {
                return true;
            }

            const view = pageStack.columnView;
            if (LayoutMirroring.enabled) {
                return view.contentWidth - view.width < view.contentX
            } else {
                return view.contentX > 0;
            }
        }

        return false;
    }

    // The gridUnit wiggle room is used to not flicker the button visibility during an animated resize for instance due to a sidebar collapse
    opacity: {
        const pageStack = applicationWindow().pageStack;
        const showNavButtons = globalToolBar?.showNavigationButtons ?? Kirigami.ApplicationHeaderStyle.NoNavigationButtons;
        return pageStack.layers.depth > 1 || (pageStack.contentItem.contentWidth > pageStack.width + Kirigami.Units.gridUnit && (showNavButtons & Kirigami.ApplicationHeaderStyle.ShowBackButton));
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Layout.rightMargin: -width * (1 - opacity)


    onClicked: {
        applicationWindow().pageStack.goBack();
    }

    text: qsTr("Navigate Back")
    display: QQC2.ToolButton.IconOnly

    QQC2.ToolTip {
        visible: button.hovered
        text: button.text
        delay: Kirigami.Units.toolTipDelay
        timeout: 5000
        y: button.height
    }
}
