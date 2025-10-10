/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick

import org.kde.kirigami.platform as Platform
import org.kde.kirigami as Kirigami

/*!
  \qmltype Separator
  \inqmlmodule org.kde.kirigami.primitives

  \brief A visual separator.

  Useful for splitting one set of items from another.

 */
Item {
    id: root
    implicitHeight: 1
    implicitWidth: 1
    Accessible.role: Accessible.Separator
    Accessible.focusable: false

    enum Weight {
        Light,
        Normal
    }

    /*!
      \brief This property holds the visual weight of the separator.

      Weight options:
      \list
      \li Kirigami.Separator.Weight.Light
      \li Kirigami.Separator.Weight.Normal
      \endlist

      default: Kirigami.Separator.Weight.Normal

      \since 5.72
     */
    property int weight: Separator.Weight.Normal

    // The separator is drawn by an internal rectangle, which gets moved and resized
    // in a way to align exactly to the pixel grid in fractional scaling
    Rectangle {
        width: Math.round(root.width * root.Kirigami.ScenePosition.devicePixelRatio) /root.Kirigami.ScenePosition.devicePixelRatio
        height: Math.round(root.height * root.Kirigami.ScenePosition.devicePixelRatio) /root.Kirigami.ScenePosition.devicePixelRatio

        /* TODO: If we get a separator color role, change this to
         * mix weights lower than Normal with the background color
         * and mix weights higher than Normal with the text color.
         */
        color: Platform.ColorUtils.linearInterpolation(
                Platform.Theme.backgroundColor,
                Platform.Theme.textColor,
                weight === Separator.Weight.Light ? Platform.Theme.lightFrameContrast : Platform.Theme.frameContrast
        )

        x: {return 0
            if (!root.Window.contentItem) {
                return 0;
            }

            const dpr = root.Kirigami.ScenePosition.devicePixelRatio;

            if (root.anchors.left !== undefined && root.anchors.right !== undefined) {
                // If is aligned to both left and rightuse the internal
                // Rectangle pixel snapping as in this case we don't care for it to be exactly 1 pixel wide
                return 0;
            } else if ((LayoutMirroring.enabled && root.anchors.left !== undefined) ||
                       (!LayoutMirroring.enabled && root.anchors.right !== undefined)) {
                // If is right-anchored, we want the visual line to be drawn exactly on the pixel edge
                // of the parent or what's is anchored to
                const xStart = root.Kirigami.ScenePosition.x + root.width - width;
                const xAdjusted = Math.floor(xStart * dpr) / dpr;
                const delta = xStart - xAdjusted
                return root.width - width + delta
            }

            const xAdjusted = Math.floor(root.Kirigami.ScenePosition.x * dpr) / dpr;
            const delta = root.Kirigami.ScenePosition.x - xAdjusted
            return -delta
        }

        y: {return 0
            if (!root.Window.contentItem) {
                return 0;
            }

            const dpr = root.Kirigami.ScenePosition.devicePixelRatio;
            const atTop = root.y <= root.anchors.topMargin;
            const atBottom = root.y + root.height >= root.parent.height - root.anchors.bottomMargin;

            if (atTop && atBottom) {
                return 0;
            } else if (atBottom) {
                const yStart = root.Kirigami.ScenePosition.y + root.height - height;
                const yAdjusted = Math.floor(yStart * dpr) / dpr;
                const delta = yStart - yAdjusted
                return root.height - height + delta
            }

            const yAdjusted = Math.floor(root.Kirigami.ScenePosition.y * dpr) / dpr;
            const delta = root.Kirigami.ScenePosition.y - yAdjusted
            return -delta
        }
    }
}
