/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls.Material
import org.kde.kirigami as Kirigami

Kirigami.BasicThemeDefinition {
    textColor: Material.foreground
    disabledTextColor: Qt.alpha(Material.foreground, 0.6)

    highlightColor: Material.accent
    //FIXME: something better?
    highlightedTextColor: Material.background
    backgroundColor: Material.background
    alternateBackgroundColor: Qt.darker(Material.background, 1.05)

    hoverColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)
    focusColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)

    activeTextColor: Material.primary
    activeBackgroundColor: Material.primary
    linkColor: "#2980B9"
    linkBackgroundColor: "#2980B9"
    visitedLinkColor: "#7F8C8D"
    visitedLinkBackgroundColor: "#7F8C8D"
    negativeTextColor: "#DA4453"
    negativeBackgroundColor: "#DA4453"
    neutralTextColor: "#F67400"
    neutralBackgroundColor: "#F67400"
    positiveTextColor: "#27AE60"
    positiveBackgroundColor: "#27AE60"

    buttonTextColor: Material.foreground
    buttonBackgroundColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, false, false)
    buttonAlternateBackgroundColor: Qt.darker(Material.buttonColor, 1.05)
    buttonHoverColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)
    buttonFocusColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)

    viewTextColor: Material.foreground
    viewBackgroundColor: Material.dialogColor
    viewAlternateBackgroundColor: Qt.darker(Material.dialogColor, 1.05)
    viewHoverColor: Material.listHighlightColor
    viewFocusColor: Material.listHighlightColor

    selectionTextColor: Material.primaryHighlightedTextColor
    selectionBackgroundColor: Material.textSelectionColor
    selectionAlternateBackgroundColor: Qt.darker(Material.textSelectionColor, 1.05)
    selectionHoverColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)
    selectionFocusColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)

    tooltipTextColor: fontMetrics.Material.foreground
    tooltipBackgroundColor: fontMetrics.Material.tooltipColor
    tooltipAlternateBackgroundColor: Qt.darker(Material.tooltipColor, 1.05)
    tooltipHoverColor: fontMetrics.Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)
    tooltipFocusColor: fontMetrics.Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)

    complementaryTextColor: fontMetrics.Material.foreground
    complementaryBackgroundColor: fontMetrics.Material.background
    complementaryAlternateBackgroundColor: Qt.lighter(fontMetrics.Material.background, 1.05)
    complementaryHoverColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)
    complementaryFocusColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)

    headerTextColor: fontMetrics.Material.primaryTextColor
    headerBackgroundColor: fontMetrics.Material.primaryColor
    headerAlternateBackgroundColor: Qt.lighter(fontMetrics.Material.primaryColor, 1.05)
    headerHoverColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)
    headerFocusColor: Material.buttonColor(Material.theme, Material.background, Material.accent, true, false, true, false)

    defaultFont: fontMetrics.font

    property list<QtObject> children: [
        TextMetrics {
            id: fontMetrics
            //this is to get a source of dark colors
            Material.theme: Material.Dark
        }
    ]

    onSync: object => {
        //TODO: actually check if it's a dark or light color
        if (object.Kirigami.Theme.colorSet === Kirigami.Theme.Complementary) {
            object.Material.theme = Material.Dark
        } else {
            object.Material.theme = Material.Light
        }

        object.Material.foreground = object.Kirigami.Theme.textColor
        object.Material.background = object.Kirigami.Theme.backgroundColor
        object.Material.primary = object.Kirigami.Theme.highlightColor
        object.Material.accent = object.Kirigami.Theme.highlightColor
    }
}
