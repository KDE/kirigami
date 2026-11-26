/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.forms.private.templates as FT
import org.kde.kirigami.controls as KC

FT.GridFormGroup {
    id: root

    background: Item {
        Repeater {
            model: root.visibleChildren
            delegate: KC.AbstractCard {
                x: modelData.x
                y: modelData.y
                width: modelData.width
                height: modelData.height
            }
        }
    }
}
