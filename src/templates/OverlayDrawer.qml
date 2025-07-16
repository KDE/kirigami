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

      When collapsed, drawers can't be manually resized even when
      interactiveResizeEnabled is true

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
      \brief When true it will be possible to resize the drawer by dragging its edge with the mouse

      When the drawer is collapsed, drawers can't be manually resized even when
      interactiveResizeEnabled is true
     */
    property bool interactiveResizeEnabled: false

    /*!
      \brief True when the user is resizing the drawer with the mouse
     */
    property alias interactiveResizing: resizeHandle.pressed

    /*!
      \brief The minimum size (width or height, depending on the edge) this drawer is allowed to be resized

      For left and right drawers the default is Kirigami.Units.gridUnit * 8
      For top and bottom drawers the default is Kirigami.Units.gridUnit * 4
     */
    property real minimumSize: {
        switch (edge) {
        case Qt.TopEdge:
        case Qt.BottomEdge:
            return Kirigami.Units.gridUnit * 4;
        default:
            return Kirigami.Units.gridUnit * 8;
        }
    }

    /*!
      \brief The size (width or height, depending on the edge) the drawer wants to have when on left or right edges and not collapsed.

      Wnen interactiveResizing is true and the app wants to restore its saved custom drawer size, it should write to this property, width, height, implicitWidth and implicitHeight should not be touched.

      Default value is -1, which means the drawer will be sized following its contents size hints
     */
    property real preferredSize: -1

    /*!
      \brief The maximum size (width or height, depending on the edge) this drawer is allowed to be resized

      For left and right drawers the default is the minimum between Kirigami.Units.gridUnit * 25
      and 80% of the window width
      For Top and bottom drawers the default is the minimum between Kirigami.Units.gridUnit * 15 and half of
      the window height
    */
    property real maximumSize: {
        switch (edge) {
        case Qt.TopEdge:
        case Qt.BottomEdge:
            return Math.round(Math.min(T.ApplicationWindow.window.height * 0.5, Kirigami.Units.gridUnit * 15));
        default:
            return Math.round(Math.min(T.ApplicationWindow.window.width * 0.8, Kirigami.Units.gridUnit * 25));
        }
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
    padding: Kirigami.Units.smallSpacing

    y: modal ? 0 : ((T.ApplicationWindow.menuBar && T.ApplicationWindow.menuBar.visible ? T.ApplicationWindow.menuBar.height : 0) + (T.ApplicationWindow.header && T.ApplicationWindow.header.visible ? T.ApplicationWindow.header.height : 0))

    height: parent && (root.edge === Qt.LeftEdge || root.edge === Qt.RightEdge) ? (modal ? parent.height : (parent.height - y - (T.ApplicationWindow.footer ? T.ApplicationWindow.footer.height : 0))) : implicitHeight

    parent: modal || edge === Qt.LeftEdge || edge === Qt.RightEdge ? T.Overlay.overlay : T.ApplicationWindow.contentItem

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
                        root.background.parent.parent = root.T.Overlay.overlay.parent
                    }
                }
            }
            NumberAnimation {
                easing.type: Easing.OutQuad
                duration: Kirigami.Units.longDuration
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
            NumberAnimation {
                easing.type: Easing.InQuad
                duration: Kirigami.Units.longDuration
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
                        implicitWidth: edge === Qt.TopEdge || edge === Qt.BottomEdge ? root.T.ApplicationWindow.window.width : Math.min(collapsedSize + leftPadding + rightPadding, Math.round(root.T.ApplicationWindow.window.width*0.8))

                        implicitHeight: edge === Qt.LeftEdge || edge === Qt.RightEdge ? root.T.ApplicationWindow.window.height : Math.min(collapsedSize + topPadding + bottomPadding, Math.round(root.T.ApplicationWindow.window.height*0.8))
                    }
                },
                State {
                    when: !root.collapsed
                    PropertyChanges {
                        target: root
                        implicitWidth: {
                            if (edge === Qt.TopEdge || edge === Qt.BottomEdge) {
                                return root.T.ApplicationWindow.window?.width ?? Kirigami.Units.gridUnit * 30;
                            } else {
                                const implicitWidth = root.preferredSize > 0 ? root.preferredSize : contentItem.implicitWidth;
                                return Math.max(root.minimumSize, Math.min(implicitWidth + leftPadding + rightPadding, root.maximumSize))
                            }
                        }

                        implicitHeight: {
                            if (edge === Qt.LeftEdge || edge === Qt.RightEdge) {
                                return root.T.ApplicationWindow.window?.height ?? Kirigami.Units.gridUnit * 5;
                            } else {
                                const implicitHeight = root.preferredSize > 0 ? root.preferredSize : contentItem.implicitHeight;
                                return Math.max(root.minimumSize, Math.min(implicitHeight + topPadding + bottomPadding, root.maximumSize))
                            }
                        }

                        contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
                        contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)
                    }
                }
            ]
            transitions: Transition {
                reversible: true
                enabled: root.collapsible === true
                NumberAnimation {
                    properties: root.edge === Qt.TopEdge || root.edge === Qt.BottomEdge ? "implicitHeight" : "implicitWidth"
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        readonly property MouseArea resizeHandle: MouseArea {
            id: resizeHandle
            anchors.margins: -Kirigami.Units.smallSpacing
            parent: root.background.parent
            z: 999
            visible: root.interactiveResizeEnabled && !root.collapsed
            width: Kirigami.Units.smallSpacing * 2
            height: Kirigami.Units.smallSpacing * 2
            cursorShape: {
                switch (root.edge) {
                case Qt.TopEdge:
                case Qt.BottomEdge:
                    return Qt.SplitVCursor;
                default:
                    return Qt.SplitHCursor;
                }
            }
            preventStealing: true
            property real startX
            property real startY
            property real startWidth;
            property real startHeight;

            onPressed: mouse => {
                const pos = mapToItem(null, mouse.x, mouse.y);
                startX = pos.x;
                startY = pos.y;
                startWidth = root.width;
                startHeight = root.height;
            }
            onPositionChanged: mouse => {
                const pos = mapToItem(null, mouse.x, mouse.y);
                switch (root.edge) {
                case Qt.TopEdge:
                    root.preferredSize = startHeight + pos.y - startY;
                    break;
                case Qt.BottomEdge:
                    root.preferredSize = startHeight - pos.y + startY;
                    break;
                case Qt.RightEdge:
                    root.preferredSize = startWidth - pos.x + startX;
                    break;
                case Qt.LeftEdge:
                default:
                    root.preferredSize = startWidth + pos.x - startX;
                }
            }

            states: [
                State {
                    when: root.edge === Qt.LeftEdge
                    AnchorChanges {
                        target: resizeHandle
                        anchors.top: root.background.top
                        anchors.right: root.background.right
                        anchors.bottom: root.background.bottom
                    }
                },
                State {
                    when: root.edge === Qt.RightEdge
                    AnchorChanges {
                        target: resizeHandle
                        anchors.top: root.background.top
                        anchors.left: root.background.left
                        anchors.bottom: root.background.bottom
                    }
                },
                State {
                    when: root.edge === Qt.TopEdge
                    AnchorChanges {
                        target: resizeHandle
                        anchors.left: root.background.left
                        anchors.right: root.background.right
                        anchors.bottom: root.background.bottom
                    }
                }
                ,
                State {
                    when: root.edge === Qt.BottomEdge
                    AnchorChanges {
                        target: resizeHandle
                        anchors.left: root.background.left
                        anchors.right: root.background.right
                        anchors.top: root.background.top
                    }
                }
            ]
        }
    }
}
