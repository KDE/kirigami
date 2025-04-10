/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls

import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 600
    height: 800
    visible: true

    pageStack.initialPage: Kirigami.Page {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        Column {
            anchors.centerIn: parent

            Kirigami.ShadowedRectangle {
                width: 400
                height: 300

                color: Kirigami.Theme.highlightColor

                radius: radiusSlider.value

                shadow.size: sizeSlider.value
                shadow.xOffset: xOffsetSlider.value
                shadow.yOffset: yOffsetSlider.value

                border.width: borderWidthSlider.value
                border.color: Kirigami.Theme.textColor

                corners.topLeftRadius: topLeftSlider.value
                corners.topRightRadius: topRightSlider.value
                corners.bottomLeftRadius: bottomLeftSlider.value
                corners.bottomRightRadius: bottomRightSlider.value
            }

            Kirigami.FormLayout {
                Item { Kirigami.FormData.isSection: true }

                Slider { id: radiusSlider; from: 0; to: 200; stepSize: 1; Kirigami.FormData.label: `Overall Radius (${parseInt(value)})` }
                Slider { id: topLeftSlider; from: -1; to: 200; stepSize: 1; value: -1; Kirigami.FormData.label: `Top Left Radius (${parseInt(value)})` }
                Slider { id: topRightSlider; from: -1; to: 200; stepSize: 1; value: -1; Kirigami.FormData.label: `Top Right Radius (${parseInt(value)})` }
                Slider { id: bottomLeftSlider; from: -1; to: 200; stepSize: 1; value: -1; Kirigami.FormData.label: `Bottom Left Radius (${parseInt(value)})` }
                Slider { id: bottomRightSlider; from: -1; to: 200; stepSize: 1; value: -1; Kirigami.FormData.label: `Bottom Right Radius (${parseInt(value)})` }

                Slider { id: sizeSlider; from: 0; to: 100; stepSize: 1; Kirigami.FormData.label: `Shadow Size (${parseInt(value)})` }
                Slider { id: xOffsetSlider; from: -100; to: 100; stepSize: 1; Kirigami.FormData.label: `Shadow X-Offset (${parseInt(value)})` }
                Slider { id: yOffsetSlider; from: -100; to: 100; stepSize: 1; Kirigami.FormData.label: `Shadow Y-Offset (${parseInt(value)})` }

                Slider { id: borderWidthSlider; from: 0; to: 50; stepSize: 1; Kirigami.FormData.label: `Border Width (${parseInt(value)})` }
            }
        }
    }
}
