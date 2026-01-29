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

/*!
  \qmltype NavigationTabBar
  \inqmlmodule org.kde.kirigami.templates

  \brief Template for NavigationTabBar.

 */

QQC.ToolBar {
    id: root

//BEGIN properties
    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the list of actions to be displayed in the toolbar.

      If the \c checked attribute in the action is set to \c true, the tab will be highlighted/selected.
     */
    property list<T.Action> actions

    /*!
      \qmlproperty list<Action> visibleActions
      \brief This property holds a subset of visible actions of the list of actions.

      An action is considered visible if it is either a Kirigami.Action with
      \c visible property set to true, or it is a plain QQC.Action.
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
    property int currentIndex: tabGroup.checkedButton && tabGroup.buttons.length > 0 ? (tabGroup.checkedButton as NavigationTabButton).tabIndex : -1

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

        if (visibleButtonCount == 0) {
            return 0;
        }

        return Math.round(contentItem.width / visibleButtonCount);
    }

    contentWidth: root.maximumContentWidth

    position: {
        if (QQC.ApplicationWindow.window?.footer === root) {
            return QQC.ToolBar.Footer
        } else if (parent?.footer === root) {
            return QQC.ToolBar.Footer
        } else if (parent?.parent?.footer === parent) {
            return QQC.ToolBar.Footer
        } else {
            return QQC.ToolBar.Header
        }
    }

    contentItem: RowLayout {
        id: rowLayout
        spacing: root.spacing
    }
//END properties

    onCurrentIndexChanged: {
        if (currentIndex === -1) {
            if (tabGroup.checkState !== Qt.Unchecked) {
                tabGroup.checkState = Qt.Unchecked;
            }
            return;
        }
        if (!tabGroup.checkedButton || (tabGroup.checkedButton as KT.NavigationTabButton).tabIndex !== currentIndex) {
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

    // Used to manage which tab is checked and change the currentIndex
    T.ButtonGroup {
        id: tabGroup
        exclusive: true
        buttons: root.contentItem.children.filter((child) => child !== instantiator)

        onCheckedButtonChanged: {
            if (!checkedButton) {
                return
            }
            if (root.currentIndex !== (checkedButton as KT.NavigationTabButton).tabIndex) {
                root.currentIndex = (checkedButton as KT.NavigationTabButton).tabIndex;
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
        delegate: Kirigami.NavigationTabButton {
            id: delegate

            required property T.Action modelData

            parent: root.contentItem
            action: modelData
            // Workaround setting the action when checkable is not explicitly set making tabs uncheckable
            onActionChanged: action.checkable = true

            Layout.minimumWidth: root.buttonWidth
            Layout.maximumWidth: root.buttonWidth
            Layout.fillHeight: true
        }
    }
}
