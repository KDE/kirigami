/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.impl as QQC2Impl
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: listItem

    required property T.Action tAction
    // `as` case operator is still buggy
    readonly property Kirigami.Action kAction: tAction instanceof Kirigami.Action ? tAction : null

    readonly property bool actionVisible: kAction?.visible ?? true
    readonly property bool isSeparator: kAction?.separator ?? false
    readonly property bool isExpandable: kAction?.expandible ?? false
    readonly property bool hasChildren: kAction ? kAction.children.length > 0 : false
    readonly property bool hasVisibleMenu: actionsMenu?.visible ?? false
    readonly property bool hasToolTip: kAction ? kAction.tooltip !== "" : false

    checked: checkedBinding()
    highlighted: checked
    activeFocusOnTab: true

    width: parent.width

    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            id: iconItem
            color: listItem.tAction.icon.color
            source: listItem.tAction.icon.name || listItem.tAction.icon.source

            readonly property int size: Kirigami.Units.iconSizes.smallMedium
            Layout.minimumHeight: size
            Layout.maximumHeight: size
            Layout.minimumWidth: size
            Layout.maximumWidth: size

            selected: (listItem.highlighted || listItem.checked || listItem.down)
            visible: source !== undefined && !listItem.isSeparator
        }

        QQC2Impl.MnemonicLabel {
            id: labelItem
            visible: !listItem.isSeparator
            text: width > height * 2 ? listItem.Kirigami.MnemonicData.mnemonicLabel : ""
            Accessible.name: listItem.Kirigami.MnemonicData.plainTextLabel

            // Work around Qt bug where left aligned text is not right aligned
            // in RTL mode unless horizontalAlignment is explicitly set.
            // https://bugreports.qt.io/browse/QTBUG-95873
            horizontalAlignment: Text.AlignLeft

            Layout.fillWidth: true
            mnemonicVisible: listItem.Kirigami.MnemonicData.active
            color: (listItem.highlighted || listItem.checked || listItem.down) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            elide: Text.ElideRight
            font: listItem.font
            opacity: {
                if (root.collapsed) {
                    return 0;
                } else if (!listItem.enabled) {
                    return 0.75;
                } else {
                    return 1.0;
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration/2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Kirigami.Separator {
            id: separatorAction

            visible: listItem.isSeparator
            Layout.fillWidth: true
        }

        Kirigami.Icon {
            isMask: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: !root.collapsed ? 0 : -width
            Layout.preferredHeight: !root.collapsed ? Kirigami.Units.iconSizes.small : Kirigami.Units.iconSizes.small/2
            opacity: 0.75
            selected: listItem.checked || listItem.down
            Layout.preferredWidth: Layout.preferredHeight
            source: listItem.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
            visible: (!listItem.isExpandable || root.collapsed) && !listItem.isSeparator && listItem.hasChildren
        }
    }

    Accessible.name: Kirigami.MnemonicData.plainTextLabel
    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
    Kirigami.MnemonicData.label: tAction?.text ?? ""

    Shortcut {
        sequence: listItem.Kirigami.MnemonicData.sequence
        onActivated: listItem.clicked()
    }

    property ActionsMenu actionsMenu: ActionsMenu {
        x: Application.layoutDirection === Qt.RightToLeft ? -width : listItem.width
        actions: listItem.kAction?.children ?? []
        submenuComponent: ActionsMenu {}

        onVisibleChanged: {
            if (visible) {
                stackView.openSubMenu = listItem.actionsMenu;
            } else if (stackView.openSubMenu === listItem.actionsMenu) {
                stackView.openSubMenu = null;
            }
        }
    }

    // TODO: animate the hide by collapse
    visible: actionVisible && opacity > 0
    opacity: !root.collapsed || iconItem.source.toString().length > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration / 2
            easing.type: Easing.InOutQuad
        }
    }

    enabled: tAction?.enabled ?? false

    hoverEnabled: (!isExpandable || root.collapsed) && !Kirigami.Settings.tabletMode && !isSeparator
    font.pointSize: isExpandable ? Kirigami.Theme.defaultFont.pointSize * 1.30 : Kirigami.Theme.defaultFont.pointSize
    height: implicitHeight * opacity

    QQC2.ToolTip {
        visible: !listItem.isSeparator
            && (listItem.hasToolTip || root.collapsed)
            && !listItem.hasVisibleMenu
            && listItem.hovered
            && text.length > 0

        text: (listItem.kAction?.tooltip || listItem.tAction?.text) ?? ""
        delay: Kirigami.Units.toolTipDelay
        y: (listItem.height - height) / 2
        x: Application.layoutDirection === Qt.RightToLeft ? -width : listItem.width
    }

    onHoveredChanged: {
        if (!hovered) {
            return;
        }
        if (stackView.openSubMenu) {
            stackView.openSubMenu.visible = false;

            if (actionsMenu.count > 0) {
                actionsMenu.popup(this, width, 0);
            }
        }
    }

    onClicked: trigger()
    Accessible.onPressAction: trigger()
    Keys.onEnterPressed: event => trigger()
    Keys.onReturnPressed: event => trigger()

    function trigger() {
        tAction?.trigger();

        if (hasChildren) {
            if (root.collapsed) {
                if (actionsMenu.count > 0 && !actionsMenu.visible) {
                    stackView.openSubMenu = actionsMenu;
                    actionsMenu.popup(this, width, 0);
                }
            } else {
                stackView.push(menuComponent, {
                    model: kAction?.children ?? [],
                    level: level + 1,
                    current: tAction,
                });
            }
        } else if (root.resetMenuOnTriggered) {
            root.resetMenu();
        }
        checked = Qt.binding(() => checkedBinding());
    }

    function checkedBinding(): bool {
        return (tAction?.checked || actionsMenu?.visible) ?? false;
    }

    Keys.onDownPressed: event => nextItemInFocusChain().focus = true
    Keys.onUpPressed: event => nextItemInFocusChain(false).focus = true
}
