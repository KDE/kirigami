/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import "../../templates/private" as Private

Private.GlobalDrawerActionItem {
    id: listItem

    contentItem: RowLayout {
        spacing: Platform.Units.largeSpacing

        Primitives.Icon {
            id: iconItem
            color: listItem.tAction.icon.color
            source: listItem.tAction.icon.name || listItem.tAction.icon.source

            readonly property int size: Platform.Units.iconSizes.smallMedium
            Layout.minimumHeight: size
            Layout.maximumHeight: size
            Layout.minimumWidth: size
            Layout.maximumWidth: size

            selected: (listItem.highlighted || listItem.checked || listItem.down)
            visible: source !== undefined && !listItem.isSeparator
        }

        QQC2.Label {
            id: labelItem
            visible: !listItem.isSeparator
            text: width > height * 2 ? listItem.Primitives.MnemonicData.richTextLabel : ""
            Accessible.name: listItem.Primitives.MnemonicData.plainTextLabel
            Layout.preferredWidth: metrics.width
            Layout.preferredHeight: metrics.height
            Layout.minimumWidth: 0
            // Work around Qt bug where left aligned text is not right aligned
            // in RTL mode unless horizontalAlignment is explicitly set.
            // https://bugreports.qt.io/browse/QTBUG-95873
            horizontalAlignment: Text.AlignLeft

            Layout.fillWidth: true
            color: (listItem.highlighted || listItem.checked || listItem.down) ? Platform.Theme.highlightedTextColor : Platform.Theme.textColor
            elide: Text.ElideRight
            font: listItem.font
            opacity: {
                if (listItem.drawerCollapsed) {
                    return 0;
                } else if (!listItem.enabled) {
                    return 0.75;
                } else {
                    return 1.0;
                }
            }
            TextMetrics {
                id: metrics
                text: listItem.Primitives.MnemonicData.mnemonicLabel
                font: labelItem.font
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: Platform.Units.longDuration/2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Primitives.Separator {
            id: separatorAction

            visible: listItem.isSeparator
            Layout.fillWidth: true
        }

        Primitives.Icon {
            isMask: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: !listItem.drawerCollapsed ? 0 : -width
            Layout.preferredHeight: !listItem.drawerCollapsed ? Platform.Units.iconSizes.small : Platform.Units.iconSizes.small/2
            opacity: 0.75
            selected: listItem.checked || listItem.down
            Layout.preferredWidth: Layout.preferredHeight
            source: listItem.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
            visible: (!listItem.isExpandable || listItem.drawerCollapsed) && !listItem.isSeparator && listItem.hasChildren
        }
    }

}
