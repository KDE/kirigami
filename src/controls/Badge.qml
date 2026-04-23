/*
 *  SPDX-FileCopyrightText: 2025-2026 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT
import org.kde.kirigami.primitives as Primitives


KT.Badge {
    id: root

    padding: Platform.Units.smallSpacing
    topPadding: padding
    // Extra horizontal padding looks better when pill-shaped with icons and long labels
    horizontalPadding: internal.pillShaped && !internal.circular && internal.labelVisible ? (padding + Platform.Units.smallSpacing) : padding
    leftPadding: horizontalPadding + (LayoutMirroring.enabled ? internal.extraTrailingPadding : 0)
    rightPadding: horizontalPadding + (LayoutMirroring.enabled ? 0 : internal.extraTrailingPadding)
    bottomPadding: padding

    spacing: Platform.Units.smallSpacing

    font.bold: true
    font.pointSize: Platform.Theme.smallFont.pointSize
    font.family: Platform.Theme.smallFont.family

    QtObject {
        id: internal

        // Size and layout
        readonly property bool pillShaped: root.text.length === 0 || label.lineCount === 1
        readonly property bool labelVisible: root.text.length > 0
        readonly property bool circular: root.implicitContentWidth + root.padding * 2 <= root.implicitHeight
        readonly property int extraTrailingPadding: internal.pillShaped && icon.visible && labelVisible ? Platform.Units.smallSpacing : 0

        // Colors
        // TODO: use unmodified semantically appropriate colors from the color scheme, once they exist
        readonly property color borderColor: {
            if (root.customColor !== Qt.color("transparent")) {
                return Platform.ColorUtils.linearInterpolation(root.customColor, Platform.Theme.textColor, 0.5)
            }

            switch (root.type) {
                case KT.Badge.Type.Positive:
                    return Platform.Theme.positiveTextColor;
                case KT.Badge.Type.Warning:
                    return Platform.Theme.neutralTextColor;
                case KT.Badge.Type.Error:
                    return Platform.Theme.negativeTextColor;
                default:
                    return Platform.Theme.activeTextColor;
            }
        }
        readonly property color backgroundColor: root.customColor !== Qt.color("transparent")
            ? root.customColor
            : Platform.ColorUtils.tintWithAlpha(Platform.Theme.backgroundColor, borderColor, 0.2)
        readonly property color textColor: {
            if (root.customTextColor !== Qt.color("transparent")) {
                return root.customTextColor;
            }

            let baseTextColor = Platform.Theme.textColor

            // Ensure readability on arbitrary background colors, overriding
            // the theme's text color if needed
            if (Platform.ColorUtils.brightnessForColor(backgroundColor) == Platform.ColorUtils.brightnessForColor(baseTextColor)) {
                baseTextColor = Platform.ColorUtils.brightnessForColor(backgroundColor) == Platform.ColorUtils.Light ? "black" : "white"
            }
            // 0.17 is the lowest we can go and still achieve WCAG AAA contrast ratio with the default colors
            Platform.ColorUtils.linearInterpolation(baseTextColor, backgroundColor, 0.17)
        }
    }

    // Match styling of Kirigami.InlineMessage
    background: Rectangle {
        border.width: 1
        border.color: internal.borderColor
        color: internal.backgroundColor
        radius: internal.pillShaped ? root.height / 2 : Platform.Units.cornerRadius
    }

    contentItem: RowLayout {
        spacing: root.spacing

        Primitives.Icon {
            id: icon

            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            Layout.alignment: internal.pillShaped ? Qt.AlignHCenter : Qt.AlignTop

            visible: source.length > 0

            source: root.icon.name || root.icon.source || ""

            isMask: root.icon.color !== Qt.color("transparent") || root.icon.name.endsWith("-symbolic")
            color: root.icon.color !== Qt.color("transparent") ? root.icon.color : internal.textColor

        }

        QQC2.Label {
            id: label

            Layout.fillWidth: true

            visible: text.length > 0

            text: root.text
            color: internal.textColor
            font: root.font

            wrapMode: Text.Wrap
            horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
            textFormat: Text.PlainText
        }
    }
}
