/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami.controls as KC
import org.kde.kirigami.layouts as KL
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.private.polyfill
import "private" as KP

/*!
  \qmltype GlobalDrawer
  \inqmlmodule org.kde.kirigami

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
KC.OverlayDrawer {
    id: root

    edge: Application.layoutDirection === Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge

    handleClosedIcon.source: null
    handleOpenIcon.source: null

    leftPadding: root.edge === Qt.LeftEdge ? parent.SafeArea.margins.left : 0
    topPadding: parent.SafeArea.margins.top
    rightPadding: root.edge === Qt.RightEdge ? parent.SafeArea.margins.right : 0
    bottomPadding: parent.SafeArea.margins.bottom

    handleVisible: {
        // When drawer is inline with content and opened, there is no point is showing handle.
        if (!modal && drawerOpen) {
            return false;
        }

        // GlobalDrawer can be hidden by controlsVisible...
        if (typeof applicationWindow === "function") {
            const w = applicationWindow();
            if (w && !w.controlsVisible) {
                return false;
            }
        }

        // ...but it still performs additional checks.
        return !isMenu || Platform.Settings.isMobile;
    }

    enabled: !isMenu || Platform.Settings.isMobile

//BEGIN properties
    /*!
      \brief This property holds the title displayed at the top of the drawer.
     */
    property string title

    /*!
      \brief This property holds an icon to be displayed alongside the title.
      \sa Icon::source
     */
    property var titleIcon

    /*!
      \qmlproperty list<Action> GlobalDrawer::actions
      \brief This property holds the actions displayed in the drawer.

      The list of actions can be nested having a tree structure.
      A tree depth bigger than 2 is discouraged.

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
    property list<T.Action> actions

    /*!
      \qmlproperty Item GlobalDrawer::header
      \brief This property holds an item that will always be displayed at the top of the drawer.

      If the drawer contents can be scrolled, this item will stay still and won't scroll.

      \note This property is mainly intended for toolbars.
      \since 2.12
     */
    property alias header: mainLayout.header

    /*!
      \qmlproperty Item GlobalDrawer::footer

      \brief This property holds an item that will always be displayed at the bottom of the drawer.

      If the drawer contents can be scrolled, this item will stay still and won't scroll.

      \note This property is mainly intended for toolbars.
     */
    property alias footer: mainLayout.footer

    /*!
      \qmlproperty list<QtObject> GlobalDrawer::topContent
      \brief This property holds items that are displayed above the actions.

      Example usage:
      \code
      import org.kde.kirigami as Kirigami

      Kirigami.ApplicationWindow {
       [...]
          globalDrawer: Kirigami.GlobalDrawer {
              actions: [...]
              topContent: [Button {
                  text: "Button"
                  onClicked: //do stuff
              }]
          }
       [...]
      }
      \endcode
     */
    property alias topContent: topContent.data

    /*!
      \qmlproperty list<QtObject> GlobalDrawer::content

      \brief This property holds items that are displayed under the actions.

      Example usage:
      \code
      import org.kde.kirigami as Kirigami

      Kirigami.ApplicationWindow {
       [...]
          globalDrawer: Kirigami.GlobalDrawer {
              actions: [...]
              Button {
                  text: "Button"
                  onClicked: //do stuff
              }
          }
       [...]
      }
      \endcode
     */
    default property alias content: mainContent.data

    /*!
      \brief This property sets whether content items at the top should be shown.
      when the drawer is collapsed as a sidebar.

      If you want to keep some items visible and some invisible, set this to
      false and control the visibility/opacity of individual items,
      binded to the collapsed property.

      default: false

      \since 2.5
     */
    property bool showTopContentWhenCollapsed: false

    /*!
      \brief This property sets whether content items at the bottom should be shown.
      when the drawer is collapsed as a sidebar.

      If you want to keep some items visible and some invisible, set this to
      false and control the visibility/opacity of individual items,
      binded to the collapsed property.

      default: false

      \sa content
      \since 2.5
     */
    property bool showContentWhenCollapsed: false

    // TODO
    property bool showHeaderWhenCollapsed: false

    /*!
      \brief This property sets whether activating a leaf action resets the
      menu to show leaf's parent actions.

      A leaf action is an action without any child actions.

      default: true
     */
    property bool resetMenuOnTriggered: true

    /*!
      \brief This property points to the action acting as a submenu
     */
    readonly property T.Action currentSubMenu: stackView.currentItem?.current ?? null

    /*!
      \brief This property sets whether the drawer becomes a menu on the desktop.

      default: \c false

      \since 2.11
     */
    property bool isMenu: false

    /*!
      \brief This property sets the visibility of the collapse button
      when the drawer collapsible.

      default: true

      \since 2.12
     */
    property bool collapseButtonVisible: true
