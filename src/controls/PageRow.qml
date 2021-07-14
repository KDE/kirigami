/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQml.Models 2.2
import QtQuick.Templates 2.0 as T
import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.7
import "private/globaltoolbar" as GlobalToolBar
import "templates" as KT

/**
 * @inherits QtQuick.Controls.Control
 * PageRow implements a row-based navigation model, which can be used
 * with a set of interlinked information pages. Items are pushed in the
 * back of the row and the view scrolls until that row is visualized.
 * A PageRow can show a single page or a multiple set of columns, depending
 * on the window width: on a phone a single column should be fullscreen,
 * while on a tablet or a desktop more than one column should be visible.
 * @inherit QtQuick.Control
 */
T.Control {
    id: root

//BEGIN PROPERTIES
    /**
     * This property holds the number of items currently pushed onto the view.
     * @var int depth
     */
    property alias depth: columnView.count

    /**
     * The last Page in the Row.
     */
    readonly property Item lastItem: columnView.contentChildren.length > 0 ?  columnView.contentChildren[columnView.contentChildren.length - 1] : null

    /**
     * The currently visible Item.
     * @var Item currentItem
     */
    property alias currentItem: columnView.currentItem

    /**
     * The index of the currently visible Item.
     * @var int currentIndex
     */
    property alias currentIndex: columnView.currentIndex

    /**
     * The initial item when this PageRow is created.
     * @var Page initialPage
     */
    property variant initialPage

    /**
     * The main ColumnView of this Row.
     * @var Item contentItem
     */
    contentItem: columnView

    /**
     * @var ColumnView columnView
     *
     * The ColumnView that this PageRow owns.
     * Generally, you shouldn't need to change
     * the value of this.
     *
     * @since 2.12
     */
    property alias columnView: columnView

    /**
     * @var list<Item> items
     * All the items that are present in the PageRow.
     * @since 2.6
     */
    property alias items: columnView.contentChildren;

    /**
     * @var list<Item> visibleItems
     * All pages which are visible in the PageRow, excluding those which are scrolled away
     * @since 2.6
     */
    property alias visibleItems: columnView.visibleItems

    /**
     * @var Item firstVisibleItem
     * The first at least partially visible page in the PageRow, pages before that one will be out of the viewport
     * @since 2.6
     */
    property alias firstVisibleItem: columnView.firstVisibleItem

    /**
     * @var Item lastVisibleItem
     * The last at least partially visible page in the PageRow, pages after that one will be out of the viewport
     * @since 2.6
     */
    property alias lastVisibleItem: columnView.lastVisibleItem

    /**
     * The default width for a column
     * default is wide enough for 30 grid units.
     * Pages can override it with their Layout.fillWidth,
     * implicitWidth Layout.minimumWidth etc.
     */
    property int defaultColumnWidth: Units.gridUnit * 20

    /**
     * @var bool interactive
     * If true it will be possible to go back/forward by dragging the
     * content themselves with a gesture.
     * Otherwise the only way to go back will be programmatically
     * default: true
     */
    property alias interactive: columnView.interactive

    /**
     * If true, the PageRow is wide enough that willshow more than one column at once
     * @since 5.37
     */
    readonly property bool wideMode: root.width >= root.defaultColumnWidth*2 && depth >= 2

    /**
     * @var bool separatorVisible
     * True if the separator between pages should be visible
     * default: true
     * @since 5.38
     */
    property alias separatorVisible: columnView.separatorVisible

    /**
     * globalToolBar: grouped property
     * Controls the appearance of an optional global toolbar for the whole PageRow.
     * It's a grouped property comprised of the following properties:
     * * style (Kirigami.ApplicationHeaderStyle): can have the following values:
     *  * Auto: depending on application formfactor, it can behave automatically like other values, such as a Breadcrumb on mobile and ToolBar on desktop
     *  * Breadcrumb: it will show a breadcrumb of all the page titles in the stack, for easy navigation
     *  * Titles: each page will only have its own tile on top
     *  * TabBar: the global toolbar will look like a TabBar to select the pages
     *  * ToolBar: each page will have the title on top together buttons and menus to represent all of the page actions: not available on Mobile systems.
     *  * None: no global toolbar will be shown
     *
     * * actualStyle: this will represent the actual style of the toolbar: it can be different from style in the case style is Auto
     * * showNavigationButtons: OR flags combination of ApplicationHeaderStyle.ShowBackButton and ApplicationHeaderStyle.ShowForwardButton
     * * toolbarActionAlignment: How to horizontally align the actions when using the ToolBar style. Note that anything but Qt.AlignRight will cause the title to be hidden (default: Qt.AlignRight)
     * * minimumHeight (int): minimum height of the header, which will be resized when scrolling, only in Mobile mode (default: preferredHeight, sliding but no scaling)
     * * preferredHeight (int): the height the toolbar will usually have
     * * maximumHeight (int): the height the toolbar will have in mobile mode when the app is in reachable mode (default: preferredHeight * 1.5)
     * * leftReservedSpace (int, readonly): how many pixels are reserved at the left of the page toolbar (for navigation buttons or drawer handle)
     * * rightReservedSpace (int, readonly): how many pixels are reserved at the right of the page toolbar (drawer handle)
     *
     * @since 5.48
     */
    readonly property alias globalToolBar: globalToolBar

    /**
     * Assign a drawer as an internal left sidebar for this PageRow.
     * In this case, when open and not modal, the drawer contents will be in the same layer as the base pagerow.
     * Pushing any other layer on top will cover the sidebar.
     *
     * @since 5.84
     */
    // TODO KF6: globaldrawer should use action al so used by this sidebar instead of reparenting globaldrawer contents?
    property OverlayDrawer leftSidebar

    onLeftSidebarChanged: {
        if (leftSidebar && !leftSidebar.modal) {
            modalConnection.onModalChanged();
        }
    }

    Connections {
        id: modalConnection
        target: root.leftSidebar
        function onModalChanged() {
            if (leftSidebar.modal) {
                let sidebar = sidebarControl.contentItem;
                let background = sidebarControl.background;
                sidebarControl.contentItem = null;
                leftSidebar.contentItem = sidebar;
                sidebarControl.background = null;
                leftSidebar.background = background;

                sidebar.visible = true;
                background.visible = true;
            } else {
                let sidebar = leftSidebar.contentItem
                let background = leftSidebar.background
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
//END PROPERTIES

//BEGIN FUNCTIONS
    /**
     * Pushes a page on the stack.
     * The page can be defined as a component, item or string.
     * If an item is used then the page will get re-parented.
     * If a string is used then it is interpreted as a url that is used to load a page
     * component.
     * The last pushed page will become the current item.
     *
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     *
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page. If page is actually an array of pages, properties should also be an array of key/value maps
     * @return The new created page (or the last one if it was an array)
     */
    function push(page, properties) {
        var item = insertPage(depth, page, properties);
        currentIndex = depth - 1;
        return item;
    }

    /**
     * Pushes a page as a new dialog on desktop and as a layer on mobile.
     * @param page The page can be defined as a component, item or string. If an item is
     *             used then the page will get re-parented. If a string is used then it
     *             is interpreted as a url that is used to load a page component. Once
     *             pushed the page gains the methods `closeDialog` allowing to close itself.
     *             Kirigami only supports calling `closeDialog` once.
     * @param properties The properties given when initializing the page.
     * @param windowProperties The properties given to the initialized window on desktop.
     * @return The new created page
     */
    function pushDialogLayer(page, properties = {}, windowProperties = {}) {
        let item;
        if (Settings.isMobile) {
            if (QQC2.ApplicationWindow.window.width > Units.gridUnit * 40) {
                // open as a QQC2.Dialog
                const dialog = Qt.createQmlObject('
                    import QtQuick 2.15;
                    import QtQuick.Controls 2.15;
                    import QtQuick.Layouts 1.15;
                    import org.kde.kirigami 2.15 as Kirigami;
                    Dialog {
                        id: dialog
                        modal: true;
                        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0;
                        header: Kirigami.AbstractApplicationHeader {
                            pageRow: null
                            page: null
                            minimumHeight: Units.gridUnit * 1.6
                            maximumHeight: Units.gridUnit * 1.6
                            preferredHeight: Units.gridUnit * 1.6

                            Keys.onEscapePressed: {
                                if (dialog.opened) {
                                    dialog.close();
                                } else {
                                    event.accepted = false;
                                }
                            }

                            contentItem: RowLayout {
                                width: parent.width
                                Kirigami.Heading {
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    text: dialog.title
                                    elide: Text.ElideRight
                                }
                                Item {
                                    Layout.fillWidth: true;
                                }
                                Kirigami.Icon {
                                    id: closeIcon
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: Kirigami.Units.largeSpacing
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                    source: closeMouseArea.containsMouse ? "window-close" : "window-close-symbolic"
                                    active: closeMouseArea.containsMouse
                                    MouseArea {
                                        id: closeMouseArea
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        onClicked: dialog.close();
                                    }
                                }
                            }
                        }
                    }', root);
                dialog.parent = root;
                dialog.width = Qt.binding(() => QQC2.ApplicationWindow.window.width - Units.gridUnit * 5);
                dialog.height = Qt.binding(() => QQC2.ApplicationWindow.window.height - Units.gridUnit * 5);
                dialog.x = Units.gridUnit * 2.5;
                dialog.y = Units.gridUnit * 2.5;
                let item;
                if (typeof page === "string") {
                    // url => load component and then load item from component
                    const component = Qt.createComponent(Qt.resolvedUrl(page));
                    item = component.createObject(dialog);
                } else if (page instanceof Component) {
                    item = component.createObject(dialog);
                } else if (page instanceof Item) {
                    item = page;
                    page.parent = dialog.contentItem;
                }
                dialog.contentItem = item;
                dialog.title = Qt.binding(() => dialog.contentItem.title);
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
            if (!windowProperties.modality) {
                windowProperties.modality = Qt.WindowModal;
            }
            if (!windowProperties.height) {
                windowProperties.height = Units.gridUnit * 30;
            }
            if (!windowProperties.width) {
                windowProperties.width = Units.gridUnit * 50;
            }
            if (!windowProperties.minimumWidth) {
                windowProperties.minimumWidth = Units.gridUnit * 20;
            }
            if (!windowProperties.minimumHeight) {
                windowProperties.minimumHeight = Units.gridUnit * 15;
            }
            if (!windowProperties.flags) {
                windowProperties.flags = Qt.Dialog | Qt.WindowCloseButtonHint;
            }
            const windowComponent = Qt.createComponent(Qt.resolvedUrl("./ApplicationWindow.qml"));
            const window = windowComponent.createObject(root, windowProperties);
            item = window.pageStack.push(page, properties);
            Object.defineProperty(item, 'closeDialog', {
                value: function() {
                    window.close();
                }
            });
        }
        return item;
    }

    /**
     * Inserts a new page or a list of new at an arbitrary position
     * The page can be defined as a component, item or string.
     * If an item is used then the page will get re-parented.
     * If a string is used then it is interpreted as a url that is used to load a page
     * component.
     * The current Page will not be changed, currentIndex will be adjusted
     * accordingly if needed to keep the same current page.
     *
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     *
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page. If page is actually an array of pages, properties should also be an array of key/value maps
     * @return The new created page (or the last one if it was an array)
     * @since 2.7
     */
    function insertPage(position, page, properties) {
        if (!page) {
            return null
        }
        //don't push again things already there
        if (page.createObject === undefined && typeof page != "string" && columnView.containsItem(page)) {
            print("The item " + page + " is already in the PageRow");
            return null;
        }

        position = Math.max(0, Math.min(depth, position));

        columnView.pop(columnView.currentItem);

        // figure out if more than one page is being pushed
        var pages;
        var propsArray = [];
        if (page instanceof Array) {
            pages = page;
            page = pages.pop();
            //compatibility with pre-qqc1 api, can probably be removed
            if (page.createObject === undefined && page.parent === undefined && typeof page != "string") {
                properties = properties || page.properties;
                page = page.page;
            }
        }
        if (properties instanceof Array) {
            propsArray = properties;
            properties = propsArray.pop();
        } else {
            propsArray = [properties];
        }

        // push any extra defined pages onto the stack
        if (pages) {
            var i;
            for (i = 0; i < pages.length; i++) {
                var tPage = pages[i];
                var tProps = propsArray[i];
                //compatibility with pre-qqc1 api, can probably be removed
                if (tPage.createObject === undefined && tPage.parent === undefined && typeof tPage != "string") {
                    if (columnView.containsItem(tPage)) {
                        print("The item " + page + " is already in the PageRow");
                        continue;
                    }
                    tProps = tPage.properties;
                    tPage = tPage.page;
                }

                var pageItem = pagesLogic.initAndInsertPage(position, tPage, tProps);
                ++position;
            }
        }

        // initialize the page
        var pageItem = pagesLogic.initAndInsertPage(position, page, properties);

        pagePushed(pageItem);

        return pageItem;
    }

    /**
     * Move the page at position fromPos to the new position toPos
     * If needed, currentIndex will be adjusted
     * in order to keep the same current page.
     * @since 2.7
     */
    function movePage(fromPos, toPos) {
        columnView.moveItem(fromPos, toPos);
    }

    /**
     * Remove the given page
     * @param page The page can be given both as integer position or by reference
     * @return The page that has just been removed
     * @since 2.7
     */
    function removePage(page) {
        if (depth == 0) {
            return null;
        }

        return columnView.removeItem(page);
    }

    /**
     * Pops a page off the stack.
     * @param page If page is specified then the stack is unwound to that page,
     * to unwind to the first page specify
     * page as null.
     * @return The page instance that was popped off the stack.
     */
    function pop(page) {
        if (depth == 0) {
            return null;
        }

        return columnView.pop(page);
    }

    /**
     * Emitted when a page has been inserted anywhere
     * @param position where the page has been inserted
     * @param page the new page
     * @since 2.7
     */
    signal pageInserted(int position, Item page)

    /**
     * Emitted when a page has been pushed to the bottom
     * @param page the new page
     * @since 2.5
     */
    signal pagePushed(Item page)

    /**
     * Emitted when a page has been removed from the row.
     * @param page the page that has been removed: at this point it's still valid,
     *           but may be auto deleted soon.
     * @since 2.5
     */
    signal pageRemoved(Item page)

    /**
     * Replaces a page on the stack.
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     the current page and all pagest after it in the stack will be removed.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page.
     * @see push() for details.
     */
    function replace(page, properties) {
        if (!page) {
            return null;
        }

        // Remove all pages on top of the one being replaced.
        if (currentIndex >= 0) {
            columnView.pop(columnView.contentChildren[currentIndex]);
        } else {
            console.warn("There's no page to replace");
        }

        // Figure out if more than one page is being pushed.
        var pages;
        var propsArray = [];
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
        var pageItem = pagesLogic.initPage(page, properties);
        if (depth > 0)
            columnView.replaceItem(depth - 1, pageItem);
        else {
            console.log("Calling replace on empty PageRow", pageItem)
            columnView.addItem(pageItem)
        }
        pagePushed(pageItem);

        // Push any extra defined pages onto the stack.
        if (pages) {
            var i;
            for (i = 0; i < pages.length; i++) {
                var tPage = pages[i];
                var tProps = propsArray[i];

                var pageItem = pagesLogic.initPage(tPage, tProps);
                columnView.addItem(pageItem);
                pagePushed(pageItem);
            }
        }

        currentIndex = depth - 1;
        return pageItem;
    }

    /**
     * Clears the page stack.
     * Destroy (or reparent) all the pages contained.
     */
    function clear() {
        return columnView.clear();
    }

    /**
     * @return the page at idx
     * @param idx the depth of the page we want
     */
    function get(idx) {
        return columnView.contentChildren[idx];
    }

    /**
     * Go back to the previous index and scroll to the left to show one more column.
     */
    function flickBack() {
        if (depth > 1) {
            currentIndex = Math.max(0, currentIndex - 1);
        }
    }

    /**
     * @var QtQuick.Controls.StackView layers
     * Access to the modal layers.
     * Sometimes an application needs a modal page that always covers all the rows.
     * For instance the full screen image of an image viewer or a settings page.
     * @since 5.38
     */
    property alias layers: layersStack
//END FUNCTIONS

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
        anchors {
            fill: parent
        }
        //placeholder as initial item
        initialItem: columnViewLayout

        function clear () {
            //don't let it kill the main page row
            var d = layersStack.depth;
            for (var i = 1; i < d; ++i) {
                pop();
            }
        }

        popEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        popExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: 0
                    to: height/2
                    duration: Units.longDuration
                    easing.type: Easing.InCubic
                }
            }
        }

        pushEnter: Transition {
            ParallelAnimation {
                //NOTE: It's a PropertyAnimation instead of an Animator because with an animator the item will be visible for an instant before starting to fade
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/2
                    to: 0
                    duration: Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }


        pushExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }

        replaceEnter: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/2
                    to: 0
                    duration: Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        replaceExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Units.longDuration
                    easing.type: Easing.InCubic
                }
                YAnimator {
                    from: 0
                    to: -height/2
                    duration: Units.longDuration
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
        property T.Control pageRow: root
        active: globalToolBar.actualStyle != ApplicationHeaderStyle.None || (firstVisibleItem && firstVisibleItem.globalToolBarStyle == ApplicationHeaderStyle.ToolBar)
        visible: active
        height: active ? implicitHeight : 0
        source: Qt.resolvedUrl("private/globaltoolbar/PageRowGlobalToolBarUI.qml");
    }

    QtObject {
        id: pagesLogic
        readonly property var componentCache: new Array()

        function getPageComponent(page) {
            var pageComp;

            if (page.createObject) {
                // page defined as component
                pageComp = page;
            } else if (typeof page == "string") {
                // page defined as string (a url)
                pageComp = pagesLogic.componentCache[page];
                if (!pageComp) {
                    pageComp = pagesLogic.componentCache[page] = Qt.createComponent(page);
                }
            }

            return pageComp
        }

        function initPage(page, properties) {
            var pageComp = getPageComponent(page, properties);

            if (pageComp) {
                // instantiate page from component
                // FIXME: parent directly to columnView or root?
                page = pageComp.createObject(null, properties || {});

                if (pageComp.status === Component.Error) {
                    throw new Error("Error while loading page: " + pageComp.errorString());
                }
            } else {
                // copy properties to the page
                for (var prop in properties) {
                    if (properties.hasOwnProperty(prop)) {
                        page[prop] = properties[prop];
                    }
                }
            }
            return page;
        }

        function initAndInsertPage(position, page, properties) {
            page = initPage(page, properties);
            columnView.insertItem(position, page);
            return page;
        }
    }

    RowLayout {
        id: columnViewLayout
        spacing: 1
        readonly property alias columnView: columnView
        QQC2.Control {
            id: sidebarControl
            Layout.fillHeight: true
            visible: contentItem !== null && root.leftDrawer && root.leftDrawer.visible
            leftPadding: root.leftSidebar ? root.leftSidebar.leftPadding : 0
            topPadding: root.leftSidebar ? root.leftSidebar.topPadding : 0
            rightPadding: root.leftSidebar ? root.leftSidebar.rightPadding : 0
            bottomPadding: root.leftSidebar ? root.leftSidebar.bottomPadding : 0
        }
        ColumnView {
            id: columnView
            Layout.fillWidth: true
            Layout.fillHeight: true

            topPadding: globalToolBarUI.item && globalToolBarUI.item.breadcrumbVisible
                        ? globalToolBarUI.height : 0

            // Internal hidden api for Page
            readonly property Item __pageRow: root
            acceptsMouse: Settings.isMobile
            columnResizeMode: root.wideMode ? ColumnView.FixedColumns : ColumnView.SingleColumn
            columnWidth: root.defaultColumnWidth

            onItemInserted: root.pageInserted(position, item);
            onItemRemoved: root.pageRemoved(item);
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        height: Units.smallSpacing
        x: (columnView.width - width) * (columnView.contentX / (columnView.contentWidth - columnView.width))
        width: columnView.width * (columnView.width/columnView.contentWidth)
        color: Theme.textColor
        opacity: 0
        onXChanged: {
            opacity = 0.3
            scrollIndicatorTimer.restart();
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Timer {
            id: scrollIndicatorTimer
            interval: Units.longDuration * 4
            onTriggered: parent.opacity = 0;
        }
    }
}
