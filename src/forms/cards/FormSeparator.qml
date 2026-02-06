/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.forms.private.templates as FT

FT.FormSeparator {
    id: root

    Layout.fillWidth: true

    implicitWidth: separator.implicitWidth
    implicitHeight: separator.implicitHeight

    Primitives.Separator {
        id: separator
        opacity: 0.5
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Platform.Units.largeSpacing
            rightMargin: Platform.Units.largeSpacing
        }
    }
}
