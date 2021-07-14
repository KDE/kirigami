/*
 *  SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *  SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.17 as Kirigami


/**
 * A categorized settings component that is ready to integrate in a kirigami app.
 *
 * Allows to have a component that will show a list of settings pages in a sidebar
 * and a available area on the right that will show the actual settings page
 * content.
 *
 * @since 5.84
 * @since org.kde.kirigami 2.17
 */
Kirigami.PageRow {
    id: pageSettingStack


    property list<Kirigami.PagePoolAction> actions
    property alias stack: pageSettingStack

    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0

    columnView.columnWidth: Kirigami.Units.gridUnit * 12
    globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    globalToolBar.style: Kirigami.ApplicationHeaderStyle.Breadcrumb

    onActionsChanged: {
        for (let i in actions) {
            let action = actions[i];
            action.pageStack = pageSettingStack;
            action.pagePool = pageSettingsPool;
            action.basePage = pageSettingStack.initialPage
        }
    }

    signal backRequested(var event)
    onBackRequested: {
        if (pageSettingStack.depth > 1 && !pageSettingStack.wideMode && pageSettingStack.currentIndex !== 0) {
            event.accepted = true;
            pageSettingStack.pop();
        }
    }

    Kirigami.PagePool {
        id: pageSettingsPool
    }

    initialPage: Kirigami.ScrollablePage {
        title: qsTr("Settings")
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        ListView {
            Component.onCompleted: if (pageSettingStack.width >= Kirigami.Units.gridUnit * 40) {
                actions[0].trigger();
            }
            model: pageSettingStack.actions
            delegate: Kirigami.BasicListItem {
                action: modelData
            }
        }
    }
}

