import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string title: contentItem?.Kirigami.FormData.label
    property string subtitle
    property alias contentItem: layout.contentItem
    property alias leadingItems: leadingItems.children
    property alias trailingItems: trailingItems.children
    //property alias background: impl.background

    signal clicked

    implicitWidth: Math.max(mainLayout.implicitWidth + impl.padding * 2, Math.min(layout.implicitWidth, Kirigami.Units.gridUnit * 20 + impl.padding * 2))
    implicitHeight: impl.implicitHeight

    Layout.fillWidth: true

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    QQC.Label {
        id: label
        anchors {
            top: parent.top
            right: parent.left
            rightMargin: -impl.leftPadding + Kirigami.Units.largeSpacing
            topMargin: root.contentItem.Kirigami.FormData.buddyFor.y + root.contentItem.Kirigami.FormData.buddyFor.height/2 - label.height/2 + layout.y + impl.topPadding
        }
        visible: text.length > 0 && !impl.formLayout.__collapsed
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

    T.ItemDelegate {
        id: impl
        anchors.fill: parent
        implicitWidth: mainLayout.implicitWidth + leftPadding + rightPadding
        implicitHeight: mainLayout.implicitHeight + topPadding + bottomPadding
        padding: Kirigami.Units.largeSpacing// + Kirigami.Units.smallSpacing

        leftPadding: impl.formLayout.__collapsed ? padding : root.parent?.__assignedWidthForLabels + Kirigami.Units.largeSpacing * 2

        readonly property bool nextIsFormEntry: root.parent.visibleChildren[root.parent.visibleChildren.indexOf(root) + 1] instanceof FormEntry
        readonly property bool prevIsFormEntry: root.parent.visibleChildren[root.parent.visibleChildren.indexOf(root) - 1] instanceof FormEntry

        topPadding: prevIsFormEntry ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
        bottomPadding: nextIsFormEntry ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

        readonly property Item formLayout: {
            let candidate = root.parent
            while (candidate) {
                if (candidate instanceof FormLayout2) {
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
            } else {
                root.clicked();
            }
        }

        contentItem: GridLayout {
            id: mainLayout
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            columns: 1 + leadingItems.visible + trailingItems.visible
            QQC.Label {
                Layout.columnSpan: mainLayout.columns
                visible: text.length > 0 && impl.formLayout.__collapsed
                text: label.Kirigami.MnemonicData.richTextLabel
                Accessible.name: label.Kirigami.MnemonicData.plainTextLabel
            }
            RowLayout {
                id: leadingItems
                Layout.rowSpan: subtitleLabel.visible ? 2 : 1
                visible: children.length > 0
                spacing: Kirigami.Units.smallSpacing
            }
            Kirigami.Padding {
                id: layout
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
