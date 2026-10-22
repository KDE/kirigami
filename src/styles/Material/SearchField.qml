/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Material
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform

KT.SearchField {
    id: control

    Material.background: undefined
    Material.containerStyle: Material.Filled

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: Platform.Units.largeSpacing * 2
    bottomPadding: padding
    leftPadding: padding + (LayoutMirroring.enabled ? _rightActionsRow.width : _searchIcon.width + padding)
    rightPadding: padding + (LayoutMirroring.enabled ? _searchIcon.width + padding : _rightActionsRow.width)

    // HACK to hide the floating placeholder text
    placeholderTextColor: "transparent"
    topPadding: padding
    topInset: 0

    Text {
        x: control.leftPadding
        y: control.topPadding
        width: Math.max(0, control.width - control.leftPadding - control.rightPadding)
        height: Math.max(0, control.height - control.topPadding - control.bottomPadding)
        visible: control.length === 0 && control.preeditText.length === 0
        text: control.placeholderText
        font: control.font
        color: control.Material.hintTextColor
        horizontalAlignment: control.effectiveHorizontalAlignment
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        renderType: control.renderType
        Accessible.ignored: true
    }

    _searchIcon.anchors.leftMargin: control.padding
    _searchIcon.implicitWidth: Platform.Units.iconSizes.smallMedium
    _searchIcon.implicitHeight: Platform.Units.iconSizes.smallMedium
    _searchIcon.color: Qt.alpha(control.Material.foreground, control.enabled ? 0.8 : 0.38)
    _actionIconSize: _searchIcon.implicitWidth

    background: Rectangle {
        implicitWidth: Platform.Units.gridUnit * 20
        implicitHeight: Platform.Units.largeSpacing * 7
        radius: height / 2
        color: Qt.tint(control.Material.backgroundColor, Qt.alpha(control.Material.primary, 0.08))

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.alpha(control.Material.foreground, !control.enabled ? 0 : control.activeFocus ? 0.08 : control.hovered ? 0.04 : 0)

            Behavior on color {
                ColorAnimation { duration: Platform.Units.shortDuration }
            }
        }
    }
}
