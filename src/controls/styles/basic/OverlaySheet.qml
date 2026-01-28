/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.kirigami.platform as Platform
import "private" as P
import org.kde.kirigami.templates as T

T.OverlaySheet {
    id: root

    background: P.DefaultCardBackground {
        Platform.Theme.colorSet: root.Platform.Theme.colorSet
        Platform.Theme.inherit: false
    }
}
