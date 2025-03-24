/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import QtQuick.Layouts
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
 * The `implicitHeight` and `implicitWidth` of the dialog contentItem is
 * the primary hint used for the dialog size. The dialog will be the
 * minimum size required for the header, footer and content unless
 * it is larger than the parent object at which point it will be limited to the
 * size of the parent with padding.
 *
 * If the content height of the dialog's contents is likely to exceed the parent
 * size the content should be placed within a <b>ScrollView</b>. The user needs
 * to manage this.
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
     * @brief This property holds the component to the left of the footer buttons.
     */
    property Component footerLeadingComponent

    /**
     * @brief his property holds the component to the right of the footer buttons.
     */
    property Component footerTrailingComponent

    /**
     * @brief This property sets whether to show the close button in the header.
     */
    property bool showCloseButton: true

    /**
     * @brief This property sets whether the footer button style should be flat.
     */
    property bool flatFooterButtons: false

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
        if (footer instanceof T.DialogButtonBox) {
            return footer.standardButton(button);
        } else if (footer === footerToolBar) {
            return dialogButtonBox.standardButton(button);
        } else {
            return null;
        }
    }

    function customFooterButton(action: T.Action): T.AbstractButton {
        if (!action) {
            // Even if there's a null object in the list of actions, we should
            // not return a button for it.
            return null;
        }
        const index = __visibleCustomFooterActions.indexOf(action);
        if (index < 0) {
            return null;
        }
        return customFooterButtons.itemAt(index) as T.AbstractButton;
    }

    z: Kirigami.OverlayZStacking.z

    // calculate dimensions and in case footer is wider than content, use that
    implicitWidth: Math.max(implicitContentWidth, implicitFooterWidth, implicitHeaderWidth) + leftPadding + rightPadding // maximum width enforced from our content (one source of truth) to avoid binding loops
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
                    + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                    + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0);

    width: Math.min(_private.absoluteMaximumWidth, implicitWidth)
    height: Math.min(_private.absoluteMaximumHeight, implicitHeight)

    // misc. dialog settings
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnReleaseOutside
    modal: true
    clip: false
    padding: 0
    horizontalPadding: _private.borderWidth + padding

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
            width: _private.borderWidth
            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast);
        }
    }

    header: KDialogs.DialogHeader {
        dialog: root
    }

    // use top level control rather than toolbar, since toolbar causes button rendering glitches
    footer: T.Control {
        id: footerToolBar

        // if there is nothing in the footer, still maintain a height so that we can create a rounded bottom buffer for the dialog
        property bool bufferMode: !root.footerLeadingComponent && !dialogButtonBox.visible
        implicitHeight: bufferMode ? Math.round(Kirigami.Units.smallSpacing / 2) : implicitContentHeight + topPadding + bottomPadding
        implicitWidth: footerLayout.implicitWidth + leftPadding + rightPadding

        padding: !bufferMode ? Kirigami.Units.largeSpacing : 0

        contentItem: RowLayout {
            id: footerLayout
            spacing: footerToolBar.spacing
            // Don't let user interact with footer during transitions
            enabled: root.opened

            Loader {
                id: leadingLoader
                sourceComponent: root.footerLeadingComponent
            }

            // footer buttons
            QQC2.DialogButtonBox {
                // we don't explicitly set padding, to let the style choose the padding
                id: dialogButtonBox
                standardButtons: root.standardButtons
                visible: count > 0
                padding: 0

                Layout.fillWidth: true
                Layout.alignment: dialogButtonBox.alignment

                position: QQC2.DialogButtonBox.Footer

                // ensure themes don't add a background, since it can lead to visual inconsistencies
                // with the rest of the dialog
                background: null

                // we need to hook all of the buttonbox events to the dialog events
                onAccepted: root.accept()
                onRejected: root.reject()
                onApplied: root.applied()
                onDiscarded: root.discarded()
                onHelpRequested: root.helpRequested()
                onReset: root.reset()

                // add custom footer buttons
                Repeater {
                    id: customFooterButtons
                    model: root.__visibleCustomFooterActions
                    // we have to use Button instead of ToolButton, because ToolButton has no visual distinction when disabled
                    delegate: QQC2.Button {
                        required property T.Action modelData

                        flat: root.flatFooterButtons
                        action: modelData
                    }
                }
            }

            Loader {
                id: trailingLoader
                sourceComponent: root.footerTrailingComponent
            }
        }

        background: Item {
            Kirigami.Separator {
                id: footerSeparator
                visible: if (root.contentItem instanceof T.Pane || root.contentItem instanceof Flickable) {
                    return root.contentItem.contentHeight > root.implicitContentHeight;
                } else {
                    return false;
                }
                width: parent.width
                anchors.top: parent.top
            }
        }
    }

    QtObject {
        id: _private

        readonly property real absoluteMaximumHeight: ((root,parent && root.parent.height) || Infinity) - Kirigami.Units.largeSpacing * 2

        readonly property real absoluteMaximumWidth: ((root.parent && root.parent.width) || Infinity) - Kirigami.Units.largeSpacing * 2

        readonly property real borderWidth: 1
    }
}
