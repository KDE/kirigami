/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

/**
 * A settings page action that is ready to integrate in a kirigami app.
 *
 * Allows to have an action that requires a component field, which will
 * be the page sent to the categorized settings page component.
 *
 *
 * @since 5.84
 * @since org.kde.kirigami 2.17
 *
 * @see CategorizedSettingsPage
 */
Kirigami.Action {
    required property string page

    onTriggered: stack.push(page)
}
