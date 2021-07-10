/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.17 as Kirigami

Kirigami.ScrollablePage {
    id: page

    default property alias data: layout.children

    ColumnLayout {
        Kirigami.FormLayout {
            id: layout
        }
    }
}
