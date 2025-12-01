/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
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
}
