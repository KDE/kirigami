/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
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

    contentItem: GridLayout {
        id: contentLayout

        readonly property bool multiLine: label.contentWidth > label.width || root.actions.length > 1 || actionsLayout.maximumContentWidth < actionsLayout.implicitWidth

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

        Accessible.ignored: true

        rows: contentLayout.multiLine ? 2 : 1
        columns: contentLayout.multiLine ? (root.showCloseButton ? 3 : 2) : -1

        columnSpacing: Kirigami.Units.smallSpacing
        rowSpacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            id: icon

            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: contentLayout.multiLine ? 0 : Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.rowSpan: contentLayout.multiLine || label.height > icon.height * 1.7 ? 2 : 1

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

            Layout.fillWidth: true
            Layout.maximumWidth: contentLayout.multiLine ? -1 : labelMetrics.width + contentLayout.columnSpacing

            color: Kirigami.Theme.textColor
            wrapMode: Text.WordWrap

            text: root.text

            verticalAlignment: Text.AlignVCenter

            onLinkHovered: link => root.linkHovered(link)
            onLinkActivated: link => root.linkActivated(link)

            Accessible.ignored: !root.visible
        }

        Kirigami.ActionToolBar {
            id: actionsLayout

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            flat: false
            actions: root.actions
            visible: root.actions.length > 0
            Accessible.ignored: !visible || !root.visible
            alignment: Qt.AlignRight
        }

        QQC2.ToolButton {
            id: closeButton

            visible: root.showCloseButton

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.rowSpan: contentLayout.multiLine || label.height > icon.height * 1.7 ? 2 : 1

            text: qsTr("Close")
            display: QQC2.ToolButton.IconOnly
            icon.name: "dialog-close"

            onClicked: root.visible = false

            Accessible.ignored: !root.visible
        }

        Component.onCompleted: complete = true
    }

    TextMetrics {
        id: labelMetrics
        text: root.text
    }
}
