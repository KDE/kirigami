/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.layouts as KL
import org.kde.kirigami.templates as KT

KT.SegmentedControl {
    id: root

    Component {
        id: buttonDelegate
        QQC.Button {
            action: parent.modelData
            display: action.displayHint & KL.DisplayHint.IconOnly ? QQC.AbstractButton.IconOnly : QQC.AbstractButton.TextBesideIcon
        }
    }

    contentItem: RowLayout {
        spacing: Platform.Units.smallSpacing
        Repeater {
            model: root.actions
            delegate: Loader {
                Layout.minimumWidth: item.Layout.minimumWidth
                Layout.preferredWidth: item.Layout.preferredWidth
                Layout.maximumWidth: item.Layout.maximumWidth
                Layout.fillWidth: item.Layout.fillWidth
                required property var modelData
                sourceComponent: modelData?.displayComponent ?? buttonDelegate
            }
        }
    }
}
