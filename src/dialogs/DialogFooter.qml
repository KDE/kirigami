/*
 SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
 SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KDialogs

/**
 * @brief Base for a footer, to be used as the footer: item of a Dialog.
 *
 * Provides appropriate padding and a top separator when the dialog's content
 * is scrollable.
 *
 * Chiefly useful as the base element of a custom footer. Example usage for this:
 *
 * @code{.qml}
 * import QtQuick
 * import org.kde.kirigami as Kirigami
 * import org.kde.kirigami.dialogs as KD
 *
 * Kirigami.Dialog {
 *     id: myDialog
 *
 *     title: i18n("My Dialog")
 *
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     footer: KDialogs.DialogFooter {
 *         dialog: myDialog
 *         contentItem: CustomFooterContentItem {...}
 *     }
 *     [...]
 * }
 * @endcode
 *
 * @note This item provides a minimum height even when empty so that the dialog
 *       corners can be rounded.
 *
 * @inherit T.Control
 */
T.Control {
    id: root

    /**
     * @brief This property points to the parent dialog, some of whose properties
     * need to be available here.
     * @property T.Dialog dialog
     */
    required property T.Dialog dialog

    // if there is nothing in the footer, still maintain a height so that we can create a rounded bottom buffer for the dialog
    property bool bufferMode: !dialogButtonBox.visible
    implicitHeight: bufferMode ? Math.round(Kirigami.Units.smallSpacing / 2) : implicitContentHeight + topPadding + bottomPadding
    implicitWidth: footerLayout.implicitWidth + leftPadding + rightPadding

    padding: !bufferMode ? Kirigami.Units.largeSpacing : 0

    contentItem: QQC2.DialogButtonBox {
        id: dialogButtonBox
        standardButtons: root.dialog.standardButtons
        visible: count > 0
        padding: 0

        position: QQC2.DialogButtonBox.Footer

        // ensure themes don't add a background, since it can lead to visual inconsistencies
        // with the rest of the dialog
        background: null

        // we need to hook all of the buttonbox events to the dialog events
        onAccepted: root.dialog.accept()
        onRejected: root.dialog.reject()
        onApplied: root.dialog.applied()
        onDiscarded: root.dialog.discarded()
        onHelpRequested: root.dialog.helpRequested()
        onReset: root.dialog.reset()

        // add custom footer buttons
        Repeater {
            id: customFooterButtons
            model: root.dialog.__visibleCustomFooterActions
            // we have to use Button instead of ToolButton, because ToolButton has no visual distinction when disabled
            delegate: QQC2.Button {
                required property T.Action modelData
                action: modelData
            }
        }
    }

    background: Item {
        Kirigami.Separator {
            id: footerSeparator
            visible: if (root.dialog.contentItem instanceof T.Pane || root.dialog.contentItem instanceof Flickable) {
                return root.dialog.contentItem.contentHeight > root.dialog.implicitContentHeight;
            } else {
                return false;
            }
            width: parent.width
            anchors.top: parent.top
        }
    }
}
