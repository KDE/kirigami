/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import QtQuick.Controls as QQC2
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT
import "private"


// TODO KF6: undo many workarounds to make existing code work?

/*!
  \qmltype ScrollablePage
  \inqmlmodule org.kde.kirigami

  \brief ScrollablePage is a Page that holds scrollable content, such as a ListView.

  Scrolling and scrolling indicators will be automatically managed.

  Example usage:
  \code
  ScrollablePage {
      id: root
      // The page will automatically be scrollable
      Rectangle {
          width: root.width
          height: 99999
      }
  }
  \endcode

  \warning Do not put a ScrollView inside of a ScrollablePage; children of a ScrollablePage are already inside a ScrollView.

  Another behavior added by this class is a "scroll down to refresh" behavior
  It also can give the contents of the flickable to have more top margins in order
  to make possible to scroll down the list to reach it with the thumb while using the
  phone with a single hand.

  Implementations should handle the refresh themselves as follows.

  Example usage:
  \code
  Kirigami.ScrollablePage {
      id: view
      supportsRefreshing: true
      onRefreshingChanged: {
          if (refreshing) {
              myModel.refresh();
          }
      }
      ListView {
          // NOTE: MyModel doesn't come from the components,
          // it's purely an example on how it can be used together
          // some application logic that can update the list model
          // and signals when it's done.
          model: MyModel {
              onRefreshDone: view.refreshing = false;
          }
          delegate: ItemDelegate {}
      }
  }
  [...]
  \endcode
 */
