/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2024 Filipe Azevedo <pasnox@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

/*!
  \qmltype ListItemDragHandle
  \inqmlmodule org.kde.kirigami

  \brief A handle to reorder items in a view.

  Implements a drag handle supposed to be in items in ListViews to reorder items.

  The ListView must visualize a model which supports item reordering,
  such as ListModel.move() or QAbstractItemModel  instances with moveRows() correctly implemented.

  In order for ListItemDragHandle to work correctly, the listItem that is being dragged
  should not directly be the delegate of the ListView, but a child of it.

  It is recommended to use DelagateRecycler as base delegate like the following code:
  \code
  import QtQuick
  import QtQuick.Layouts
  import QtQuick.Controls as QQC2
  import org.kde.kirigami as Kirigami
    ...
    Component {
        id: delegateComponent
        QQC2.ItemDelegate {
            id: listItem
            contentItem: RowLayout {
                Kirigami.ListItemDragHandle {
                    listItem: listItem
                    listView: mainList
                    onMoveRequested: (oldIndex, newIndex) => {
                        listModel.move(oldIndex, newIndex, 1);
                    }
                }
                QQC2.Label {
                    text: model.label
                }
            }
        }
    }
    ListView {
        id: mainList

        model: ListModel {
            id: listModel
            ListElement {
                label: "Item 1"
            }
            ListElement {
                label: "Item 2"
            }
            ListElement {
                label: "Item 3"
            }
        }
        //this is optional to make list items animated when reordered
        moveDisplaced: Transition {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        delegate: Loader {
            width: mainList.width
            sourceComponent: delegateComponent
        }
    }
    ...
  \endcode
 */
Item {
    id: root

    /*!
      \brief This property holds the delegate that will be dragged around.

      \note This item must be a child of the actual ListView's delegate.
     */
    property Item listItem

    /*!
      \brief This property holds the ListView that the delegate belong to.
     */
    property ListView listView

    /*!
      \brief This property holds the fact that we are doing incremental move requests or not.
     */
    property bool incrementalMoves: true

    /*!
      \brief This property holds the fact that the handle is being dragged.
     */
    readonly property alias dragActive: mouseArea.drag.active

    /*!
      \brief This signal is emitted when the drag handle wants to move the item in the model.

      The following example does the move in the case a ListModel is used:
      \code
      onMoveRequested: (oldIndex, newIndex) => {
          listModel.move(oldIndex, newIndex, 1);
      }
      \endcode

      \a oldIndex The index the item is currently at.

      \a newIndex The index we want to move the item to.
     */
    signal moveRequested(int oldIndex, int newIndex)

    /*!
      \brief This signal is emitted when the drag operation is complete and the item has been
      dropped in the new final position.

      \a oldIndex The index the item is currently at.

      \a newIndex The index we want to drop the item to.
     */
    signal dropped(int oldIndex, int newIndex)

    implicitWidth: Kirigami.Units.iconSizes.smallMedium
    implicitHeight: Kirigami.Units.iconSizes.smallMedium

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        drag {
            target: listItem
            axis: Drag.YAxis
            minimumY: 0
        }

        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        preventStealing: true

        QtObject {
            id: _previousMove

            property int oldIndex: -1
            property int newIndex: -1

            function reset() {
                _previousMove.oldIndex = -1;
                _previousMove.newIndex = -1;
            }
        }

        Kirigami.Icon {
            id: internal

            anchors.fill: parent

            source: "handle-sort"
            opacity: mouseArea.pressed || (!Kirigami.Settings.tabletMode && listItem.hovered) ? 1 : 0.6

            property int startY
            property int mouseDownY
            property Item originalParent
            property int listItemLastY
            property bool draggingUp

            function arrangeItem() {
                const newIndex = listView.indexAt(1, listView.contentItem.mapFromItem(listItem, 0, listItem.height / 2).y);

                if (newIndex > -1 && ((incrementalMoves && internal.draggingUp && newIndex < index) ||
                                      (incrementalMoves && !internal.draggingUp && newIndex > index) ||
                                      (!incrementalMoves && newIndex < listView.count))) {
                    if (_previousMove.oldIndex === index && _previousMove.newIndex === newIndex) {
                        return;
                    }

                    _previousMove.oldIndex = index;
                    _previousMove.newIndex = newIndex;

                    root.moveRequested(index, newIndex);
                }
            }
        }

        onPressed: mouse => {
            internal.originalParent = listItem.parent;
            listItem.parent = listView;
            listItem.y = internal.originalParent.mapToItem(listItem.parent, listItem.x, listItem.y).y;
            internal.originalParent.z = 99;
            internal.startY = listItem.y;
            internal.listItemLastY = listItem.y;
            internal.mouseDownY = mouse.y;
            // while dragging listItem's height could change
            // we want a const maximumY during the dragging time
            mouseArea.drag.maximumY = listView.height - listItem.height;
        }

        onPositionChanged: mouse => {
            if (!pressed || listItem.y === internal.listItemLastY) {
                return;
            }

            internal.draggingUp = listItem.y < internal.listItemLastY
            internal.listItemLastY = listItem.y;

            internal.arrangeItem();

             // autoscroll when the dragging item reaches the listView's top/bottom boundary
            scrollTimer.running = (listView.contentHeight > listView.height)
                && ((listItem.y === 0 && !listView.atYBeginning)
                    || (listItem.y === mouseArea.drag.maximumY && !listView.atYEnd));
        }

        onReleased: mouse => dropped()
        onCanceled: dropped()

        function dropped() {
            listItem.y = internal.originalParent.mapFromItem(listItem, 0, 0).y;
            listItem.parent = internal.originalParent;
            dropAnimation.running = true;
            scrollTimer.running = false;
            root.dropped(_previousMove.oldIndex, _previousMove.newIndex);
            _previousMove.reset();
        }

        SequentialAnimation {
            id: dropAnimation
            YAnimator {
                target: listItem
                from: listItem.y
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            PropertyAction {
                target: listItem.parent
                property: "z"
                value: 0
            }
        }

        Timer {
            id: scrollTimer

            interval: 50
            repeat: true

            onTriggered: {
                if (internal.draggingUp) {
                    listView.contentY -= Kirigami.Units.gridUnit;
                    if (listView.atYBeginning) {
                        listView.positionViewAtBeginning();
                        stop();
                    }
                } else {
                    listView.contentY += Kirigami.Units.gridUnit;
                    if (listView.atYEnd) {
                        listView.positionViewAtEnd();
                        stop();
                    }
                }
                internal.arrangeItem();
            }
        }
    }
}
