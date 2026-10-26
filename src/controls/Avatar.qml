/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

KT.Avatar {
    id: root

    padding: 1

    contentItem: Item {
        QQC.Label {
            anchors.fill: parent

            visible: avatarImage.status !== Image.Ready

            text: Primitives.NameUtils.initialsFromString(root.name)
            textFormat: Text.PlainText
            color: root.color

            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Primitives.Icon {
            anchors.fill: parent
            anchors.margins: Platform.Units.largeSpacing
            source: root.icon.name || root.icon.source

            visible: avatarImage.status !== Image.Ready && Primitives.NameUtils.isStringUnsuitableForInitials(root.name)

            color: root.color
        }

        Image {
            id: avatarImage

            anchors.fill: parent

            visible: status === Image.Ready

            source: root.source
            cache: root.cache
            asynchronous: root.asynchronous
            sourceSize: root.sourceSize

            fillMode: Image.PreserveAspectCrop
            mipmap: true

            layer {
                enabled: GraphicsInfo.api !== GraphicsInfo.Software
                effect: Primitives.ShadowedTexture {
                    radius: Math.min(width, height)
                }
            }
        }
    }

    background: Rectangle {
        visible: !root.__showImage
        anchors.fill: parent
        radius: Math.min(width, height)

        border.width: 1
        border.color: root.color
        color: Platform.ColorUtils.tintWithAlpha(Platform.Theme.backgroundColor, border.color, 0.07)
    }
}
