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

  \brief An inline message item with support for associated actions

  InlineMessage can be used to provide non-modal information or interactivity
  without requiring the use of a dialog. To learn when to use it, see
  https://develop.kde.org/hig/status_changes/#in-app-notifications.

  InlineMessage has two visibility modes: inline (default) and borderless. The
  inline version includes outer padding suitable for being displayed amidst
  page content. The borderless version is best used used as a header or footer
  where it is expected to touch the edges of its parent view, and is activated
  using the \l position property.

  The InlineMessage item is hidden by default. It also manages its
  height (and implicitHeight) during an animated reveal when shown.
  You should avoid setting height on an InlineMessage unless it is
  already visible.

  The \l type property determines the message's coloration and default icon.
  This icon can be overridden using the \l icon property.

  No close button is shown by default, which means you're responsible for
  hiding the message when it's no longer relevant. Optionally, a close button
  can be added using the \l showCloseButton property.

  Actions are added from leading to trailing, and aligned to the trailing
  position. If more actions are set than can fit, an overflow menu is provided.

  Example displayed inline:
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

  Example displayed in the header position:
  \qml
  import org.kde.kirigami as Kirigami

  Kirigami.Page {
      header: Kirigami.InlineMessage {
          position: Kirigami.InlineMessage.Position.Header
          type: Kirigami.MessageType.Warning

          text: i18n("My warning message")

          actions: [
              Kirigami.Action {
                  icon.name: "edit-undo"
                  text: i18n("Undo")
                  onTriggered: source => {
                      // do stuff
                  }
              }
          ]
      }

      // Add page content here
  }
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
    property TP.IconPropertiesGroup icon: TP.IconPropertiesGroup {}

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

      This property holds the list of actions to show. Actions are added from
      leading to trailing. If more actions are set than can fit, an overflow
      menu is provided.
     */
    property list<T.Action> actions

    /*!
      This property holds whether the current message item is animating.
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

            text: qsTr("Close")
            display: QQC2.ToolButton.IconOnly
            icon.name: "dialog-close"

            onClicked: root.visible = false

            Accessible.ignored: !root.visible
        }

        Component.onCompleted: complete = true
    }
}
