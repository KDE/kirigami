/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.forms.private.templates as FT

FT.FormEntry {
    id: root

    implicitWidth: Math.max(contentItem.implicitWidth + impl.leftPadding * 2, Math.min(impl.implicitWidth, Platform.Units.gridUnit * 20 + impl.leftPadding * 2))
    implicitHeight: impl.implicitHeight

    Layout.fillWidth: true

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    QQC.Label {
        id: label
        anchors {
            top: parent.top
            right: parent.left
            topMargin: root.contentItem.KirigamiLayouts.FormData.buddyFor.y + root.contentItem.KirigamiLayouts.FormData.buddyFor.height/2 - label.height/2 + impl.topPadding
        }
        visible: text.length > 0 && !impl.formLayout.__collapsed
        Primitives.MnemonicData.enabled: {
                const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
                if (buddy && buddy.enabled && buddy.visible && buddy.activeFocusOnTab) {
                    // Only set mnemonic if the buddy doesn't already have one.
                    const buddyMnemonic = buddy.Primitives.MnemonicData;
                    return !buddyMnemonic.label || !buddyMnemonic.enabled;
                } else {
                    return false;
                }
            }
        Primitives.MnemonicData.controlType: Primitives.MnemonicData.FormLabel
        Primitives.MnemonicData.label: root.title
        text: Primitives.MnemonicData.richTextLabel
        Accessible.name: Primitives.MnemonicData.plainTextLabel
        Shortcut {
            sequence: label.Primitives.MnemonicData.sequence
            onActivated: {
                const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;

                const buttonBuddy = buddy as T.AbstractButton;
                buttonBuddy.animateClick();
            }
        }
        TapHandler {
            onTapped: {
                if (!root.clickEnabled) {
                    return;
                }
                const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
                buddy.forceActiveFocus(Qt.ShortcutFocusReason);
                root.clicked();
            }
        }
    }

    T.Control {
        id: impl
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: layout.contentItem?.Layout.fillWidth ? parent.width : Math.min(implicitWidth, parent.width)
        implicitWidth: mainLayout.implicitWidth + leftPadding + rightPadding
        implicitHeight: mainLayout.implicitHeight + topPadding + bottomPadding
        leftPadding: Platform.Units.largeSpacing
        rightPadding: leftPadding
        topPadding: 0
        bottomPadding: 0
        readonly property Item formLayout: {
            let candidate = root.parent
            while (candidate) {
                if (candidate instanceof Form) {
                    return candidate;
                }
                candidate = candidate.parent
            }
            console.warn("Warning: FormEntry not inside a Form")
            return null
        }

        contentItem: RowLayout {
            id: mainLayout
            spacing: Platform.Units.smallSpacing
            RowLayout {
                id: leadingItems
                visible: children.length > 0
                spacing: Platform.Units.smallSpacing
                children: root.leadingItems
            }
            KirigamiLayouts.HeaderFooterLayout {
                id: layout
                Layout.fillWidth: true
                //Layout.fillWidth: contentItem?.Layout.fillWidth

                header: QQC.Label {
                    topPadding: root.y > 0 ? Platform.Units.largeSpacing : 0
                    visible: impl.formLayout.__collapsed && text.length > 0
                    text: label.Primitives.MnemonicData.richTextLabel
                }

                footer: QQC.Label {
                    font: Platform.Theme.smallFont
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    visible: text.length > 0
                    text: root.subtitle
                    leftPadding: Application.layoutDirection === Qt.LeftToRight
                        ? root.contentItem.KirigamiLayouts.FormData.buddyFor?.indicator?.width + root.contentItem.KirigamiLayouts.FormData.buddyFor?.spacing
                        : padding
                    rightPadding: Application.layoutDirection === Qt.RightToLeft
                        ? root.contentItem.KirigamiLayouts.FormData.buddyFor?.indicator?.width + root.contentItem.KirigamiLayouts.FormData.buddyFor?.spacing
                        : padding
                }

                contentItem: root.contentItem
            }
            RowLayout {
                id: trailingItems
                Layout.minimumWidth: implicitWidth
                visible: children.length > 0
                spacing: Platform.Units.smallSpacing
                children: root.trailingItems
            }
        }
    }
}
