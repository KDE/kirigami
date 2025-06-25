/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

NavigationButton {
    id: button

    icon.name: (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")
    text: qsTr("Navigate Forward")

    enabled: applicationWindow().pageStack.currentIndex < applicationWindow().pageStack.depth-1

    onClicked: applicationWindow().pageStack.goForward();

    visible: false

    function syncVisibility() {
        const pageStack = applicationWindow().pageStack;
        const globalToolBar = pageStack.globalToolBar;
        let showNavButtons = Kirigami.ApplicationHeaderStyle.NoNavigationButtons;
        if (pageStack.leadingVisibleItem instanceof Kirigami.Page
            && pageStack.leadingVisibleItem.globalToolBarStyle == Kirigami.ApplicationHeaderStyle.None) {
            showNavButtons = Kirigami.ApplicationHeaderStyle.NoNavigationButtons
        } else {
            showNavButtons = showNavButtons = globalToolBar?.showNavigationButtons ?? Kirigami.ApplicationHeaderStyle.NoNavigationButtons;
        }
        if (pageStack.layers.depth === 1
            && pageStack.contentItem.contentWidth > pageStack.width + Kirigami.Units.gridUnit
            && (showNavButtons & Kirigami.ApplicationHeaderStyle.ShowForwardButton)) {
            button.state =  "";
            return;
        }
        button.state = "invisible";
    }

    Connections {
        target: pageStack.layers
        function onDepthChanged() {
            syncVisibility();
        }
    }
    Connections {
        target: pageStack.columnView
        function onContentWidthChanged() {
            syncVisibility();
        }
    }
}
