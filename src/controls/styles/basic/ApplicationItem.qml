/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KC

/*!
  \qmltype ApplicationItem
  \inqmlmodule org.kde.kirigami

  \brief An item that provides the features of ApplicationWindow without the window itself.

  This allows embedding into a larger application.
  It's based around the PageRow component that allows adding/removing of pages.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  Kirigami.ApplicationItem {
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

      pageStack.initialPage: Kirigami.Page {
          mainAction: Kirigami.Action {
              icon.name: "edit"
              onTriggered: {
                  // do stuff
              }
          }
          contextualActions: [
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
          // ...
      }
  }
  \endcode
*/
KC.AbstractApplicationItem {
    id: root

    /*!
      \qmlproperty PageRow ApplicationItem::pageStack

      \brief This property holds the PageRow used to allocate the pages and
      manage the transitions between them.

      It's using a PageRow, while having the same API as PageStack,
      it positions the pages as adjacent columns, with as many columns
      as can fit in the screen. An handheld device would usually have a single
      fullscreen column, a tablet device would have many tiled columns.
     */
    readonly property alias pageStack: __pageStack

    // Redefines here as here we can know a pointer to PageRow
    wideScreen: width >= applicationWindow().pageStack.defaultColumnWidth * 2

    Component.onCompleted: {
        pageStack.currentItem?.forceActiveFocus();
    }

    KC.PageRow {
        id: __pageStack
        anchors {
            fill: parent
        }

        function goBack() {
            // NOTE: drawers are handling the back button by themselves
            const backEvent = {accepted: false}
            if (root.pageStack.currentIndex >= 1) {
                (root.pageStack.currentItem as Page).backRequested(backEvent);
                if (!backEvent.accepted) {
                    root.pageStack.flickBack();
                    backEvent.accepted = true;
                }
            }

            if (Platform.Settings.isMobile && !backEvent.accepted && Qt.platform.os !== "ios") {
                Qt.quit();
            }
        }
        function goForward() {
            root.pageStack.currentIndex = Math.min(root.pageStack.depth - 1, root.pageStack.currentIndex + 1);
        }
        Keys.onBackPressed: event => {
            goBack();
            event.accepted = true;
        }
        Shortcut {
            sequences: [StandardKey.Forward]
            onActivated: __pageStack.goForward();
        }
        Shortcut {
            sequences: [StandardKey.Back]
            onActivated: __pageStack.goBack();
        }

        background: Rectangle {
            color: root.color
        }

        focus: true
    }
}
