/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT
import "../" as P

P.PrivateActionToolButton {
    id: root
    property KT.OverlayDrawer drawer

    icon.name: drawer?.handleClosedIcon.name ?? ""
    icon.source: drawer?.handleClosedIcon.source ?? ""

    action: Kirigami.Action {
        children: drawer instanceof Kirigami.GlobalDrawer && drawer.isMenu ? drawer.actions : []
        tooltip: {
            if (drawer.isMenu) {
                return checked ? qsTr("Close menu") : qsTr("Open menu");
            }

            return root.QQC.ApplicationWindow.window?.globalDrawer.handleClosedToolTip
        }
    }

    onClicked: {
        if (!drawer || drawer?.isMenu) {
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
        target: drawer as Kirigami.GlobalDrawer
        function onIsMenuChanged() {
            if (!drawer.isMenu && root.menu) {
                root.menu.dismiss()
            }
        }
    }


    DragHandler {
        target: null
        acceptedDevices: PointerDevice.TouchScreen
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
