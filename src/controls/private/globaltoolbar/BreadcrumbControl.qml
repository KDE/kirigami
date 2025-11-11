/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: root

    readonly property Kirigami.PageRow pageRow: {
        // This is fetched from breadcrumbLoader in PageRowGlobalToolBarUI.qml
        const pr = parent?.pageRow ?? null;
        return pr as Kirigami.PageRow;
    }

    // No spacing as the separator will be the thing that visually clips the ListView
    spacing: 0

    HandleButton {
        drawer: QQC.ApplicationWindow.window?.globalDrawer
        visible: drawer !== null
    }

    NavigationButtons {
        id: navButtons
        pageStack: root.pageRow
        page: root.pageRow.currentItem
    }

    Kirigami.Separator {
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        Layout.bottomMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false
        visible: navButtons.visible
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true

        currentIndex: {
            if (!pageRow) {
                return -1;
            }
            // This ListView is eventually consistent with PageRow, so it has to
            // force-refresh currentIndex when its count finally catches up,
            // otherwise currentIndex might get reset and stuck at -1.
            void count;
            // TODO: This "eventual consistency" causes Behavior on contentX to
            // scroll from the start each time a page is added. Besides, simple
            // number is not the most efficient model, because ListView
            // recreates all delegates when number changes.

            if (pageRow.layers.depth > 1) {
                // First layer (index 0) is the main columnView.
                // Since it is ignored, depth has to be adjusted by 1.
                // In case of layers, current index is always the last one,
                // which is one less than their count, thus minus another 1.
                return pageRow.layers.depth - 2;
            } else {
                return pageRow.currentIndex;
            }
        }

        // This function exists outside of delegate, so that when popping layers
        // the JavaScript execution context won't be destroyed along with delegate.
        function selectIndex(index: int) {
            if (!pageRow) {
                return;
            }
            if (pageRow.layers.depth > 1) {
                // First layer (index 0) is the main columnView.
                // Since it is ignored, index has to be adjusted by 1.
                // We want to pop anything after selected index,
                // turning selected layer into current one, thus plus another 1.
                while (pageRow.layers.depth > index + 2) {
                    pageRow.layers.pop();
                }
            } else {
                pageRow.currentIndex = index;
            }
        }

        contentHeight: height
        clip: true
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        interactive: Kirigami.Settings.hasTransientTouchInput

        contentX: {
            if (!currentItem) {
                return 0;
            }
            // preferred position: current item is centered within viewport
            const preferredPosition = currentItem.x + (currentItem.width - width) / 2;

            // Note: Order of min/max is important. Make sure to test on all sorts
            // and sizes before committing changes to this formula.
            if (LayoutMirroring.enabled) {
                // In a mirrored ListView contentX starts from left edge and increases to the left.
                const maxLeftPosition = -contentWidth;
                const minRightPosition = -width;
                return Math.round(Math.min(minRightPosition, Math.max(preferredPosition, maxLeftPosition)));
            } else {
                const minLeftPosition = 0;
                const maxRightPosition = contentWidth - width;
                return Math.round(Math.max(minLeftPosition, Math.min(preferredPosition, maxRightPosition)));
            }
        }

        Behavior on contentX {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        model: {
            if (!root.pageRow) {
                return null;
            }
            if (root.pageRow.layers.depth > 1) {
                // First layer (index 0) is the main columnView; ignore it.
                return root.pageRow.layers.depth - 1;
            } else {
                return root.pageRow.depth;
            }
        }

        delegate: MouseArea {
            id: delegate

            required property int index

            // We can't use Kirigami.Page here instead of Item since we now accept
            // pushing PageRow to a new layer.
            readonly property Item page: {
                if (!root.pageRow) {
                    return null;
                }
                if (root.pageRow.layers.depth > 1) {
                    // First layer (index 0) is the main columnView.
                    // Since it is ignored, index has to be adjusted by 1.
                    return pageRow.layers.get(index + 1);
                } else {
                    return pageRow.get(index);
                }
            }


            width: Math.ceil(layout.implicitWidth)
            height: ListView.view?.height ?? 0

            hoverEnabled: !Kirigami.Settings.tabletMode

            onClicked: mouse => {
                list.selectIndex(index);
            }

            // background
            Rectangle {
                color: Kirigami.Theme.highlightColor
                anchors.fill: parent
                radius: Kirigami.Units.cornerRadius
                opacity: list.count > 1 && parent.containsMouse ? 0.1 : 0
            }

            // content
            RowLayout {
                id: layout
                anchors.fill: parent
                spacing: 0

                Kirigami.Icon {
                    visible: delegate.index > 0
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    isMask: true
                    color: Kirigami.Theme.textColor
                    source: LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic"
                }
                Kirigami.Heading {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.NoWrap
                    text: delegate.page?.title ?? ""
                    opacity: delegate.ListView.isCurrentItem ? 1 : 0.4
                }
            }
        }
    }

    HandleButton {
        drawer: QQC.ApplicationWindow.window?.contextDrawer
        visible: drawer !== null
    }
}
