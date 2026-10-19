/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../../../templates/private" as Private
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

Private.GlobalDrawerActionItem {
    id: control

    readonly property color _foregroundColor: Qt.alpha(Material.foreground, !enabled ? 0.38 : checked ? 1 : 0.8)
    readonly property bool _hasIcon: (tAction?.icon.name.length ?? 0) > 0 || (tAction?.icon.source.toString().length ?? 0) > 0

    visible: actionVisible && (!drawerCollapsed || !isSeparator)
    opacity: 1
    activeFocusOnTab: !isSeparator
    hoverEnabled: !isSeparator && !Platform.Settings.hasTransientTouchInput

    font.family: drawerCollapsed ? Platform.Theme.smallFont.family : Platform.Theme.defaultFont.family
    font.pointSize: drawerCollapsed ? Platform.Theme.smallFont.pointSize : Platform.Theme.defaultFont.pointSize
    font.weight: Font.Medium

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: isSeparator ? Platform.Units.largeSpacing
        : Math.max(Platform.Units.largeSpacing * (drawerCollapsed ? 8 : 6), implicitContentHeight + topPadding + bottomPadding)
    horizontalPadding: drawerCollapsed ? 0 : Platform.Units.largeSpacing * 2
    verticalPadding: Platform.Units.smallSpacing
    leftInset: Math.max(0, leftPadding - horizontalPadding)
    rightInset: Math.max(0, rightPadding - horizontalPadding)
    spacing: Platform.Units.smallSpacing

    background: NavigationIndicator {
        control: control
        visible: !control.isSeparator && (!control.drawerCollapsed || !control._hasIcon)
    }

    contentItem: GridLayout {
        columns: control.drawerCollapsed ? 1 : 3
        rowSpacing: control.spacing
        columnSpacing: Platform.Units.largeSpacing * 2

        Item {
            visible: !control.isSeparator && control._hasIcon
            implicitWidth: control.drawerCollapsed ? Platform.Units.largeSpacing * 7 : Platform.Units.iconSizes.smallMedium
            implicitHeight: control.drawerCollapsed ? Platform.Units.largeSpacing * 4 : Platform.Units.iconSizes.smallMedium
            Layout.maximumWidth: implicitWidth
            Layout.alignment: Qt.AlignCenter

            NavigationIndicator {
                control: control
                visible: control.drawerCollapsed
                anchors.fill: parent
            }

            Primitives.Icon {
                anchors.centerIn: parent
                source: control.tAction?.icon.name || control.tAction?.icon.source || ""
                implicitWidth: Platform.Units.iconSizes.smallMedium
                implicitHeight: Platform.Units.iconSizes.smallMedium
                color: control.tAction?.icon.color.a > 0 ? control.tAction.icon.color : control._foregroundColor
                isMask: (control.tAction?.icon.name ?? "").endsWith("-symbolic") || (control.tAction?.icon.color.a ?? 0) > 0
                Accessible.ignored: true
            }
        }

        Label {
            visible: !control.isSeparator
            text: control.Primitives.MnemonicData.richTextLabel
            color: control._foregroundColor
            font: control.font
            horizontalAlignment: control.drawerCollapsed ? Text.AlignHCenter : Text.AlignLeft
            wrapMode: control.drawerCollapsed ? Text.WordWrap : Text.NoWrap
            maximumLineCount: control.drawerCollapsed ? 2 : 1
            elide: Text.ElideRight
            Layout.fillWidth: true
            Accessible.ignored: true
        }

        Primitives.Icon {
            visible: !control.drawerCollapsed && !control.isSeparator && !control.isExpandable && control.hasChildren
            source: control.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
            color: control._foregroundColor
            implicitWidth: Platform.Units.iconSizes.small
            implicitHeight: Platform.Units.iconSizes.small
            Accessible.ignored: true
        }

        Primitives.Separator {
            visible: control.isSeparator
            Layout.fillWidth: true
            color: Qt.alpha(control.Material.foreground, 0.12)
        }
    }
}
