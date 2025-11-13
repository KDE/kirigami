/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

Item {
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

    QQC2.ToolButton {
        id: button
        anchors.centerIn: parent
        flat: false

        icon.name: root.drawer.drawerOpen ? drawer.handleOpenIcon.name : drawer.handleClosedIcon.name
        icon.source: root.drawer.drawerOpen ? drawer.handleOpenIcon.source ?? "" : drawer.handleClosedIcon.source ?? ""
        icon.width: drawer.handleOpenIcon.width
        icon.height: drawer.handleOpenIcon.height
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

        QQC2.ToolTip.visible: displayToolTip && hovered
        QQC2.ToolTip.text: drawer.drawerOpen ? handleOpenToolTip : handleClosedToolTip
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

        DragHandler {
            target: null
            acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Stylus
            xAxis {
                enabled: drawer.edge === Qt.LeftEdge || drawer.edge === Qt.RightEdge
                minimum: 0
                maximum: drawer.contentItem.width
                onActiveValueChanged: (delta) => {
                    let positionDelta = delta / drawer.contentItem.width;
                    if (drawer.edge === Qt.RightEdge) {
                        positionDelta *= -1;
                    }
                    drawer.position += positionDelta;
                }
            }
            yAxis.enabled: false
            onGrabChanged: (transition, point) => {
                switch (transition) {
                case PointerDevice.GrabExclusive:
                case PointerDevice.GrabPassive:
                    drawer.peeking = true;
                    break;
                case PointerDevice.UngrabExclusive:
                case PointerDevice.UngrabPassive:
                case PointerDevice.CancelGrabExclusive:
                case PointerDevice.CancelGrabPassive:
                    drawer.peeking = false;
                    break;
                default:
                    break;
                }
            }
        }
    }

    property Item handleAnchor: {
        if (typeof applicationWindow === "undefined") {
            return null;
        }
        const window = applicationWindow();
        const globalToolBar = window.pageStack?.globalToolBar;
        if (!globalToolBar) {
            return null;
        }
        return (drawer.edge === Qt.LeftEdge && !LayoutMirroring.enabled) || (drawer.edge === Qt.RightEdge && LayoutMirroring.enabled)
            ? globalToolBar.leftHandleAnchor
            : globalToolBar.rightHandleAnchor;
    }

    enabled: drawer.handleVisible

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

    visible: drawer.enabled && drawer.modal && (drawer.edge === Qt.LeftEdge || drawer.edge === Qt.RightEdge) && opacity > 0
    width: handleAnchor?.visible ? handleAnchor.width : Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
    height: handleAnchor?.visible ? handleAnchor.height : width
    // NOTE: check on pageStack.depth is to keep and hack elisa is doing working
    opacity: handleAnchor && applicationWindow()?.pageStack.depth > 0 ? drawer.position : 1

    transform: Translate {
        x: root.drawer.handleVisible ? 0 : (root.drawer.edge === Qt.LeftEdge ? -Math.max(root.width, button.width) : Math.max(root.width, button.width))
        Behavior on x {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: !root.drawer.handleVisible ? Easing.OutQuad : Easing.InQuad
            }
        }
    }
}
