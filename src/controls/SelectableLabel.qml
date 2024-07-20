/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2

/**
 * @brief This is a label which supports text selection.
 *
 * You can use all elements of the QML TextArea component, in particular
 * the "text" property to define the label text.
 *
 * Example usage:
 * @code{.qml}
 *     Kirigami.SelectableLabel {
 *         text: "Label"
 *     }
 * @endcode
 *
 * \sa https://bugreports.qt.io/browse/QTBUG-14077
 * @since 5.95
 * @since org.kde.kirigami 2.20
 * @inherit QtQuick.Controls.TextArea
 */
QQC2.TextArea {
    id: root

    /**
     * @brief This property holds the cursor shape that will appear whenever
     * the mouse is hovering over the label.
     *
     * default: @c Qt.IBeamCursor
     *
     * @property Qt::CursorShape cursorShape
     */
    property alias cursorShape: hoverHandler.cursorShape

    padding: 0
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined

    activeFocusOnTab: false
    readOnly: true
    wrapMode: TextEdit.WordWrap
    textFormat: TextEdit.AutoText
    verticalAlignment: TextEdit.AlignTop

    Accessible.selectableText: true
    Accessible.editable: false

    background: Item {}

    HoverHandler {
        id: hoverHandler
        // By default HoverHandler accepts the left button while it shouldn't accept anything,
        // causing https://bugreports.qt.io/browse/QTBUG-106489.
        // Qt.NoButton unfortunately is not a valid value for acceptedButtons.
        // Disabling masks the problem, but
        // there is no proper workaround other than an upstream fix
        // See qqc2-desktop-style Label.qml
        enabled: false
        cursorShape: root.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
    }
}
