/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KDialogs

/**
 * @brief Popup dialog that is used for short tasks and user interaction.
 *
 * Dialog consists of three components: the header, the content,
 * and the footer.
 *
 * By default, the header is a heading with text specified by the
 * `title` property.
 *
 * By default, the footer consists of a row of buttons specified by
 * the `standardButtons` and `customFooterActions` properties.
 *
 * @note The dialog footer is always a minimum height even when empty so that the
 *       dialog corners can be rounded. It is recommended to use DialogFooter as the
 *       base for any custom footer to retain this behavior, just replace the content.
 *       See DialogFooter documentation for an example.
 *
 * The `implicitHeight` and `implicitWidth` of the dialog contentItem is
 * the primary hint used for the dialog size. The dialog will be the
 * minimum size required for the header, footer and content unless
 * it is larger than `maximumHeight` and `maximumWidth`. Use
 * `preferredHeight` and `preferredWidth` in order to manually specify
 * a size for the dialog.
 *
 * If the content height exceeds the maximum height of the dialog, the
 * dialog's contents will become scrollable.
 *
 * If the contentItem is a <b>ListView</b>, the dialog will take care of the
 * necessary scrollbars and scrolling behaviour. Do <b>not</b> attempt
 * to nest ListViews (it must be the top level item), as the scrolling
 * behaviour will not be handled. Use ListView's `header` and `footer` instead.
 *
 * Example for a selection dialog:
 *
 * @code{.qml}
 * import QtQuick
 * import QtQuick.Layouts
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.Dialog {
 *     title: i18n("Dialog")
 *     padding: 0
 *     preferredWidth: Kirigami.Units.gridUnit * 16
 *
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     onAccepted: console.log("OK button pressed")
 *     onRejected: console.log("Rejected")
 *
 *     ColumnLayout {
 *         spacing: 0
 *         Repeater {
 *             model: 5
 *             delegate: QQC2.CheckDelegate {
 *                 topPadding: Kirigami.Units.smallSpacing * 2
 *                 bottomPadding: Kirigami.Units.smallSpacing * 2
 *                 Layout.fillWidth: true
 *                 text: modelData
 *             }
 *         }
 *     }
 * }
 * @endcode
 *
 * Example with scrolling (ListView scrolling behaviour is handled by the Dialog):
 *
 * @code{.qml}
 * import QtQuick
 * import QtQuick.Layouts
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.Dialog {
 *     id: scrollableDialog
 *     title: i18n("Select Number")
 *
 *     ListView {
 *         id: listView
 *         // hints for the dialog dimensions
 *         implicitWidth: Kirigami.Units.gridUnit * 16
 *         implicitHeight: Kirigami.Units.gridUnit * 16
 *
 *         model: 100
 *         delegate: QQC2.RadioDelegate {
 *             topPadding: Kirigami.Units.smallSpacing * 2
 *             bottomPadding: Kirigami.Units.smallSpacing * 2
 *             implicitWidth: listView.width
 *             text: modelData
 *         }
 *     }
 * }
 * @endcode
 *
 * There are also sub-components of the Dialog that target specific usecases,
 * and can reduce boilerplate code if used:
 *
 * @see PromptDialog
 * @see MenuDialog
 *
 * @inherit QtQuick.QtObject
 */
