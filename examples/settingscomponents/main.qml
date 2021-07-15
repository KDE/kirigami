/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Layouts 1.15

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Hello, World")

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: !Kirigami.isMobile
        actions: [
            Kirigami.Action {
                text: i18n("Settings")
                icon.name: "settings-configure"
                onTriggered: root.pageStack.pushDialogLayer("qrc:/SettingsPage.qml", {
                    width: root.width
                }, {
                    title: i18n("Settings"),
                    width: root.width - (Kirigami.Units.gridUnit * 4),
                    height: root.height - (Kirigami.Units.gridUnit * 4)
                })
            }
        ]
    }

    pageStack.initialPage: Kirigami.Page {
        title: i18n("Main Page")
    }
}
