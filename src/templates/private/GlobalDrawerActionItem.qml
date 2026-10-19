/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.controls as KC
import "../../controls/private" as KP

/*!
  \qmltype GlobalDrawerActionItem
  \inqmlmodule org.kde.kirigami.templates.private
  \internal
 */
QQC2.ItemDelegate {
    id: listItem

    required property T.Action tAction
    required property bool drawerCollapsed
    // `as` case operator is still buggy
    readonly property KC.Action kAction: tAction as KC.Action

    readonly property bool actionVisible: kAction?.visible ?? true
    readonly property bool isSeparator: kAction?.separator ?? false
    readonly property bool isExpandable: kAction?.expandible ?? false
    readonly property bool hasChildren: kAction ? kAction.children.length > 0 : false
    readonly property bool hasVisibleMenu: actionsMenu?.visible ?? false
    readonly property bool hasToolTip: kAction ? kAction.tooltip !== "" : false

    signal actionsMenuVisibleChanged(bool visible)
    signal actionTriggered

    checked: checkedBinding()
    highlighted: checked
    activeFocusOnTab: true

    Accessible.name: Primitives.MnemonicData.plainTextLabel
    Primitives.MnemonicData.enabled: enabled && visible
    Primitives.MnemonicData.controlType: Primitives.MnemonicData.MenuItem
    Primitives.MnemonicData.label: tAction?.text ?? ""

    Shortcut {
        sequence: listItem.Primitives.MnemonicData.sequence
        onActivated: listItem.clicked()
    }

    property KP.ActionsMenu actionsMenu: KP.ActionsMenu {
        x: Application.layoutDirection === Qt.RightToLeft ? -width : listItem.width
        actions: listItem.kAction?.children ?? []
        submenuComponent: KP.ActionsMenu {}

        onVisibleChanged: listItem.actionsMenuVisibleChanged(visible)
    }

    // TODO: animate the hide by collapse
    visible: actionVisible && opacity > 0
    opacity: !listItem.drawerCollapsed || Boolean(tAction?.icon.name || tAction?.icon.source)

    Behavior on opacity {
        NumberAnimation {
            duration: Platform.Units.longDuration / 2
            easing.type: Easing.InOutQuad
        }
    }

    enabled: tAction?.enabled ?? false

    hoverEnabled: (!isExpandable || listItem.drawerCollapsed) && !Platform.Settings.tabletMode && !isSeparator
    font.pointSize: isExpandable ? Platform.Theme.defaultFont.pointSize * 1.30 : Platform.Theme.defaultFont.pointSize
    height: implicitHeight * opacity

    QQC2.ToolTip {
        visible: !listItem.isSeparator
            && (listItem.hasToolTip || listItem.drawerCollapsed)
            && !listItem.hasVisibleMenu
            && listItem.hovered
            && text.length > 0

        text: (listItem.kAction?.tooltip || listItem.tAction?.text) ?? ""
        delay: Platform.Units.toolTipDelay
        y: (listItem.height - height) / 2
        x: Application.layoutDirection === Qt.RightToLeft ? -width : listItem.width
    }

    onClicked: trigger()
    Accessible.onPressAction: trigger()
    Keys.onEnterPressed: event => trigger()
    Keys.onReturnPressed: event => trigger()

    function trigger() {
        tAction?.trigger();
        listItem.actionTriggered()

        checked = Qt.binding(() => checkedBinding());
    }

    function checkedBinding(): bool {
        return (tAction?.checked || actionsMenu?.visible) ?? false;
    }

    Keys.onDownPressed: event => nextItemInFocusChain().focus = true
    Keys.onUpPressed: event => nextItemInFocusChain(false).focus = true
}
