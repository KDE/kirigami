/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami
import "templates/private" as TP
import org.kde.kirigami.templates as KT

/*!
  \qmltype AbstractApplicationItem
  \inqmlmodule org.kde.kirigami

  \brief An item that provides the features of AbstractApplicationWindow without the window itself.

  This allows embedding into a larger application.
  Unless you need extra flexibility it is recommended to use ApplicationItem instead.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  Kirigami.AbstractApplicationItem {
   [...]
      globalDrawer: Kirigami.GlobalDrawer {
          actions: [
             Kirigami.Action {
                 text: "View"
                 icon.name: "view-list-icons"
                 Kirigami.Action {
                         text: "action 1"
                 }
                 Kirigami.Action {
                         text: "action 2"
                 }
                 Kirigami.Action {
                         text: "action 3"
                 }
             },
             Kirigami.Action {
                 text: "Sync"
                 icon.name: "folder-sync"
             }
          ]
      }

      contextDrawer: Kirigami.ContextDrawer {
          id: contextDrawer
      }

      pageStack: Kirigami.PageRow {
          ...
      }
   [...]
  }
  \endcode
 */
Item {
    id: root

//BEGIN properties
    /*!
      \brief This property holds the stack used to allocate the pages and to manage the
      transitions between them.

      Put a container here, such as QtQuick.Controls.StackView.
     */
    property Item pageStack

    /*!
      \brief This property holds the font for this item.

      default: Kirigami.Theme.defaultFont
     */
    property font font: Kirigami.Theme.defaultFont

    /*!
      \brief This property holds the locale for this item.
     */
    property Locale locale

    /*!
      \brief This property holds an item that can be used as a menuBar for the application.
     */
    property T.MenuBar menuBar

    /*!
     \qmlproperty AbstractApplicationHeader header
     \brief This property holds an item that can be used as a title for the application.

     Scrolling the main page will make it taller or shorter (through the point of going away).

     It's a behavior similar to the typical mobile web browser addressbar.

     The minimum, preferred and maximum heights of the item can be controlled with:
     \list
     \li Layout.minimumHeight: default is 0, i.e. hidden
     \li Layout.preferredHeight: default is Kirigami.Units.gridUnit * 1.6
     \li Layout.maximumHeight: default is Kirigami.Units.gridUnit * 3
     \endlist
     To achieve a titlebar that stays completely fixed, just set the 3 sizes as the same.
    */
    property KT.AbstractApplicationHeader header

    /*!
      \brief This property holds an item that can be used as a footer for the application.
     */
    property Item footer

    /*!
      \brief This property sets whether the standard chrome of the app is visible.

      These are the action button, the drawer handles and the application header.

      default: true
     */
    property bool controlsVisible: true

    /*!
      \brief This property holds the drawer for global actions.

      Thos drawer can be opened by sliding from the left screen edge
      or by dragging the ActionButton to the right.

      \note It is recommended to use the GlobalDrawer here.
     */
    property OverlayDrawer globalDrawer

    /*!
      \brief This property tells us whether the application is in "widescreen" mode.

      This is enabled on desktops or horizontal tablets.

      \note Different styles can have their own logic for deciding this.
     */
    property bool wideScreen: width >= Kirigami.Units.gridUnit * 60

    /*!
      \brief This property holds the drawer for context-dependent actions.

      The drawer that will be opened by sliding from the right screen edge
      or by dragging the ActionButton to the left.

      \note It is recommended to use the ContextDrawer type here.

      The contents of the context drawer should depend from what page is
      loaded in the main pageStack.

      Example usage:

      \code
      import org.kde.kirigami as Kirigami

      Kirigami.ApplicationWindow {
          contextDrawer: Kirigami.ContextDrawer {
              enabled: true
              actions: [
                  Kirigami.Action {
                      icon.name: "edit"
                      text: "Action text"
                      onTriggered: {
                          // do stuff
                      }
                  },
                  Kirigami.Action {
                      icon.name: "edit"
                      text: "Action text"
                      onTriggered: {
                          // do stuff
                      }
                  }
              ]
          }
      }
      \endcode
     */
    property OverlayDrawer contextDrawer

    default property alias __data: contentItemRoot.data

    /*!
      \brief This property holds the Item of the main part of the Application UI.
     */
    readonly property Item contentItem: Item {
        id: contentItemRoot
        parent: root
        anchors {
            fill: parent
            topMargin: controlsVisible ? (root.header ? root.header.height : 0) + (root.menuBar ? root.menuBar.height : 0) : 0
            bottomMargin: controlsVisible && root.footer ? root.footer.height : 0
            leftMargin: root.globalDrawer && root.globalDrawer.modal === false ? root.globalDrawer.contentItem.width * root.globalDrawer.position : 0
            rightMargin: root.contextDrawer && root.contextDrawer.modal === false ? root.contextDrawer.contentItem.width * root.contextDrawer.position : 0
        }
    }

    /*!
      \brief This property holds the color for the background.

      default: Kirigami.Theme.backgroundColor
     */
    property color color: Kirigami.Theme.backgroundColor

    /*!
      \brief This property holds the background of the Application UI.
     */
    property Item background

    property alias overlay: overlayRoot
//END properties

//BEGIN functions
    /*!
      \brief This function shows a little passive notification at the bottom of the app window
      lasting for few seconds, with an optional action button.

      \a message The text message to be shown to the user.

      \a timeout How long to show the message:
                 possible values: "short", "long", or the number of milliseconds.

      \a actionText Text in the action button, if any.

      \a callBack A JavaScript function that will be executed when the
                 user clicks the button.
     */
    function showPassiveNotification(message, timeout, actionText, callBack) {
        notificationsObject.showNotification(message, timeout, actionText, callBack);
    }

    /*!
      \brief This function hides the passive notification at specified index, if any is shown.

      \a index Index of the notification to hide. Default is 0 (oldest notification).
    */
    function hidePassiveNotification(index = 0) {
        notificationsObject.hideNotification(index);
    }

    /*!
      \brief This property gets application windows object anywhere in the application.
      Returns a pointer to this item.
     */
    function applicationWindow() {
        return root;
    }
//END functions

//BEGIN signals handlers
    onMenuBarChanged: {
        if (menuBar) {
            menuBar.parent = root.contentItem
            if (menuBar instanceof T.ToolBar) {
                menuBar.position = T.ToolBar.Footer
            } else if (menuBar instanceof T.DialogButtonBox) {
                menuBar.position = T.DialogButtonBox.Footer
            }
            menuBar.width = Qt.binding(() => root.contentItem.width)
            // FIXME: (root.header.height ?? 0) when we can depend from 5.15
            menuBar.y = Qt.binding(() => -menuBar.height - (root.header.height ? root.header.height : 0))
        }
    }

    onHeaderChanged: {
        if (header) {
            header.parent = root.contentItem
            if (header instanceof T.ToolBar) {
                header.position = T.ToolBar.Header
            } else if (header instanceof T.DialogButtonBox) {
                header.position = T.DialogButtonBox.Header
            }
            header.width = Qt.binding(() => root.contentItem.width)
            header.y = Qt.binding(() => -header.height)
        }
    }

    onFooterChanged: {
        if (footer) {
            footer.parent = root.contentItem
            if (footer instanceof T.ToolBar) {
                footer.position = T.ToolBar.Footer
            } else if (footer instanceof T.DialogButtonBox) {
                footer.position = T.DialogButtonBox.Footer
            }
            footer.width = Qt.binding(() => root.contentItem.width)
            footer.y = Qt.binding(() => root.contentItem.height)
        }
    }

    onBackgroundChanged: {
        if (background) {
            background.parent = root.contentItem
            background.anchors.fill = background.parent
        }
    }

    onPageStackChanged: pageStack.parent = root.contentItem;
//END signals handlers

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TP.PassiveNotificationsManager {
        id: notificationsObject

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        parent: root.T.Overlay.overlay || root
        z: 99999
    }

    Item {
        anchors.fill: parent
        parent: root.parent || root
        z: 999999

        Item {
            id: overlayRoot
            z: -1
            anchors.fill: parent
        }
    }

    // Don't use root.overlay property here. For one, we know that in a window
    // it will always be the same as T.Overlay.overlay; secondly Drawers
    // don't care about being contained/parented to anything else anyway.
    onGlobalDrawerChanged: {
        if (globalDrawer) {
            globalDrawer.parent = Qt.binding(() => visible ? T.Overlay.overlay : null);
        }
    }
    onContextDrawerChanged: {
        if (contextDrawer) {
            contextDrawer.parent = Qt.binding(() => visible ? T.Overlay.overlay : null);
        }
    }

    Window.onWindowChanged: {
        if (globalDrawer) {
            globalDrawer.visible = globalDrawer.drawerOpen;
        }
        if (contextDrawer) {
            contextDrawer.visible = contextDrawer.drawerOpen;
        }
    }

    implicitWidth: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 30 : Kirigami.Units.gridUnit * 55
    implicitHeight: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 45 : Kirigami.Units.gridUnit * 40
    visible: true
}
