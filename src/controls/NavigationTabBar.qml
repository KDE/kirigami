/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT
import org.kde.kirigami.private.polyfill

/*!
  \qmltype NavigationTabBar
  \inqmlmodule org.kde.kirigami

  \brief Page navigation tab-bar, used as an alternative to sidebars for 3-5 elements. A NavigationTabBar can be both used as a footer or a header for a page. It can be combined with secondary toolbars above (if in the footer) to provide page actions.

  Example usage:
  \qml

  import QtQuick
  import org.kde.kirigami as Kirigami

  Kirigami.ApplicationWindow {
      title: "Clock"

      pageStack.initialPage: worldPage

      Kirigami.Page {
          id: worldPage
          title: "World"
          visible: false
      }
      Kirigami.Page {
          id: timersPage
          title: "Timers"
          visible: false
      }
      Kirigami.Page {
          id: stopwatchPage
          title: "Stopwatch"
          visible: false
      }
      Kirigami.Page {
          id: alarmsPage
          title: "Alarms"
          visible: false
      }

      footer: Kirigami.NavigationTabBar {
          actions: [
              Kirigami.Action {
                  icon.name: "globe"
                  text: "World"
                  checked: worldPage.visible
                  onTriggered: {
                       if (!worldPage.visible) {
                           while (pageStack.depth > 0) {
                               pageStack.pop();
                           }
                           pageStack.push(worldPage);
                      }
                  }
              },
              Kirigami.Action {
                  icon.name: "player-time"
                  text: "Timers"
                  checked: timersPage.visible
                  onTriggered: {
                      if (!timersPage.visible) {
                          while (pageStack.depth > 0) {
                              pageStack.pop();
                          }
                          pageStack.push(timersPage);
                      }
                  }
              },
              Kirigami.Action {
                  icon.name: "chronometer"
                  text: "Stopwatch"
                  checked: stopwatchPage.visible
                  onTriggered: {
                      if (!stopwatchPage.visible) {
                          while (pageStack.depth > 0) {
                              pageStack.pop();
                          }
                          pageStack.push(stopwatchPage);
                      }
                  }
              },
              Kirigami.Action {
                  icon.name: "notifications"
                  text: "Alarms"
                  checked: alarmsPage.visible
                  onTriggered: {
                      if (!alarmsPage.visible) {
                          while (pageStack.depth > 0) {
                              pageStack.pop();
                          }
                          pageStack.push(alarmsPage);
                      }
                  }
              }
          ]
      }
  }
\endqml

  A NavigationTabBar can also be combined with a QtQuick SwipeView, through which swiping between Pages becomes possible.

  Example usage with a SwipeView:
  \qml
import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    title: "Clock"
    QQC.SwipeView {
        id: swipeView
        anchors.fill: parent
        clip: true
        onCurrentIndexChanged: footer.currentIndex = currentIndex
        Kirigami.Page {
            id: worldPage
            title: "World"
            QQC.Label {
                anchors.centerIn: parent
                text: "Current Page: World"
            }
        }
        Kirigami.Page {
            [...]
        }
        ...
        Kirigami.Page {
            id: alarmsPage
            title: "Alarms"
            QQC.Label {
                anchors.centerIn: parent
                text: "Current Page: Alarms"
            }
        }
    }

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.Action {
                icon.name: "globe"
                text: "World"
                checked: true
                onTriggered: swipeView.currentIndex = footer.currentIndex
            },
            Kirigami.Action {
                [...]
            },
            ...
            Kirigami.Action {
                icon.name: "notifications"
                text: "Alarms"
                onTriggered: swipeView.currentIndex = footer.currentIndex
            }
        ]
    }
}

  \endqml

  \sa NavigationTabButton
  \since 5.87
 */

KT.NavigationTabBar {
    id: root

    // ensure that by default, we do not have unintended padding and spacing from the style
    spacing: 0
    topPadding: root.position === QQC.ToolBar.Header ? parent.SafeArea.margins.top : 0
    bottomPadding: root.position === QQC.ToolBar.Footer ? parent.SafeArea.margins.bottom : 0
    // Using Math.round() on horizontalPadding can cause the contentItem to jitter left and right when resizing the window.
    leftPadding: Math.floor(Math.max(0, width - root.maximumContentWidth) / 2) + parent.SafeArea.margins.left
    rightPadding: Math.floor(Math.max(0, width - root.maximumContentWidth) / 2) + parent.SafeArea.margins.right

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

}
