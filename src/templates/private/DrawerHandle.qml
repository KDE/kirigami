/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.templates as KT

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
    z: overlay ? overlay.z  + (drawer?.modal && (drawer as KT.OverlayDrawer)?.drawerOpen ? 1 : - 1) : 0

    QQC2.ToolButton {
        id: button
        anchors.centerIn: parent
        flat: false

        icon.name: root.drawer.position > 0 ? root.drawer.handleOpenIcon.name : root.drawer.handleClosedIcon.name
        icon.source: root.drawer.position > 0 ? root.drawer.handleOpenIcon.source ?? "" : root.drawer.handleClosedIcon.source ?? ""
        icon.width: root.drawer.handleOpenIcon.width
        icon.height: root.drawer.handleOpenIcon.height
        Accessible.name: QQC2.ToolTip.text

        onClicked: {
            root.displayToolTip = false;
            Qt.callLater(() => {
                const oDrawer = root.drawer as KT.OverlayDrawer
                oDrawer.drawerOpen = !oDrawer.drawerOpen;
            })
        }
        Keys.onEscapePressed: {
            if (root.drawer.closePolicy & T.Popup.CloseOnEscape) {
                root.drawer.drawerOpen = false;
            }
        }

        QQC2.ToolTip.visible: root.displayToolTip && hovered
        QQC2.ToolTip.text: {
            const oDrawer = root.drawer as KT.OverlayDrawer
            return oDrawer.drawerOpen ? oDrawer.handleOpenToolTip : oDrawer.handleClosedToolTip
        }
        QQC2.ToolTip.delay: Platform.Units.toolTipDelay

        DragHandler {
            target: null
            acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Stylus
            xAxis {
                enabled: root.drawer.edge === Qt.LeftEdge || root.drawer.edge === Qt.RightEdge
                minimum: 0
                maximum: root.drawer.contentItem.width
                onActiveValueChanged: (delta) => {
                    let positionDelta = delta / root.drawer.contentItem.width;
                    if (root.drawer.edge === Qt.RightEdge) {
                        positionDelta *= -1;
                    }
                    root.drawer.position += positionDelta;
                }
            }
            yAxis.enabled: false
            onGrabChanged: (transition, point) => {
                switch (transition) {
                case PointerDevice.GrabExclusive:
                case PointerDevice.GrabPassive:
                    root.drawer.peeking = true;
                    break;
                case PointerDevice.UngrabExclusive:
                case PointerDevice.UngrabPassive:
                case PointerDevice.CancelGrabExclusive:
                case PointerDevice.CancelGrabPassive:
                    root.drawer.peeking = false;
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

    enabled: (drawer as KT.OverlayDrawer).handleVisible

    x: {
        switch (drawer.edge) {
        case Qt.LeftEdge:
            return drawer.background.width * drawer.position + Platform.Units.smallSpacing;
        case Qt.RightEdge:
            return parent.width - (drawer.background.width * drawer.position) - width - Platform.Units.smallSpacing;
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

            let margin = Platform.Units.smallSpacing;
            if (window.footer) {
                margin = window.footer.height + Platform.Units.smallSpacing;
            }

            if (drawer.parent && drawer.height < drawer.parent.height) {
                margin = drawer.parent.height - drawer.height - drawer.y + Platform.Units.smallSpacing;
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
                duration: Platform.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    visible: drawer.enabled && drawer.modal && (drawer.edge === Qt.LeftEdge || drawer.edge === Qt.RightEdge) && opacity > 0
    width: handleAnchor?.visible ? handleAnchor.width : Platform.Units.iconSizes.smallMedium + Platform.Units.smallSpacing * 2
    height: handleAnchor?.visible ? handleAnchor.height : width
    // NOTE: check on pageStack.depth is to keep and hack elisa is doing working
    opacity: handleAnchor && applicationWindow()?.pageStack.depth > 0
            ? drawer.position * (root.drawer as KT.OverlayDrawer).handleVisible
            : 1

    transform: Translate {
        x: (root.drawer as KT.OverlayDrawer).handleVisible ? 0 : (root.drawer.edge === Qt.LeftEdge ? -Math.max(root.width, button.width) : Math.max(root.width, button.width))
        Behavior on x {
            NumberAnimation {
                duration: Platform.Units.longDuration
                easing.type: !(root.drawer as KT.OverlayDrawer).handleVisible ? Easing.OutQuad : Easing.InQuad
            }
        }
    }
}
