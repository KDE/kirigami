/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

QQC2.ToolButton {
    id: control

    signal menuAboutToShow()

    hoverEnabled: true

    display: QQC2.ToolButton.TextBesideIcon

    property bool showMenuArrow: !Kirigami.DisplayHint.displayHintSet(action, Kirigami.DisplayHint.HideChildIndicator)

    property list<T.Action> menuActions: {
        if (action instanceof Kirigami.Action) {
            return action.children;
        }
        return []
    }

    property Component menuComponent: ActionsMenu {
        submenuComponent: ActionsMenu { }
    }

    property T.Menu menu: null

    // We create the menu instance only when there are any actual menu items.
    // This also happens in the background, avoiding slowdowns due to menu item
    // creation on the main thread.
    onMenuActionsChanged: {
        if (menuComponent && menuActions.length > 0) {
            if (!menu) {
                const setupIncubatedMenu = incubatedMenu => {
                    menu = incubatedMenu
                    // Important: We handle the press on parent in the parent, so ignore it here.
                    menu.closePolicy = QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent
                    menu.closed.connect(() => control.checked = false)
                    menu.actions = control.menuActions
                }
                const incubator = menuComponent.incubateObject(control, { actions: menuActions })
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = status => {
                        if (status === Component.Ready) {
                            setupIncubatedMenu(incubator.object)
                        }
                    }
                } else {
                    setupIncubatedMenu(incubator.object);
                }
            } else {
                menu.actions = menuActions
            }
        }
    }

    visible: action instanceof Kirigami.Action ? action.visible : true
    autoExclusive: action instanceof Kirigami.Action ? action.autoExclusive : false

    // Workaround for QTBUG-85941
    Binding {
        target: control
        property: "checkable"
        value: (control.action?.checkable ?? false) || (control.menuActions.length > 0)
        restoreMode: Binding.RestoreBinding
    }

    // Important: This cannot be a direct onVisibleChanged handler in the button
    // because it breaks action assignment if we do that. However, this slightly
    // more indirect Connections object does not have that effect.
    Connections {
        target: control
        function onVisibleChanged() {
            if (!control.visible && control.menu && control.menu.visible) {
                control.menu.dismiss()
            }
        }
    }

    onToggled: {
        if (menuActions.length > 0 && menu) {
            if (checked) {
                control.menuAboutToShow();
                menu.popup(control, 0, control.height)
            } else {
                menu.dismiss()
            }
        }
    }

    QQC2.ToolTip {
        visible: control.hovered && text.length > 0 && !(control.menu && control.menu.visible) && !control.pressed
        text: {
            const a = control.action;
            if (a) {
                if (a.tooltip) {
                    return a.tooltip;
                } else if (control.display === QQC2.Button.IconOnly) {
                    return a.text;
                }
            }
            return "";
        }
    }

    // This will set showMenuArrow when using qqc2-desktop-style.
    Accessible.role: (control.showMenuArrow && control.menuActions.length > 0) ? Accessible.ButtonMenu : Accessible.Button
    Accessible.ignored: !visible
}
