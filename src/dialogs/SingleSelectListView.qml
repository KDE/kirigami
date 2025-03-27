/*
 SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
 SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

/**
 * @brief ContentItem for a list of selectable items.
 *
 * @inherit T.Control
 */
QQC2.ScrollView {
    id: root

    property alias model: itemRepeater.model

    signal clicked(int index)

    ColumnLayout {
        Repeater {
            id: itemRepeater

            delegate: QQC2.ItemDelegate {
                id: itemDelegate
                required property int index
                required property var model

                Layout.fillWidth: true

                text: model.display
                icon.name: model?.decoration ?? ""

                onClicked: root.clicked(itemDelegate.index)
            }
        }
    }
}
