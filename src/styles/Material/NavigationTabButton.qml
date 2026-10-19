/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Templates as T
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import "private" as Private

KT.NavigationTabButton {
    id: control

    readonly property color _foregroundColor: Qt.alpha(Material.foreground, !enabled ? 0.38 : checked ? 1 : 0.8)
    readonly property bool _hasIcon: icon.name.length > 0 || icon.source.toString().length > 0

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    display: T.AbstractButton.TextUnderIcon
    hoverEnabled: true
    horizontalPadding: 0
    verticalPadding: Platform.Units.mediumSpacing
    spacing: Platform.Units.smallSpacing

    icon.width: Platform.Units.iconSizes.smallMedium
    icon.height: Platform.Units.iconSizes.smallMedium
    icon.color: _foregroundColor
    font.pixelSize: 12
    font.weight: Font.Medium

    background: Rectangle {
        implicitHeight: Platform.Units.largeSpacing * 8
        radius: height / 2
        color: control.display === T.AbstractButton.TextOnly && control.checked
            ? Qt.alpha(control.Material.accent, 0.16) : "transparent"
        border.width: control.display === T.AbstractButton.TextOnly && control.visualFocus ? 2 : 0
        border.color: control.Material.accent
    }

    contentItem: GridLayout {
        columns: control.display === T.AbstractButton.TextBesideIcon ? 2 : 1
        columnSpacing: Platform.Units.largeSpacing
        rowSpacing: control.spacing

        Item {
            id: iconContainer

            visible: control._hasIcon && control.display !== T.AbstractButton.TextOnly
            implicitWidth: Platform.Units.largeSpacing * 7
            implicitHeight: Math.max(Platform.Units.largeSpacing * 4, navigationIcon.implicitHeight)
            Layout.maximumWidth: implicitWidth
            Layout.alignment: Qt.AlignCenter

            Private.NavigationIndicator {
                id: activeIndicator
                objectName: "activeIndicator"

                anchors.fill: parent
                control: control
            }

            Primitives.Icon {
                id: navigationIcon

                anchors.centerIn: parent
                source: control.icon.name || control.icon.source
                implicitWidth: control.icon.width
                implicitHeight: control.icon.height
                color: control.icon.color
            }
        }

        Label {
            text: control.Primitives.MnemonicData.richTextLabel
            color: control._foregroundColor
            font: control.font
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: control.display === T.AbstractButton.TextBesideIcon ? Text.AlignLeft : Text.AlignHCenter
            visible: control.display !== T.AbstractButton.IconOnly
            elide: Text.ElideRight
            leftPadding: Platform.Units.smallSpacing
            rightPadding: Platform.Units.smallSpacing
            Layout.preferredHeight: Platform.Units.largeSpacing * 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            Accessible.ignored: true
        }
    }
}
