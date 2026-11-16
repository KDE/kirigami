/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami.templates as KT

KT.SegmentedControl {
    id: root

    contentItem: RowLayout {
        Repeater {
            model: root.actions
            delegate: QQC.Button {
                action: modelData
            }
        }
    }
}
