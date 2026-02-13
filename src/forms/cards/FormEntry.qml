/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
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

    implicitWidth: Math.max(mainLayout.implicitWidth + impl.padding * 2, Math.min(contentItemWrapper.implicitWidth, Platform.Units.gridUnit * 20 + impl.padding * 2))
    implicitHeight: impl.implicitHeight

    Layout.fillWidth: true

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    QQC.Label {
        id: label
        anchors {
            top: parent.top
            right: parent.left
            rightMargin: -impl.leftPadding + Platform.Units.largeSpacing
            topMargin: root.contentItem.KirigamiLayouts.FormData.buddyFor.y + root.contentItem.KirigamiLayouts.FormData.buddyFor.height/2 - label.height/2 + contentItemWrapper.y + impl.topPadding
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
    }

    T.ItemDelegate {
        id: impl
        anchors.fill: parent
        implicitWidth: mainLayout.implicitWidth + leftPadding + rightPadding
        implicitHeight: mainLayout.implicitHeight + topPadding + bottomPadding
        padding: Platform.Units.largeSpacing

        leftPadding: impl.formLayout.__collapsed ? padding : root.parent?.__assignedWidthForLabels + Platform.Units.largeSpacing * 2

        readonly property bool nextIsFormEntry: root.parent?.visibleChildren[root.parent.visibleChildren.indexOf(root) + 1] instanceof FormEntry ?? false
        readonly property bool prevIsFormEntry: root.parent?.visibleChildren[root.parent.visibleChildren.indexOf(root) - 1] instanceof FormEntry ?? false

        topPadding: prevIsFormEntry ? Platform.Units.smallSpacing : Platform.Units.largeSpacing + Platform.Units.smallSpacing
        bottomPadding: nextIsFormEntry ? Platform.Units.smallSpacing : Platform.Units.largeSpacing + Platform.Units.smallSpacing

        readonly property Item formLayout: {
            let candidate = root.parent
            while (candidate) {
                if (candidate instanceof Form) {
                    return candidate;
                }
                candidate = candidate.parent
            }
            return null
        }

        hoverEnabled: clickEnabled && !Platform.Settings.hasTransientTouchInput

        onClicked: {
            if (!clickEnabled) {
                return;
            }
            const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
            buddy.forceActiveFocus(Qt.ShortcutFocusReason);
            if (buddy instanceof T.AbstractButton) {
                buddy.animateClick();
            } else if (buddy instanceof T.ComboBox) {
                buddy.popup.open();
            }

            root.clicked()
        }

        contentItem: GridLayout {
            id: mainLayout
            columnSpacing: Platform.Units.largeSpacing
            rowSpacing: Platform.Units.smallSpacing
            columns: 1 + leadingItems.visible + trailingItems.visible
            QQC.Label {
                Layout.columnSpan: mainLayout.columns
                visible: text.length > 0 && impl.formLayout.__collapsed
                text: label.Primitives.MnemonicData.richTextLabel
                Accessible.name: label.Primitives.MnemonicData.plainTextLabel
            }
            RowLayout {
                id: leadingItems
                Layout.rowSpan: subtitleLabel.visible ? 2 : 1
                visible: children.length > 0
                spacing: Platform.Units.smallSpacing
                children: root.leadingItems
            }
            QQC.Control {
                id: contentItemWrapper
                padding: 0
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                contentItem: root.contentItem
            }

            RowLayout {
                id: trailingItems
                Layout.rowSpan: subtitleLabel.visible ? 2 : 1
                Layout.minimumWidth: implicitWidth
                visible: children.length > 0
                spacing: Platform.Units.smallSpacing
                children: root.trailingItems
            }

            QQC.Label {
                id: subtitleLabel
                Layout.fillWidth: true
                visible: text.length > 0
                color: Platform.Theme.disabledTextColor
                text: root.subtitle
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        background: Rectangle {
            color: Platform.Theme.textColor
            opacity: impl.hovered || impl.down ? (impl.down || root.contentItem?.KirigamiLayouts.FormData.buddyFor?.down ? 0.1 : 0.05) : 0
            readonly property bool first: root.parent.children[0] === root
            readonly property bool last: root.parent.children[root.parent.children.length - 1] === root
            topLeftRadius: first ? Platform.Units.cornerRadius : 0
            topRightRadius: topLeftRadius
            bottomLeftRadius: last ? Platform.Units.cornerRadius : 0
            bottomRightRadius: bottomLeftRadius
            Behavior on opacity {
                OpacityAnimator {
                    duration: Platform.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
