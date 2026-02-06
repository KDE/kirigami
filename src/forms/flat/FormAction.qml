/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami.forms.private.templates as FT

FT.FormAction {
    id: root

    triggerIcon.name: ""

    contentItem: QQC.Button {
        icon {
            name: root.action.icon.name
            source: root.action.icon.source
            color: root.action.icon.color
            width: root.action.icon.width
            height: root.action.icon.height
        }
        text: root.action.text
        onClicked: {
            root.clicked();
            root.action.trigger();
        }
    }
}
