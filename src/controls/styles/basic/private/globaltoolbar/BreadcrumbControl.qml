/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

RowLayout {
    id: root

    readonly property KC.PageRow pageRow: {
        // This is fetched from breadcrumbLoader in PageRowGlobalToolBarUI.qml
        const pr = parent?.pageRow ?? null;
        return pr as KC.PageRow;
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

    Primitives.Separator {
        Layout.fillHeight: true
        Layout.topMargin: Platform.Units.largeSpacing
        Layout.bottomMargin: Platform.Units.largeSpacing
        Platform.Theme.colorSet: Platform.Theme.Header
        Platform.Theme.inherit: false
        visible: navButtons.visible
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true

        currentIndex: {
            if (!root.pageRow) {
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

            if (root.pageRow.layers.depth > 1) {
                // First layer (index 0) is the main columnView.
                // Since it is ignored, depth has to be adjusted by 1.
                // In case of layers, current index is always the last one,
                // which is one less than their count, thus minus another 1.
                return root.pageRow.layers.depth - 2;
            } else {
                return root.pageRow.currentIndex;
            }
        }

        // This function exists outside of delegate, so that when popping layers
        // the JavaScript execution context won't be destroyed along with delegate.
        function selectIndex(index: int) {
            if (!root.pageRow) {
                return;
            }
            if (root.pageRow.layers.depth > 1) {
                // First layer (index 0) is the main columnView.
                // Since it is ignored, index has to be adjusted by 1.
                // We want to pop anything after selected index,
                // turning selected layer into current one, thus plus another 1.
                while (root.pageRow.layers.depth > index + 2) {
                    root.pageRow.layers.pop();
                }
            } else {
                root.pageRow.currentIndex = index;
            }
        }

        contentHeight: height
        clip: true
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        interactive: Platform.Settings.hasTransientTouchInput

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
                duration: Platform.Units.longDuration
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

            // We can't use KC.Page here instead of Item since we now accept
            // pushing PageRow to a new layer.
            readonly property Item page: {
                if (!root.pageRow) {
                    return null;
                }
                if (root.pageRow.layers.depth > 1) {
                    // First layer (index 0) is the main columnView.
                    // Since it is ignored, index has to be adjusted by 1.
                    return root.pageRow.layers.get(index + 1);
                } else {
                    return root.pageRow.get(index);
                }
            }


            width: Math.ceil(layout.implicitWidth)
            height: ListView.view?.height ?? 0

            hoverEnabled: !Platform.Settings.tabletMode

            onClicked: mouse => {
                list.selectIndex(index);
            }

            // background
            Rectangle {
                color: Platform.Theme.highlightColor
                anchors.fill: parent
                radius: Platform.Units.cornerRadius
                opacity: list.count > 1 && parent.containsMouse ? 0.1 : 0
            }

            // content
            RowLayout {
                id: layout
                anchors.fill: parent
                spacing: 0

                Primitives.Icon {
                    visible: delegate.index > 0
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: Platform.Units.iconSizes.small
                    Layout.preferredWidth: Platform.Units.iconSizes.small
                    isMask: true
                    color: Platform.Theme.textColor
                    source: LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic"
                }
                KC.Heading {
                    Layout.leftMargin: Platform.Units.largeSpacing
                    Layout.rightMargin: Platform.Units.largeSpacing
                    color: Platform.Theme.textColor
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
