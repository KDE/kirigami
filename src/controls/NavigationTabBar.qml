/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/*!
  \qmltype NavigationTabBar
  \inqmlmodule org.kde.kirigami

  \brief Page navigation tab-bar, used as an alternative to sidebars for 3-5 elements.

  Can be combined with secondary toolbars above (if in the footer) to provide page actions.

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

  \sa NavigationTabButton
  \since 5.87
 */

QQC2.ToolBar {
    id: root

//BEGIN properties
    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the list of actions to be displayed in the toolbar.
     */
    property list<T.Action> actions

    /*!
      \qmlproperty list<Action> visibleActions
      \brief This property holds a subset of visible actions of the list of actions.

      An action is considered visible if it is either a Kirigami.Action with
      \c visible property set to true, or it is a plain QQC2.Action.
     */
    readonly property list<T.Action> visibleActions: actions
        // Note: instanceof check implies `!== null`
        .filter(action => action instanceof Kirigami.Action
            ? action.visible
            : action !== null
        )

    /*!
      \brief The property holds the maximum width of the toolbar actions, before margins are added.
     */
    property real maximumContentWidth: {
        const minDelegateWidth = Kirigami.Units.gridUnit * 5;
        // Always have at least the width of 5 items, so that small amounts of actions look natural.
        return minDelegateWidth * Math.max(visibleActions.length, 5);
    }

    /*!
      \brief This property holds the index of currently checked tab.

      If the index set is out of bounds, or the triggered signal did not change any checked property of an action, the index
      will remain the same.
     */
    property int currentIndex: tabGroup.checkedButton && tabGroup.buttons.length > 0 ? tabGroup.checkedButton.tabIndex : -1

    /*!
      \brief This property holds the number of tab buttons.
     */
    readonly property int count: tabGroup.buttons.length

    /*!
      \qmlproperty ButtonGroup tabGroup
      \brief This property holds the ButtonGroup used to manage the tabs.
     */
    readonly property T.ButtonGroup tabGroup: tabGroup

    /*!
      \brief This property holds the calculated width that buttons on the tab bar use.

      \since 5.102
     */
    property real buttonWidth: {
        // Counting buttons because Repeaters can be counted among visibleChildren
        let visibleButtonCount = 0;
        const minWidth = contentItem.height * 0.75;
        for (const visibleChild of contentItem.visibleChildren) {
            if (contentItem.width / visibleButtonCount >= minWidth && // make buttons go off the screen if there is physically no room for them
                visibleChild instanceof T.AbstractButton) { // Checking for AbstractButtons because any AbstractButton can act as a tab
                ++visibleButtonCount;
            }
        }

        return Math.round(contentItem.width / visibleButtonCount);
    }
//END properties

    onCurrentIndexChanged: {
        if (currentIndex === -1) {
            if (tabGroup.checkState !== Qt.Unchecked) {
                tabGroup.checkState = Qt.Unchecked;
            }
            return;
        }
        if (!tabGroup.checkedButton || tabGroup.checkedButton.tabIndex !== currentIndex) {
            const buttonForCurrentIndex = tabGroup.buttons[currentIndex]
            if (buttonForCurrentIndex.action) {
                // trigger also toggles and causes clicked() to be emitted
                buttonForCurrentIndex.action.trigger();
            } else {
                // toggle() does not trigger the action,
                // so don't use it if you want to use an action.
                // It also doesn't cause clicked() to be emitted.
                buttonForCurrentIndex.toggle();
            }
        }
    }

    // ensure that by default, we do not have unintended padding and spacing from the style
    spacing: 0
    padding: 0
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined
    verticalPadding: undefined
    // Using Math.round() on horizontalPadding can cause the contentItem to jitter left and right when resizing the window.
    horizontalPadding: Math.floor(Math.max(0, width - root.maximumContentWidth) / 2)

    contentWidth: root.maximumContentWidth
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
    position: {
        if (QQC2.ApplicationWindow.window?.footer === root) {
            return QQC2.ToolBar.Footer
        } else if (parent?.footer === root) {
            return QQC2.ToolBar.Footer
        } else if (parent?.parent?.footer === parent) {
            return QQC2.ToolBar.Footer
        } else {
            return QQC2.ToolBar.Header
        }
    }

    contentItem: RowLayout {
        id: rowLayout
        spacing: root.spacing
    }

    // Used to manage which tab is checked and change the currentIndex
    T.ButtonGroup {
        id: tabGroup
        exclusive: true
        buttons: root.contentItem.children.filter((child) => child !== instantiator)

        onCheckedButtonChanged: {
            if (!checkedButton) {
                return
            }
            if (root.currentIndex !== checkedButton.tabIndex) {
                root.currentIndex = checkedButton.tabIndex;
            }
        }
    }

    // Using a Repeater here because Instantiator was causing issues:
    // NavigationTabButtons that were supposed to be destroyed were still
    // registered as buttons in tabGroup.
    // NOTE: This will make Repeater show up as child through visibleChildren
    Repeater {
        id: instantiator
        model: root.visibleActions
        delegate: NavigationTabButton {
            id: delegate

            required property T.Action modelData

            parent: root.contentItem
            action: modelData
            // Workaround setting the action when checkable is not explicitly set making tabs uncheckable
            onActionChanged: action.checkable = true

            Layout.minimumWidth: root.buttonWidth
            Layout.maximumWidth: root.buttonWidth
            Layout.fillHeight: true

            Kirigami.Theme.textColor: root.Kirigami.Theme.textColor
            Kirigami.Theme.backgroundColor: root.Kirigami.Theme.backgroundColor
            Kirigami.Theme.highlightColor: root.Kirigami.Theme.highlightColor
        }
    }
}
