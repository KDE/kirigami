/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import "private" as KP
import org.kde.kirigami.templates as KT
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.controls as KC

KT.OverlayDrawer {
    id: root

//BEGIN Properties
    focus: false
    modal: true
    drawerOpen: !modal
    closePolicy: modal ? T.Popup.CloseOnEscape | T.Popup.CloseOnReleaseOutside : T.Popup.NoAutoClose
    handleVisible: interactive && (modal || !drawerOpen) && (typeof(applicationWindow)===typeof(Function) && applicationWindow() ? applicationWindow().controlsVisible : true)

    // FIXME: set to false when it does not lead to blocking closePolicy.
    // See Kirigami bug: 454119
    interactive: true

    onPositionChanged: {
        if (!modal && !root.peeking && !root.animating) {
            position = 1;
        }
    }

    background: Rectangle {
        color: Platform.Theme.backgroundColor

        Primitives.Separator {
            id: separator

            LayoutMirroring.enabled: false

            anchors {
                top: root.edge === Qt.TopEdge ? parent.bottom : (root.edge === Qt.BottomEdge ? undefined : parent.top)
                left: root.edge === Qt.LeftEdge ? parent.right : (root.edge === Qt.RightEdge ? undefined : parent.left)
                right: root.edge === Qt.RightEdge ? parent.left : (root.edge === Qt.LeftEdge ? undefined : parent.right)
                bottom: root.edge === Qt.BottomEdge ? parent.top : (root.edge === Qt.TopEdge ? undefined : parent.bottom)
                topMargin: segmentedSeparator.height
            }

            visible: !root.modal

            Platform.Theme.inherit: false
            Platform.Theme.colorSet: Platform.Theme.Header
        }

        Item {
            id: segmentedSeparator

            // an alternative to segmented style is full height
            readonly property bool shouldUseSegmentedStyle: {
                if (root.edge !== Qt.LeftEdge && root.edge !== Qt.RightEdge) {
                    return false;
                }
                if (root.collapsed) {
                    return false;
                }
                // compatible header
                const header = (root as KC.GlobalDrawer)?.header ?? null;
                if (header instanceof T.ToolBar || header instanceof KT.AbstractApplicationHeader) {
                    return true;
                }
                // or compatible content
                if (root.contentItem instanceof ColumnLayout && root.contentItem.children[0] instanceof T.ToolBar) {
                    return true;
                }
                return false;
            }

            anchors {
                top: parent.top
                left: separator.left
                right: separator.right
            }

            height: {
                if (root.edge !== Qt.LeftEdge && root.edge !== Qt.RightEdge) {
                    return 0;
                }
                if (typeof applicationWindow === "undefined") {
                    return 0;
                }
                const window = applicationWindow();
                const globalToolBar = window.pageStack?.globalToolBar;
                if (!globalToolBar) {
                    return 0;
                }

                return globalToolBar.preferredHeight;
            }

            visible: separator.visible

            Primitives.Separator {
                LayoutMirroring.enabled: false

                anchors {
                    fill: parent
                    topMargin: segmentedSeparator.shouldUseSegmentedStyle ? Platform.Units.largeSpacing : 0
                    bottomMargin: segmentedSeparator.shouldUseSegmentedStyle ? Platform.Units.largeSpacing : 0
                }

                Behavior on anchors.topMargin {
                    NumberAnimation {
                        duration: Platform.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on anchors.bottomMargin {
                    NumberAnimation {
                        duration: Platform.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Platform.Theme.inherit: false
                Platform.Theme.colorSet: Platform.Theme.Header
            }
        }

        KP.EdgeShadow {
            z: -2
            visible: root.modal
            edge: root.edge
            anchors {
                right: root.edge === Qt.RightEdge ? parent.left : (root.edge === Qt.LeftEdge ? undefined : parent.right)
                left: root.edge === Qt.LeftEdge ? parent.right : (root.edge === Qt.RightEdge ? undefined : parent.left)
                top: root.edge === Qt.TopEdge ? parent.bottom : (root.edge === Qt.BottomEdge ? undefined : parent.top)
                bottom: root.edge === Qt.BottomEdge ? parent.top : (root.edge === Qt.TopEdge ? undefined : parent.bottom)
            }

            opacity: root.position === 0 ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Platform.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
