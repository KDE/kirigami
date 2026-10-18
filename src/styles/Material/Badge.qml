/*
 * SPDX-FileCopyrightText: 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

KT.Badge {
    id: root

    readonly property bool _hasIcon: icon.name.length > 0 || (icon.source?.toString().length ?? 0) > 0
    readonly property bool _hasContent: text.length > 0 || _hasIcon
    readonly property color _backgroundColor: {
        if (customColor !== Qt.color("transparent")) {
            return customColor;
        }
        const shade = Material.theme === Material.Dark ? Material.Shade200 : Material.Shade700;
        switch (type) {
        case KT.Badge.Type.Positive:
            return Material.color(Material.Green, shade);
        case KT.Badge.Type.Warning:
            return Material.color(Material.Amber, shade);
        default:
            return Material.color(Material.Red, shade);
        }
    }
    readonly property color _textColor: customTextColor !== Qt.color("transparent") ? customTextColor
        : Platform.ColorUtils.brightnessForColor(_backgroundColor) === Platform.ColorUtils.Light ? "black" : "white"

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitHeight,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    verticalPadding: _hasIcon ? Platform.Units.smallSpacing : 0
    horizontalPadding: _hasContent ? Platform.Units.smallSpacing : 0
    spacing: Platform.Units.smallSpacing

    font {
        family: Platform.Theme.smallFont.family
        pointSize: Platform.Theme.smallFont.pointSize
        weight: Font.Medium
    }

    icon {
        width: Platform.Units.iconSizes.small
        height: Platform.Units.iconSizes.small
    }

    background: Rectangle {
        implicitWidth: implicitHeight
        implicitHeight: root._hasContent ? Platform.Units.iconSizes.small : Platform.Units.mediumSpacing
        border.width: 0
        color: root._backgroundColor
        radius: label.lineCount > 1 ? Platform.Units.cornerRadius : height / 2
    }

    contentItem: RowLayout {
        spacing: root.spacing

        Primitives.Icon {
            visible: root._hasIcon
            source: root.icon.name || root.icon.source
            color: root.icon.color !== Qt.color("transparent") ? root.icon.color : root._textColor
            isMask: root.icon.color !== Qt.color("transparent") || root.icon.name.endsWith("-symbolic")
            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            Layout.alignment: label.lineCount > 1 ? Qt.AlignTop : Qt.AlignVCenter
            Accessible.ignored: true
        }

        Label {
            id: label

            visible: root.text.length > 0
            text: root.text
            color: root._textColor
            font: root.font
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            horizontalAlignment: root._hasIcon ? Text.AlignLeft : Text.AlignHCenter
            Layout.fillWidth: true
            Accessible.ignored: true
        }
    }
}
