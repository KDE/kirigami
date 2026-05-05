/*
 *  SPDX-FileCopyrightText: 2023 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.1-or-later
 */

import QtQuick
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: testCase
    name: "ImageColorsTest"

    width: 400
    height: 400
    visible: true

    when: windowShown

    Component {
        id: colorsComponent
        Item {
            id: root

            readonly property alias colorArea: colorArea

            readonly property Kirigami.ImageColors imageColors: Kirigami.ImageColors {
                id: imageColors
                source: colorArea

                onPaletteChanged: {
                    // Check that it can be assigned to
                    if (palette.length > 0) {
                        root.swatch = palette[0];
                    }
                }
            }

            readonly property SignalSpy paletteChangedSpy: SignalSpy {
                target: imageColors
                signalName: "paletteChanged"
            }

            // Test that the type can be named
            property Kirigami.imageColorsPaletteSwatch swatch

            width: 100
            height: 100

            Rectangle {
                id: colorArea
                anchors.fill: parent
                color: "transparent"
            }
        }
    }

    Component {
        id: invisibleWindowComponent
        Window {
            visible: false

            readonly property Kirigami.ImageColors imageColors: Kirigami.ImageColors {
                source: colorArea
            }

            readonly property alias colorArea: colorArea

            Rectangle {
                id: colorArea
                anchors.fill: parent
                color: "transparent"
            }
        }
    }

    Component {
        id: noWindowComponent
        QtObject {
            readonly property Kirigami.ImageColors imageColors: Kirigami.ImageColors {
                source: colorArea
            }

            readonly property Item colorArea: Rectangle {
                id: colorArea
                width: 10
                height: 10
                color: "transparent"
            }
        }
    }

    function test_extractColors(): void {
        const item = createTemporaryObject(colorsComponent, testCase);
        const { colorArea, imageColors, paletteChangedSpy } = item;

        colorArea.color = Qt.rgba(1, 0, 0);
        imageColors.update();
        paletteChangedSpy.wait();
        compare(paletteChangedSpy.count, 1);
        compare(imageColors.dominant, colorArea.color);

        compare(imageColors.palette.length, 1);
        compare(imageColors.palette[0].ratio, 1.0);
        compare(imageColors.palette[0].color, colorArea.color);
        compare(imageColors.palette[0].contrastColor, "#e6e6e6");
        compare(imageColors.palette[0], item.swatch);
    }

    function test_invisibleWindow(): void {
        // Do not attempt to grabToImage on an item whose window is invisible.
        // failOnWarning(/.?/);

        const window = createTemporaryObject(invisibleWindowComponent, this);
        const { imageColors, colorArea } = window;
        verify(!window.visible);
        verify(colorArea.visible);

        imageColors.update();
    }

    function test_noWindow(): void {
        // Do not attempt to grabToImage on an item which does not belong to any window.
        // failOnWarning(/.?/);

        const { imageColors, colorArea } = createTemporaryObject(noWindowComponent, this);
        verify(colorArea.visible);

        imageColors.update();
    }
}
