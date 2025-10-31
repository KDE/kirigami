/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/*!
    \qmltype FormEntry
    \inqmlmodule org.kde.kirigami.forms

    \brief An entry in a FormGroup

    This item represents a single configuration option or a single entry field in a
    form. It tipically contains a single Control (such as a TextField, a CheckBox or
    any other Control that makes sense in the particular context.

    It is to be used exclusively as a child of FormGroup as it represents a single
    semantic entry of a category in a Form.

    \sa FormGroup
  */
Item {
    id: root

    /*!
        \brief An user visible title for this entry.

        If a title is set, will be visualized as an extra description near this entry.
        It's useful as a soft subcategory title, or if the Control needs
        some extra description to be fully clear.
     */
    property string title: contentItem?.Kirigami.FormData.label

    /*!
        \brief An user visible subtitle for this entry.

        If set the subtitle will be displayed under the main Control, with less emphasis,
        such as a smaller font or a toned down color. It can contain a longer text than the title
        and is useful for an extra explanation of the functionality of this form field.
     */
    property string subtitle

    /*!
        \brief The main Control of this entry.

        This item will contain the main functionality of this field.
        It is usually preferred to use a single Control there,
        such as a CheckBox, a TextFileld and so on.
        It is also possible to set a layout of multiple controls as
        contentItem. In this case is recommended to set to it
        the attached property Kirigami.FormLayout.buddyFor, to indicate which
        sub control will be triggered or focused when this entry is activated
        via a click or a shortcut.
     */
    property alias contentItem: contentItemWrapper.contentItem

    /*!
        \brief Extra items that can be put before the main contentItem.

        It's possible to have extra items such as icons at the left of contentItem
        (or on the right on RTL layouts) to have a more decorated entries
     */
    property alias leadingItems: leadingItems.children

    /*!
        \brief Extra items that can be put after the main contentItem.

        It's possible to have extra items such as action buttons at the right of contentItem
        (or on the left on RTL layouts) to have extra triggereable actions
     */
    property alias trailingItems: trailingItems.children

    implicitWidth: Math.max(mainLayout.implicitWidth + impl.padding * 2, Math.min(contentItemWrapper.implicitWidth, Kirigami.Units.gridUnit * 20 + impl.padding * 2))
    implicitHeight: impl.implicitHeight

    Layout.fillWidth: true

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    T.ItemDelegate {
        id: impl
        anchors.fill: parent
        implicitWidth: mainLayout.implicitWidth + leftPadding + rightPadding
        implicitHeight: mainLayout.implicitHeight + topPadding + bottomPadding
        padding: Kirigami.Units.largeSpacing// + Kirigami.Units.smallSpacing

        readonly property bool nextIsFormEntry: root.parent.visibleChildren[root.parent.visibleChildren.indexOf(root) + 1] instanceof FormEntry
        readonly property bool prevIsFormEntry: root.parent.visibleChildren[root.parent.visibleChildren.indexOf(root) - 1] instanceof FormEntry

        topPadding: prevIsFormEntry ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
        bottomPadding: nextIsFormEntry ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

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

        hoverEnabled: root.contentItem?.Kirigami.FormData.buddyFor instanceof T.AbstractButton || root instanceof FormAction

        onClicked: {
            const buddy = root.contentItem?.Kirigami.FormData.buddyFor;
            buddy.forceActiveFocus(Qt.ShortcutFocusReason);
            if (buddy instanceof T.AbstractButton) {
                buddy.animateClick();
            } else if (buddy instanceof T.ComboBox) {
                buddy.popup.open();
            } else if (root instanceof FormAction) {
                root.clicked();
            }
        }

        contentItem: GridLayout {
            id: mainLayout
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            columns: 1 + leadingItems.visible + trailingItems.visible
            QQC.Label {
                id: label
                Layout.columnSpan: mainLayout.columns
                visible: text.length > 0
                Kirigami.MnemonicData.enabled: {
                        const buddy = root.contentItem?.Kirigami.FormData.buddyFor;
                        if (buddy && buddy.enabled && buddy.visible && buddy.activeFocusOnTab) {
                            // Only set mnemonic if the buddy doesn't already have one.
                            const buddyMnemonic = buddy.Kirigami.MnemonicData;
                            return !buddyMnemonic.label || !buddyMnemonic.enabled;
                        } else {
                            return false;
                        }
                    }
                Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.FormLabel
                Kirigami.MnemonicData.label: root.title
                text: Kirigami.MnemonicData.richTextLabel
                Accessible.name: Kirigami.MnemonicData.plainTextLabel
                Shortcut {
                    sequence: label.Kirigami.MnemonicData.sequence
                    onActivated: {
                        const buddy = root.contentItem?.Kirigami.FormData.buddyFor;

                        const buttonBuddy = buddy as T.AbstractButton;
                        // animateClick is only in Qt 6.8,
                        // it also takes into account focus policy.
                        if (buttonBuddy && buttonBuddy.animateClick) {
                            buttonBuddy.animateClick();
                        } else {
                            buddy.forceActiveFocus(Qt.ShortcutFocusReason);
                        }
                    }
                }
            }
            RowLayout {
                id: leadingItems
                Layout.rowSpan: subtitleLabel.visible ? 2 : 1
                visible: children.length > 0
                spacing: Kirigami.Units.smallSpacing
            }
            Kirigami.Padding {
                id: contentItemWrapper
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                id: trailingItems
                Layout.rowSpan: subtitleLabel.visible ? 2 : 1
                visible: children.length > 0
                spacing: Kirigami.Units.smallSpacing
            }

            QQC.Label {
                id: subtitleLabel
                Layout.fillWidth: true
                font: Kirigami.Theme.smallFont
                visible: text.length > 0
                text: root.subtitle
                wrapMode: Text.WordWrap
                elide: Text.ElideRight

                leftPadding: Application.layoutDirection === Qt.LeftToRight
                        ? (root.contentItem.Kirigami.FormData.buddyFor?.indicator?.width ?? 0) + (root.contentItem.Kirigami.FormData.buddyFor?.spacing ?? 0)
                        : padding
                rightPadding: Application.layoutDirection === Qt.RightToLeft
                        ? root.contentItem.Kirigami.FormData.buddyFor?.indicator?.width + root.contentItem.Kirigami.FormData.buddyFor?.spacing
                        : padding
            }
        }

        background: Rectangle {
            color: Kirigami.Theme.textColor
            opacity: impl.hovered ? (impl.down || root.contentItem?.Kirigami.FormData.buddyFor?.down ? 0.1 : 0.05) : 0
            readonly property bool first: root.parent.children[0] === root
            readonly property bool last: root.parent.children[root.parent.children.length - 1] === root
            topLeftRadius: first ? Kirigami.Units.cornerRadius : 0
            topRightRadius: topLeftRadius
            bottomLeftRadius: last ? Kirigami.Units.cornerRadius : 0
            bottomRightRadius: bottomLeftRadius
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
