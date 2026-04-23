/*
 *  SPDX-FileCopyrightText: 2016-2023 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigami.controls as KirigamiControls
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

/*!
  \qmltype Overlay
  \inqmlmodule org.kde.kirigami

  \brief An overlay sheet that covers the current Page content.

  OverlaySheet is used for auxiliary display of narrow, read-only, scrollable
  content. For more details, see
  https://develop.kde.org/hig/displaying_content/#page-vs-dialog-vs-overlaysheet.

  Can be dismissed with a touch swipe when scrolled to the top or bottom.

  \note OverlaySheet needs a single child item defined. Do not override its
  \c contentItem.

  Example usage:
  \qml
  Kirigami.OverlaySheet {
     ColumnLayout { ... }
  }
  Kirigami.OverlaySheet {
     ListView { ... }
  }
  \endqml
 */
T.Popup {
    id: root

    Kirigami.OverlayZStacking.layer: Kirigami.OverlayZStacking.FullScreen
    z: Kirigami.OverlayZStacking.z

    Platform.Theme.colorSet: Platform.Theme.View
    Platform.Theme.inherit: false

//BEGIN Own Properties

    /*!
      \brief A title to be displayed in the header of this Sheet.

      default: empty string, and no header text will be displayed
     */
    property string title

    /*!
      \brief This property sets the visibility of the close button in the top-right corner.

      default: Only shown in desktop mode
     */
    property bool showCloseButton: !Platform.Settings.isMobile

    /*!
      \brief This property holds an optional item which will be used as the
      sheet's header, and will always be displayed.

      default: \c null
     */
    property Item header: KirigamiControls.Heading {
        level: 2
        text: root.title
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        // use tooltip for long text that is elided
        T.ToolTip.visible: truncated && titleHoverHandler.hovered
        T.ToolTip.text: root.title
        HoverHandler {
            id: titleHoverHandler
        }
    }

    /*!
      \brief An optional item which will be used as the sheet's footer, and
      always kept on screen.

      default: \c null
     */
    property Item footer

    default property alias flickableContentData: scrollView.contentData
//END Own Properties

//BEGIN Reimplemented Properties
    QQC2.Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.3)

        // the opacity of the item is changed internally by QQuickPopup on open/close
        Behavior on opacity {
            OpacityAnimator {
                duration: Platform.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    modal: true
    dim: true

    leftInset: -1
    rightInset: -1
    topInset: -1
    bottomInset: -1

    closePolicy: T.Popup.CloseOnEscape
    x: parent ? Math.round(parent.width / 2 - width / 2) : 0
    y: {
        if (!parent) {
            return 0;
        }
        const visualParentAdjust = sheetHandler.visualParent?.y ?? 0;
        const wantedPosition = parent.height / 2 - implicitHeight / 2;
        return Math.round(Math.max(visualParentAdjust, wantedPosition, Platform.Units.gridUnit * 3));
    }

    width: root.parent ? Math.min(root.parent.width, implicitWidth) : implicitWidth
    implicitWidth: {
        let width = parent?.width ?? 0;
        if (!scrollView.itemForSizeHints) {
            return width;
        } else if (scrollView.itemForSizeHints.Layout.preferredWidth > 0) {
            return Math.min(width, scrollView.itemForSizeHints.Layout.preferredWidth);
        } else if (scrollView.itemForSizeHints.implicitWidth > 0) {
            return Math.min(width, scrollView.itemForSizeHints.implicitWidth);
        } else {
            return width;
        }
    }
    implicitHeight: {
        let h = parent?.height ?? 0;
        if (!scrollView.itemForSizeHints) {
            return h - y;
        } else if (scrollView.itemForSizeHints.Layout.preferredHeight > 0) {
            h = scrollView.itemForSizeHints.Layout.preferredHeight;
        } else if (scrollView.itemForSizeHints.implicitHeight > 0) {
            h = scrollView.itemForSizeHints.implicitHeight + Platform.Units.largeSpacing * 2;
        } else if ((scrollView.itemForSizeHints as Flickable)?.contentHeight > 0) {
            h = (scrollView.itemForSizeHints as Flickable).contentHeight + Platform.Units.largeSpacing * 2;
        } else {
            h = scrollView.itemForSizeHints.height;
        }
        h += headerItem.implicitHeight + footerParent.implicitHeight + topPadding + bottomPadding;
        return parent ? Math.min(h, parent.height - y) : h
    }
//END Reimplemented Properties

//BEGIN Signal handlers
    onVisibleChanged: {
        const flickable = scrollView.contentItem as Flickable;
        flickable.contentY = flickable.originY - flickable.topMargin;
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (!root.parent && typeof applicationWindow !== "undefined") {
                root.parent = applicationWindow().overlay
            }
        });
    }

    Connections {
        target: root.parent
        function onVisibleChanged() {
            if (!root.parent.visible) {
                root.close();
            }
        }
    }
