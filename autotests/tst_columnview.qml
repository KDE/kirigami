/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    name: "ColumnView"
    visible: true
    when: windowShown

    width: 500
    height: 500

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

        mouseClick(layout, 190); // where the next page begins
        compare(columnView.currentIndex, 1);
        columnView.clip = false;

        mouseClick(layout, 190); // where the next page begins
        compare(columnView.currentIndex, 2);

        // mouseClick(layout, 50);
        // compare(columnView.currentIndex, 2); // does not move
        // columnView.clip = false;
        mouseClick(layout, 50);
        compare(columnView.currentIndex, 1); // moves
    }
}