//END properties

    /*!
      \qmlmethod void GlobalDrawer::resetMenu()
      \brief This function reverts the menu back to its initial state.
     */
    function resetMenu() {
        stackView.pop(stackView.get(0, T.StackView.DontLoad));
        if (root.modal) {
            root.drawerOpen = false;
        }
    }

    //BEGIN FUNCTIONS
    /*!
       \brief This method checks whether a particular drawer entry is in view, and scrolls
       the drawer to center the item if it is not.

       Drawer items supplied through the actions property will handle this automatically,
       but items supplied in topContent will need to call this explicitly on receiving focus
       Otherwise, if the user passes focus to the item with e.g. keyboard navigation, it may
       be outside the visible area.

       When called, this method will place the visible area such that the item at the
       center if any part of it is currently outside.

       \code
       QQC2.ItemDelegate {
           id: item
           //  ...
           onFocusChanged: if (focus) drawer.ensureVisible(item)
       }
       \endcode

       \a item The item that should be in the visible area of the drawer. Item coordinates need to be in the coordinate system of the drawer's flickable.

       \a yOffset Offset to align the item's and the flickable's coordinate system (optional)
     */
    //END FUNCTIONS

    function ensureVisible(item: Item, yOffset: int) {
        var actualItemY = item.y + (yOffset ?? 0)
        var viewYPosition = (item.height <= mainFlickable.height)
            ? Math.round(actualItemY + item.height / 2 - mainFlickable.height / 2)
            : actualItemY
        if (actualItemY < mainFlickable.contentY) {
            mainFlickable.contentY = Math.max(0, viewYPosition)
        } else if ((actualItemY + item.height) > (mainFlickable.contentY + mainFlickable.height)) {
            mainFlickable.contentY = Math.min(mainFlickable.contentHeight - mainFlickable.height, viewYPosition)
        }
        mainFlickable.returnToBounds()
    }

    // rightPadding: !Platform.Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Kirigami.Units.gridUnit : Kirigami.Units.smallSpacing

    Platform.Theme.colorSet: modal ? Platform.Theme.Window : Platform.Theme.View

    onIsMenuChanged: drawerOpen = false

    collapsedSize: collapsedSizeHint.implicitWidth

    handleOpenIcon.name: "window-close-symbolic"
    handleClosedIcon.name: "application-menu-symbolic"

    Component {
        id: menuComponent

        ColumnLayout {
            id: menuColumn

            property alias model: actionsRepeater.model
            property T.Action current
            property int level: 0

            spacing: 0
            Layout.maximumHeight: Layout.minimumHeight

            QQC2.ItemDelegate {
                id: backItem

                Layout.fillWidth: true
                visible: menuColumn.level > 0
                icon.name: mirrored ? "go-previous-symbolic-rtl" : "go-previous-symbolic"

                text: Primitives.MnemonicData.richTextLabel
                Accessible.name: Primitives.MnemonicData.plainTextLabel
                activeFocusOnTab: true

                Primitives.MnemonicData.enabled: enabled && visible
                Primitives.MnemonicData.controlType: Primitives.MnemonicData.MenuItem
                Primitives.MnemonicData.label: qsTr("Back")

                onClicked: stackView.pop()

                Keys.onEnterPressed: stackView.pop()
                Keys.onReturnPressed: stackView.pop()

                Keys.onDownPressed: nextItemInFocusChain().focus = true
                Keys.onUpPressed: nextItemInFocusChain(false).focus = true
            }

            Shortcut {
                sequence: backItem.Primitives.MnemonicData.sequence
                onActivated: backItem.clicked()
            }

            Repeater {
                id: actionsRepeater

                readonly property bool withSections: {
                    for (const action of root.actions) {
                        if (action.hasOwnProperty("expandible") && action.expandible) {
                            return true;
                        }
                    }
                    return false;
                }

                model: root.actions

                delegate: ActionDelegate {
                    required property T.Action modelData

                    tAction: modelData
                    withSections: actionsRepeater.withSections
                    backItem: backItem
                }
            }
        }
    }

    component ActionDelegate : ColumnLayout {
        id: delegate

        required property int index
        required property T.Action tAction
        required property bool withSections

        property Item backItem

        readonly property KC.Action kAction: tAction as KC.Action

        readonly property bool isExpanded: {
            return !root.collapsed
                && kAction
                && kAction.expandible
                && kAction.children.length > 0;
        }

        visible: kAction?.visible ?? true

        KP.GlobalDrawerActionItem {
            Layout.fillWidth: true
            Platform.Theme.colorSet: !root.modal && !root.collapsed && delegate.withSections
                ? Platform.Theme.Window : parent.Platform.Theme.colorSet

            visible: !delegate.isExpanded
            width: parent.width

            tAction: delegate.tAction

            onCheckedChanged: {
                // move every checked item into view
                if (checked && topContent.height + delegate.backItem.height + (delegate.index + 1) * height - mainFlickable.contentY > mainFlickable.height) {
                    mainFlickable.contentY += height
                }
            }

            onFocusChanged: {
                if (focus) {
                    root.ensureVisible (delegate, topContent.height + (delegate.backItem.visible ? delegate.backItem.height : 0))
                }
            }
        }

        Item {
            id: headerItem

            visible: delegate.isExpanded
            implicitHeight: sectionHeader.implicitHeight
            Layout.fillWidth: true

            KC.ListSectionHeader {
                id: sectionHeader

                anchors.fill: parent
                Platform.Theme.colorSet: root.modal ? Platform.Theme.View : Platform.Theme.Window

                contentItem: RowLayout {
                    spacing: sectionHeader.spacing

                    Primitives.Icon {
                        property int size: Platform.Units.iconSizes.smallMedium
                        Layout.minimumHeight: size
                        Layout.maximumHeight: size
                        Layout.minimumWidth: size
                        Layout.maximumWidth: size
                        source: delegate.tAction.icon.name || delegate.tAction.icon.source
                    }

                    KC.Heading {
                        level: 4
                        text: delegate.tAction.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Repeater {
            model: delegate.isExpanded ? (delegate.kAction?.children ?? null) : null

            NestedActionDelegate {
                required property T.Action modelData

                tAction: modelData
                withSections: delegate.withSections
            }
        }
    }

    component NestedActionDelegate : KP.GlobalDrawerActionItem {
        required property bool withSections

        Layout.fillWidth: true
        opacity: !root.collapsed
        leftPadding: withSections && !root.collapsed && !root.modal ? padding * 2 : padding * 4
    }

    contentItem: KL.HeaderFooterLayout {
        id: mainLayout

        anchors {
            fill: parent
            topMargin: (root.collapsed && !root.showHeaderWhenCollapsed ? -contentItem.y : 0) + root.topPadding
            bottomMargin: root.bottomPadding
            leftMargin: root.leftPadding
            rightMargin: root.rightPadding
        }

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Platform.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        header: RowLayout {
            visible: root.title.length > 0 || Boolean(root.titleIcon)
            spacing: Platform.Units.largeSpacing

            Primitives.Icon {
                source: root.titleIcon
            }

            KC.Heading {
                text: root.title
                elide: Text.ElideRight
                visible: !root.collapsed
                Layout.fillWidth: true
            }
        }

        contentItem: QQC2.ScrollView {
            id: scrollView

            //ensure the attached property exists
            Platform.Theme.inherit: true

            // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

            implicitWidth: Math.min(mainColumn.implicitWidth, root.parent.width * 0.8)
            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Platform.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Flickable {
                id: mainFlickable

                contentWidth: width
                contentHeight: mainColumn.Layout.minimumHeight

                clip: (mainLayout.header?.visible ?? false) || (mainLayout.footer?.visible ?? false)

                ColumnLayout {
                    id: mainColumn
                    width: mainFlickable.width
                    spacing: 0
                    height: Math.max(scrollView.height, Layout.minimumHeight)

                    // This item exists only as size hint for the collapsed size
                    // In order to be sure on the collapsed width we want,
                    // we need an actual dummy item that can be referenced to get a size hint
                    QQC2.ItemDelegate {
                        id: collapsedSizeHint
                        icon.name: "sidebar-expand-left"
                        visible: false
                        Accessible.ignored: true
                    }

                    ColumnLayout {
                        id: topContent

                        spacing: 0

                        Layout.alignment: Qt.AlignHCenter
                        Layout.leftMargin: root.leftPadding
                        Layout.rightMargin: root.rightPadding
                        Layout.bottomMargin: Platform.Units.smallSpacing
                        Layout.topMargin: root.topPadding
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: implicitHeight * opacity
                        // NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                        // as items are added only after this column creation
                        Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding

                        visible: children.length > 0 && childrenRect.height > 0 && opacity > 0
                        opacity: !root.collapsed || root.showTopContentWhenCollapsed

                        Behavior on opacity {
                            // not an animator as is binded
                            NumberAnimation {
                                duration: Platform.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    T.StackView {
                        id: stackView

                        property KP.ActionsMenu openSubMenu

                        clip: true
                        Layout.fillWidth: true
                        Layout.minimumHeight: currentItem ? currentItem.implicitHeight : 0
                        Layout.maximumHeight: Layout.minimumHeight

                        initialItem: menuComponent
                        implicitWidth: currentItem.implicitWidth

                        // NOTE: it's important those are NumberAnimation and not XAnimators
                        // as while the animation is running the drawer may close, and
                        // the animator would stop when not drawing see BUG 381576
                        popEnter: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * -stackView.width; to: 0; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                            }
                        }

                        popExit: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * stackView.width; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                            }
                        }

                        pushEnter: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                            }
                        }

                        pushExit: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                            }
                        }

                        replaceEnter: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                            }
                        }

                        replaceExit: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Platform.Units.veryLongDuration; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: root.actions.length > 0
                        Layout.minimumHeight: Platform.Units.smallSpacing
                    }

                    ColumnLayout {
                        id: mainContent
                        Layout.alignment: Qt.AlignHCenter
                        Layout.leftMargin: root.leftPadding
                        Layout.rightMargin: root.rightPadding
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        // NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                        // as items are added only after this column creation
                        Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                        visible: children.length > 0 && (opacity > 0 || mainContentAnimator.running)
                        opacity: !root.collapsed || root.showContentWhenCollapsed
                        Behavior on opacity {
                            OpacityAnimator {
                                id: mainContentAnimator
                                duration: Platform.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Item {
                        Layout.minimumWidth: Platform.Units.smallSpacing
                        Layout.minimumHeight: root.bottomPadding
                    }

                    QQC2.ToolButton {
                        Layout.fillWidth: true

                        icon.name: {
                            if (root.collapsible && root.collapseButtonVisible) {
                                // Check for edge regardless of RTL/locale/mirrored status,
                                // because edge can be set externally.
                                const mirrored = root.edge === Qt.RightEdge;

                                if (root.collapsed) {
                                    return mirrored ? "sidebar-expand-right" : "sidebar-expand-left";
                                } else {
                                    return mirrored ? "sidebar-collapse-right" : "sidebar-collapse-left";
                                }
                            }
                            return "";
                        }

                        visible: root.collapsible && root.collapseButtonVisible
                        text: root.collapsed ? "" : qsTr("Close Sidebar")

                        onClicked: root.collapsed = !root.collapsed

                        QQC2.ToolTip.visible: root.collapsed && (Platform.Settings.tabletMode ? pressed : hovered)
                        QQC2.ToolTip.text: qsTr("Open Sidebar")
                        QQC2.ToolTip.delay: Platform.Units.toolTipDelay
                    }
                }
            }
        }
    }
}
