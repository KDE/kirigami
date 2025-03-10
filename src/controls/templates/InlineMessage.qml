/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates.private as TP

/**
 * An inline message item with support for informational, positive,
 * warning and error types, and with support for associated actions.
 *
 * InlineMessage can be used to give information to the user or
 * interact with the user, without requiring the use of a dialog.
 *
 * The InlineMessage item is hidden by default. It also manages its
 * height (and implicitHeight) during an animated reveal when shown.
 * You should avoid setting height on an InlineMessage unless it is
 * already visible.
 *
 * Optionally an icon can be set, defaulting to an icon appropriate
 * to the message type otherwise.
 *
 * Optionally a close button can be shown.
 *
 * Actions are added from left to right. If more actions are set than
 * can fit, an overflow menu is provided.
 *
 * Example:
 * @code
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.InlineMessage {
 *     type: Kirigami.MessageType.Error
 *
 *     text: i18n("My error message")
 *
 *     actions: [
 *         Kirigami.Action {
 *             icon.name: "list-add"
 *             text: i18n("Add")
 *             onTriggered: source => {
 *                 // do stuff
 *             }
 *         },
 *         Kirigami.Action {
 *             icon.name: "edit"
 *             text: i18n("Edit")
 *             onTriggered: source => {
 *                 // do stuff
 *             }
 *         }
 *     ]
 * }
 * @endcode
 *
 * @since 5.45
 * @inherit QtQuick.Templates.Control
 */
