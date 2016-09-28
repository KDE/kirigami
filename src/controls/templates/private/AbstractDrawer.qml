/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Templates 2.0 as T2
import QtGraphicalEffects 1.0
import org.kde.kirigami 1.0

//TODO: This will become a QQC2 Drawer
//providing just a dummy api for now
T2.Drawer {
    id: root

    parent: T2.ApplicationWindow.overlay
    height: edge == Qt.LeftEdge || edge == Qt.RightEdge ? applicationWindow().height : contentItem.implicitHeight
    width:  edge == Qt.TopEdge || edge == Qt.BottomEdge ? applicationWindow().width : contentItem.implicitwidth

    dragMargin: enabled && (edge == Qt.LeftEdge || edge == Qt.RightEdge) ? Qt.styleHints.startDragDistance : 0

    //default property alias page: mainPage.data
    property bool opened: false
    edge: Qt.LeftEdge
    modal: true
    property bool enabled: true
    property bool peeking: false
    onPositionChanged: {
        if (peeking) {
            visible = true
        }
    }
    onVisibleChanged: {
        if (peeking) {
            visible = true
        } else {
            opened = visible;
        }
    }
    onPeekingChanged:  {
        if (peeking) {
            //FIXME: setting visible here is too early to kill the animation
            //visible = true
            position = 0
        } else {
            positionResetAnim.to = position > 0.5 ? 1 : 0;
            positionResetAnim.running = true
        }
    }

    Component.onCompleted: {
        if (root.opened) {
            root.visible = true;
        }
    }
    //FIXME: any way to avoid?
    property NumberAnimation __internalAnim: NumberAnimation {
        id: positionResetAnim
        target: root
        to: 0
        property: "position"
        duration: (root.position)*Units.longDuration
    }

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    enter: Transition {
        NumberAnimation {
            duration: root.peeking ? 0 : Units.longDuration
        }
    }
    exit: Transition {
        NumberAnimation {
            duration: (root.position)*Units.longDuration
        }
    }
}

