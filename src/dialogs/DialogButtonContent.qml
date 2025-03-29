/*
 SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
 SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC2

/**
 * @brief Default button footer content for a Kirigami.Dialog.
 *
 * This provides both the standard and custom buttons for the given Kirigami.Dialog
 * item.
 *
 * This exists as a separate content item so that it can be used as part of a custom
 * footer if desired, see below:
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
 *         contentItem: RowLayout {
 *             CustomItem {...}
 *             DialogFooterButtonContent {
 *                 dialog: myDialog
 *             }
 *         }
 *     }
 *     [...]
 * }
 * @endcode
 *
 * @inherit T.Control
 */
QQC2.DialogButtonBox {
    id: root

    /**
     * @brief This property points to the parent dialog, some of whose properties
     * need to be available here.
     * @property T.Dialog dialog
     */
    required property T.Dialog dialog

    /**
     * @brief This property sets whether the footer button style should be flat.
     */
    property bool flatButtons: false

    function customFooterButton(action: T.Action): T.AbstractButton {
        if (!action) {
            // Even if there's a null object in the list of actions, we should
            // not return a button for it.
            return null;
        }
        const index = customFooterButtons.model.indexOf(action);
        if (index < 0) {
            return null;
        }
        return customFooterButtons.itemAt(index) as T.AbstractButton;
    }

    standardButtons: root.dialog.standardButtons
    visible: count > 0
    padding: 0

    position: QQC2.DialogButtonBox.Footer

    // Required so that the standardButtons follow the flatButtons property.
    delegate: QQC2.Button {
        flat: root.flatButtons
    }
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
            flat: root.flatButtons
            action: modelData
        }
    }
}
