/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as Controls
import "private" as P

/*!
  \qmltype AbstractApplicationWindow
  \inqmlmodule org.kde.kirigami
  \inherits QQC2.ApplicationWindow

  \brief A window that provides some basic features needed for all apps.

  Use this class only if you are implementing a custom content item and don’t need
  any of the standard semantics and features of ApplicationWindow.

  Otherwise, use ApplicationWindow.

  It's usually used as a root QML component for the application.
  It provides support for a central page stack, side drawers, and
  basic support for the Android back button.

  Setting a width and height property on the ApplicationWindow
  will set its initial size, but it won't set it as an automatically binding.
  to resize programmatically the ApplicationWindow they need to
  be assigned again in an imperative fashion


  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  Kirigami.ApplicationWindow {
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

      pageStack: PageStack {
          ...
      }
   [...]
  }
  \endcode

 */
QQC2.ApplicationWindow {
    id: root

//BEGIN properties
    /*!
      \brief This property holds the stack used to allocate the pages and to manage the
      transitions between them.

      Put a container here, such as QtQuick.Controls.StackView.
     */
    property Item pageStack

    /*!
      \brief This property sets whether the standard chrome of the app is visible.

      These are the action button, the drawer handles, and the application header.

      \default true
     */
    property bool controlsVisible: true

    /*!
      \brief This property holds the drawer for global actions.

      This drawer can be opened by sliding from the left screen edge
      or by dragging the ActionButton to the right.

      \note It is recommended to use the GlobalDrawer here.
     */
    property OverlayDrawer globalDrawer

    /*!
      \brief This property tells whether the application is in "widescreen" mode.

      This is enabled on desktops or horizontal tablets.

      \note Different styles can have their own logic for deciding this.
     */
    property bool wideScreen: width >= Platform.Units.gridUnit * 60

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

    /*!
      The same as Overlay.overlay.
     */
    readonly property Item overlay: T.Overlay.overlay

    /*!
      This property holds a standard action that will quit the application when triggered.
      Its properties have the following values:

      \code
      Action {
          text: "Quit"
          icon.name: "application-exit-symbolic"
          shortcut: StandardKey.Quit
          // ...
      }
      \endcode
      \since 5.76
     */
    readonly property Controls.Action quitAction: Controls.Action {
        text: qsTr("Quit")
        icon.name: "application-exit";
        shortcut: StandardKey.Quit
        onTriggered: root.close();
    }
//END properties

//BEGIN functions
    /*!
      \qmlmethod void showPassiveNotification(string message, int timeout, string actionText, var callBack)

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
      \brief This function returns application window's object anywhere in the application.
      Returns a pointer to this application window
      can be used anywhere in the application.
     */
    function applicationWindow() {
        return root;
    }
//END functions

    LayoutMirroring.enabled: Application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    color: Platform.Theme.backgroundColor

    P.PassiveNotificationsManager {
        id: notificationsObject

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        parent: T.Overlay.overlay || root
        z: 99999
    }

    // This is to make ApplicationWindow actually assign pageStack, as it replaces the property
    property alias __pageStackAlias: root.pageStack
    contentItem.z: 1
    contentItem.anchors.left: contentItem.parent.left
    contentItem.anchors.right: contentItem.parent.right
    contentItem.anchors.topMargin: root.wideScreen && header && controlsVisible ? header.height : 0
    contentItem.anchors.leftMargin: root.globalDrawer && root.globalDrawer.modal === false && (!root.pageStack || root.pageStack.leftSidebar !== root.globalDrawer) ? root.globalDrawer.width * root.globalDrawer.position : 0
    contentItem.anchors.rightMargin: root.contextDrawer && root.contextDrawer.modal === false ? root.contextDrawer.width * root.contextDrawer.position : 0

    Binding {
        target: root.header
        property: "x"
        value: -root.contentItem.x
    }
    Binding {
        target: root.footer
        property: "x"
        value: -root.contentItem.x
    }

    // Don't use root.overlay property here. For one, we know that in a window
    // it will always be the same as T.Overlay.overlay; secondly Drawers
    // don't care about being contained/parented to anything else anyway.
    onGlobalDrawerChanged: {
        if (globalDrawer) {
            globalDrawer.parent = Qt.binding(() => T.Overlay.overlay);
        }
    }
    onContextDrawerChanged: {
        if (contextDrawer) {
            contextDrawer.parent = Qt.binding(() => T.Overlay.overlay);
        }
    }
    onPageStackChanged: {
        if (pageStack) {
            // contentItem is declared as CONSTANT, so binding isn't needed.
            pageStack.parent = contentItem;
        }
    }

    width: Platform.Settings.isMobile ? Platform.Units.gridUnit * 30 : Platform.Units.gridUnit * 55
    height: Platform.Settings.isMobile ? Platform.Units.gridUnit * 45 : Platform.Units.gridUnit * 40
    visible: true

    Component.onCompleted: {
        // Explicitly break the binding as we need this to be set only at startup.
        // if the bindings are active, after this the window is resized by the
        // compositor and then the bindings are reevaluated, then the window
        // size would reset ignoring what the compositor asked.
        // see BUG 433849
        root.width = root.width;
        root.height = root.height;
    }

    // This is needed because discover in mobile mode does not
    // close with the global drawer open.
    Shortcut {
        sequences: [root.quitAction.shortcut]
        enabled: root.quitAction.enabled
        context: Qt.ApplicationShortcut
        onActivated: root.close();
    }
}