KC.Page {
    id: root

//BEGIN properties
    /*!
      \brief This property tells whether the list is asking for a refresh.

      This property will automatically be set to true when the user pulls the list down enough,
      which in return, shows a loading spinner. When this is set to true, it signals
      the application logic to start its refresh procedure.

      default: \c false

      \note The application itself will have to set back this property to false when done.
     */
    property bool refreshing: false

    /*!
      \brief This property sets whether scrollable page supports "pull down to refresh" behaviour.

      default: \c false
     */
    property bool supportsRefreshing: false

    /*!
      \brief This property holds the main Flickable item of this page.

      here for compatibility; will be removed in KF6.

      \deprecated
     */
    property Flickable flickable: Flickable {} // FIXME KF6: this empty flickable exists for compatibility reasons. some apps assume flickable exists right from the beginning but ScrollView internally assumes it does not
    onFlickableChanged: scrollView.contentItem = flickable;

    /*!
      \brief This property sets the vertical scrollbar policy.

      \sa Qt.ScrollBarPolicy

       Possible values:
       \value QQC2.ScrollBar.AsNeeded The scroll bar is only shown when the content is too large to fit.
       \value QQC2.ScrollBar.AlwaysOff The scroll bar is never shown.
       \value QQC2.ScrollBar.AlwaysOn The scroll bar is always shown.
     */
    property int verticalScrollBarPolicy

    /*!
      \brief Set if the vertical scrollbar should be interactable.
     */
    property bool verticalScrollBarInteractive: true

    /*!
      \brief This property sets the horizontal scrollbar policy.

      \sa Qt::ScrollBarPolicy

      Possible values:
      \value QQC2.ScrollBar.AsNeeded The scroll bar is only shown when the content is too large to fit.
      \value QQC2.ScrollBar.AlwaysOff The scroll bar is never shown.
      \value QQC2.ScrollBar.AlwaysOn The scroll bar is always shown.

      The default value is ScrollBar.AlwaysOff
     */
    property int horizontalScrollBarPolicy: QQC2.ScrollBar.AlwaysOff

    /*!
      \brief Set if the horizontal scrollbar should be interactable.
     */
    property bool horizontalScrollBarInteractive: true

    default property alias scrollablePageData: itemsParent.data
    property alias scrollablePageChildren: itemsParent.children

    /*!
      \deprecated
      here for compatibility; will be removed in KF6.
     */
    property QtObject mainItem
    onMainItemChanged: {
        print("Warning: the mainItem property is deprecated");
        scrollablePageData.push(mainItem);
    }

    /*!
      \brief This property sets whether it is possible to navigate the items in a view that support it.

      If true, and if flickable is an item view (e.g. ListView, GridView), it will be possible
      to navigate the view current items with keyboard up/down arrow buttons.
      Also, any key event will be forwarded to the current list item.

      default: \c true
     */
    property bool keyboardNavigationEnabled: true
//END properties

//BEGIN FUNCTIONS
/*!
  This method checks whether a particular child item is in view, and scrolls
  the page to center the item if it is not.

  If the page is a View, the view should handle this by itself, but if the page is a
  manually handled layout, this needs to be done manually. Otherwise, if the user
  passes focus to an item with e.g. keyboard navigation, this may be outside the
  visible area.

  When called, this method will place the visible area such that the item at the
  center if any part of it is currently outside. If the item is larger than the viewable
  area in either direction, the area will be scrolled such that the top left corner
  is visible.

  \qml
  Kirigami.ScrollablePage {
      id: page
      ColumnLayout {
          Repeater {
              model: 100
              delegate: QQC2.Button {
                  text: modelData
                  onFocusChanged: if (focus) page.ensureVisible(this)
              }
          }
      }
  }
  \endqml

  \a item The item that should be in the visible area of the flickable. Item coordinates need to be in the flickable's coordinate system.

  \a xOffset (optional) Offsets to align the item's and the flickable's coordinate system

  \a yOffset (optional) Offsets to align the item's and the flickable's coordinate system
 */
    function ensureVisible(item: Item, xOffset: int, yOffset: int) {
        var actualItemX = item.x + (xOffset ?? 0)
        var actualItemY = item.y + (yOffset ?? 0)
        var viewXPosition = (item.width <= root.flickable.width)
            ? Math.round(actualItemX + item.width / 2 - root.flickable.width / 2)
            : actualItemX
        var viewYPosition = (item.height <= root.flickable.height)
            ? Math.round(actualItemY + item.height / 2 - root.flickable.height / 2)
            : actualItemY
        if (actualItemX < root.flickable.contentX) {
            root.flickable.contentX = Math.max(0, viewXPosition)
        } else if ((actualItemX + item.width) > (root.flickable.contentX + root.flickable.width)) {
            root.flickable.contentX = Math.min(root.flickable.contentWidth - root.flickable.width, viewXPosition)
        }
        if (actualItemY < root.flickable.contentY) {
            root.flickable.contentY = Math.max(0, viewYPosition)
        } else if ((actualItemY + item.height) > (root.flickable.contentY + root.flickable.height)) {
            root.flickable.contentY = Math.min(root.flickable.contentHeight - root.flickable.height, viewYPosition)
        }
        root.flickable.returnToBounds()
    }
//END FUNCTIONS

    implicitWidth: flickable?.contentItem?.implicitWidth
        ?? Math.max(implicitBackgroundWidth + leftInset + rightInset,
                    contentWidth + leftPadding + rightPadding,
                    implicitHeaderWidth,
                    implicitFooterWidth)

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding
                             + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                             + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

    contentHeight: flickable?.contentHeight ?? 0

    Platform.Theme.inherit: false
    Platform.Theme.colorSet: flickable?.hasOwnProperty("model") ? Platform.Theme.View : Platform.Theme.Window

    Keys.forwardTo: {
        if (root.keyboardNavigationEnabled && root.flickable) {
            if (("currentItem" in root.flickable) && root.flickable.currentItem) {
                return [ root.flickable.currentItem, root.flickable ];
            } else {
                return [ root.flickable ];
            }
        } else {
            return [];
        }
    }

    contentItem: QQC2.ScrollView {
        id: scrollView
        anchors {
            top: root.header?.visible
                    ? root.header.bottom
                    : parent.top
            bottom: root.footer?.visible ? root.footer.top : parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        QQC2.ScrollBar.horizontal.policy: root.horizontalScrollBarPolicy
        QQC2.ScrollBar.horizontal.interactive: root.horizontalScrollBarInteractive
        QQC2.ScrollBar.vertical.policy: root.verticalScrollBarPolicy
        QQC2.ScrollBar.vertical.interactive: root.verticalScrollBarInteractive
    }

    data: [
        // Has to be a MouseArea that accepts events otherwise touch events on Wayland will get lost
        MouseArea {
            id: scrollingArea
            width: root.horizontalScrollBarPolicy === QQC2.ScrollBar.AlwaysOff ? root.flickable.width : Math.max(root.flickable.width, implicitWidth)
            height: Math.max(root.flickable.height, implicitHeight)
            implicitHeight: {
                let implicit = 0;
                for (const child of itemsParent.visibleChildren) {
                    if (child.implicitHeight > 0) {
                        implicit = Math.max(implicit, child.implicitHeight);
                    }
                }
                return implicit + itemsParent.anchors.topMargin + itemsParent.anchors.bottomMargin;
            }
            Item {
                id: itemsParent
                property Flickable flickable
                anchors {
                    fill: parent
                    topMargin: root.topPadding
                    leftMargin: root.leftPadding
                    rightMargin: root.rightPadding
                    bottomMargin: root.bottomPadding
                }
                onChildrenChanged: {
                    const child = children[children.length - 1];
                    if (child instanceof QQC2.ScrollView) {
                        print("Warning: it's not supported to have ScrollViews inside a ScrollablePage")
                    }
                }
            }
            Binding {
                target: root.flickable
                property: "bottomMargin"
                value: root.bottomPadding
                restoreMode: Binding.RestoreBinding
            }
        },

        Loader {
            id: busyIndicatorLoader
            active: root.supportsRefreshing
            sourceComponent: PullDownIndicator {
                parent: root
                active: root.refreshing
                refreshing: root.refreshing
                onTriggered: root.refreshing = true
            }
        }
    ]

    Component.onCompleted: {
        let flickableFound = false;
        for (const child of itemsParent.data) {
            if (child instanceof Flickable) {
                // If there were more flickable children, take the last one, as behavior compatibility
                // with old internal ScrollView
                child.activeFocusOnTab = true;
                root.flickable = child;
                flickableFound = true;
                if (child instanceof ListView) {
                    child.keyNavigationEnabled = true;
                    child.keyNavigationWraps = false;
                }
            } else if (child instanceof Item) {
                child.anchors.left = itemsParent.left;
                child.anchors.right = itemsParent.right;
            } else if (child instanceof KT.OverlaySheet) {
                // Reparent sheets, needs to be done before Component.onCompleted
                if (child.parent === itemsParent || child.parent === null) {
                    child.parent = root;
                }
            }
        }

        if (flickableFound) {
            scrollView.contentItem = root.flickable;
            root.flickable.parent = scrollView;
            // The flickable needs focus only if the page didn't already explicitly set focus to some other control (eg a text field in the header)
            Qt.callLater(() => {
                if (root.activeFocus) {
                    root.flickable.forceActiveFocus();
                }
            });
            // Some existing code incorrectly uses anchors
            root.flickable.anchors.fill = undefined;
            root.flickable.anchors.top = undefined;
            root.flickable.anchors.left = undefined;
            root.flickable.anchors.right = undefined;
            root.flickable.anchors.bottom = undefined;
            scrollingArea.visible = false;
        } else {
            scrollView.contentItem = root.flickable;
            scrollingArea.parent = root.flickable.contentItem;
            scrollingArea.visible = true;
            root.flickable.contentHeight = Qt.binding(() => scrollingArea.implicitHeight - root.flickable.topMargin - root.flickable.bottomMargin);
            scrollView.forceActiveFocus(Qt.TabFocusReason); // QTBUG-44043 : Focus on currentItem instead of pageStack itself
        }
        root.flickable.flickableDirection = Flickable.VerticalFlick;

        // HACK: Qt's default flick deceleration is too high, and we can't change it from plasma-integration, see QTBUG-121500
        root.flickable.flickDeceleration = 1500;
        root.flickable.maximumFlickVelocity = 5000;
    }
}
