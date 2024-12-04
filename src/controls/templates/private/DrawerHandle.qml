/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

MouseArea {
    id: root

    /*
     * This property is used to set when the tooltip is visible.
     * It exists because the text is changed while the tooltip is still visible.
     */
    property bool displayToolTip: true

    /*
     * The drawer this handle will control
     */
    // Should be KT.OverlayDrawer, but can't due to "Cyclic dependency"
    property T.Drawer drawer

    readonly property T.Overlay overlay: drawer.T.Overlay.overlay

    // Above the Overlay when modal but below when non-modal and when the drawer is closed
    // so that other overlays can be above it.
    parent: overlay?.parent ?? null
    z: overlay ? overlay.z  + (drawer?.modal && drawer?.drawerOpen ? 1 : - 1) : 0

    preventStealing: true
    hoverEnabled: handleAnchor?.visible ?? false

    QQC2.ToolButton {
        anchors.centerIn: parent
        width: parent.height - Kirigami.Units.smallSpacing * 1.5
        height: parent.height - Kirigami.Units.smallSpacing * 1.5
        visible: !Kirigami.Settings.tabletMode && !Kirigami.Settings.hasTransientTouchInput

        Accessible.name: root.drawer.drawerOpen ? root.drawer.handleOpenToolTip : root.drawer.handleClosedToolTip

        onClicked: {
            root.displayToolTip = false;
            Qt.callLater(() => {
                root.drawer.drawerOpen = !root.drawer.drawerOpen;
            })
        }
        Keys.onEscapePressed: {
            if (root.drawer.closePolicy & T.Popup.CloseOnEscape) {
                root.drawer.drawerOpen = false;
            }
        }
    }

    QQC2.ToolTip.visible: displayToolTip && containsMouse
    QQC2.ToolTip.text: drawer.drawerOpen ? handleOpenToolTip : handleClosedToolTip
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

    property Item handleAnchor: {
        if (typeof applicationWindow === "undefined") {
            return null;
        }
        const window = applicationWindow();
        const globalToolBar = window.pageStack?.globalToolBar;
        if (!globalToolBar) {
            return null;
        }
        return (drawer.edge === Qt.LeftEdge && !drawer.mirrored) || (drawer.edge === Qt.RightEdge && drawer.mirrored)
            ? globalToolBar.leftHandleAnchor
            : globalToolBar.rightHandleAnchor;
    }

    property int startX
    property int mappedStartX

    enabled: drawer.handleVisible

    onPressed: mouse => {
        drawer.peeking = true;
        startX = mouse.x;
        mappedStartX = mapToItem(parent, startX, 0).x;
    }

    onPositionChanged: mouse => {
        if (!pressed) {
            return;
        }
        const pos = mapToItem(parent, mouse.x - startX, mouse.y);
        switch (drawer.edge) {
        case Qt.LeftEdge:
            drawer.position = pos.x / drawer.contentItem.width;
            break;
        case Qt.RightEdge:
            drawer.position = (drawer.parent.width - pos.x - width) / drawer.contentItem.width;
            break;
        default:
        }
    }

    onReleased: mouse => {
        drawer.peeking = false;
        if (Math.abs(mapToItem(parent, mouse.x, 0).x - mappedStartX) < Qt.styleHints.startDragDistance) {
            if (!drawer.drawerOpen) {
                drawer.close();
            }
            drawer.drawerOpen = !drawer.drawerOpen;
        }
    }

    onCanceled: {
        drawer.peeking = false
    }

    x: {
        switch (drawer.edge) {
        case Qt.LeftEdge:
            return drawer.background.width * drawer.position + Kirigami.Units.smallSpacing;
        case Qt.RightEdge:
            return parent.width - (drawer.background.width * drawer.position) - width - Kirigami.Units.smallSpacing;
        default:
            return 0;
        }
    }

    Binding {
        when: root.handleAnchor && root.anchors.bottom
        target: root
        property: "y"
        value: root.handleAnchor ? root.handleAnchor.Kirigami.ScenePosition.y : 0
        restoreMode: Binding.RestoreBinding
    }

    anchors {
        bottom: handleAnchor ? undefined : parent.bottom
        bottomMargin: {
            if (typeof applicationWindow === "undefined") {
                return undefined;
            }
            const window = applicationWindow();

            let margin = Kirigami.Units.smallSpacing;
            if (window.footer) {
                margin = window.footer.height + Kirigami.Units.smallSpacing;
            }

            if (drawer.parent && drawer.height < drawer.parent.height) {
                margin = drawer.parent.height - drawer.height - drawer.y + Kirigami.Units.smallSpacing;
            }

            if (!window || !window.pageStack ||
                !window.pageStack.contentItem ||
                !window.pageStack.contentItem.itemAt) {
                return margin;
            }

            let item;
            if (window.pageStack.layers.depth > 1) {
                item = window.pageStack.layers.currentItem;
            } else {
                item = window.pageStack.contentItem.itemAt(window.pageStack.contentItem.contentX + x, 0);
            }

            // try to take the last item
            if (!item) {
                item = window.pageStack.lastItem;
            }

            let pageFooter = item && item.page ? item.page.footer : (item ? item.footer : undefined);
            if (pageFooter && drawer.parent) {
                margin = drawer.height < drawer.parent.height ? margin : margin + pageFooter.height
            }

            return margin;
        }

        Behavior on bottomMargin {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    visible: drawer.enabled && (drawer.edge === Qt.LeftEdge || drawer.edge === Qt.RightEdge) && opacity > 0
    width: handleAnchor?.visible ? handleAnchor.width : Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
    height: handleAnchor?.visible ? handleAnchor.height : width
    opacity: drawer.handleVisible ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    transform: Translate {
        x: root.drawer.handleVisible ? 0 : (root.drawer.edge === Qt.LeftEdge ? -root.width : root.width)
        Behavior on x {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: !root.drawer.handleVisible ? Easing.OutQuad : Easing.InQuad
            }
        }
    }
}
