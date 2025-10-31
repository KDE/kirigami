/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami


/*!
    \qmltype FormGroup
    \inqmlmodule org.kde.kirigami.forms

    \brief A group of items in a form.

    In a Form, items are gruped semantically in categories represented
    by the FormGroup Item, which can have a title and is a container
    of FormEntry items, each one representing a single configuration
    option or entry field.

    It has to be exclusively used as a child of a Form item, as
    it semantically represents a category within a Form.

    \sa FormEntry
 */
Item {
    id: root

    /*!
        A title for this FormGroup. If set the title will be presented to the user
        above the group contents.
     */
    property string title

    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Layout.fillWidth: true

    Kirigami.HeaderFooterLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
        // TODO: HeaderFooterLayout needs headerMargin/footerMargin

        header: Kirigami.Heading {
            level: 5
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: Kirigami.AbstractCard {
            padding: 0
            contentItem: ColumnLayout {
                id: innerLayout
                spacing: 0
            }
        }
    }
}