//END Signal handlers

//BEGIN UI
    contentItem: MouseArea {
        implicitWidth: mainLayout.implicitWidth
        implicitHeight: mainLayout.implicitHeight
        Platform.Theme.colorSet: root.Platform.Theme.colorSet
        Platform.Theme.inherit: false

        property real scenePressY
        property real lastY
        property bool dragStarted
        drag.filterChildren: true
        DragHandler {
            id: mouseDragBlocker
            target: null
            dragThreshold: 0
            acceptedDevices: PointerDevice.Mouse
            onActiveChanged: {
                if (active) {
                    parent.dragStarted = false;
                }
            }
        }

        onPressed: mouse => {
            scenePressY = mapToItem(null, mouse.x, mouse.y).y;
            lastY = scenePressY;
            dragStarted = false;
        }
        onPositionChanged: mouse => {
            if (mouseDragBlocker.active) {
                return;
            }
            const currentY = mapToItem(null, mouse.x, mouse.y).y;

            if (dragStarted && currentY !== lastY) {
                translation.y += currentY - lastY;
            }
            if (Math.abs(currentY - scenePressY) > Application.styleHints.startDragDistance) {
                dragStarted = true;
            }
            lastY = currentY;
        }
        onCanceled: restoreAnim.restart();
        onReleased: mouse => {
            if (mouseDragBlocker.active) {
                return;
            }
            if (Math.abs(mapToItem(null, mouse.x, mouse.y).y - scenePressY) > Platform.Units.gridUnit * 5) {
                root.close();
            } else {
                restoreAnim.restart();
            }
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 0

            Item {
                id: headerItem
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                //Layout.margins: 1
                visible: root.header || root.showCloseButton
                implicitHeight: Math.max(headerParent.implicitHeight, closeIcon.height)// + Platform.Units.smallSpacing * 2
                z: 2

                Rectangle {
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: Platform.Units.smallSpacing
                    }
                    width: Math.round(Platform.Units.gridUnit * 3)
                    height: Math.round(Platform.Units.gridUnit / 4)
                    radius: height
                    color: Platform.Theme.textColor
                    opacity: 0.4
                    visible: Platform.Settings.hasTransientTouchInput
                }
                KirigamiLayouts.Padding {
                    id: headerParent

                    readonly property real leadingPadding: Platform.Units.largeSpacing
                    readonly property real trailingPadding: (root.showCloseButton ? closeIcon.width + closeIcon.anchors.rightMargin : 0) + Platform.Units.smallSpacing

                    anchors.fill: parent
                    verticalPadding: Platform.Units.largeSpacing
                    leftPadding: root.mirrored ? trailingPadding : leadingPadding
                    rightPadding: root.mirrored ? leadingPadding : trailingPadding

                    contentItem: root.header
                }
                QQC2.ToolButton {
                    id: closeIcon

                    // We want to position the close button in the top-right
                    // corner if the header is very tall, but we want to
                    // vertically center it in a short header
                    readonly property bool tallHeader: parent.height > (Platform.Units.iconSizes.smallMedium + Platform.Units.largeSpacing * 2)
                    readonly property real tallHeaderMargins: Platform.Units.largeSpacing
                    readonly property real shortHeaderMargins: Math.round((headerItem.implicitHeight - implicitHeight) / 2)

                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: tallHeader ? tallHeaderMargins : shortHeaderMargins
                    }
                    z: 3

                    visible: root.showCloseButton
                    icon.name: closeIcon.hovered ? "window-close" : "window-close-symbolic"
                    text: qsTr("Close", "@action:button close dialog")
                    onClicked: root.close()
                    display: QQC2.AbstractButton.IconOnly
                }
                Primitives.Separator {
                    anchors {
                        right: parent.right
                        left: parent.left
                        top: parent.bottom
                    }
                    visible: scrollView.T.ScrollBar.vertical.visible
                }
            }

            // Here goes the main Sheet content
            QQC2.ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                T.ScrollBar.horizontal.policy: T.ScrollBar.AlwaysOff

                property bool initialized: false
                property Item itemForSizeHints

                // Important to not even access contentItem before it has been spontaneously created
                contentWidth: initialized ? contentItem.width : width
                contentHeight: itemForSizeHints?.implicitHeight ?? 0

                onContentItemChanged: {
                    initialized = true;
                    const flickable = contentItem as Flickable;
                    flickable.boundsBehavior = Flickable.StopAtBounds;
                    if ((flickable instanceof ListView) || (flickable instanceof GridView)) {
                        itemForSizeHints = flickable;
                        return;
                    }
                    const content = flickable.contentItem;
                    content.childrenChanged.connect(() => {
                        for (const item of content.children) {
                            item.anchors.margins = Platform.Units.largeSpacing;
                            item.anchors.top = content.top;
                            item.anchors.left = content.left;
                            item.anchors.right = content.right;
                        }
                        itemForSizeHints = content.children?.[0] ?? null;
                    });
                }
            }

            // Optional footer
            Primitives.Separator {
                Layout.fillWidth: true
                visible: footerParent.visible
            }
            KirigamiLayouts.Padding {
                id: footerParent
                Layout.fillWidth: true
                padding: Platform.Units.smallSpacing
                contentItem: root.footer
                visible: contentItem !== null
            }
        }
        Translate {
            id: translation
        }
        MouseArea {
            id: sheetHandler
            readonly property Item visualParent: root.parent?.contentItem ?? root.parent
            x: -root.x
            y: -root.y
            z: -1
            width:  visualParent?.width ?? 0
            height: (visualParent?.height ?? 0) * 2

            property var pressPos
            onPressed: mouse => {
                pressPos = mapToItem(null, mouse.x, mouse.y)
            }
            onReleased: mouse => {
                // onClicked is emitted even if the mouse was dragged a lot, so we have to check the Manhattan length by hand
                // https://en.wikipedia.org/wiki/Taxicab_geometry
                let pos = mapToItem(null, mouse.x, mouse.y)
                if (Math.abs(pos.x - pressPos.x) + Math.abs(pos.y - pressPos.y) < Application.styleHints.startDragDistance) {
                    root.close();
                }
            }

            NumberAnimation {
                id: restoreAnim
                target: translation
                property: "y"
                from: translation.y
                to: 0
                easing.type: Easing.InOutQuad
                duration: Platform.Units.longDuration
            }
            Component.onCompleted: {
                root.contentItem.parent.transform = translation
                root.contentItem.parent.clip = false
            }
        }
    }
//END UI

//BEGIN Transitions
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                easing.type: Easing.InOutQuad
                duration: Platform.Units.longDuration
            }
            NumberAnimation {
                target: translation
                property: "y"
                from: Platform.Units.gridUnit * 5
                to: 0
                easing.type: Easing.InOutQuad
                duration: Platform.Units.longDuration
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                easing.type: Easing.InOutQuad
                duration: Platform.Units.longDuration
            }
            NumberAnimation {
                target: translation
                property: "y"
                from: translation.y
                to: translation.y >= 0 ? translation.y + Platform.Units.gridUnit * 5 : translation.y - Platform.Units.gridUnit * 5
                easing.type: Easing.InOutQuad
                duration: Platform.Units.longDuration
            }
        }
    }
//END Transitions
}

