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

/*!
  \qmltype InlineMessage
  \inqmlmodule org.kde.kirigami

  \brief An inline message item with support for informational, positive,
  warning and error types, and with support for associated actions.

  InlineMessage can be used to give information to the user or
  interact with the user, without requiring the use of a dialog.

  The InlineMessage item is hidden by default. It also manages its
  height (and implicitHeight) during an animated reveal when shown.
  You should avoid setting height on an InlineMessage unless it is
  already visible.

  Optionally an icon can be set, defaulting to an icon appropriate
  to the message type otherwise.

  Optionally a close button can be shown.

  Actions are added from left to right. If more actions are set than
  can fit, an overflow menu is provided.

  Example:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.InlineMessage {
      type: Kirigami.MessageType.Error

      text: i18n("My error message")

      actions: [
          Kirigami.Action {
              icon.name: "list-add"
              text: i18n("Add")
              onTriggered: source => {
                  // do stuff
              }
          },
          Kirigami.Action {
              icon.name: "edit"
              text: i18n("Edit")
              onTriggered: source => {
                  // do stuff
              }
          }
      ]
  }
  \endqml

  \since 5.45
 */
T.Control {
    id: root

    visible: false

    /*!
      Defines a position for the message: whether it's to be used as an inline component inside the page,
      a page header, or a page footer.
     */
    enum Position {
        Inline,
        Header,
        Footer
    }

    /*!
      \qmlproperty enumeration InlineMessage::position

      Adjust the look of the message based upon the position.
      If a message is positioned in the header area or in the footer area
      of a page, it might be desirable to not have borders but just a line
      separating it from the content area. In this case, use the Header or
      Footer position.

      Possible values are:
      \list
      \li InlineMessage.Position.Inline
      \li InlineMessage.Position.Header
      \li InlineMessage.Position.Footer
      \endlist

      Default is InlineMessage.Position.Inline
     */
    property int position: InlineMessage.Position.Inline

    /*!
      This signal is emitted when a link is hovered in the message text.

      \a link The hovered link.
     */
    signal linkHovered(string link)

    /*!
      This signal is emitted when a link is clicked or tapped in the message text.

      \a link The clicked or tapped link.
     */
    signal linkActivated(string link)

    /*!
      \qmlproperty string InlineMessage::hoveredLink

      This property holds the link embedded in the message text that the user is hovering over.
     */
    readonly property alias hoveredLink: label.hoveredLink

    /*!
      \qmlproperty enumeration InlineMessage::type

      This property holds the message type.
      One of
      \list
      \li Information
      \li Positive
      \li Warning
      \li Error
      \endlist

      The default is Kirigami.MessageType.Information.
     */
    property int type: Kirigami.MessageType.Information

    /*!
      \qmlproperty string icon.name
      \qmlproperty var icon.source
      \qmlproperty color icon.color
      \qmlproperty real icon.width
      \qmlproperty real icon.height
      \qmlproperty function icon.fromControlsIcon

      This grouped property holds the description of an optional icon.

      \include iconpropertiesgroup.qdocinc grouped-properties
     */
    property IconPropertiesGroup icon

    /*!
      This property holds the message text.
     */
    property string text

    /*!
      This property holds whether the close button is displayed.

      The default is \c false.
     */
    property bool showCloseButton: false

    /*!
      \qmlproperty list<Action> actions

      This property holds the list of actions to show. Actions are added from left to
      right. If more actions are set than can fit, an overflow menu is
      provided.
     */
    property list<T.Action> actions

    /*!
      This property holds whether the current message item is animating.
     */
    readonly property bool animating: _animating

    property bool _animating: false

    implicitHeight: visible ? (contentLayout.implicitHeight + topPadding + bottomPadding) : 0

    padding: Kirigami.Units.smallSpacing

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
            let maximumTopHeight = Math.max(label.implicitHeight, icon.implicitHeight, (root.showCloseButton ? closeButton.implicitHeight : 0))
            if (atBottom) {
                return maximumTopHeight + actionsLayout.implicitHeight + Kirigami.Units.smallSpacing
            } else {
                return Math.max(maximumTopHeight, actionsLayout.implicitHeight)
            }
        }

        Accessible.ignored: true

        readonly property real fixedContentWidth: icon.width + Kirigami.Units.smallSpacing * 3 + (root.showCloseButton ? closeButton.width + Kirigami.Units.smallSpacing : 0)
        readonly property real remainingWidth: width - fixedContentWidth - label.implicitWidth
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
        }

        Kirigami.SelectableLabel {
            id: label

            anchors {
                left: icon.right
                leftMargin: Kirigami.Units.largeSpacing
                top: parent.top
                bottom: parent.bottom
            }

            width: Math.min(parent.width - parent.fixedContentWidth, implicitWidth)

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
                }
            ]

            onLinkHovered: link => root.linkHovered(link)
            onLinkActivated: link => root.linkActivated(link)
        }

        Kirigami.ActionToolBar {
            id: actionsLayout

            flat: false
            actions: root.actions
            visible: root.actions.length > 0
            alignment: Qt.AlignRight

            anchors {
                bottom: parent.bottom
                right: (!contentLayout.atBottom && root.showCloseButton) ? closeButton.left : parent.right
                rightMargin: !contentLayout.atBottom && root.showCloseButton ? Kirigami.Units.smallSpacing : 0
            }

            width: Math.min(implicitWidth, parent.width)
        }

        QQC2.ToolButton {
            id: closeButton

            visible: root.showCloseButton

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            // Incompatible anchors need to be evaluated in a given order,
            // which simple declarative bindings cannot assure
            states: State {
                name: "onTop"
                when: contentLayout.atBottom
                AnchorChanges {
                    target: closeButton
                    anchors.top: parent.top
                    anchors.verticalCenter: undefined
                }
            }

            icon.name: "dialog-close"

            onClicked: root.visible = false
        }

        Component.onCompleted: complete = true
    }
}
