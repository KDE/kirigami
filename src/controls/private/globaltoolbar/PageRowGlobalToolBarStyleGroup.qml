/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: globalToolBar
    property int style: Kirigami.ApplicationHeaderStyle.None

    readonly property int actualStyle: {
        if (style === Kirigami.ApplicationHeaderStyle.Auto) {
            if (!Kirigami.Settings.isMobile) {
                return Kirigami.ApplicationHeaderStyle.ToolBar
            } else if (root.wideMode) {
                return Kirigami.ApplicationHeaderStyle.Titles
            } else {
                return Kirigami.ApplicationHeaderStyle.Breadcrumb
            }
        }
        return style;
    }

    /*! @property kirigami::ApplicationHeaderStyle::NavigationButtons */
    property int showNavigationButtons: (!Kirigami.Settings.isMobile || Qt.platform.os === "ios")
        ? (Kirigami.ApplicationHeaderStyle.ShowBackButton | Kirigami.ApplicationHeaderStyle.ShowForwardButton)
        : Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    property bool separatorVisible: true
    //Unfortunately we can't access pageRow.globalToolbar.Kirigami.Theme directly in a declarative way
    property int colorSet: Kirigami.Theme.Header
    // whether or not the header should be
    // "pushed" back when scrolling using the
    // touch screen
    property bool hideWhenTouchScrolling: false
    /*!
     * If true, when any kind of toolbar is shown, the drawer handles will be shown inside the toolbar, if they're present
     */
    property bool canContainHandles: true
    property int toolbarActionAlignment: Qt.AlignRight
    property int toolbarActionHeightMode: Kirigami.ToolBarLayout.ConstrainIfLarger

    property real minimumHeight: 0

    // NOTE: This 40 comes from Breeze but there are not magic units to get it from for now
    property real preferredHeight: 40 + Kirigami.Units.smallSpacing * 2
    property real maximumHeight: preferredHeight

    // Sets the minimum leading padding for the title in a page header
    property int titleLeftPadding: Kirigami.Units.gridUnit
}
