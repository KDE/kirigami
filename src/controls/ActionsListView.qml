/*
    SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT

KT.ActionsListView {
    id: root

    itemDelegate: QQC2.ItemDelegate {
        id: itemDelegate
        property Item delegate
        property T.Action modelData

        action: modelData
        visible: (modelData as Kirigami.Action)?.visible ?? true

        contentItem: RowLayout {
            LayoutMirroring.enabled: itemDelegate.mirrored

            Kirigami.Icon {
                Layout.preferredHeight: itemDelegate.icon.height
                Layout.preferredWidth: itemDelegate.icon.width
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: itemDelegate.icon.name.length > 0 || itemDelegate.icon.source.toString().length > 0
                source: itemDelegate.icon.name.length > 0 ? itemDelegate.icon.name : itemDelegate.icon.source
                selected: itemDelegate.highlighted || itemDelegate.down
            }
            QQC2.Label {
                id: textLabel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Accessible.ignored: true
                text: itemDelegate.text
                font: itemDelegate.font
                color: itemDelegate.highlighted || itemDelegate.down
                ? Kirigami.Theme.highlightedTextColor
                : (itemDelegate.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor)

                elide: Text.ElideRight
                visible: itemDelegate.text
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            Kirigami.Icon {
                visible: (itemDelegate.modelData as Kirigami.Action).children.length > 0
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: Kirigami.Units.iconSizes.small
                source: itemDelegate.delegate.expanded ? "go-up" : "go-down"
            }
        }

        onClicked: {
            if ((modelData as Kirigami.Action)?.children.length > 0) {
                item.delegate.expanded = !item.delegate.expanded
            }
            root.clicked(modelData)
        }
    }

    checkDelegate: QQC2.CheckDelegate {
        id: check
        property Item delegate
        property T.Action modelData

        action: modelData
        visible: (modelData as Kirigami.Action)?.visible ?? true

        onClicked: root.clicked(modelData)
    }

    radioDelegate: QQC2.RadioDelegate {
        property Item delegate
        property T.Action modelData

        QQC2.ButtonGroup.group: modelData.QQC2.ButtonGroup.group

        action: modelData
        visible: (modelData as Kirigami.Action)?.visible ?? true

        onClicked: root.clicked(modelData)
    }

    separatorDelegate: QQC2.Control {
        id: separatorControl
        property Item delegate
        property T.Action modelData
        padding: Kirigami.Units.largeSpacing
        contentItem: Kirigami.Separator {
            visible: (separatorControl.modelData as Kirigami.Action)?.visible ?? true
        }
    }

    delegate: ColumnLayout {
        id: delegateColumn
        required property T.Action modelData

        property bool expanded: false

        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        Loader {
            Layout.fillWidth: true

            sourceComponent: _private.delegateForAction(delegateColumn.modelData)
            onItemChanged: if (item) {
                item.delegate = delegateColumn;
                item.modelData = delegateColumn.modelData;
            }
        }
        Repeater {
            model: {
                if (!delegateColumn.expanded) {
                    return [];
                }
                return (delegateColumn.modelData as Kirigami.Action)?.children ?? [];
            }
            delegate: Loader {
                id: childLoader
                required property T.Action modelData
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.preferredHeight: active ? (item as Item).implicitHeight : 0

                sourceComponent: _private.delegateForAction(childLoader.modelData)
                onItemChanged: if (item) {
                    item.delegate = delegateColumn;
                    item.modelData = childLoader.modelData;
                }
            }
        }
    }

    QtObject {
        id: _private

        function delegateForAction(action: T.Action) : Component {
            const kirigamiAction = action as Kirigami.Action;
            if (kirigamiAction && kirigamiAction.separator) {
                return root.separatorDelegate;
            } else if (kirigamiAction && kirigamiAction.displayComponent) {
                return kirigamiAction.displayComponent;
            } else if (action.checkable) {
                return kirigamiAction && kirigamiAction.autoExclusive ? root.radioDelegate : root.checkDelegate;
            }
            return root.itemDelegate
        }
    }
}