T.Control {
    id: root

    visible: false

    /**
     * Defines a position for the message: whether it's to be used as an inline component inside the page,
     * a page header, or a page footer.
     */
    enum Position {
        Inline,
        Header,
        Footer
    }

    /**
     * Adjust the look of the message based upon the position.
     * If a message is positioned in the header area or in the footer area
     * of a page, it might be desirable to not have borders but just a line
     * separating it from the content area. In this case, use the Header or
     * Footer position.
     * Default is InlineMessage.Position.Inline
     */
    property int position: InlineMessage.Position.Inline

    /**
     * This signal is emitted when a link is hovered in the message text.
     * @param The hovered link.
     */
    signal linkHovered(string link)

    /**
     * This signal is emitted when a link is clicked or tapped in the message text.
     * @param The clicked or tapped link.
     */
    signal linkActivated(string link)

    /**
     * This property holds the link embedded in the message text that the user is hovering over.
     */
    readonly property alias hoveredLink: label.hoveredLink

    /**
     * This property holds the message type. One of Information, Positive, Warning or Error.
     *
     * The default is Kirigami.MessageType.Information.
     */
    property int type: Kirigami.MessageType.Information

    /**
     * This grouped property holds the description of an optional icon.
     *
     * * source: The source of the icon, a freedesktop-compatible icon name is recommended.
     * * color: An optional tint color for the icon.
     *
     * If no custom icon is set, an icon appropriate to the message type
     * is shown.
     */
    property TP.IconPropertiesGroup icon: TP.IconPropertiesGroup {}

    /**
     * This property holds the message text.
     */
    property string text

    /**
     * This property holds whether the close button is displayed.
     *
     * The default is false.
     */
    property bool showCloseButton: false

    /**
     * This property holds the list of actions to show. Actions are added from left to
     * right. If more actions are set than can fit, an overflow menu is
     * provided.
     */
    property list<T.Action> actions

    /**
     * This property holds whether the current message item is animating.
     */
    readonly property bool animating: _animating

    property bool _animating: false

    implicitHeight: visible ? (contentLayout.implicitHeight + topPadding + bottomPadding) : 0

    padding: Kirigami.Units.smallSpacing

    Accessible.role: Accessible.AlertMessage
    Accessible.ignored: !visible

    Behavior on implicitHeight {
        enabled: !root.visible

        SequentialAnimation {
            PropertyAction { targets: root; property: "_animating"; value: true }
            NumberAnimation { duration: Kirigami.Units.longDuration }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            contentLayout.opacity = 0;
        }
    }

    opacity: visible ? 1 : 0

    Behavior on opacity {
        enabled: !root.visible

        NumberAnimation { duration: Kirigami.Units.shortDuration }
    }

    onOpacityChanged: {
        if (opacity === 0) {
            contentLayout.opacity = 0;
        } else if (opacity === 1) {
            contentLayout.opacity = 1;
        }
    }

    onImplicitHeightChanged: {
        height = implicitHeight;
    }

    contentItem: Item {
        id: contentLayout

        // Used to defer opacity animation until we know if InlineMessage was
        // initialized visible.
        property bool complete: false

        Behavior on opacity {
            enabled: root.visible && contentLayout.complete

            SequentialAnimation {
                NumberAnimation { duration: Kirigami.Units.shortDuration * 2 }
                PropertyAction { targets: root; property: "_animating"; value: false }
            }
        }

        implicitHeight: {
            if (atBottom) {
                return label.implicitHeight + actionsLayout.implicitHeight + actionsLayout.anchors.topMargin
            } else {
                return Math.max(icon.implicitHeight, label.implicitHeight, closeButton.implicitHeight, actionsLayout.implicitHeight)
            }
        }

        Accessible.ignored: true

        readonly property real remainingWidth: width - (
            icon.width
            + label.anchors.leftMargin + label.implicitWidth + label.anchors.rightMargin
            + (root.showCloseButton ? closeButton.width : 0)
        )
        readonly property bool multiline: remainingWidth <= 0 || atBottom

        readonly property bool atBottom: (root.actions.length > 0) && (label.lineCount > 1 || actionsLayout.implicitWidth > remainingWidth)

        Kirigami.Icon {
            id: icon

            width: Kirigami.Units.iconSizes.smallMedium
            height: Kirigami.Units.iconSizes.smallMedium

            anchors {
                left: parent.left
                leftMargin: Kirigami.Units.smallSpacing
                topMargin: Kirigami.Units.smallSpacing
            }

            states: [
                State {
                    name: "multi-line"
                    when: contentLayout.atBottom || label.height > icon.height * 1.7
                    AnchorChanges {
                        target: icon
                        anchors.top: icon.parent.top
                        anchors.verticalCenter: undefined
                    }
                },
                // States are evaluated in the order they are declared.
                // This is a fallback state.
                State {
                    name: "single-line"
                    when: true
                    AnchorChanges {
                        target: icon
                        anchors.top: undefined
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            ]

            source: {
                if (root.icon.name) {
                    return root.icon.name;
                } else if (root.icon.source) {
                    return root.icon.source;
                }

                switch (root.type) {
                case Kirigami.MessageType.Positive:
                    return "emblem-success";
                case Kirigami.MessageType.Warning:
                    return "emblem-warning";
                case Kirigami.MessageType.Error:
                    return "emblem-error";
                default:
                    return "emblem-information";
                }
            }

            color: root.icon.color

            Accessible.ignored: !root.visible
            Accessible.name: {
                switch (root.type) {
                case Kirigami.MessageType.Positive:
                    return qsTr("Success");
                case Kirigami.MessageType.Warning:
                    return qsTr("Warning");
                case Kirigami.MessageType.Error:
                    return qsTr("Error");
                default:
                    return qsTr("Note");
                }
             }
        }

        Kirigami.SelectableLabel {
            id: label

            anchors {
                left: icon.right
                leftMargin: Kirigami.Units.largeSpacing
                right: root.showCloseButton ? closeButton.left : parent.right
                rightMargin: root.showCloseButton ? Kirigami.Units.smallSpacing : 0
                top: parent.top
            }

            color: Kirigami.Theme.textColor
            wrapMode: Text.WordWrap

            text: root.text

            verticalAlignment: Text.AlignVCenter

            // QTBUG-117667 TextEdit (super-type of SelectableLabel) needs
            // very specific state-management trick so it doesn't get stuck.
            // State names serve purely as a description.
            states: [
                State {
                    name: "multi-line"
                    when: contentLayout.multiline
                    AnchorChanges {
                        target: label
                        anchors.bottom: undefined
                    }
                    PropertyChanges {
                        target: label
                        height: label.implicitHeight
                    }
                },
                // States are evaluated in the order they are declared.
                // This is a fallback state.
                State {
                    name: "single-line"
                    when: true
                    AnchorChanges {
                        target: label
                        anchors.bottom: label.parent.bottom
                    }
                }
            ]

            onLinkHovered: link => root.linkHovered(link)
            onLinkActivated: link => root.linkActivated(link)

            Accessible.ignored: !root.visible
        }

        Kirigami.ActionToolBar {
            id: actionsLayout

            flat: false
            actions: root.actions
            visible: root.actions.length > 0
            Accessible.ignored: !visible || !root.visible
            alignment: Qt.AlignRight

            anchors {
                left: parent.left
                top: contentLayout.atBottom ? label.bottom : parent.top
                topMargin: contentLayout.atBottom ? Kirigami.Units.largeSpacing : 0
                right: (!contentLayout.atBottom && root.showCloseButton) ? closeButton.left : parent.right
                rightMargin: !contentLayout.atBottom && root.showCloseButton ? Kirigami.Units.smallSpacing : 0
            }
        }

        QQC2.ToolButton {
            id: closeButton

            visible: root.showCloseButton

            anchors.right: parent.right

            // Incompatible anchors need to be evaluated in a given order,
            // which simple declarative bindings cannot assure
            states: [
                State {
                    name: "onTop"
                    when: contentLayout.atBottom
                    AnchorChanges {
                        target: closeButton
                        anchors.top: parent.top
                        anchors.verticalCenter: undefined
                    }
                } ,
                State {
                    name: "centered"
                    AnchorChanges {
                        target: closeButton
                        anchors.top: undefined
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            ]

            height: contentLayout.atBottom ? implicitHeight : implicitHeight

            text: qsTr("Close")
            display: QQC2.ToolButton.IconOnly
            icon.name: "dialog-close"

            onClicked: root.visible = false

            Accessible.ignored: !root.visible
        }

        Component.onCompleted: complete = true
    }
}
