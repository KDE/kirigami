/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "templates" as T
import "private" as P

T.AbstractCard {
    id: root

    background: P.DefaultCardBackground {
        clickFeedback: root.showClickFeedback
        hoverFeedback: root.hoverEnabled
    }
}
