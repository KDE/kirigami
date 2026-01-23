// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.templates as KT
import "private" as P

KT.Chip {
    id: chip

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            implicitIndicatorWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight)

    checkable: chip.interactive && !closable
    hoverEnabled: chip.interactive
    down: chip.interactive && pressed

    property alias labelItem: label

    icon.width: Kirigami.Platform.iconSizes.small
    icon.height: Kirigami.Platform.iconSizes.small
    spacing: Kirigami.Platform.smallSpacing
    leftPadding: Kirigami.Platform.smallSpacing
        + ((!iconItem.visible && !mirrored) || (!indicator.visible && mirrored)
            ? Kirigami.Platform.smallSpacing : 0)
        + (indicator.visible && mirrored ? implicitIndicatorWidth : 0)
    rightPadding: Kirigami.Platform.smallSpacing
        + ((!iconItem.visible && mirrored) || (!indicator.visible && !mirrored)
            ? Kirigami.Platform.smallSpacing : 0)
        + (indicator.visible && !mirrored ? implicitIndicatorWidth : 0)

    indicator: QQC2.ToolButton {
        x: chip.mirrored ? 0 : parent.width - width
        y: Math.round((parent.height - height) / 2)
        visible: chip.closable
        text: qsTr("Remove")
        icon.name: "edit-delete-remove"
        icon.width: Kirigami.Platform.iconSizes.sizeForLabels
        icon.height: Kirigami.Platform.iconSizes.sizeForLabels
        display: QQC2.AbstractButton.IconOnly
        onClicked: chip.removed()
    }

    contentItem: RowLayout {
        spacing: chip.spacing

        Primitives.Icon {
            id: iconItem
            visible: valid && chip.display !== QQC2.AbstractButton.TextOnly
            implicitWidth: chip.icon.width
            implicitHeight: chip.icon.height
            color: chip.icon.color
            isMask: chip.iconMask
            source: chip.icon.name || chip.icon.source
        }
        QQC2.Label {
            id: label
            visible: text.length > 0 && chip.display !== QQC2.AbstractButton.IconOnly
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: chip.text
            color: Platform.Theme.textColor
            elide: Text.ElideRight
        }
    }

    background: P.DefaultChipBackground {}
}
