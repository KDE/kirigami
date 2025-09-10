/*
 *  SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */


import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

ToolBar {
    id: root

    // The custom component to show in the header
    property Component titleDelegate

    // The list of actions for the ActionToolBar
    property list<T.Action> actions

    // Whether to show the back button
    property bool showBackButton: false

    // The Kirigami PageStack
    property var pageStack

    position: ToolBar.Header

    onTitleDelegateChanged: {
        if (!titleDelegate) {
            return;
        }
        let item = titleDelegate.createObject(root);
        titleDelegateContainer.contentItem = item;
        item.parent = titleDelegateContainer;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ToolButton {
            id: backButton
            visible: showBackButton
            icon.name: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")
            text: i18n("Navigate Back")
            display: AbstractButton.IconOnly
            onClicked: root.pageStack.pop()

            ToolTip {
                visible: backButton.hovered
                text: backButton.text
                delay: Kirigami.Units.toolTipDelay
                timeout: 5000
                y: backButton.height
            }
        }

        Item {
            Layout.minimumHeight: backButton.height // Keep RowLayout height to be at least button height
            implicitWidth: 0
        }

        Control {
            id: titleDelegateContainer
            padding: 0
            Layout.leftMargin: Kirigami.Units.largeSpacing
        }

        Kirigami.ActionToolBar {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            alignment: Qt.AlignRight
            Layout.fillHeight: true
            actions: root.actions
        }
    }
}
