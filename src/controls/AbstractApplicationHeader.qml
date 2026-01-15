/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import "private" as P
import org.kde.kirigami.templates as T
import org.kde.kirigami.platform as Platform

//TODO KF6: remove
T.AbstractApplicationHeader {
    id: root

    Platform.Theme.inherit: false
    Platform.Theme.colorSet: Platform.Theme.Header

    background: Rectangle {
        color: Platform.Theme.backgroundColor
        P.EdgeShadow {
            id: shadow
            visible: root.separatorVisible
            anchors {
                right: parent.right
                left: parent.left
                top: parent.bottom
            }
            edge: Qt.TopEdge
            opacity: (!root.page || !root.page.header || root.page.header.toString().indexOf("ToolBar") === -1)
            Behavior on opacity {
                OpacityAnimator {
                    duration: Platform.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Platform.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
