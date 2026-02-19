/*
 *  SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami.templates as KT
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

KT.InlineViewHeader {
    id: root

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            Math.ceil(label.implicitWidth)
                            + rowLayout.spacing
                            + Math.ceil(Math.max(buttonsLoader.implicitWidth, buttonsLoader.Layout.minimumWidth))
                            + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topPadding: Platform.Units.smallSpacing + (root.position === T.ToolBar.Footer ? separator.implicitHeight : 0)
    leftPadding: Platform.Units.largeSpacing
    rightPadding: Platform.Units.smallSpacing
    bottomPadding: Platform.Units.smallSpacing + (root.position === T.ToolBar.Header ? separator.implicitHeight : 0)


    background: Rectangle {
        Platform.Theme.colorSet: Platform.Theme.View
        Platform.Theme.inherit: false
        // We want a color that's basically halfway between the view background
        // color and the window background color. But due to the use of color
        // scopes, only one will be available at a time. So to get basically the
        // same thing, we blend the view background color with a smidgen of the
        // text color.
        color: Qt.tint(Platform.Theme.backgroundColor, Qt.alpha(Platform.Theme.textColor, 0.03))

        Primitives.Separator {
            id: separator

            anchors {
                top: root.position === T.ToolBar.Footer ? parent.top : undefined
                left: parent.left
                right: parent.right
                bottom: root.position === T.ToolBar.Header ? parent.bottom : undefined
            }
        }
    }

    contentItem: RowLayout {
        id: rowLayout

        spacing: 0

        KC.Heading {
            id: label

            Layout.fillWidth: !buttonsLoader.active
            Layout.maximumWidth: {
                if (!buttonsLoader.active) {
                    return -1;
                }
                return rowLayout.width
                    - rowLayout.spacing
                    - buttonsLoader.Layout.minimumWidth;
            }
            Layout.alignment: Qt.AlignVCenter
            level: 2
            text: root.text
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }

        Loader {
            id: buttonsLoader

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.minimumWidth: (item as Item)?.Layout.minimumWidth ?? 0
            active: root.actions.length > 0
            sourceComponent: KC.ActionToolBar {
                actions: root.actions
                alignment: Qt.AlignRight
            }
        }
    }
}
