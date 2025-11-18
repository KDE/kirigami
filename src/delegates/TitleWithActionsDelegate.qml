/*
 * SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 * SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    /*!
     * List of actions to show as icons-only buttons.
     */
    property list<T.Action> actions

    /*!
        The title to display.
     */
    required property string title

    /*!
        The subtitle to display.
     */
    property string subtitle

    /*!
        Should this item be displayed in a selected style?
     */
    property bool selected

    /*!
        The text elision mode used for both the title and subtitle.
     */
    property var elide: Text.ElideRight

    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.fill: root

        Kirigami.TitleSubtitle {
            Layout.alignment: Qt.AlignLeft
            title: root.title
            subtitle: root.subtitle
            elide: root.elide
            selected: root.selected
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            Repeater {
                model: root.actions

                delegate: QQC2.Button {
                    Layout.alignment: Qt.AlignRight
                    required property T.Action modelData
                    action: modelData
                    display: QQC2.Button.IconOnly
                }
            }
        }
    }
}
