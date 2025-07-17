/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import "private" as KP
import org.kde.kirigami.templates as KT

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
        color: Kirigami.Theme.backgroundColor

        Item {
            parent: root.handle
            anchors.fill: parent

            Kirigami.ShadowedRectangle {
                id: handleGraphics
                anchors.centerIn: parent

                Kirigami.Theme.colorSet: parent.parent.handleAnchor && parent.parent.handleAnchor.visible ? parent.parent.handleAnchor.Kirigami.Theme.colorSet : Kirigami.Theme.Button

                Kirigami.Theme.backgroundColor: parent.parent.handleAnchor && parent.parent.handleAnchor.visible ? parent.parent.handleAnchor.Kirigami.Theme.backgroundColor : undefined

                Kirigami.Theme.textColor: parent.parent.handleAnchor && parent.parent.handleAnchor.visible ? parent.parent.handleAnchor.Kirigami.Theme.textColor : undefined

                Kirigami.Theme.inherit: false
                color: root.handle.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor

                visible: root.modal && (!parent.parent.handleAnchor || !parent.parent.handleAnchor.visible || root.handle.pressed || root.position > 0)
                opacity: (parent.parent.handleAnchor && parent.parent.handleAnchor.visible) ? root.position : 1


                shadow.color: Qt.rgba(0, 0, 0, root.handle.pressed ? 0.6 : 0.4)
                shadow.yOffset: 1
                shadow.size: Kirigami.Units.gridUnit / 2

                width: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
                height: width
                radius: Kirigami.Units.cornerRadius
                Behavior on color {
                    ColorAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            Loader {
                anchors.centerIn: handleGraphics
                width: height
                height: Kirigami.Units.iconSizes.smallMedium

                Kirigami.Theme.colorSet: handleGraphics.Kirigami.Theme.colorSet
                Kirigami.Theme.backgroundColor: handleGraphics.Kirigami.Theme.backgroundColor
                Kirigami.Theme.textColor: handleGraphics.Kirigami.Theme.textColor

                asynchronous: true

                source: {
                    let edge = root.edge;
                    if (Qt.application.layoutDirection === Qt.RightToLeft) {
                        if (edge === Qt.LeftEdge) {
                            edge = Qt.RightEdge;
                        } else {
                            edge = Qt.LeftEdge;
                        }
                    }

                    // TODO: those 3 still resolve because templates files are installed on
                    // the same place, but we should probably eventually just use normal icons
                    // and drop that custom morphing animation
                    if ((root.handleClosedIcon.source || root.handleClosedIcon.name)
                        && (root.handleOpenIcon.source || root.handleOpenIcon.name)) {
                        return Qt.resolvedUrl("templates/private/GenericDrawerIcon.qml");
                    } else if (edge === Qt.LeftEdge) {
                        return Qt.resolvedUrl("templates/private/MenuIcon.qml");
                    } else if (edge === Qt.RightEdge && root instanceof Kirigami.ContextDrawer) {
                        return Qt.resolvedUrl("templates/private/ContextIcon.qml");
                    } else {
                        return "";
                    }
                }
                onItemChanged: {
                    if (item) {
                        item.drawer = root;
                        item.color = Qt.binding(() => root.handle.pressed
                            ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor);
                    }
                }
            }
        }

        Kirigami.Separator {
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

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
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
                const header = root.header ?? null;
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

            Kirigami.Separator {
                LayoutMirroring.enabled: false

                anchors {
                    fill: parent
                    topMargin: segmentedSeparator.shouldUseSegmentedStyle ? Kirigami.Units.largeSpacing : 0
                    bottomMargin: segmentedSeparator.shouldUseSegmentedStyle ? Kirigami.Units.largeSpacing : 0
                }

                Behavior on anchors.topMargin {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on anchors.bottomMargin {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Header
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
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
