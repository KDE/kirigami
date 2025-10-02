/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

QQC2.Menu {
    id: root

    property alias actions: actionsInstantiator.model

    property Component submenuComponent
    property Component itemDelegate: ActionMenuItem {}
    property Component separatorDelegate: QQC2.MenuSeparator {
        property T.Action action
    }
    property Component loaderDelegate: Loader {
        property T.Action action
    }
    property T.Action parentAction
    property T.MenuItem parentItem

    Instantiator {
        id: actionsInstantiator

        active: root.visible
        delegate: QtObject {
            readonly property T.Action action: modelData

            property QtObject item: null
            property bool isSubMenu: false

            Component.onCompleted: {
                const isKirigamiAction = action instanceof Kirigami.Action;
                if (!isKirigamiAction || action.children.length === 0) {
                    if (isKirigamiAction && action.separator) {
                        item = root.separatorDelegate.createObject(null, { action });
                    } else if (action.displayComponent) {
                        item = root.loaderDelegate.createObject(null, {
                            action,
                            sourceComponent: action.displayComponent,
                        });
                    } else {
                        item = root.itemDelegate.createObject(null, { action });
                    }
                    root.addItem(item)
                } else if (root.submenuComponent) {
                    item = root.submenuComponent.createObject(null, {
                        parentAction: action,
                        icon: action.icon,
                        title: action.text,
                        actions: action.children,
                        submenuComponent: root.submenuComponent,
                    });

                    root.insertMenu(root.count, item);
                    item.parentItem = root.contentData[root.contentData.length - 1];
                    isSubMenu = true;
                }
            }

            Component.onDestruction: {
                if (isSubMenu) {
                    root.removeMenu(item);
                } else {
                    root.removeItem(item);
                }
                item.destroy();
            }
        }
    }
}
