/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "private" as KTP

/*!
  \qmltype OverlayDrawer
  \inqmlmodule org.kde.kirigami

  \brief A Drawer used to expose additional UI elements needed for
  small secondary tasks for which the main UI elements are not needed.

  For example in Okular Mobile, an Overlay Drawer is used to display
  thumbnails of all pages within a document along with a search field.
  This is used for the distinct task of navigating to another page.
 */
T.Drawer {
    id: root

//BEGIN properties
    /*!
      \brief This property tells whether the drawer is open and visible.

      default: \c false
     */
    property bool drawerOpen: false

    /*!
      \brief This property tells whether the drawer is in a state between open
      and closed.

      The drawer is visible but not completely open. This is usually the case when
      the user is dragging the drawer from a screen edge, so the user is "peeking"
      at what's in the drawer.

      default: \c false
     */
    property bool peeking: false

    /*!
      \brief This property tells whether the drawer is currently opening or closing itself.
     */
    readonly property bool animating : enterAnimation.animating || exitAnimation.animating || positionResetAnim.running

    /*!
      \brief This property holds whether the drawer can be collapsed to a
      very thin, usually icon only sidebar.

      Only modal drawers are collapsible. Collapsible is not supported in
      the mobile mode.

      \since 2.5
     */
    property bool collapsible: false

    /*!
      \brief This property tells whether the drawer is collapsed to a
      very thin sidebar, usually icon only.

      When true, the drawer will be collapsed to a very thin sidebar,
      usually icon only.

      Only collapsible drawers can be collapsed.

      default: \c false

      \sa collapsible
     */
    property bool collapsed: false

    /*!
      \brief This property holds the size of the collapsed drawer.

      For vertical drawers this will be the width of the drawer and for horizontal
      drawers this will be the height of the drawer.

      default: Units.iconSizes.medium, just enough to accommodate medium sized icons
     */
    property int collapsedSize: Kirigami.Units.iconSizes.medium

    /*!
      \qmlproperty string icon.name
      \qmlproperty var icon.source
      \qmlproperty color icon.color
      \qmlproperty real icon.width
      \qmlproperty real icon.height
      \qmlproperty function icon.fromControlsIcon

      This property holds the options for handle's open icon.

      If no custom icon is set, a menu icon is shown for the application globalDrawer
      and an overflow menu icon is shown for the contextDrawer.
      That's the default for the GlobalDrawer and ContextDrawer components respectively.

      For OverlayDrawer the default is view-right-close or view-left-close depending on
      the drawer location

      \since 2.5

      \include iconpropertiesgroup.qdocinc grouped-properties
     */
    readonly property KTP.IconPropertiesGroup handleOpenIcon: KTP.IconPropertiesGroup {
        source: root.edge === Qt.RightEdge ? "view-right-close" : "view-left-close"
    }

    /*!
      \qmlproperty string handleClosedIcon.name
      \qmlproperty var handleClosedIcon.source
      \qmlproperty color handleClosedIcon.color
      \qmlproperty real handleClosedIcon.width
      \qmlproperty real handleClosedIcon.height
      \qmlproperty function handleClosedIcon.fromControlsIcon

      This grouped property holds the description of an optional icon.

      If no custom icon is set, an X icon is shown,
      which will morph into the Menu or overflow icons.

      For OverlayDrawer the default is view-right-new or view-left-new depending on
      the drawer location.

      \since 2.5
     */
    property KTP.IconPropertiesGroup handleClosedIcon: KTP.IconPropertiesGroup {
        source: root.edge === Qt.RightEdge ? "view-right-new" : "view-left-new"
    }

    /*!
      \brief This property holds the tooltip displayed when the drawer is open.
      \since 2.15
     */
    property string handleOpenToolTip: qsTr("Close drawer")

    /*!
      \brief This property holds the tooltip displayed when the drawer is closed.
      \since 2.15
     */
    property string handleClosedToolTip: qsTr("Open drawer")

    /*!
      \brief This property holds whether the handle is visible, to make opening the
      drawer easier.

      Currently supported only on left and right drawers.
     */
    property bool handleVisible: {
        if (typeof applicationWindow === "function") {
            const w = applicationWindow();
            if (w) {
                return w.controlsVisible;
            }
        }
        // For a generic-purpose OverlayDrawer its handle is visible by default
        return true;
    }

    /*!
      \brief Readonly property that points to the item that will act as a physical
      handle for the Drawer.
     */
    readonly property Item handle: KTP.DrawerHandle {
        drawer: root
    }
//END properties

    interactive: modal

    z: Kirigami.OverlayZStacking.z

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: modal ? Kirigami.Theme.View : Kirigami.Theme.Window
    Kirigami.Theme.onColorSetChanged: {
        contentItem.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet
        background.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet
    }

//BEGIN reassign properties
    //default paddings
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    y: modal ? 0 : ((T.ApplicationWindow.menuBar && T.ApplicationWindow.menuBar.visible ? T.ApplicationWindow.menuBar.height : 0) + (T.ApplicationWindow.header && T.ApplicationWindow.header.visible ? T.ApplicationWindow.header.height : 0))

    height: parent && (root.edge === Qt.LeftEdge || root.edge === Qt.RightEdge) ? (modal ? parent.height : (parent.height - y - (T.ApplicationWindow.footer ? T.ApplicationWindow.footer.height : 0))) : implicitHeight

    parent: modal || edge === Qt.LeftEdge || edge === Qt.RightEdge ? T.ApplicationWindow.overlay : T.ApplicationWindow.contentItem

    edge: Qt.LeftEdge
    modal: true
    // Doesn't dim on isSidebarTransitioning to not flash a dark background
    // see https://bugs.kde.org/502260
    dim: modal && !__internal.isSidebarTransitioning

    QQC2.Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.35)
    }

    dragMargin: enabled && (edge === Qt.LeftEdge || edge === Qt.RightEdge) ? Math.min(Kirigami.Units.gridUnit, Qt.styleHints.startDragDistance) : 0

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding

    enter: Transition {
        enabled: !__internal.isSidebarTransitioning
        SequentialAnimation {
            id: enterAnimation
            /* NOTE: why this? the running status of the enter transition is not relaible and
             * the SmoothedAnimation is always marked as non running,
             * so the only way to get to a reliable animating status is with this
             */
            property bool animating
            ScriptAction {
                script: {
                    enterAnimation.animating = true
                    // on non modal dialog we don't want drawers in the overlay
                    if (!root.modal) {
                        root.background.parent.parent = applicationWindow().overlay.parent
                    }
                }
            }
            SmoothedAnimation {
                velocity: 5
            }
            ScriptAction {
                script: enterAnimation.animating = false
            }
        }
    }

    exit: Transition {
        enabled: !__internal.isSidebarTransitioning
        SequentialAnimation {
            id: exitAnimation
            property bool animating
            ScriptAction {
                script: exitAnimation.animating = true
            }
            SmoothedAnimation {
                velocity: 5
            }
            ScriptAction {
                script: exitAnimation.animating = false
            }
        }
    }
