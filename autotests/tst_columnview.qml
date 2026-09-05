/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import KirigamiTestUtils
import QtTest

TestCase {
    id: root
    name: "ColumnView"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Component {
        id: columnViewComponent
        Kirigami.ColumnView {}
    }

    Component {
        id: emptyItemPageComponent
        Item {}
    }

    function createViewWith3Items() {
        const view = createTemporaryObject(columnViewComponent, this);
        verify(view);

        const zero = createTemporaryObject(emptyItemPageComponent, this, { objectName: "zero" });
        view.addItem(zero);

        const one = createTemporaryObject(emptyItemPageComponent, this, { objectName: "one" });
        view.addItem(one);

        const two = createTemporaryObject(emptyItemPageComponent, this, { objectName: "two" });
        view.addItem(two);

        compare(view.count, 3);

        return ({
            view,
            zero,
            one,
            two,
        });
    }

    function test_clear() {
        const { view } = createViewWith3Items();
        view.clear();
        compare(view.count, 0);
    }

    function test_contains() {
        const { view, zero, one, two } = createViewWith3Items();

        verify(view.containsItem(zero));
        verify(view.containsItem(one));
        verify(view.containsItem(two));

        view.removeItem(zero);
        verify(!view.containsItem(zero));

        view.addItem(zero);
        verify(view.containsItem(zero));

        verify(!view.containsItem(null));
    }

    function test_remove_by_index_leading() {
        const { view, zero: target } = createViewWith3Items();
        const item = view.removeItem(0);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_index_trailing() {
        const { view, two: target } = createViewWith3Items();
        compare(view.count - 1, 2);
        const item = view.removeItem(2);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_index_middle() {
        const { view, one: target } = createViewWith3Items();
        const item = view.removeItem(1);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_index_last() {
        const { view, zero, one, two } = createViewWith3Items();
        let item;

        item = view.removeItem(0);
        compare(item, zero);
        compare(view.count, 2);

        item = view.removeItem(1);
        compare(item, two);
        compare(view.count, 1);

        item = view.removeItem(0);
        compare(item, one);
        compare(view.count, 0);
    }

    function test_remove_by_index_negative() {
        const { view } = createViewWith3Items();
        const item = view.removeItem(-1);
        compare(item, null);
        compare(view.count, 3);
    }

    function test_remove_by_index_out_of_bounds() {
        const { view } = createViewWith3Items();
        const item = view.removeItem(view.count);
        compare(item, null);
        compare(view.count, 3);
    }

    function test_remove_by_item_leading() {
        const { view, zero: target } = createViewWith3Items();
        const item = view.removeItem(target);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_item_trailing() {
        const { view, two: target } = createViewWith3Items();
        const item = view.removeItem(target);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_item_middle() {
        const { view, one: target } = createViewWith3Items();
        const item = view.removeItem(target);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_item_last() {
        const { view, zero, one, two } = createViewWith3Items();
        let item;

        item = view.removeItem(zero);
        compare(item, zero);
        compare(view.count, 2);

        item = view.removeItem(one);
        compare(item, one);
        compare(view.count, 1);

        item = view.removeItem(two);
        compare(item, two);
        compare(view.count, 0);
    }

    function test_remove_by_item_null() {
        const { view } = createViewWith3Items();
        const item = view.removeItem(null);
        compare(item, null);
        compare(view.count, 3);
    }

    function test_remove_by_item_from_empty() {
        const view = createTemporaryObject(columnViewComponent, this);
        verify(view);
        let item;

        item = view.removeItem(null);
        compare(item, null);

        item = view.removeItem(this);
        compare(item, null);
    }

    function test_pop_item_arg() {
        const { view, zero, one, two } = createViewWith3Items();

        compare(view.pop(one), two);
        compare(view.count, 2);
        compare(view.pop(zero), one);
        compare(view.count, 1);
    }

    function test_pop_index_arg() {
        const { view, zero, one, two } = createViewWith3Items();

        compare(view.pop(1), two);
        compare(view.count, 2);
        compare(view.pop(-1), zero);
        compare(view.count, 0);
    }

    function test_pop_no_args() {
        const { view, zero, one, two } = createViewWith3Items();

        compare(view.pop(), two);
        compare(view.pop(), one);
        compare(view.pop(), zero);
        compare(view.pop(), null);
    }

    function test_move() {
        const { view, zero, one, two } = createViewWith3Items();

        compare(view.contentChildren.length, 3);
        compare(view.contentChildren[0], zero);
        compare(view.contentChildren[2], two);

        view.moveItem(0, 2);

        compare(view.contentChildren[0], one);
        compare(view.contentChildren[1], two);
        compare(view.contentChildren[2], zero);

        // TODO: test currentIndex adjustments
    }

    function test_insert_null() {
        const { view } = createViewWith3Items();
        view.insertItem(0, null);
        compare(view.count, 3);
    }

    function test_insert_duplicate() {
        const { view, one: target } = createViewWith3Items();
        view.insertItem(0, target);
        compare(view.count, 3);
    }

    function test_insert_leading() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.insertItem(0, item);
        compare(view.count, 4)
        compare(view.contentChildren, [item, zero, one, two]);
    }

    function test_insert_trailing() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.insertItem(view.count, item);
        compare(view.count, 4)
        compare(view.contentChildren, [zero, one, two, item]);
    }

    function test_insert_middle() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.insertItem(2, item);
        compare(view.count, 4)
        compare(view.contentChildren, [zero, one, item, two]);
    }

    function test_replace_middle() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.replaceItem(1, item);
        compare(view.count, 3)
        compare(view.contentChildren, [zero, item, two]);
    }

    function test_attached_index() {
        const { view, zero, one, two } = createViewWith3Items();

        compare((zero as Item).Kirigami.ColumnView.index, 0);
        compare((one as Item).Kirigami.ColumnView.index, 1);
        compare((two as Item).Kirigami.ColumnView.index, 2);
    }

    component Filler : Rectangle {
        z: 1
        opacity: 0.2
        color: "#1EA8F7"
        border.color: "black"
        border.width: 1
        radius: 11
        implicitWidth: 100
        height: parent.height
    }

    component Page : Rectangle {
        id: page

        z: 0
        opacity: 0.2
        color: "#CF271C"
        border.color: "black"
        border.width: 1
        radius: 11
        height: parent.height

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => {
                page.Kirigami.ColumnView.view.currentIndex = page.Kirigami.ColumnView.index;
            }
        }
    }

    Component {
        id: clippingColumnViewComponent
        Row {
            readonly property Kirigami.ColumnView columnView: columnView

            width: 300
            height: 100

            Filler {}
            Kirigami.ColumnView {
                id: columnView

                height: 100
                width: 100

                columnWidth: 80
                scrollDuration: 0

                Page {}
                Page {}
                Page {}
            }
            Filler {}
        }
    }

    function test_clicks_outside() {
        const layout = createTemporaryObject(clippingColumnViewComponent, this);
        const { columnView } = layout;
        compare(columnView.count, 3);
        waitForPolish(columnView);

        mouseClick(layout);
        compare(columnView.currentIndex, 0);

        mouseClick(layout, 250); // center of trailing filler
        compare(columnView.currentIndex, 0);

        mouseClick(layout, 50); // center of leading filler
        compare(columnView.currentIndex, 0);

        mouseClick(layout, 190); // where the next page begins
        compare(columnView.currentIndex, 1);

        mouseClick(layout, 190); // where the next page begins
        compare(columnView.currentIndex, 2);

        mouseClick(layout, 50);
        compare(columnView.currentIndex, 2); // does not move
        columnView.clip = false;
        mouseClick(layout, 50);
        compare(columnView.currentIndex, 1); // moves
    }

    function test_contentChildren_assign() {
        const columnView = createTemporaryObject(columnViewComponent, this);
        columnView.width = 800;
        columnView.height = 500;
        waitForPolish(columnView);
        const item1 = createTemporaryObject(emptyItemPageComponent, this);
        const item2 = createTemporaryObject(emptyItemPageComponent, this);
        const item3 = createTemporaryObject(emptyItemPageComponent, this);

        compare(columnView.count, 0);

        columnView.contentChildren = [item1, item2, item3]

        waitForPolish(columnView);

        compare(item1.visible, true);
        compare(item2.visible, true);
        compare(item3.visible, true);

        compare(item1.parent, columnView.contentItem);
        compare(item2.parent, columnView.contentItem);
        compare(item3.parent, columnView.contentItem);

        compare(item1.width, columnView.columnWidth);
        compare(item2.width, columnView.columnWidth);
        compare(item3.width, columnView.width - columnView.columnWidth);

        compare(item1.height, columnView.height);
        compare(item2.height, columnView.height);
        compare(item3.height, columnView.height);

        // Switch to [item3, item2]
        columnView.contentChildren = [item3, item2]

        waitForPolish(columnView);

        compare(item1.visible, false);
        compare(item2.visible, true);
        compare(item3.visible, true);

        compare(item1.parent, root);
        compare(item2.parent, columnView.contentItem);
        compare(item3.parent, columnView.contentItem);

        compare(item2.width, columnView.width - columnView.columnWidth);
        compare(item3.width, columnView.columnWidth);

        compare(item2.height, columnView.height);
        compare(item3.height, columnView.height);

        // Switch to [item3, item1]
        columnView.contentChildren = [item3, item1]

        waitForPolish(columnView);

        compare(item1.visible, true);
        compare(item2.visible, false);
        compare(item3.visible, true);

        compare(item1.parent, columnView.contentItem);
        compare(item2.parent, root);
        compare(item3.parent, columnView.contentItem);

        compare(item1.width, columnView.width - columnView.columnWidth);
        compare(item3.width, columnView.columnWidth);

        compare(item1.height, columnView.height);
        compare(item3.height, columnView.height);
    }

    // ==== page visibility (data-driven: ltr + rtl rows) ====

    Component {
        id: pageComponent
        Item {
            height: parent ? parent.height : 100
        }
    }

    function setDirection(rtl) {
        TestUtils.setLayoutDirection(rtl ? Qt.RightToLeft : Qt.LeftToRight);
    }

    function ltrRtlData() {
        return [ { tag: "ltr", rtl: false }, { tag: "rtl", rtl: true } ];
    }

    function makeScrollingView(properties, count) {
        const view = createTemporaryObject(columnViewComponent, this, properties);
        verify(view);
        const items = [];
        for (let i = 0; i < count; i++) {
            const item = createTemporaryObject(pageComponent, this, { objectName: "page" + i });
            view.addItem(item);
            items.push(item);
        }
        waitForPolish(view);
        return { view, items };
    }

    function cleanup() {
        // the RTL tests change the application-wide layout direction
        TestUtils.setLayoutDirection(Qt.LeftToRight);
    }

    function test_pageVisibility_states_data() {
        return ltrRtlData();
    }

    // Visible/PartlyVisible/Hidden (and inViewport) across the reading start, a half-scrolled row and the reading end.
    function test_pageVisibility_states(data) {
        setDirection(data.rtl);
        const { view, items } = makeScrollingView({
            width: 200,
            height: 200,
            columnWidth: 100,
            scrollDuration: 0,
        }, 3);

        const V = Kirigami.ColumnView.Visible;
        const P = Kirigami.ColumnView.PartlyVisible;
        const H = Kirigami.ColumnView.Hidden;

        // reading start: LTR contentX 0, RTL contentX max
        view.contentX = data.rtl ? view.contentWidth - view.width : 0;
        compare(items[0].Kirigami.ColumnView.pageVisibility, V);
        compare(items[1].Kirigami.ColumnView.pageVisibility, V);
        compare(items[2].Kirigami.ColumnView.pageVisibility, H);

        // half-scrolled row: all states in between
        view.contentX = 50;
        compare(items[0].Kirigami.ColumnView.pageVisibility, P);
        compare(items[1].Kirigami.ColumnView.pageVisibility, V);
        compare(items[2].Kirigami.ColumnView.pageVisibility, P);
        compare(items[0].Kirigami.ColumnView.inViewport, true);
        compare(items[2].Kirigami.ColumnView.inViewport, true);

        // reading end: LTR contentX max, RTL contentX 0
        view.contentX = data.rtl ? 0 : view.contentWidth - view.width;
        compare(items[0].Kirigami.ColumnView.pageVisibility, H);
        compare(items[1].Kirigami.ColumnView.pageVisibility, V);
        compare(items[2].Kirigami.ColumnView.pageVisibility, V);
        compare(items[0].Kirigami.ColumnView.inViewport, false);
    }

    function test_pageVisibility_covered_by_pin_data() {
        // the pin's own legacy state after the scroll is history-dependent
        // (legacy pin state is not refreshed on pure scrolls): LTR keeps
        // the pre-scroll values, RTL happens to land fresh. Both are the
        // preserved base behavior; only pageVisibility is asserted fresh.
        return [
            { tag: "ltr", rtl: false, pinInViewport: false, pinEnabled: false, pinInList: false },
            { tag: "rtl", rtl: true, pinInViewport: true, pinEnabled: true, pinInList: true },
        ];
    }

    // a page fully covered by a pinned dock reports Hidden, while its legacy state (inViewport, enabled, visibleItems) is unchanged.
    function test_pageVisibility_covered_by_pin(data) {
        setDirection(data.rtl);
        const { view, items } = makeScrollingView({
            width: 200,
            height: 200,
            columnWidth: 100,
            scrollDuration: 0,
        }, 4);
        items[0].Kirigami.ColumnView.pinned = true;
        waitForPolish(view);

        // rest at the reading end: the pin docks over page 2's flow slot
        view.contentX = data.rtl ? 0 : view.contentWidth - view.width;
        waitForPolish(view);

        const V = Kirigami.ColumnView.Visible;
        const H = Kirigami.ColumnView.Hidden;
        compare(items[0].Kirigami.ColumnView.pageVisibility, V, "the docked pin is visible");
        compare(items[1].Kirigami.ColumnView.pageVisibility, H);
        compare(items[2].Kirigami.ColumnView.pageVisibility, H, "fully covered by the dock");
        compare(items[3].Kirigami.ColumnView.pageVisibility, V);

        // legacy behavior is preserved: the covered page keeps its
        // viewport-only state
        compare(items[2].Kirigami.ColumnView.inViewport, true, "legacy inViewport untouched");
        compare(items[2].enabled, true, "legacy enabled untouched");
        verify(view.visibleItems.indexOf(items[2]) >= 0, "legacy visibleItems untouched");

        // ... as does the pin's own legacy state
        compare(items[0].Kirigami.ColumnView.inViewport, data.pinInViewport, "pin legacy inViewport");
        compare(items[0].enabled, data.pinEnabled, "pin legacy enabled");
        compare(view.visibleItems.indexOf(items[0]) >= 0, data.pinInList, "pin legacy visibleItems");
    }
}
