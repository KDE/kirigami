/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Layouts
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

QQC2.ItemDelegate {
    id: listItem

    required property T.Action tAction

    readonly property KC.Action kAction: tAction as KC.Action

    readonly property bool isSeparator: kAction?.separator ?? false
    readonly property bool isExpandable: kAction?.expandible ?? false

    checked: tAction.checked || (actionsMenu && actionsMenu.visible)
    highlighted: checked
    icon.name: tAction.icon.name
    icon.source: tAction.icon.source

    text: tAction.text ? tAction.text : kAction?.tooltip ?? ""
    hoverEnabled: (!isExpandable || root.collapsed) && !Platform.Settings.tabletMode && !isSeparator
    font.pointSize: Platform.Theme.defaultFont.pointSize * (isExpandable ? 1.30 : 1)

    enabled: !isExpandable && tAction.enabled
    visible: kAction?.visible ?? true
    opacity: enabled || isExpandable ? 1.0 : 0.75

    Accessible.onPressAction: listItem.clicked()

    Primitives.Separator {
        id: separatorAction

        visible: listItem.isSeparator
        Layout.fillWidth: true
    }

    ActionsMenu {
        id: actionsMenu
        y: Platform.Settings.isMobile ? -height : listItem.height
        actions: listItem.kAction?.children ?? []
        submenuComponent: ActionsMenu {}
    }

    Loader {
        Layout.fillWidth: true
        Layout.fillHeight: true
        sourceComponent: listItem.kAction?.displayComponent ?? null
        onStatusChanged: {
            for (const child of parent.children) {
                if (child === this) {
                    child.visible = status === Loader.Ready;
                    break;
                } else {
                    child.visible = status !== Loader.Ready;
                }
            }
        }
        Component.onCompleted: statusChanged()
    }

    onPressed: {
        if (kAction && kAction.children.length > 0) {
            actionsMenu.open();
        }
    }
    onClicked: {
        if (!kAction || kAction.children.length === 0) {
            root.drawerOpen = false;
        }

        tAction?.trigger();
    }
}
