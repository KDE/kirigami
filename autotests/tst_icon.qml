/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: testCase
    name: "IconTests"

    width: 400
    height: 400
    visible: true

    when: windowShown

    Component { id: emptyIcon; Kirigami.Icon { } }
    Component { id: sourceOnlyIcon; Kirigami.Icon { source: "document-new" } }
    Component { id: sizeOnlyIcon; Kirigami.Icon { width: 50; height: 50 } }
    Component { id: sizeSourceIcon; Kirigami.Icon { width: 50; height: 50; source: "document-new" } }
    Component { id: minimalSizeIcon; Kirigami.Icon { width: 1; height: 1; source: "document-new" } }
    Component {
        id: absolutePathIcon;
        Kirigami.Icon {
            id: icon
            width: 50;
            height: 50;
            source: Qt.resolvedUrl("stop-icon.svg")
        }
    }
    Kirigami.ImageColors {
        id: imageColors
    }

    function test_create_data() {
        return [
            { tag: "Empty", component: emptyIcon },
            { tag: "Source Only", component: sourceOnlyIcon },
            { tag: "Size Only", component: sizeOnlyIcon },
            { tag: "Size & Source", component: sizeSourceIcon },
            { tag: "Minimal Size", component: minimalSizeIcon }
        ]
    }

    // Test creation of Icon objects.
    // It should not crash when certain properties are not specified and also
    // should still work when they are.
    function test_create(data) {
        var icon = createTemporaryObject(data.component, testCase)
        verify(icon)
        verify(waitForRendering(icon))
    }

    function test_absolutepath_recoloring() {
        var icon = createTemporaryObject(absolutePathIcon, testCase)
        verify(icon)
        verify(waitForRendering(icon))

        var image = icon.grabToImage(function(result) {
            // Access pixel data of the captured image
            imageColors.source = result.image
            imageColors.update()
        })
        print(Qt.resolvedUrl("stop-icon.svg"))
        tryCompare(imageColors, "dominant", "#2980b9")
    }
}