T.Dialog {
    id: root

    /**
     * @brief This property holds the dialog's contents; includes Items and QtObjects.
     * @property list<QtObject> dialogData
     */
    default property alias dialogData: contentControl.contentData

    /**
     * @brief This property holds the content items of the dialog.
     *
     * The initial height and width of the dialog is calculated from the
     * `implicitWidth` and `implicitHeight` of the content.
     *
     * @property list<Item> dialogChildren
     */
    property alias dialogChildren: contentControl.contentChildren

    /**
     * @brief This property sets the absolute maximum height the dialog can have.
     *
     * The height restriction is solely applied on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     *
     * This is the window height, subtracted by largeSpacing on both the top
     * and bottom.
     */
    readonly property real absoluteMaximumHeight: ((parent && parent.height) || Infinity) - Kirigami.Units.largeSpacing * 2

    /**
     * @brief This property holds the absolute maximum width the dialog can have.
     *
     * By default, it is the window width, subtracted by largeSpacing on both
     * the top and bottom.
     */
    readonly property real absoluteMaximumWidth: ((parent && parent.width) || Infinity) - Kirigami.Units.largeSpacing * 2

    readonly property real __borderWidth: 1

    /**
     * @brief This property holds the maximum height the dialog can have
     * (including the header and footer).
     *
     * The height restriction is solely enforced on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     *
     * By default, this is `absoluteMaximumHeight`.
     */
    property real maximumHeight: absoluteMaximumHeight

    /**
     * @brief This property holds the maximum width the dialog can have.
     *
     * By default, this is `absoluteMaximumWidth`.
     */
    property real maximumWidth: absoluteMaximumWidth

    /**
     * @brief This property holds the preferred height of the dialog.
     *
     * The content will receive a hint for how tall it should be to have
     * the dialog to be this height.
     *
     * If the content, header or footer require more space, then the height
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredHeight: -1

    /**
     * @brief This property holds the preferred width of the dialog.
     *
     * The content will receive a hint for how wide it should be to have
     * the dialog be this wide.
     *
     * If the content, header or footer require more space, then the width
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredWidth: -1

    /**
     * @brief This property sets whether to show the close button in the header.
     */
    property bool showCloseButton: true

    /**
     * @brief This property holds the custom actions displayed in the footer.
     *
     * Example usage:
     * @code{.qml}
     * import QtQuick
     * import org.kde.kirigami as Kirigami
     *
     * Kirigami.PromptDialog {
     *     id: dialog
     *     title: i18n("Confirm Playback")
     *     subtitle: i18n("Are you sure you want to play this song? It's really loud!")
     *
     *     standardButtons: Kirigami.Dialog.Cancel
     *     customFooterActions: [
     *         Kirigami.Action {
     *             text: i18n("Play")
     *             icon.name: "media-playback-start"
     *             onTriggered: {
     *                 //...
     *                 dialog.close();
     *             }
     *         }
     *     ]
     * }
     * @endcode
     *
     * @see org::kde::kirigami::Action
     */
    property list<T.Action> customFooterActions

    // DialogButtonBox should NOT contain invisible buttons, because in Qt 6
    // ListView preserves space even for invisible items.
    readonly property list<T.Action> __visibleCustomFooterActions: customFooterActions
        .filter(action => !(action instanceof Kirigami.Action) || action?.visible)

    function standardButton(button): T.AbstractButton {
        // in case a footer is redefined
        if (footer.standardButton && typeof footer.standardButton === "function") {
            return footer.standardButton(button);
        } else {
            return null;
        }
    }

    function customFooterButton(action: T.Action): T.AbstractButton {
        // in case a footer is redefined
        if (footer.customFooterButton && typeof footer.customFooterButton === "function") {
            return footer.customFooterButton(action);
        } else {
            return null;
        }
    }

    z: Kirigami.OverlayZStacking.z

    // calculate dimensions and in case footer is wider than content, use that
    implicitWidth: Math.max(implicitContentWidth, implicitFooterWidth, implicitHeaderWidth) + leftPadding + rightPadding // maximum width enforced from our content (one source of truth) to avoid binding loops
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
                    + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                    + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0);

    // misc. dialog settings
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnReleaseOutside
    modal: true
    clip: false
    padding: 0
    horizontalPadding: __borderWidth + padding

    // determine parent so that popup knows which window to popup in
    // we want to open the dialog in the center of the window, if possible
    Component.onCompleted: {
        if (typeof applicationWindow !== "undefined") {
            parent = applicationWindow().overlay;
        }
    }

    // center dialog
    x: parent ? Math.round(((parent && parent.width) - width) / 2) : 0
    y: parent ? Math.round(((parent && parent.height) - height) / 2) + Kirigami.Units.gridUnit * 2 * (1 - opacity) : 0 // move animation

    // dialog enter and exit transitions
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; easing.type: Easing.InOutQuad; duration: Kirigami.Units.longDuration }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; easing.type: Easing.InOutQuad; duration: Kirigami.Units.longDuration }
    }

    // black background, fades in and out
    QQC2.Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.3)

        // the opacity of the item is changed internally by QQuickPopup on open/close
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    // dialog view background
    background: Kirigami.ShadowedRectangle {
        id: rect
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.cornerRadius
        shadow {
            size: radius * 2
            color: Qt.rgba(0, 0, 0, 0.3)
            yOffset: 1
        }

        border {
            width: root.__borderWidth
            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast);
        }
    }

    // dialog content
    contentItem: QQC2.ScrollView {
        id: contentControl

        // ensure view colour scheme, and background color
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

        // height of everything else in the dialog other than the content
        property real otherHeights: (root.header?.height ?? 0) + (root.footer?.height ?? 0) + root.topPadding + root.bottomPadding;

        property real calculatedMaximumWidth: Math.min(root.absoluteMaximumWidth, root.maximumWidth) - root.leftPadding - root.rightPadding
        property real calculatedMaximumHeight: Math.min(root.absoluteMaximumHeight, root.maximumHeight) - root.topPadding - root.bottomPadding
        property real calculatedImplicitWidth: implicitContentWidth + leftPadding + rightPadding
        property real calculatedImplicitHeight: implicitContentHeight + topPadding + bottomPadding

        onContentItemChanged: {
            const contentFlickable = contentItem as Flickable;
            if (contentFlickable) {
                /*
                 Why this is necessary? A Flickable mainItem syncs its size with the contents only on startup,
                 and if the contents can change their size dinamically afterwards (wrapping text does that),
                 the contentsize will be wrong see BUG 477257.

                 We also don't do this declaratively but only we are sure a contentItem is declared/created as just
                 accessing the property would create an internal Flickable, making it impossible to assign custom
                 flickables/listviews to the Dialog.
                */
                contentFlickable.contentHeight = Qt.binding(() => calculatedImplicitHeight);

                contentFlickable.clip = true;
            }
        }

        // how do we deal with the scrollbar width?
        // - case 1: the dialog itself has the preferredWidth set
        //   -> we hint a width to the content so it shrinks to give space to the scrollbar
        // - case 2: preferredWidth not set, so we are using the content's implicit width
        //   -> we expand the dialog's width to accommodate the scrollbar width (to respect the content's desired width)

        // don't enforce preferred width and height if not set (-1), and expand to a larger implicit size
        property real preferredWidth: Math.max(root.preferredWidth, calculatedImplicitWidth)
        property real preferredHeight: Math.max(root.preferredHeight - otherHeights, calculatedImplicitHeight)

        property real maximumWidth: calculatedMaximumWidth
        property real maximumHeight: calculatedMaximumHeight - otherHeights // we enforce maximum height solely from the content

        implicitWidth: Math.min(preferredWidth, maximumWidth)
        implicitHeight: Math.min(preferredHeight, maximumHeight)

        // give an implied width and height to the contentItem so that features like word wrapping/eliding work
        // cannot placed directly in contentControl as a child, so we must use a property
        property var widthHint: Binding {
            target: contentControl.contentChildren[0] || null
            property: "width"
            value: contentControl.width + contentControl.leftPadding + contentControl.rightPadding
            restoreMode: Binding.RestoreBinding
        }
    }

    header: KDialogs.DialogHeader {
        dialog: root
        contentItem: KDialogs.DialogHeaderTopContent {
            dialog: root
        }
    }

    footer: KDialogs.DialogFooter {
        dialog: root
    }
}
