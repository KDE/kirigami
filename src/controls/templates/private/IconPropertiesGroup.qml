/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml

QtObject {
    property string name

    property var source

    property color color: Qt.rgba(0, 0, 0, 0)

    property real width

    property real height

    function fromControlsIcon(icon) {
        name = Qt.binding(() => icon.name)
        source = Qt.binding(() => icon.source)
        color = Qt.binding(() => icon.color)
        width = Qt.binding(() => icon.width)
        height = Qt.binding(() => icon.height)
        return this
    }
}