//END reassign properties


//BEGIN signal handlers
    onCollapsedChanged: {
        if (Kirigami.Settings.isMobile) {
            collapsed = false;
        }
        if (!__internal.completed) {
            return;
        }
        if ((!collapsible || modal) && collapsed) {
            collapsed = true;
        }
    }
    onCollapsibleChanged: {
        if (Kirigami.Settings.isMobile) {
            collapsible = false;
        }
        if (!__internal.completed) {
            return;
        }
        if (!collapsible) {
            collapsed = false;
        } else if (modal) {
            collapsible = false;
        }
    }
    onModalChanged: {
        if (!__internal.completed) {
            return;
        }
        if (modal) {
            collapsible = false;
        }
        __internal.isSidebarTransitioning = true
        if (modal) {
            position = 0
            drawerOpen = false
        }
    }

    onPositionChanged: {
        if (peeking) {
            visible = true
        }
    }
    onVisibleChanged: {
        if (peeking) {
            visible = true
        } else {
            drawerOpen = visible;
        }
        if (__internal.isSidebarTransitioning) {
            position = visible ? 1 : 0
            __internal.isSidebarTransitioning = false
        }
    }
    onPeekingChanged:  {
        if (peeking) {
            root.enter.enabled = false;
            root.exit.enabled = false;
        } else {
            drawerOpen = position > 0.5 ? 1 : 0;
            positionResetAnim.running = true
            root.enter.enabled = true;
            root.exit.enabled = true;
        }
    }
    onDrawerOpenChanged: {
        // sync this property only when the component is properly loaded
        if (!__internal.completed) {
            return;
        }
        positionResetAnim.running = false;
        if (drawerOpen) {
            open();
        } else {
            close();
        }
        Qt.callLater(() => root.handle.displayToolTip = true)
    }

    Component.onCompleted: {
        // if defined as drawerOpen by default in QML, don't animate
        if (root.drawerOpen) {
            root.enter.enabled = false;
            root.visible = true;
            root.position = 1;
            root.enter.enabled = true;
        }
        __internal.completed = true;
        contentItem.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet;
        background.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet;
    }
//END signal handlers

    // this is as hidden as it can get here
    property QtObject __internal: QtObject {
        //here in order to not be accessible from outside
        property bool completed: false
        property bool isSidebarTransitioning: false
        property SequentialAnimation positionResetAnim: SequentialAnimation {
            id: positionResetAnim
            property alias to: internalAnim.to
            NumberAnimation {
                id: internalAnim
                target: root
                to: drawerOpen ? 1 : 0
                property: "position"
                duration: (root.position)*Kirigami.Units.longDuration
            }
            ScriptAction {
                script: {
                    root.drawerOpen = internalAnim.to !== 0;
                }
            }
        }
        readonly property Item statesItem: Item {
            states: [
                State {
                    when: root.collapsed
                    PropertyChanges {
                        target: root
                        implicitWidth: edge === Qt.TopEdge || edge === Qt.BottomEdge ? applicationWindow().width : Math.min(collapsedSize + leftPadding + rightPadding, Math.round(applicationWindow().width*0.8))

                        implicitHeight: edge === Qt.LeftEdge || edge === Qt.RightEdge ? applicationWindow().height : Math.min(collapsedSize + topPadding + bottomPadding, Math.round(applicationWindow().height*0.8))
                    }
                },
                State {
                    when: !root.collapsed
                    PropertyChanges {
                        target: root
                        implicitWidth: edge === Qt.TopEdge || edge === Qt.BottomEdge ? applicationWindow().width : Math.min(contentItem.implicitWidth, Math.round(applicationWindow().width*0.8))

                        implicitHeight: edge === Qt.LeftEdge || edge === Qt.RightEdge ? applicationWindow().height : Math.min(contentHeight + topPadding + bottomPadding, Math.round(applicationWindow().height*0.4))

                        contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
                        contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)
                    }
                }
            ]
            transitions: Transition {
                reversible: true
                NumberAnimation {
                    properties: root.edge === Qt.TopEdge || root.edge === Qt.BottomEdge ? "implicitHeight" : "implicitWidth"
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
