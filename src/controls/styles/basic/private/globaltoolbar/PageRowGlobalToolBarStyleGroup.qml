/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.layouts as KL

QtObject {
    id: globalToolBar
    property int style: KC.ApplicationHeaderStyle.None

    readonly property int actualStyle: {
        if (style === KC.ApplicationHeaderStyle.Auto) {
            if (!Platform.Settings.isMobile) {
                return KC.ApplicationHeaderStyle.ToolBar
            } else if (root.wideMode) {
                return KC.ApplicationHeaderStyle.Titles
            } else {
                return KC.ApplicationHeaderStyle.Breadcrumb
            }
        }
        return style;
    }

    /*! @property kirigami::ApplicationHeaderStyle::NavigationButtons */
    property int showNavigationButtons: (!Platform.Settings.isMobile || Qt.platform.os === "ios")
        ? (KC.ApplicationHeaderStyle.ShowBackButton | KC.ApplicationHeaderStyle.ShowForwardButton)
        : KC.ApplicationHeaderStyle.NoNavigationButtons
    property bool separatorVisible: true
    //Unfortunately we can't access pageRow.globalToolbar.Platform.Theme directly in a declarative way
    property int colorSet: Platform.Theme.Header
    // whether or not the header should be
    // "pushed" back when scrolling using the
    // touch screen
    property bool hideWhenTouchScrolling: false
    /*!
     * If true, when any kind of toolbar is shown, the drawer handles will be shown inside the toolbar, if they're present
     */
    property bool canContainHandles: true
    property int toolbarActionAlignment: Qt.AlignRight
    property int toolbarActionHeightMode: KL.ToolBarLayout.ConstrainIfLarger

    property real minimumHeight: 0

    // NOTE: This 40 comes from Breeze but there are not magic units to get it from for now
    property real preferredHeight: 40 + Platform.Units.smallSpacing * 2
    property real maximumHeight: preferredHeight

    // Sets the minimum leading padding for the title in a page header
    property int titleLeftPadding: Platform.Units.gridUnit
}
