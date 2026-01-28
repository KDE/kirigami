/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami.controls as KC
import org.kde.kirigami.templates as KT
import "../" as P

P.PrivateActionToolButton {
    id: root
    property KT.OverlayDrawer drawer

    icon.name: drawer?.position === 1 ? (drawer?.handleOpenIcon.name ?? "") : (drawer?.handleClosedIcon.name ?? "")
    icon.source: drawer?.position === 1 ? (drawer?.handleOpenIcon.source ?? "") : (drawer?.handleClosedIcon.source ?? "")

    action: KC.Action {
        children: root.drawer && (root.drawer as KC.GlobalDrawer)?.isMenu ? (root.drawer as KC.GlobalDrawer).actions : []
        tooltip: {
            if (root.drawer && (root.drawer as KC.GlobalDrawer)?.isMenu) {
                return checked ? qsTr("Close menu") : qsTr("Open menu");
            }

            return (root.QQC.ApplicationWindow.window as KC.ApplicationWindow)?.globalDrawer?.handleClosedToolTip || ""
        }
    }

    onClicked: {
        if (!drawer || (root.drawer as KC.GlobalDrawer)?.isMenu) {
            return;
        }
        if (drawer.visible) {
            drawer.close();
        } else {
            // CallLater is necessary for when the DragHandler still had grab
            Qt.callLater(drawer.open);
        }
    }

    Connections {
        // Only target the GlobalDrawer when it *is* a GlobalDrawer, since
        // it can be something else, and that something else probably
        // doesn't have an isMenuChanged() signal.
        target: root.drawer as KC.GlobalDrawer
        function onIsMenuChanged() {
            if (!(root.drawer as KC.GlobalDrawer).isMenu && root.menu) {
                root.menu.dismiss()
            }
        }
    }


    DragHandler {
        target: null
        acceptedDevices: PointerDevice.TouchScreen
        xAxis {
            enabled: root.drawer && (root.drawer.edge === Qt.LeftEdge || root.drawer.edge === Qt.RightEdge)
            minimum: 0
            maximum: root.drawer?.contentItem.width ?? 0
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
