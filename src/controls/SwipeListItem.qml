/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import "private"

/*!
  \qmltype SwipeListItem
  \inqmlmodule org.kde.kirigami

  An item delegate intended to support extra actions obtainable
  by uncovering them by dragging away the item with the handle.

  This acts as a container for normal list items.

  Example usage:
  \code
  ListView {
      model: myModel
      delegate: SwipeListItem {
          QQC2.Label {
              text: model.text
          }
          actions: [
               Action {
                   icon.name: "document-decrypt"
                   onTriggered: print("Action 1 clicked")
               },
               Action {
                   icon.name: model.action2Icon
                   onTriggered: //do something
               }
          ]
      }

  }
  \endcode
*/
QQC2.SwipeDelegate {
    id: listItem

//BEGIN properties
    /*!
      \qmlproperty bool SwipeListItem::supportsMouseEvents
      \brief This property sets whether the item should emit signals related to mouse interaction.

      \default true

      \deprecated Use hoverEnabled instead.
     */
    property alias supportsMouseEvents: listItem.hoverEnabled

    /*!
      \qmlproperty bool SwipeListItem::containsMouse
      \brief This property tells whether the cursor is currently hovering over the item.

      On mobile touch devices, this will be true only when pressed.

      \sa ItemDelegate::hovered
      \deprecated use the hovered property instead.
     */
    readonly property alias containsMouse: listItem.hovered

    /*!
      \brief This property sets whether instances of this list item will alternate
      between two colors, helping readability.

      It is suggested to use this only when implementing a view with multiple columns.

      \default false
     */
    property bool alternatingBackground: false

    /*!
      \brief This property sets whether this item is a section delegate.

      Setting this to true will make the list item look like a "title" for items under it.

      \default false

      \sa ListSectionHeader
     */
    property bool sectionDelegate: false

    /*!
      \brief This property sets whether the separator is visible.

      The separator is a line between this and the item under it.

      \default false
     */
    property bool separatorVisible: false

    /*!
      \brief This property holds the background color of the list item.

      It is advised to use the default value.

      \default Kirigami.Theme.backgroundColor
     */
    property color backgroundColor: Kirigami.Theme.backgroundColor

    /*!
      \brief This property holds the background color to be used when
      background alternating is enabled.

      It is advised to use the default value.
      \default: Kirigami.Theme.alternateBackgroundColor

     */
    property color alternateBackgroundColor: Kirigami.Theme.alternateBackgroundColor

    /*!
      \brief This property holds the color of the background
      when the item is pressed or selected.

      It is advised to use the default value.
      \default Kirigami.Theme.highlightColor
     */
    property color activeBackgroundColor: Kirigami.Theme.highlightColor

    /*!
      \brief This property holds the color of the text in the item.

      It is advised to use the default value.
      \default Theme.textColor

      If custom text elements are inserted in a SwipeListItem,
      their color will have to be manually set with this property.
     */
    property color textColor: Kirigami.Theme.textColor

    /*!
      \brief This property holds the color of the text when the item is pressed or selected.

      It is advised to use the default value.
      default: Kirigami.Theme.highlightedTextColor

      If custom text elements are inserted in a SwipeListItem,
      their color property will have to be manually bound with this property
     */
    property color activeTextColor: Kirigami.Theme.highlightedTextColor

    /*!
      \brief This property tells whether actions are visible and interactive.

      True if it's possible to see and interact with the item's actions.

      Actions become hidden while editing of an item, for example.

     */
    readonly property bool actionsVisible: actionsLayout.hasVisibleActions

    /*!
      \brief This property sets whether actions behind this SwipeListItem will always be visible.

      default: true in desktop and tablet mode

     */
    property bool alwaysVisibleActions: !Kirigami.Settings.isMobile

    /*!
      \brief This property holds actions of the list item.

      At most 4 actions can be revealed when sliding away the list item;
      others will be shown in the overflow menu.
     */
    property list<T.Action> actions

    /*!
      \qmlproperty real SwipeListItem::overlayWidth

      \brief This property holds the width of the overlay.

      The value can represent the width of the handle component or the action layout.
     */
    readonly property alias overlayWidth: overlayLoader.width

//END properties

    property ListView listView;

    LayoutMirroring.childrenInherit: true

    hoverEnabled: true
    implicitHeight: Math.max(actionsLayout.implicitHeight, contentItem.implicitHeight) + topPadding + bottomPadding
    implicitWidth: Math.max(actionsLayout.implicitWidth, contentItem.implicitWidth) + leftPadding + rightPadding
    width: parent ? parent.width : implicitWidth

    Keys.onTabPressed: (event) => {
        if (actionsLayout.hasVisibleActions) {
            actionsLayout.children[0].tabbedFromDelegate = true
            actionsLayout.children[0].forceActiveFocus(Qt.TabFocusReason)
        } else {
            event.accepted = false
        }
    }

    Keys.onPressed: (event) => {
        if ((actionsLayout.hasVisibleActions && activeFocus && event.key == Qt.Key_Right && Application.layoutDirection == Qt.LeftToRight) ||
            (actionsLayout.hasVisibleActions && activeFocus && event.key == Qt.Key_Left && Application.layoutDirection == Qt.RightToLeft)) {
            for (var target = 0; target < actionsRep.count; target ++) {
                if (actionsLayout.children[target].visible) {
                    break
                }
            }
            if (target < actionsRep.count) {
                actionsLayout.children[target].forceActiveFocus(Qt.TabFocusReason)
                event.accepted = true
            }
        }
    }

    QtObject {
        id: internal

        property Flickable view: listItem.ListView.view || (listItem.parent ? (listItem.parent.ListView.view || (listItem.parent instanceof Flickable ? listItem.parent : null)) : null)

        function viewHasPropertySwipeFilter(): bool {
            return view && view.parent && view.parent.parent && "_swipeFilter" in view.parent.parent;
        }

        readonly property QtObject swipeFilterItem: (viewHasPropertySwipeFilter() && view.parent.parent._swipeFilter) ? view.parent.parent._swipeFilter : null

        readonly property bool edgeEnabled: swipeFilterItem ? swipeFilterItem.currentItem === listItem || swipeFilterItem.currentItem === listItem.parent : false

        // install the SwipeItemEventFilter
        onViewChanged: {
            if (listItem.alwaysVisibleActions || !Kirigami.Settings.tabletMode) {
                return;
            }
            if (viewHasPropertySwipeFilter() && Kirigami.Settings.tabletMode && !internal.view.parent.parent._swipeFilter) {
                const component = Qt.createComponent(Qt.resolvedUrl("../private/SwipeItemEventFilter.qml"));
                internal.view.parent.parent._swipeFilter = component.createObject(internal.view.parent.parent);
                component.destroy();
            }
        }
    }

    Connections {
        target: Kirigami.Settings
        function onTabletModeChanged() {
            if (!internal.viewHasPropertySwipeFilter()) {
                return;
            }
            if (Kirigami.Settings.tabletMode) {
                if (!internal.swipeFilterItem) {
                    const component = Qt.createComponent(Qt.resolvedUrl("../private/SwipeItemEventFilter.qml"));
                    listItem.ListView.view.parent.parent._swipeFilter = component.createObject(listItem.ListView.view.parent.parent);
                    component.destroy();
                }
            } else {
                if (listItem.ListView.view.parent.parent._swipeFilter) {
                    listItem.ListView.view.parent.parent._swipeFilter.destroy();
                    slideAnim.to = 0;
                    slideAnim.restart();
                }
            }
        }
    }

//BEGIN items
    Loader {
        id: overlayLoader
        readonly property int paddingOffset: (visible ? width : 0) + Kirigami.Units.smallSpacing
        readonly property var theAlias: anchors
        function validate(want, defaultValue) {
            const expectedLeftPadding = () => listItem.padding * 2 + (listItem.mirrored ? overlayLoader.paddingOffset : 0)
            const expectedRightPadding = () => listItem.padding * 2 + (listItem.mirrored ? 0 : overlayLoader.paddingOffset)

            const warningText =
                `Don't override the leftPadding or rightPadding on a SwipeListItem!\n` +
                `This makes it impossible for me to adjust my layout as I need to for various usecases.\n` +
                `I'll try to fix the mistake for you, but you should remove your overrides from your app's code entirely.\n` +
                `If I can't fix the paddings, I'll fall back to a default layout, but it'll be slightly incorrect and lacks\n` +
                `adaptations needed for touch screens and right-to-left languages, among other things.`

            if (listItem.leftPadding != expectedLeftPadding() || listItem.rightPadding != expectedRightPadding()) {
                console.warn(warningText)
                return defaultValue
            }

            return want
        }

        states: State {
            name: "reanchored"
            AnchorChanges {
                target: overlayLoader
                anchors.right: listItem.contentItem.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: overlayLoader
                anchors.topMargin: listItem.topPadding
                anchors.bottomMargin: listItem.bottomPadding
            }
        }
        Component.onCompleted: overlayLoader.state = "reanchored"

        LayoutMirroring.enabled: false

        parent: listItem
        z: contentItem ? contentItem.z + 1 : 0
        width: item ? item.implicitWidth : actionsLayout.implicitWidth
        active: !listItem.alwaysVisibleActions && Kirigami.Settings.tabletMode
        visible: listItem.actionsVisible && opacity > 0
        asynchronous: true
        sourceComponent: handleComponent
        opacity: listItem.alwaysVisibleActions || Kirigami.Settings.tabletMode || listItem.hovered ? 1 : 0
        Behavior on opacity {
            OpacityAnimator {
                id: opacityAnim
                duration: Kirigami.Units.veryShortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component {
        id: handleComponent

        MouseArea {
            id: dragButton
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            preventStealing: true
            readonly property real openPosition: (listItem.width - width - listItem.leftPadding * 2)/listItem.width
            property real startX: 0
            property real lastPosition: 0
            property bool openIntention

            onPressed: mouse => {
                startX = mapToItem(listItem, 0, 0).x;
            }
            onClicked: mouse => {
                if (Math.abs(mapToItem(listItem, 0, 0).x - startX) > Qt.styleHints.startDragDistance) {
                    return;
                }
                if (listItem.mirrored) {
                    if (listItem.swipe.position < 0.5) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (listItem.swipe.position > -0.5) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }
            onPositionChanged: mouse => {
                const pos = mapToItem(listItem, mouse.x, mouse.y);

                if (listItem.mirrored) {
                    listItem.swipe.position = Math.max(0, Math.min(openPosition, (pos.x / listItem.width)));
                    openIntention = listItem.swipe.position > lastPosition;
                } else {
                    listItem.swipe.position = Math.min(0, Math.max(-openPosition, (pos.x / (listItem.width - listItem.rightPadding) - 1)));
                    openIntention = listItem.swipe.position < lastPosition;
                }
                lastPosition = listItem.swipe.position;
            }
            onReleased: mouse => {
                if (listItem.mirrored) {
                    if (openIntention) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (openIntention) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }

            Kirigami.Icon {
                id: handleIcon
                anchors.fill: parent
                selected: listItem.checked || (listItem.down && !listItem.checked && !listItem.sectionDelegate)
                source: (listItem.mirrored ? (listItem.background.x < listItem.background.width/2 ? "overflow-menu-right" : "overflow-menu-left") : (listItem.background.x < -listItem.background.width/2 ? "overflow-menu-right" : "overflow-menu-left"))
            }

            Connections {
                id: swipeFilterConnection

                target: internal.edgeEnabled ? internal.swipeFilterItem : null
                function onPeekChanged() {
                    if (!listItem.actionsVisible) {
                        return;
                    }

                    if (listItem.mirrored) {
                        listItem.swipe.position = Math.max(0, Math.min(dragButton.openPosition, internal.swipeFilterItem.peek));
                        dragButton.openIntention = listItem.swipe.position > dragButton.lastPosition;

                    } else {
                        listItem.swipe.position = Math.min(0, Math.max(-dragButton.openPosition, -internal.swipeFilterItem.peek));
                        dragButton.openIntention = listItem.swipe.position < dragButton.lastPosition;
                    }

                    dragButton.lastPosition = listItem.swipe.position;
                }
                function onPressed(mouse) {
                    if (internal.edgeEnabled) {
                        dragButton.pressed(mouse);
                    }
                }
                function onClicked(mouse) {
                    if (Math.abs(listItem.background.x) < Kirigami.Units.gridUnit && internal.edgeEnabled) {
                        dragButton.clicked(mouse);
                    }
                }
                function onReleased(mouse) {
                    if (internal.edgeEnabled) {
                        dragButton.released(mouse);
                    }
                }
                function onCurrentItemChanged() {
                    if (!internal.edgeEnabled) {
                        slideAnim.to = 0;
                        slideAnim.restart();
                    }
                }
            }
        }
    }

    // TODO: expose in API?
    Component {
        id: actionsBackgroundDelegate
        Item {
            anchors.fill: parent
            z: 1

            readonly property Item contentItem: swipeBackground
            Rectangle {
                id: swipeBackground
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                clip: true
                color: parent.pressed ? Qt.darker(Kirigami.Theme.backgroundColor, 1.1) : Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
                x: listItem.mirrored ? listItem.background.x - width : (listItem.background.x + listItem.background.width)
                width: listItem.mirrored ? parent.width - (parent.width - x) : parent.width - x

                TapHandler {
                    onTapped: listItem.swipe.close()
                }
                EdgeShadow {
                    edge: Qt.TopEdge
                    visible: background.x != 0
                    anchors {
                        right: parent.right
                        left: parent.left
                        top: parent.top
                    }
                }
                EdgeShadow {
                    edge: listItem.mirrored ? Qt.RightEdge : Qt.LeftEdge

                    visible: background.x != 0
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                }
            }

            visible: listItem.swipe.position != 0
        }
    }


    RowLayout {
        id: actionsLayout

        LayoutMirroring.enabled: listItem.mirrored
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        visible: parent !== listItem
        parent: !listItem.alwaysVisibleActions && Kirigami.Settings.tabletMode
                ? listItem.swipe.leftItem?.contentItem || listItem.swipe.rightItem?.contentItem || listItem
                : overlayLoader

        property bool hasVisibleActions: false
        property int indexInListView: (typeof index !== 'undefined' && index !== null) ? index : -1 // might not be set if using required properties

        function updateVisibleActions(definitelyVisible: bool) {
            hasVisibleActions = definitelyVisible || listItem.actions.some(isActionVisible);
        }

        function isActionVisible(action: T.Action): bool {
            return (action instanceof Kirigami.Action) ? action.visible : true;
        }

        Repeater {
            id: actionsRep
            model: listItem.actions

            delegate: QQC2.ToolButton {
                required property T.Action modelData
                required property int index

                property bool tabbedFromDelegate: false

                action: modelData
                display: T.AbstractButton.IconOnly
                visible: {
                    let newVisible = actionsLayout.isActionVisible(action)
                    actionsLayout.updateVisibleActions(newVisible)
                    return newVisible
                }

                Component.onCompleted: actionsLayout.updateVisibleActions(visible);
                Component.onDestruction: actionsLayout.updateVisibleActions(visible);

                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.visible: (Kirigami.Settings.tabletMode ? pressed : hovered) && QQC2.ToolTip.text.length > 0
                QQC2.ToolTip.text: (action as Kirigami.Action)?.tooltip ?? action?.text ?? ""

                onClicked: {
                    slideAnim.to = 0;
                    slideAnim.restart();
                }

                Keys.onBacktabPressed: (event) => {
                    if (tabbedFromDelegate) {
                        listItem.forceActiveFocus(Qt.BacktabFocusReason)
                    } else {
                        event.accepted = false
                    }
                }

                Keys.onPressed: (event) => {
                    if ((Application.layoutDirection == Qt.LeftToRight && event.key == Qt.Key_Left) ||
                        (Application.layoutDirection == Qt.RightToLeft && event.key == Qt.Key_Right)) {
                        for (var target = index -1; target>=0; target--) {
                            if (target == -1 || actionsLayout.children[target].visible) {
                                break
                            }
                        }
                        if (target == -1) {
                            listItem.forceActiveFocus(Qt.BacktabFocusReason)
                        } else {
                            actionsLayout.children[target].tabbedFromDelegate = tabbedFromDelegate
                            actionsLayout.children[target].forceActiveFocus(Qt.TabFocusReason)
                        }
                        event.accepted = true
                    } else if ((Application.layoutDirection == Qt.LeftToRight && event.key == Qt.Key_Right) ||
                               (Application.layoutDirection == Qt.RightToLeft && event.key == Qt.Key_Left)) {
                        var found=false
                        for (var target = index +1; target<actionsRep.count; target++) {
                            if (actionsLayout.children[target].visible) {
                                break
                            }
                        }
                        if (target < (actionsRep.count)) {
                            actionsLayout.children[target].tabbedFromDelegate = tabbedFromDelegate
                            actionsLayout.children[target].forceActiveFocus(Qt.TabFocusReason)
                            event.accepted = true
                        }
                    }
                }

                Keys.onUpPressed: (event) => {
                    if (listview && actionsLayout.indexInListView >= 0) {
                        listView.currentIndex = actionsLayout.indexInListView
                    }
                    event.accepted = false // pass to ListView
                }

                Keys.onDownPressed: (event) => {
                    if (listView && actionsLayout.indexInListView >= 0) {
                        listView.currentIndex = actionsLayout.indexInListView
                    }
                    event.accepted = false // pass to ListView
                }

                onActiveFocusChanged: {
                    if (focus && listView) {
                        listView.positionViewAtIndex(actionsLayout.indexInListView, ListView.Contain)
                    } else if (!focus) {
                        tabbedFromDelegate = false
                    }
                }

                Accessible.name: text
                Accessible.description: (action as Kirigami.Action)?.tooltip ?? ""
            }
        }
    }

    swipe {
        enabled: false
        right: listItem.alwaysVisibleActions || listItem.mirrored || !Kirigami.Settings.tabletMode ? null : actionsBackgroundDelegate
        left: listItem.alwaysVisibleActions || listItem.mirrored && Kirigami.Settings.tabletMode ? actionsBackgroundDelegate : null
    }
    NumberAnimation {
        id: slideAnim
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
        target: listItem.swipe
        property: "position"
        from: listItem.swipe.position
    }
//END items

    Component.onCompleted: {
        listView: {
            for (var targetItem = listItem; (targetItem.ListView.view === null); targetItem = targetItem.parent) {
            }
            listView = targetItem.ListView.view
        }
    }
}
