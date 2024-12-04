/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "private" as P

/*!
  \qmltype Page
  \inqmlmodule org.kde.kirigami

  \brief A container for all the app pages.

  Everything pushed to the ApplicationWindow's pageStack should be a Page.

  \sa ScrollablePage
  For content that should be scrollable, such as ListViews, use ScrollablePage instead.
 */
QQC2.Page {
    id: root

//BEGIN properties
    padding: Kirigami.Units.gridUnit

    /*!
      \brief If the central element of the page is a Flickable
      (ListView and Gridview as well) you can set it there.

      Normally, you wouldn't need to do that, but just use the
      ScrollablePage element instead.

      Use this if your flickable has some non standard properties, such as not covering the whole Page.

      \sa ScrollablePage
     */
    property Flickable flickable

    /*!
      \qmlproperty list<Action> actions
      \brief This property holds the actions for the page.

      These actions will be displayed in the toolbar on the desktop and inside
      the ContextDrawer on mobile.

      \code
      import org.kde.kirigami as Kirigami

      Kirigami.Page {
          actions: [
              Kirigami.Action {...},
              Kirigami.Action {...}
          }
      }
      \endcode
     */
    property list<T.Action> actions

    /*!
      \brief This property tells us if it is the currently active page.

      Specifies if it's the currently selected page in the window's pages row, or if layers
      are used whether this is the topmost item on the layers stack. If the page is
      not attached to either a column view or a stack view, expect this to be true.

      \since 2.1
     */
    //TODO KF6: remove this or at least all the assumptions about the internal tree structure of items
    // Kirigami.ColumnView.view.parent.parent is the StackView in which the ColumnView is, the condition means "is the ColumnView the current layer of the pagerow"
    readonly property bool isCurrentPage: Kirigami.ColumnView.view
            ? (Kirigami.ColumnView.index === Kirigami.ColumnView.view.currentIndex && Kirigami.ColumnView.view.parent.parent.currentItem === Kirigami.ColumnView.view.parent)
            : (parent && parent instanceof QQC2.StackView
                ? parent.currentItem === root
                : true)

    /*!
      \qmlproperty Item overlay

      An item which stays on top of every other item in the page,
      if you want to make sure some elements are completely in a
      layer on top of the whole content, parent items to this one.
      It's a "local" version of ApplicationWindow's overlay

     */
    readonly property alias overlay: overlayItem

    /*!
      \qmlproperty string Page::icon.name
      \qmlproperty string Page::icon.source
      \qmlproperty int Page::icon.width
      \qmlproperty int Page::icon.height
      \qmlproperty color Page::icon.color

      \brief This holds the icon that represents this page.
     */
    property P.ActionIconGroup icon: P.ActionIconGroup {}

    /*!
      \brief Progress of a task this page is doing.

      Set to undefined to indicate that there are no ongoing tasks.

      default: \c undefined
     */
    property var progress: undefined

    /*!
      \brief The delegate which will be used to draw the page title.

      It can be customized to put any kind of Item in there.

      \since 2.7
     */
    property Component titleDelegate: Component {
        id: defaultTitleDelegate
        P.DefaultPageTitleDelegate {
            text: root.title
        }
    }

    /*!
      The item used as global toolbar for the page
      present only if we are in a PageRow as a page or as a layer,
      and the style is either Titles or ToolBar.

      \since 2.5
     */
    readonly property Item globalToolBarItem: globalToolBar.item

    /*!
      The style for the automatically generated global toolbar.

      By default the Page toolbar is the one set globally in the PageRow in its globalToolBar.style property.

      A single page can override the application toolbar style for itself.
      It is discouraged to use this, except very specific exceptions, like a chat
      application which can't have controls on the bottom except the text field.

      If the Page is not in a PageRow, by default the toolbar will be invisible,
      so has to be explicitly set to Kirigami.ApplicationHeaderStyle.ToolBar if
      desired to be used in that case.
     */
    property int globalToolBarStyle: {
        if (globalToolBar.row && !globalToolBar.stack) {
            return globalToolBar.row.globalToolBar.actualStyle;
        } else if (globalToolBar.stack) {
            return Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.ToolBar;
        } else {
            return Kirigami.ApplicationHeaderStyle.None;
        }
    }
//END properties

//BEGIN signal and signal handlers
    /*!
      \brief Emitted when the application requests a Back action.

      For instance a global "back" shortcut or the Android
      Back button has been pressed.
      The page can manage the back event by itself,
      and if it set event.accepted = true, it will stop the main
      application to manage the back event.
     */
    signal backRequested(var event);

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    // FIXME: on material the shadow would bleed over
    clip: root.header !== null;

    Component.onCompleted: {
        headerChanged();
        parentChanged(root.parent);
        globalToolBar.syncSource();
        bottomToolBar.pageComplete = true
    }

    onParentChanged: {
        if (!parent) {
            return;
        }
        globalToolBar.stack = null;
        globalToolBar.row = null;

        if (root.Kirigami.ColumnView.view) {
            globalToolBar.row = root.Kirigami.ColumnView.view.__pageRow;
        }
        if (root.T.StackView.view) {
            globalToolBar.stack = root.T.StackView.view;
            globalToolBar.row = root.T.StackView.view.parent instanceof Kirigami.PageRow ? root.T.StackView.view.parent : null;
        }
        if (globalToolBar.row) {
            root.globalToolBarStyleChanged.connect(globalToolBar.syncSource);
            globalToolBar.syncSource();
        }
    }
//END signals and signal handlers

    // in data in order for them to not be considered for contentItem, contentChildren, contentData
    data: [
        Item {
            id: overlayItem
            parent: root
            z: 9997
            anchors {
                fill: parent
                topMargin: globalToolBar.height
            }
        }
    ]
    // global top toolbar if we are in a PageRow (in the row or as a layer)
    Kirigami.ColumnView.globalHeader: Loader {
        id: globalToolBar
        z: 9999
        height: item ? item.implicitHeight : 0

        width: root.width
        // NOTE: This is an Item instead of a Kirigami.PageRow as a workaround for QTBUG-120189
        // Once Frameworks can depend from Qt 6.9, this property can be a PageRow again
        property Item row
        property T.StackView stack

        // don't load async so that on slower devices we don't have the page content height changing while loading in
        // otherwise, it looks unpolished and jumpy
        asynchronous: false

        visible: active
        active: root.parent && root.visible && (root.titleDelegate !== defaultTitleDelegate || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.Titles)
        onActiveChanged: {
            if (active) {
                syncSource();
            }
        }

        function syncSource() {
            if (root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar &&
                root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.Titles &&
                root.titleDelegate !== defaultTitleDelegate) {
                sourceComponent = root.titleDelegate;
            } else if (active) {
                const url = root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                    ? "private/globaltoolbar/ToolBarPageHeader.qml"
                    : "private/globaltoolbar/TitlesPageHeader.qml";
                // TODO: find container reliably, remove assumption
                setSource(Qt.resolvedUrl(url), {
                    pageRow: Qt.binding(() => row),
                    page: root,
                    current: Qt.binding(() => {
                        if (!row && !stack) {
                            return true;
                        } else if (stack) {
                            return stack;
                        } else {
                            return row.currentIndex === root.Kirigami.ColumnView.level;
                        }
                    }),
                });
            }
        }
    }
    // bottom action buttons
    Kirigami.ColumnView.globalFooter: Loader {
        id: bottomToolBar

        property T.Page page: root
        property bool pageComplete: false

        visible: active

        active: {
            // Important! Do not do anything until the page has been
            // completed, so we are sure what the globalToolBarStyle is,
            // otherwise we risk creating the content and then discarding it.
            if (!pageComplete) {
                return false;
            }

            if ((globalToolBar.row && globalToolBar.row.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.ToolBar)
                || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.None) {
                return false;
            }

            if (root.actions.length === 0) {
                return false;
            }

            // Legacy
            if (typeof applicationWindow === "undefined") {
                return true;
            }

            const drawer = applicationWindow() ? applicationWindow()['contextDrawer'] : undefined;
            if (Boolean(drawer) && drawer.enabled && drawer.handleVisible) {
                return false;
            }

            return true;
        }

        source: Qt.resolvedUrl("./private/globaltoolbar/ToolBarPageFooter.qml")
    }

    Layout.fillWidth: true
}
