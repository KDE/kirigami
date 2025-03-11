/*
 SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/**
 * @brief Standard top content for a Dialog, including header text and an
 * optional close button.
 *
 * Provides appropriate padding and a bottom separator when the dialog's content
 * is scrollable.
 *
 * Chiefly useful as the first item in a `ColumnLayout` inside a custom header,
 * for when you want a custom header that only consists of extra content, and
 * does not need to override the standard content. Example usage for a this:
 *
 * @code{.qml}
 * import QtQuick
 * import QtQuick.Layouts
 * import org.kde.kirigami as Kirigami
 * import org.kde.kirigami.dialogs as KDialogs
 *
 * Kirigami.Dialog {
 *     id: myDialog
 *
 *     title: i18n("My Dialog")
 *
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     header: KDialogs.DialogHeader {
 *         dialog: myDialog
 *
 *         contentItem: ColumnLayout {
 *             Spacing: Kirigami.Units.smallSpacing
 *
 *             KDialogs.DialogHeaderTopContent {
 *                 dialog: myDialog
 *             }
 *
 *             [...]
 *         }
 *     }
 *     [...]
 * }
 * @endcode
 * @inherit T.Control
 */
RowLayout {
    id: root

    /**
     * @brief This property points to the parent dialog, some of whose properties
     * need to be available here.
     * @property T.Dialog dialog
     */
    required property T.Dialog dialog

    spacing: Kirigami.Units.smallSpacing

    Kirigami.Heading {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        text: root.dialog.title.length === 0 ? " " : root.dialog.title // always have text to ensure header height
        elide: Text.ElideRight

        // use tooltip for long text that is elided
        QQC2.ToolTip.visible: truncated && titleHoverHandler.hovered
        QQC2.ToolTip.text: root.dialog.title

        HoverHandler {
            id: titleHoverHandler
        }
    }

    QQC2.ToolButton {
        // We want to position the close button in the top-right
        // corner if the header is very tall, but we want to
        // vertically center it in a short header
        readonly property bool tallHeader: root.dialog.implicitHeaderHeight > (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing * 2)
        Layout.alignment: tallHeader ? Qt.AlignRight | Qt.AlignTop : Qt.AlignRight | Qt.AlignVCenter
        Layout.topMargin: tallHeader ? Kirigami.Units.largeSpacing : 0

        icon.name: hovered ? "window-close" : "window-close-symbolic"
        text: qsTr("Close", "@action:button close dialog")
        display: QQC2.AbstractButton.IconOnly
        visible: root.dialog.showCloseButton

        onClicked: root.dialog.reject()
    }
}
