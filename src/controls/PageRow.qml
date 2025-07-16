/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as QT
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "private/globaltoolbar" as GlobalToolBar
import org.kde.kirigami.templates as KT

/*!
  \qmltype PageRow
  \inqmlmodule org.kde.kirigami

  \brief A row-based navigation model that can be used
  with a set of interlinked information pages.

  Pages are pushed in the back of the row and the view scrolls
  until that row is visualized.
  A PageRow can show a single page or a multiple set of columns, depending
  on the window width: on a phone a single column should be fullscreen,
  while on a tablet or a desktop more than one column should be visible.

 */
QT.Control {
    id: root

//BEGIN PROPERTIES
    /*!
      \qmlproperty int PageRow::depth
      \brief This property holds the number of pages currently pushed onto the view.
     */
    readonly property alias depth: columnView.count

    /*!
      \qmlproperty Page PageRow::lastItem
      \brief This property holds the last page in the row.
     */
    readonly property Item lastItem: columnView.contentChildren.length > 0 ?  columnView.contentChildren[columnView.contentChildren.length - 1] : null

    /*!
      \qmlproperty Page PageRow::currentItem
      \brief This property holds the currently visible/active page.

      Because of the ability to display multiple pages, it will hold the currently active page.

     */
    readonly property alias currentItem: columnView.currentItem

    /*!
      \qmlproperty int PageRow::currentIndex
      \brief This property holds the index of the currently active page.
      \sa currentItem
     */
    property alias currentIndex: columnView.currentIndex

    /*!
      \qmlproperty Page PageRow::initialPage
      \brief This property sets the initial page for this PageRow.
     */
    property var initialPage

    contentItem: columnView

    /*!
      \qmlproperty ColumnView PageRow::columnView
      \brief This property holds the ColumnView that this PageRow owns.

      Generally, you shouldn't need to change the value of this property.

      \since 2.12
     */
    property alias columnView: columnView

    /*!
      \qmlproperty list<Page> PageRow::items
      \brief This property holds the present pages in the PageRow.
      \since 2.6
     */
    readonly property alias items: columnView.contentChildren

    /*!
      \qmlproperty list<Page> PageRow::visibleItems
      \brief This property holds all visible pages in the PageRow,
      excluding those which are scrolled away.
      \since 2.6
     */
    readonly property alias visibleItems: columnView.visibleItems

    /*!
      \qmlproperty Item PageRow::leadingVisibleItem
      \brief This property holds the first page in the PageRow that is at least partially visible.
      \note Pages before that one (the one contained in the property) will be out of the viewport.
      \sa ColumnView::leadingVisibleItem
      \since 2.6
     */
    readonly property alias leadingVisibleItem: columnView.leadingVisibleItem

    /*!
      \qmlproperty Item PageRow::trailingVisibleItem
      \brief This property holds the last page in the PageRow that is at least partially visible.
      \note Pages after that one (the one contained in the property) will be out of the viewport.
      \sa ColumnView::trailingVisibleItem
      \since 2.6
     */
    readonly property alias trailingVisibleItem: columnView.trailingVisibleItem

    /*!
      \brief This property holds the default width for a column.

      default: \c{20 * Kirigami.Units.gridUnit}

      \note Pages can override it using implicitWidth, Layout.fillWidth, Layout.minimumWidth etc.
     */
    property int defaultColumnWidth: Kirigami.Units.gridUnit * 20

    /*!
      \qmlproperty bool PageRow::interactive

      \brief This property sets whether it is possible to go back/forward
      by swiping with a gesture on the content view.

      default: \c true

     */
    property alias interactive: columnView.interactive

    /*!
      \brief This property tells whether the PageRow is wide enough to show multiple pages.
      \since 5.37
     */
    readonly property bool wideMode: width >= defaultColumnWidth * 2 && depth >= 2

    /*!
      \qmlproperty bool PageRow::separatorVisible

      \brief This property sets whether the separators between pages should be displayed.

      default: \c true

      \since 5.38
     */
    property alias separatorVisible: columnView.separatorVisible

    /*!
      \qmlproperty var PageRow::globalToolBar

      \brief This property sets the appearance of an optional global toolbar for the whole PageRow.

      It's a grouped property comprised of the following properties:
      \list
      \li style (Kirigami.ApplicationHeaderStyle): can have the following values:
       \list
       \li Auto: Depending on application formfactor, it can behave automatically like other values, such as a Breadcrumb on mobile and ToolBar on desktop.
       \li Breadcrumb: It will show a breadcrumb of all the page titles in the stack, for easy navigation.
       \li Titles: Each page will only have its own title on top.
       \li ToolBar: Each page will have the title on top together buttons and menus to represent all of the page actions. Not available on Mobile systems.
       \li None: No global toolbar will be shown.
       \endlist

      \li actualStyle: This will represent the actual style of the toolbar; it can be different from style in the case style is Auto.
      \li showNavigationButtons: OR flags combination of Kirigami.ApplicationHeaderStyle.ShowBackButton and Kirigami.ApplicationHeaderStyle.ShowForwardButton.
      \li toolbarActionAlignment (Qt::Alignment): How to horizontally align the actions when using the ToolBar style. Note that anything but Qt.AlignRight will cause the title to be hidden (default: Qt.AlignRight).
      \li minimumHeight: int Minimum height of the header, which will be resized when scrolling. Only in Mobile mode (default: preferredHeight, sliding but no scaling).
      \li preferredHeight: int The height the toolbar will usually have.
      \li leftReservedSpace: int, readonly How many pixels of extra space are reserved at the left of the page toolbar (typically for navigation buttons or a drawer handle).
      \li rightReservedSpace: int, readonly How many pixels of extra space  are reserved at the right of the page toolbar (typically for a drawer handle).
      \endlist

      \since 5.48
     */
    readonly property alias globalToolBar: globalToolBar

    /*!
      \brief This property assigns a drawer as an internal left sidebar for this PageRow.

      In this case, when open and not modal, the drawer contents will be in the same layer as the base pagerow.
      Pushing any other layer on top will cover the sidebar.

      \since 5.84
     */
    // TODO KF6: globaldrawer should use actions also used by this sidebar instead of reparenting globaldrawer contents?
    property OverlayDrawer leftSidebar

    /*!
      \qmlproperty QtQuick.Controls.StackView PageRow::layers
      \brief This property holds the modal layers.

      Sometimes an application needs a modal page that always covers all the rows.
      For instance the full screen image of an image viewer or a settings page.

      \since 5.38
     */
    property alias layers: layersStack

    /*!
      \brief This property holds whether to automatically pop pages at the top of the stack if they are not visible.

      If a user navigates to a previous page on the stack (ex. pressing back button) and pages above
      it on the stack are not visible, they will be popped if this property is true.

      \since 5.101
     */
    property bool popHiddenPages: false
//END PROPERTIES

//BEGIN FUNCTIONS
    /*!
      \qmlmethod Page PageRow::push(var page, var properties)

      \brief This method pushes a page on the stack.

      A single page can be defined as an url, a component, or an object. It can
      also be an array of the above said types, but in that case, the
      properties' array length must match pages' array length or it must be
      empty. Failing to comply with the following rules will make the method
      return null before doing anything.

      \a page A single page or an array of pages.

      \a properties A single property object or an array of property
      objects.

      Returns The new created page (or the last one if it was an array).
     */
    function push(page, properties): QT.Page {
        if (!pagesLogic.verifyPages(page, properties)) {
            console.warn("Pushed pages do not conform to the rules. Please check the documentation.");
            console.trace();
            return null
        }

        const item = pagesLogic.insertPage_unchecked(currentIndex + 1, page, properties)
        currentIndex = depth - 1
        return item
    }

    /*!
      \qmlmethod Page PageRow::pushDialogLayer(var page, var properties, var windowProperties)

      \brief Pushes a page as a new dialog on desktop and as a layer on mobile.

      \a page A single page defined as either a string url, a component or
      an object (which will be reparented). The following page gains
      closeDialog() method allowing to make it indistinguishable to
      close/hide it when in desktop or mobile mode. Note that Kiriami supports
      calling closeDialog() only once.

      \a properties The properties given when initializing the page.

      \a windowProperties The properties given to the initialized window on desktop.

      Returns a newly created page.
     */
    function pushDialogLayer(page, properties = {}, windowProperties = {}): QT.Page {
        if (!pagesLogic.verifyPages(page, properties)) {
            console.warn("Page pushed as a dialog or layer does not conform to the rules. Please check the documentation.");
            console.trace();
            return null
        }
        let item;
        if (Kirigami.Settings.isMobile) {
            if (QQC2.ApplicationWindow.window.width > Kirigami.Units.gridUnit * 40) {
                // open as a QQC2.Dialog
                const component = pagesLogic.getMobileDialogLayerComponent();
                const dialog = component.createObject(QQC2.Overlay.overlay, {
                    width: Qt.binding(() => QQC2.ApplicationWindow.window.width - Kirigami.Units.gridUnit * 5),
                    height: Qt.binding(() => QQC2.ApplicationWindow.window.height - Kirigami.Units.gridUnit * 5),
                    x: Kirigami.Units.gridUnit * 2.5,
                    y: Kirigami.Units.gridUnit * 2.5,
                });

                if (typeof page === "string") {
                    // url => load component and then load item from component
                    const component = Qt.createComponent(Qt.resolvedUrl(page));
                    item = component.createObject(dialog.contentItem, properties);
                    component.destroy();
                    dialog.contentItem.contentItem = item
                } else if (page instanceof Component) {
                    item = page.createObject(dialog.contentItem, properties);
                    dialog.contentItem.contentItem = item
                } else if (page instanceof Item) {
                    item = page;
                    page.parent = dialog.contentItem;
                } else if (typeof page === 'object' && typeof page.toString() === 'string') { // url
                    const component = Qt.createComponent(page);
                    item = component.createObject(dialog.contentItem, properties);
                    component.destroy();
                    dialog.contentItem.contentItem = item
                }
                dialog.title = Qt.binding(() => item.title);

                // Pushing a PageRow is supported but without PageRow toolbar
                if (item.globalToolBar && item.globalToolBar.style) {
                    item.globalToolBar.style = Kirigami.ApplicationHeaderStyle.None
                }
                Object.defineProperty(item, 'closeDialog', {
                    value: function() {
                        dialog.close();
                    }
                });
                dialog.open();
            } else {
                // open as a layer
                if (root.globalToolBar.style !== Kirigami.ApplicationHeaderStyle.Breadcrumb) {
                    properties.globalToolBarStyle = root.globalToolBar.style
                }
                item = layers.push(page, properties);
                Object.defineProperty(item, 'closeDialog', {
                    value: function() {
                        layers.pop();
                    }
                });
            }
        } else {
            // open as a new window
            if (!("modality" in windowProperties)) {
                windowProperties.modality = Qt.WindowModal;
            }
            if (!("height" in windowProperties)) {
                windowProperties.height = Kirigami.Units.gridUnit * 30;
            }
            if (!("width" in windowProperties)) {
                windowProperties.width = Kirigami.Units.gridUnit * 50;
            }
            if (!("minimumWidth" in windowProperties)) {
                windowProperties.minimumWidth = Kirigami.Units.gridUnit * 20;
            }
            if (!("minimumHeight" in windowProperties)) {
                windowProperties.minimumHeight = Kirigami.Units.gridUnit * 15;
            }
            if (!("flags" in windowProperties)) {
                windowProperties.flags = Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint;
            }
            const windowComponent = Qt.createComponent(Qt.resolvedUrl("./ApplicationWindow.qml"));
            const window = windowComponent.createObject(root, windowProperties);
            windowComponent.destroy();
            item = window.pageStack.push(page, properties);
            Object.defineProperty(item, 'closeDialog', {
                value: function() {
                    window.close();
                }
            });
        }
        item.Keys.escapePressed.connect(event => item.closeDialog());
        return item;
    }

    /*!
      \qmlmethod Page PageRow::insertPage(int position, var page, var properties)

      \brief Inserts a new page or a list of new pages at an arbitrary position.

      A single page can be defined as an url, a component, or an object. It can
      also be an array of the above said types, but in that case, the
      properties' array length must match pages' array length or it must be
      empty. Failing to comply with the following rules will make the method
      return null before doing anything.

      \a page A single page or an array of pages.

      \a properties A single property object or an array of property
      objects.

      Returns the new created page (or the last one if it was an array).
      \since 2.7
     */
    function insertPage(position, page, properties): QT.Page {
        if (!pagesLogic.verifyPages(page, properties)) {
            console.warn("Inserted pages do not conform to the rules. Please check the documentation.");
            console.trace();
            return null
        }

        if (position < 0 || position > depth) {
            console.warn("You are trying to insert a page to an out-of-bounds position. Position will be adjusted accordingly.");
            console.trace();
            position = Math.max(0, Math.min(depth, position));
        }
        return pagesLogic.insertPage_unchecked(position, page, properties)
    }

    /*!
      \qmlmethod void PageRow::movePage(int fromPos, int toPos)

      Move the page at position fromPos to the new position toPos
      If needed, currentIndex will be adjusted
      in order to keep the same current page.
      \since 2.7
     */
    function movePage(fromPos, toPos): void {
        columnView.moveItem(fromPos, toPos);
    }

    /*!
      \qmlmethod Page PageRow::removePage(var page)

      \brief Remove the given page.

      \a page The page can be given both as integer position or by reference

      Returns the page that has just been removed
      \since 2.7
     */
    function removePage(page): QT.Page {
        if (depth > 0) {
            return columnView.removeItem(page);
        }
        return null
    }

    /*!
      \qmlmethod Page PageRow::pop(var page)

      \brief Pops a page off the stack.
      \a page If page is specified then the stack is unwound to that page,
      to unwind to the first page specify page as null.

      Returns the page instance that was popped off the stack.
     */
    function pop(page): QT.Page {
        return columnView.pop(page);
    }

    /*!
      \qmlmethod Page PageRow::repace(var page, var properties)

      \brief Replaces a page on the current index.

      A single page can be defined as an url, a component, or an object. It can
      also be an array of the above said types, but in that case, the
      properties' array length must match pages' array length or it must be
      empty. Failing to comply with the following rules will make the method
      return null before doing anything.

      \a page A single page or an array of pages.

      \a properties A single property object or an array of property
      objects.

      Returns the new created page (or the last one if it was an array).
      See push() for details.
     */
    function replace(page, properties): QT.Page {
        if (!pagesLogic.verifyPages(page, properties)) {
            console.warn("Specified pages do not conform to the rules. Please check the documentation.");
            console.trace();
            return null
        }

        // Remove all pages on top of the one being replaced.
        if (currentIndex >= 0) {
            columnView.pop(currentIndex);
        } else {
            console.warn("There's no page to replace");
        }

        // Figure out if more than one page is being pushed.
        let pages;
        let propsArray = [];
        if (page instanceof Array) {
            pages = page;
            page = pages.shift();
        }
        if (properties instanceof Array) {
            propsArray = properties;
            properties = propsArray.shift();
        } else {
            propsArray = [properties];
        }

        // Replace topmost page.
        let pageItem = pagesLogic.initPage(page, properties);
        if (depth > 0)
            columnView.replaceItem(depth - 1, pageItem);
        else {
            console.log("Calling replace on empty PageRow", pageItem)
            columnView.addItem(pageItem)
        }
        pagePushed(pageItem);

        // Push any extra defined pages onto the stack.
        if (pages) {
            for (const i in pages) {
                const tPage = pages[i];
                const tProps = propsArray[i];

                pageItem = pagesLogic.initPage(tPage, tProps);
                columnView.addItem(pageItem);
                pagePushed(pageItem);
            }
        }

        currentIndex = depth - 1;
        return pageItem;
    }

    /*!
      \qmlmethod void PageRow::clear()
      \brief Clears the page stack.

      Destroy (or reparent) all the pages contained.
     */
    function clear(): void {
        columnView.clear();
    }

    /*!
      \qmlmethod Page PageRow::get(int idx)

      \a idx the depth of the page we want

      Returns the page at idx
     */
    function get(idx): QT.Page {
        return items[idx];
    }

    /*!
      \qmlmethod void PageRow::flickBack()

      Go back to the previous index and scroll to the left to show one more column.
     */
    function flickBack(): void {
        if (depth > 1) {
            currentIndex = Math.max(0, currentIndex - 1);
        }
    }

    /*!
      \qmlmethod void PageRow::goBack(var event = null)

      Acts as if you had pressed the "back" button on Android or did Alt-Left on desktop,
      "going back" in the layers and page row. Results in a layer being popped if available,
      or the currentIndex being set to currentIndex-1 if not available.

      \a event Optional, an event that will be accepted if a page is successfully
      "backed" on
     */
    function goBack(event = null): void {
        const backEvent = {accepted: false}

        if (layersStack.depth >= 1) {
            try { // app code might be screwy, but we still want to continue functioning if it throws an exception
                layersStack.currentItem.backRequested(backEvent)
            } catch (error) {}

            if (!backEvent.accepted) {
                if (layersStack.depth > 1) {
                    layersStack.pop()
                    if (event) {
                        event.accepted = true
                    }
                    return
                }
            }
        }

        if (currentIndex >= 1) {
            try { // app code might be screwy, but we still want to continue functioning if it throws an exception
                currentItem.backRequested(backEvent)
            } catch (error) {}

            if (!backEvent.accepted) {
                if (depth > 1) {
                    currentIndex = Math.max(0, currentIndex - 1)
                    if (event) {
                        event.accepted = true
                    }
                }
            }
        }
    }

    /*!
      \qmlmethod void goForward()

      Acts as if you had pressed the "forward" shortcut on desktop,
      "going forward" in the page row. Results in the active page
      becoming the next page in the row from the current active page,
      i.e. currentIndex + 1.
     */
    function goForward(): void {
        currentIndex = Math.min(depth - 1, currentIndex + 1)
    }
//END FUNCTIONS

//BEGIN signals & signal handlers
    /*!
      \brief Emitted when a page has been inserted anywhere.
      \a position where the page has been inserted
      \a page the new page
      \since 2.7
     */
    signal pageInserted(int position, Item page)

    /*!
      \brief Emitted when a page has been pushed to the bottom.
      \a page the new page
      \since 2.5
     */
    signal pagePushed(Item page)

    /*!
      \brief Emitted when a page has been removed from the row.
      \a page the page that has been removed: at this point it's still valid,
                but may be auto deleted soon.
      \since 2.5
     */
    signal pageRemoved(Item page)

    onLeftSidebarChanged: {
        if (leftSidebar && !leftSidebar.modal) {
            modalConnection.onModalChanged();
        }
    }

    Keys.onReleased: event => {
        if (event.key === Qt.Key_Back) {
            this.goBack(event)
        }
    }

    onInitialPageChanged: {
        if (initialPage) {
            clear();
            push(initialPage, null)
        }
    }
/*
    onActiveFocusChanged:  {
        if (activeFocus) {
            layersStack.currentItem.forceActiveFocus()
            if (columnView.activeFocus) {
                print("SSS"+columnView.currentItem)
                columnView.currentItem.forceActiveFocus();
            }
        }
    }
*/
//END signals & signal handlers

    Connections {
        id: modalConnection
        target: leftSidebar
        function onModalChanged(): void {
            if (leftSidebar.modal) {
                leftSidebar.parent = root.QQC2.Overlay.overlay
                leftSidebar.background.parent.parent = null
            } else {
                leftSidebar.parent = sidebarControl
                leftSidebar.background.parent.parent = sidebarControl
            }
        }
    }
    // Enforce the parent when we are in sidebar mode
    Connections {
        enabled: leftSidebar && leftSidebar.contentItem && !leftSidebar.modal
        target: leftSidebar?.contentItem.parent ?? null
        function onParentChanged () {
            leftSidebar.contentItem.parent.parent = sidebarControl
        }
    }

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    Shortcut {
        sequences: [ StandardKey.Back ]
        onActivated: goBack()
    }
    Shortcut {
        sequences: [ StandardKey.Forward ]
        onActivated: goForward()
    }

    Keys.forwardTo: [currentItem]

    GlobalToolBar.PageRowGlobalToolBarStyleGroup {
        id: globalToolBar
        readonly property int leftReservedSpace: globalToolBarUI.item ? globalToolBarUI.item.leftReservedSpace : 0
        readonly property int rightReservedSpace: globalToolBarUI.item ? globalToolBarUI.item.rightReservedSpace : 0
        readonly property int height: globalToolBarUI.height
        readonly property Item leftHandleAnchor: globalToolBarUI.item ? globalToolBarUI.item.leftHandleAnchor : null
        readonly property Item rightHandleAnchor: globalToolBarUI.item ? globalToolBarUI.item.rightHandleAnchor : null
    }

    QQC2.StackView {
        id: layersStack
        z: 99
        Accessible.role: Accessible.Pane
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: depth < 2
                        ? globalToolBarUI.height
                        : currentItem.Kirigami.ColumnView.globalHeader?.height ?? 0
            bottomMargin: currentItem.Kirigami.ColumnView.globalFooter?.height ?? 0
        }
        // placeholder as initial item
        initialItem: columnViewLayout

        onDepthChanged: {
            if (depth < 2) {
                return;
            }
            let item = layersStack.get(depth - 1)
            // headers are parented to items in layers, so items can't clip otherwise headers become invisible
            item.clip = false

            // For layers reparent the global header to the page
            const header = item.Kirigami.ColumnView.globalHeader
            header.parent = item
            header.anchors.bottom = item.top
            header.anchors.left = item.left
            header.anchors.right = item.right

            const footer = item.Kirigami.ColumnView.globalFooter
            footer.parent = item
            footer.anchors.top = item.bottom
            footer.anchors.left = item.left
            footer.anchors.right = item.right
        }

        function clear(): void {
            // don't let it kill the main page row
            const d = layersStack.depth;
            for (let i = 1; i < d; ++i) {
                pop();
            }
        }

        popEnter: Transition {
            PauseAnimation {
                duration: Kirigami.Units.longDuration
            }
        }
        popExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: 0
                    to: height/2
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
            }
        }

        pushEnter: Transition {
            ParallelAnimation {
                // NOTE: It's a PropertyAnimation instead of an Animator because with an animator the item will be visible for an instant before starting to fade
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/2
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }



        pushExit: Transition {
            PauseAnimation {
                duration: Kirigami.Units.longDuration
            }
        }

        replaceEnter: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/2
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        replaceExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
                YAnimator {
                    from: 0
                    to: -height/2
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    Loader {
        id: globalToolBarUI
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        z: 100
        property QT.Control pageRow: root
        active: globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None || (leadingVisibleItem && leadingVisibleItem.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar)
        visible: active
        height: active ? implicitHeight : 0
        // If load is asynchronous, it will fail to compute the initial implicitHeight
        // https://bugs.kde.org/show_bug.cgi?id=442660
        asynchronous: false
        source: Qt.resolvedUrl("private/globaltoolbar/PageRowGlobalToolBarUI.qml");
    }

    QtObject {
        id: pagesLogic
        readonly property var componentCache: new Array()

        property Component __mobileDialogLayerComponent

        function getMobileDialogLayerComponent() {
            if (!__mobileDialogLayerComponent) {
                __mobileDialogLayerComponent = Qt.createComponent(Qt.resolvedUrl("private/MobileDialogLayer.qml"));
            }
            return __mobileDialogLayerComponent;
        }

        function verifyPages(pages, properties): bool {
            function validPage(page) {
                //don't try adding an already existing page
                if (page instanceof QT.Page && columnView.containsItem(page)) {
                    console.log(`Page ${page} is already in the PageRow`)
                    return false
                }
                return page instanceof QT.Page || page instanceof Component || typeof page === 'string'
                    || (typeof page === 'object' && typeof page.toString() === 'string')
            }

            // check page/pages that it is/they are valid
            const pagesIsArr = Array.isArray(pages) && pages.length > 0
            let isValidArrOfPages = pagesIsArr;

            if (pagesIsArr) {
                for (const page of pages) {
                    if (!validPage(page)) {
                        isValidArrOfPages = false;
                        break;
                    }
                }
            }

            // check properties obejct/array object validity
            const isProp = typeof properties === 'object';
            const propsIsArr = Array.isArray(properties) && properties.length > 0
            let isValidPropArr = propsIsArr;

            if (propsIsArr) {
                for (const prop of properties) {
                    if (typeof prop !== 'object') {
                        isValidPropArr = false;
                        break;
                    }
                }
                isValidPropArr = isValidPropArr && pages.length === properties.length
            }

            return (validPage(pages) || isValidArrOfPages)
                && (!properties || (isProp || isValidPropArr))
        }

        function insertPage_unchecked(position, page, properties) {
            columnView.pop(position - 1);

            // figure out if more than one page is being pushed
            let pages;
            let propsArray = [];
            if (page instanceof Array) {
                pages = page;
                page = pages.pop();
            }
            if (properties instanceof Array) {
                propsArray = properties;
                properties = propsArray.pop();
            } else {
                propsArray = [properties];
            }

            // push any extra defined pages onto the stack
            if (pages) {
                for (const i in pages) {
                    let tPage = pages[i];
                    let tProps = propsArray[i];

                    pagesLogic.initAndInsertPage(position, tPage, tProps);
                    ++position;
                }
            }

            // initialize the page
            const pageItem = pagesLogic.initAndInsertPage(position, page, properties);

            pagePushed(pageItem);

            return pageItem;
        }

        function getPageComponent(page): Component {
            let pageComp;

            if (page.createObject) {
                // page defined as component
                pageComp = page;
            } else if (typeof page === "string") {
                // page defined as string (a url)
                pageComp = pagesLogic.componentCache[page];
                if (!pageComp) {
                    pageComp = pagesLogic.componentCache[page] = Qt.createComponent(page);
                }
            } else if (typeof page === "object" && !(page instanceof Item) && page.toString !== undefined) {
                // page defined as url (QML value type, not a string)
                pageComp = pagesLogic.componentCache[page.toString()];
                if (!pageComp) {
                    pageComp = pagesLogic.componentCache[page.toString()] = Qt.createComponent(page.toString());
                }
            }

            return pageComp
        }

        function initPage(page, properties): QT.Page {
            const pageComp = getPageComponent(page, properties);

            if (pageComp) {
                // instantiate page from component
                // Important: The parent needs to be set otherwise a reference needs to be kept around
                // to avoid the page being garbage collected.
                page = pageComp.createObject(pagesLogic, properties || {});

                if (pageComp.status === Component.Error) {
                    throw new Error("Error while loading page: " + pageComp.errorString());
                }
            } else {
                // copy properties to the page
                for (const prop in properties) {
                    if (page.hasOwnProperty(prop)) {
                        page[prop] = properties[prop];
                    }
                }
            }
            return page;
        }

        function initAndInsertPage(position, page, properties): QT.Page {
            page = initPage(page, properties);
            columnView.insertItem(position, page);
            return page;
        }
    }

    Item {
        Item {
            id: columnViewLayout
            anchors {
                fill: parent
                // Use this instead Layout.topMargin in RowLayout seems to be unreliable
                topMargin: -layersStack.y
            }
            readonly property alias columnView: columnView
            // set the pagestack of this and all children to root, otherwise
            // they would automatically resolve to the layer's stackview
            Kirigami.PageStack.pageStack: root

            Item {
                id: sidebarControl
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                z: 1
                width: visible ? leftSidebar.width : 0
                // Using leftSidebar.position instead of visible because leftSidebar.visible depends from its main item visibility which is our child so would be a loop
                visible: leftSidebar && leftSidebar.position > 0 && children.length > 0
            }

            Kirigami.ColumnView {
                id: columnView
                anchors {
                    left: sidebarControl.right
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }

                topPadding: globalToolBarUI.item && globalToolBarUI.item.breadcrumbVisible
                            ? globalToolBarUI.height : 0

                // Internal hidden api for Page
                readonly property Item __pageRow: root
                acceptsMouse: Kirigami.Settings.isMobile
                columnResizeMode: root.wideMode ? Kirigami.ColumnView.FixedColumns : Kirigami.ColumnView.SingleColumn
                columnWidth: root.defaultColumnWidth
                interactive: Qt.platform.os !== 'android'

                onItemInserted: (position, item) => root.pageInserted(position, item);
                onItemRemoved: item => root.pageRemoved(item);

                onVisibleItemsChanged: {
                    // implementation of `popHiddenPages` option
                    if (root.popHiddenPages) {
                        // manually fetch lastItem here rather than use root.lastItem property, since that binding may not have updated yet
                        let lastItem = columnView.contentChildren[columnView.contentChildren.length - 1];
                        let trailingVisibleItem = columnView.trailingVisibleItem;

                        // pop every page that isn't visible and at the top of the stack
                        while (lastItem && columnView.trailingVisibleItem &&
                            lastItem !== columnView.trailingVisibleItem && columnView.containsItem(lastItem)) {
                            root.pop();
                        }
                    }
                }
            }
        }
    }
}
