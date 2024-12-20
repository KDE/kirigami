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
import "templates" as KT

/**
 * PageRow implements a row-based navigation model, which can be used
 * with a set of interlinked information pages. Pages are pushed in the
 * back of the row and the view scrolls until that row is visualized.
 * A PageRow can show a single page or a multiple set of columns, depending
 * on the window width: on a phone a single column should be fullscreen,
 * while on a tablet or a desktop more than one column should be visible.
 *
 * @inherits QtQuick.Templates.Control
 */
QT.Control {
    id: root

//BEGIN PROPERTIES
    /**
     * @brief This property holds the number of pages currently pushed onto the view.
     * @property int depth
     */
    readonly property alias depth: columnView.count

    /**
     * @brief This property holds the last page in the row.
     * @property Page lastItem
     */
    readonly property Item lastItem: columnView.contentChildren.length > 0 ?  columnView.contentChildren[columnView.contentChildren.length - 1] : null

    /**
     * @brief This property holds the currently visible/active page.
     *
     * Because of the ability to display multiple pages, it will hold the currently active page.
     *
     * @property Page currentItem
     */
    readonly property alias currentItem: columnView.currentItem

    /**
     * @brief This property holds the index of the currently active page.
     * @see currentItem
     * @property int currentIndex
     */
    property alias currentIndex: columnView.currentIndex

    /**
     * @brief This property sets the initial page for this PageRow.
     * @property Page initialPage
     */
    property var initialPage

    /**
     * @brief This property holds the main ColumnView of this Row.
     * @property ColumnView contentItem
     */
    contentItem: columnView

    /**
     * @brief This property holds the ColumnView that this PageRow owns.
     *
     * Generally, you shouldn't need to change the value of this property.
     *
     * @property ColumnView columnView
     * @since 2.12
     */
    property alias columnView: columnView

    /**
     * @brief This property holds the present pages in the PageRow.
     * @property list<Page> items
     * @since 2.6
     */
    readonly property alias items: columnView.contentChildren

    /**
     * @brief This property holds all visible pages in the PageRow,
     * excluding those which are scrolled away.
     * @property list<Page> visibleItems
     * @since 2.6
     */
    readonly property alias visibleItems: columnView.visibleItems

    /**
     * @brief This property holds the first page in the PageRow that is at least partially visible.
     * @note Pages before that one (the one contained in the property) will be out of the viewport.
     * @see ColumnView::leadingVisibleItem
     * @property Item leadingVisibleItem
     * @since 2.6
     */
    readonly property alias leadingVisibleItem: columnView.leadingVisibleItem

    /**
     * @brief This property holds the last page in the PageRow that is at least partially visible.
     * @note Pages after that one (the one contained in the property) will be out of the viewport.
     * @see ColumnView::trailingVisibleItem
     * @property Item trailingVisibleItem
     * @since 2.6
     */
    readonly property alias trailingVisibleItem: columnView.trailingVisibleItem

    /**
     * @brief This property holds the default width for a column.
     *
     * default: ``20 * Kirigami.Units.gridUnit``
     *
     * @note Pages can override it using implicitWidth, Layout.fillWidth, Layout.minimumWidth etc.
     */
    property int defaultColumnWidth: Kirigami.Units.gridUnit * 20

    /**
     * @brief This property sets whether it is possible to go back/forward
     * by swiping with a gesture on the content view.
     *
     * default: ``true``
     *
     * @property bool interactive
     */
    property alias interactive: columnView.interactive

    /**
     * @brief This property tells whether the PageRow is wide enough to show multiple pages.
     * @since 5.37
     */
    readonly property bool wideMode: width >= defaultColumnWidth * 2 && depth >= 2

    /**
     * @brief This property sets whether the separators between pages should be displayed.
     *
     * default: ``true``
     *
     * @property bool separatorVisible
     * @since 5.38
     */
    property alias separatorVisible: columnView.separatorVisible

    /**
     * @brief This property sets the appearance of an optional global toolbar for the whole PageRow.
     *
     * It's a grouped property comprised of the following properties:
     * * style (``Kirigami.ApplicationHeaderStyle``): can have the following values:
     *  * ``Auto``: Depending on application formfactor, it can behave automatically like other values, such as a Breadcrumb on mobile and ToolBar on desktop.
     *  * ``Breadcrumb``: It will show a breadcrumb of all the page titles in the stack, for easy navigation.
     *  * ``Titles``: Each page will only have its own title on top.
     *  * ``ToolBar``: Each page will have the title on top together buttons and menus to represent all of the page actions. Not available on Mobile systems.
     *  * ``None``: No global toolbar will be shown.
     *
     * * ``actualStyle``: This will represent the actual style of the toolbar; it can be different from style in the case style is Auto.
     * * ``showNavigationButtons``: OR flags combination of Kirigami.ApplicationHeaderStyle.ShowBackButton and Kirigami.ApplicationHeaderStyle.ShowForwardButton.
     * * ``toolbarActionAlignment: Qt::Alignment``: How to horizontally align the actions when using the ToolBar style. Note that anything but Qt.AlignRight will cause the title to be hidden (default: ``Qt.AlignRight``).
     * * ``minimumHeight: int`` Minimum height of the header, which will be resized when scrolling. Only in Mobile mode (default: ``preferredHeight``, sliding but no scaling).
     * * ``preferredHeight: int`` The height the toolbar will usually have.
     * * ``leftReservedSpace: int, readonly`` How many pixels of extra space are reserved at the left of the page toolbar (typically for navigation buttons or a drawer handle).
     * * ``rightReservedSpace: int, readonly`` How many pixels of extra space  are reserved at the right of the page toolbar (typically for a drawer handle).
     *
     * @property org::kde::kirigami::private::globaltoolbar::PageRowGlobalToolBarStyleGroup globalToolBar
     * @since 5.48
     */
    readonly property alias globalToolBar: globalToolBar

    /**
     * @brief This property assigns a drawer as an internal left sidebar for this PageRow.
     *
     * In this case, when open and not modal, the drawer contents will be in the same layer as the base pagerow.
     * Pushing any other layer on top will cover the sidebar.
     *
     * @since 5.84
     */
    // TODO KF6: globaldrawer should use actions also used by this sidebar instead of reparenting globaldrawer contents?
    property OverlayDrawer leftSidebar

    /**
     * @brief This property holds the modal layers.
     *
     * Sometimes an application needs a modal page that always covers all the rows.
     * For instance the full screen image of an image viewer or a settings page.
     *
     * @property QtQuick.Controls.StackView layers
     * @since 5.38
     */
    property alias layers: layersStack

    /**
     * @brief This property holds whether to automatically pop pages at the top of the stack if they are not visible.
     *
     * If a user navigates to a previous page on the stack (ex. pressing back button) and pages above
     * it on the stack are not visible, they will be popped if this property is true.
     *
     * @since 5.101
     */
    property bool popHiddenPages: false
//END PROPERTIES

//BEGIN FUNCTIONS
    /**
     * @brief This method pushes a page on the stack.
     *
     * A single page can be defined as an url, a component, or an object. It can
     * also be an array of the above said types, but in that case, the
     * properties' array length must match pages' array length or it must be
     * empty. Failing to comply with the following rules will make the method
     * return null before doing anything.
     *
     * @param page A single page or an array of pages.
     * @param properties A single property object or an array of property
     * objects.
     *
     * @return The new created page (or the last one if it was an array).
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

    /**
     * @brief Pushes a page as a new dialog on desktop and as a layer on mobile.
     *
     * @param page A single page defined as either a string url, a component or
     * an object (which will be reparented). The following page gains
     * `closeDialog()` method allowing to make it indistinguishable to
     * close/hide it when in desktop or mobile mode. Note that Kiriami supports
     * calling `closeDialog()` only once.
     *
     * @param properties The properties given when initializing the page.
     * @param windowProperties The properties given to the initialized window on desktop.
     * @return Returns a newly created page.
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

    /**
     * @brief Inserts a new page or a list of new pages at an arbitrary position.
     *
     * A single page can be defined as an url, a component, or an object. It can
     * also be an array of the above said types, but in that case, the
     * properties' array length must match pages' array length or it must be
     * empty. Failing to comply with the following rules will make the method
     * return null before doing anything.
     *
     * @param page A single page or an array of pages.
     * @param properties A single property object or an array of property
     * objects.
     *
     * @return The new created page (or the last one if it was an array).
     * @since 2.7
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

    /**
     * Move the page at position fromPos to the new position toPos
     * If needed, currentIndex will be adjusted
     * in order to keep the same current page.
     * @since 2.7
     */
    function movePage(fromPos, toPos): void {
        columnView.moveItem(fromPos, toPos);
    }

    /**
     * @brief Remove the given page.
     * @param page The page can be given both as integer position or by reference
     * @return The page that has just been removed
     * @since 2.7
     */
    function removePage(page): QT.Page {
        if (depth > 0) {
            return columnView.removeItem(page);
        }
        return null
    }

    /**
     * @brief Pops a page off the stack.
     * @param page If page is specified then the stack is unwound to that page,
     * to unwind to the first page specify page as null.
     * @return The page instance that was popped off the stack.
     */
    function pop(page): QT.Page {
        return columnView.pop(page);
    }

    /**
     * @brief Replaces a page on the current index.
     *
     * A single page can be defined as an url, a component, or an object. It can
     * also be an array of the above said types, but in that case, the
     * properties' array length must match pages' array length or it must be
     * empty. Failing to comply with the following rules will make the method
     * return null before doing anything.
     *
     * @param page A single page or an array of pages.
     * @param properties A single property object or an array of property
     * objects.
     *
     * @return The new created page (or the last one if it was an array).
     * @see push() for details.
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

    /**
     * @brief Clears the page stack.
     *
     * Destroy (or reparent) all the pages contained.
     */
    function clear(): void {
        columnView.clear();
    }

    /**
     * @return the page at idx
     * @param idx the depth of the page we want
     */
    function get(idx): QT.Page {
        return items[idx];
    }

    /**
     * Go back to the previous index and scroll to the left to show one more column.
     */
    function flickBack(): void {
        if (depth > 1) {
            currentIndex = Math.max(0, currentIndex - 1);
        }
    }

    /**
     * Acts as if you had pressed the "back" button on Android or did Alt-Left on desktop,
     * "going back" in the layers and page row. Results in a layer being popped if available,
     * or the currentIndex being set to currentIndex-1 if not available.
     *
     * @param event Optional, an event that will be accepted if a page is successfully
     * "backed" on
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

    /**
     * Acts as if you had pressed the "forward" shortcut on desktop,
     * "going forward" in the page row. Results in the active page
     * becoming the next page in the row from the current active page,
     * i.e. currentIndex + 1.
     */
    function goForward(): void {
        currentIndex = Math.min(depth - 1, currentIndex + 1)
    }
//END FUNCTIONS

//BEGIN signals & signal handlers
    /**
     * @brief Emitted when a page has been inserted anywhere.
     * @param position where the page has been inserted
     * @param page the new page
     * @since 2.7
     */
    signal pageInserted(int position, Item page)

    /**
     * @brief Emitted when a page has been pushed to the bottom.
     * @param page the new page
     * @since 2.5
     */
    signal pagePushed(Item page)

    /**
     * @brief Emitted when a page has been removed from the row.
     * @param page the page that has been removed: at this point it's still valid,
     *           but may be auto deleted soon.
     * @since 2.5
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
                const sidebar = sidebarControl.contentItem;
                const background = sidebarControl.background;
                sidebarControl.contentItem = null;
                leftSidebar.contentItem = sidebar;
                sidebarControl.background = null;
                leftSidebar.background = background;

                sidebar.visible = true;
                background.visible = true;
            } else {
                const sidebar = leftSidebar.contentItem
                const background = leftSidebar.background
                leftSidebar.contentItem=null
                sidebarControl.contentItem = sidebar
                leftSidebar.background=null
                sidebarControl.background = background

                sidebar.visible = true;
                background.visible = true;
            }
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
        id: layerToolbarStack
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        z: 100 // 100 is layersStack.z + 1
        height: currentItem?.implicitHeight ?? 0
        initialItem: Item {implicitHeight: 0}

        Component {
            id: emptyToolbar
            Item {
                implicitHeight: 0
            }
        }
        popEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        popExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        pushEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        pushExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        replaceEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        replaceExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    QQC2.StackView {
        id: layerFooterStack
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }
        z: 100 // 100 is layersStack.z + 1
        height: currentItem?.implicitHeight ?? 0
        initialItem: Item {implicitHeight: 0}

        popEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        popExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        pushEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        pushExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        replaceEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        replaceExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    QQC2.StackView {
        id: layersStack
        z: 99
        anchors {
            left: parent.left
            top: layerToolbarStack.bottom
            right: parent.right
            bottom: layerFooterStack.top
        }
        // placeholder as initial item
        initialItem: columnViewLayout

        onDepthChanged: {
            let item = layersStack.get(depth - 1)

            if (layerToolbarStack.depth > depth) {
                while (layerToolbarStack.depth > depth) {
                    layerToolbarStack.pop();
                }
            } else if (layerToolbarStack.depth < depth) {
                for (let i = layerToolbarStack.depth; i < depth; ++i) {
                    const toolBar = layersStack.get(i).Kirigami.ColumnView.globalHeader;
                    layerToolbarStack.push(toolBar || emptyToolbar);
                }
            }
            let toolBarItem = layerToolbarStack.get(layerToolbarStack.depth - 1)
            if (item.Kirigami.ColumnView.globalHeader != toolBarItem) {
                const toolBar = item.Kirigami.ColumnView.globalHeader;
                layerToolbarStack.replace(toolBar ?? emptyToolbar);
            }
            // WORKAROUND: the second time the transition on opacity doesn't seem to be executed
            toolBarItem = layerToolbarStack.get(layerToolbarStack.depth - 1)
            toolBarItem.opacity = 1;

            if (layerFooterStack.depth > depth) {
                while (layerFooterStack.depth > depth) {
                    layerFooterStack.pop();
                }
            } else if (layerFooterStack.depth < depth) {
                for (let i = layerFooterStack.depth; i < depth; ++i) {
                    const footer = layersStack.get(i).Kirigami.ColumnView.globalFooter;
                    layerFooterStack.push(footer ?? emptyToolbar);
                }
            }
            let footerItem = layerFooterStack.get(layerFooterStack.depth - 1)
            if (item.Kirigami.ColumnView.globalHeader != footerItem) {
                const footer = item.Kirigami.ColumnView.globalFooter;
                layerFooterStack.replace(footer ?? emptyToolbar);
            }
            footerItem = layerFooterStack.get(layerFooterStack.depth - 1)
            footerItem.opacity = 1;
        }

        function clear(): void {
            // don't let it kill the main page row
            const d = layersStack.depth;
            for (let i = 1; i < d; ++i) {
                pop();
            }
        }

        popEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
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
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
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

    RowLayout {
        id: columnViewLayout
        spacing: 1
        readonly property alias columnView: columnView
        // set the pagestack of this and all children to root, otherwise
        // they would automatically resolve to the layer's stackview
        Kirigami.PageStack.pageStack: root
        anchors {
            fill: parent
            topMargin: -layersStack.y
        }
        QQC2.Control {
            id: sidebarControl
            Layout.fillHeight: true
            visible: contentItem !== null
            leftPadding: root.leftSidebar ? root.leftSidebar.leftPadding : 0
            topPadding: root.leftSidebar ? root.leftSidebar.topPadding : 0
            rightPadding: root.leftSidebar ? root.leftSidebar.rightPadding : 0
            bottomPadding: root.leftSidebar ? root.leftSidebar.bottomPadding : 0
        }
        Kirigami.ColumnView {
            id: columnView
            Layout.fillWidth: true
            Layout.fillHeight: true

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

    Rectangle {
        anchors.bottom: parent.bottom
        height: Kirigami.Units.smallSpacing
        x: (columnView.width - width) * (columnView.contentX / (columnView.contentWidth - columnView.width))
        width: columnView.width * (columnView.width/columnView.contentWidth)
        color: Kirigami.Theme.textColor
        opacity: 0
        onXChanged: {
            opacity = 0.3
            scrollIndicatorTimer.restart();
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Timer {
            id: scrollIndicatorTimer
            interval: Kirigami.Units.longDuration * 4
            onTriggered: parent.opacity = 0;
        }
    }
}
