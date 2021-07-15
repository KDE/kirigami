/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.11 as Kirigami

/**
 * A action for creating setting actions, it requires a
 * page to send to the CategorizedSettings components.
 *
 * @since 5.85
 * @since org.kde.kirigami 2.11
 *
 * @see CategorizedSettings
 */
Kirigami.PagePoolAction {
    required property var page
    checkable: false

    onTriggered: stack.push(page)
}
