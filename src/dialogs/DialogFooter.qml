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
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KDialogs

/**
 * @brief Base for a footer, to be used as the footer: item of a Dialog.
 *
 * Provides appropriate padding and a top separator when the dialog's content
 * is scrollable.
 *
 * @note This item provides a minimum height even when empty so that the dialog
 *       corners can be rounded.
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

    function standardButton(button): T.AbstractButton {
        // in case a footer is redefined
        if (contentItem.standardButton && typeof contentItem.standardButton === "function") {
            return contentItem.standardButton(button);
        } else {
            return null;
        }
    }

    function customFooterButton(action: T.Action): T.AbstractButton {
        // in case a footer is redefined
        if (contentItem.customFooterButton && typeof contentItem.customFooterButton === "function") {
            return contentItem.customFooterButton(action);
        } else {
            return null;
        }
    }

    readonly property bool bufferMode: !footerButtonContent.visible || contentItem == null || contentItem.implicitHeight < Kirigami.Units.smallSpacing / 2
    implicitHeight: bufferMode ? Math.round(Kirigami.Units.smallSpacing / 2) : implicitContentHeight + topPadding + bottomPadding
    padding: !bufferMode ? Kirigami.Units.largeSpacing : 0

    contentItem: KDialogs.DialogFooterButtonContent {
        id: footerButtonContent
        dialog: root.dialog
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
