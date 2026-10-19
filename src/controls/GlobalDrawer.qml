/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami.templates as KT

/*!
  \qmltype GlobalDrawer
  \inqmlmodule org.kde.kirigami
  \inherits OverlayDrawer

  \brief A specialized form of the Drawer intended for showing an application's
  always-available global actions.

  Think of it like a mobile version of a desktop application's menubar.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  Kirigami.ApplicationWindow {
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
  }
  \endcode
 */
KT.GlobalDrawer {
    leftPadding: edge === Qt.LeftEdge ? parent.SafeArea.margins.left : 0
    topPadding: parent.SafeArea.margins.top
    rightPadding: edge === Qt.RightEdge ? parent.SafeArea.margins.right : 0
    bottomPadding: parent.SafeArea.margins.bottom
}
