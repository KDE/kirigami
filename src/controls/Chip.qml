// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "templates" as KT
import "private" as P

KT.Chip {
    id: chip

    implicitWidth: layout.implicitWidth
    implicitHeight: toolButton.implicitHeight

    checkable: !closable

    property alias labelItem: label

    contentItem: RowLayout {
        id: layout
        spacing: 0

        Kirigami.Icon {
            id: icon
            visible: icon.valid
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            Layout.leftMargin: Kirigami.Units.smallSpacing
            color: chip.icon.color
            isMask: chip.iconMask
            source: chip.icon.name || chip.icon.source
        }
        QQC2.Label {
            id: label
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 1.5
            Layout.leftMargin: icon.visible ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            Layout.rightMargin: chip.closable ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: chip.text
            color: Kirigami.Theme.textColor
            elide: Text.ElideRight
        }
        QQC2.ToolButton {
            id: toolButton
            visible: chip.closable
            text: qsTr("Remove Tag")
            icon.name: "edit-delete-remove"
            icon.width: Kirigami.Units.iconSizes.sizeForLabels
            icon.height: Kirigami.Units.iconSizes.sizeForLabels
            display: QQC2.AbstractButton.IconOnly
            onClicked: chip.removed()
        }
    }

    background: P.DefaultChipBackground {}
}
