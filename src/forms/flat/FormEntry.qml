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

    implicitWidth: Math.max(contentItem.implicitWidth + impl.leftPadding * 2, Math.min(impl.implicitWidth, Kirigami.Units.gridUnit * 20 + impl.leftPadding * 2))
    implicitHeight: impl.implicitHeight

    Layout.fillWidth: true

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    QQC.Label {
        id: label
        anchors {
            top: parent.top
            right: parent.left
            topMargin: root.contentItem.Kirigami.FormData.buddyFor.y + root.contentItem.Kirigami.FormData.buddyFor.height/2 - label.height/2 + impl.topPadding
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
        TapHandler {
            onTapped: {
                const buddy = root.contentItem?.Kirigami.FormData.buddyFor;
                buddy.forceActiveFocus(Qt.ShortcutFocusReason);
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
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: leftPadding
        topPadding: 0
        bottomPadding: 0
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

        contentItem: RowLayout {
            id: mainLayout
            spacing: Kirigami.Units.smallSpacing
            RowLayout {
                id: leadingItems
                visible: children.length > 0
                spacing: Kirigami.Units.smallSpacing
            }
            Kirigami.HeaderFooterLayout {
                id: layout
                Layout.fillWidth: true
                //Layout.fillWidth: contentItem?.Layout.fillWidth

                header: QQC.Label {
                    topPadding: root.y > 0 ? Kirigami.Units.largeSpacing : 0
                    visible: impl.formLayout.__collapsed && text.length > 0
                    text: label.Kirigami.MnemonicData.richTextLabel
                }

                footer: QQC.Label {
                    font: Kirigami.Theme.smallFont
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    visible: text.length > 0
                    text: root.subtitle
                    leftPadding: Application.layoutDirection === Qt.LeftToRight
                        ? root.contentItem.Kirigami.FormData.buddyFor?.indicator?.width + root.contentItem.Kirigami.FormData.buddyFor?.spacing
                        : padding
                    rightPadding: Application.layoutDirection === Qt.RightToLeft
                        ? root.contentItem.Kirigami.FormData.buddyFor?.indicator?.width + root.contentItem.Kirigami.FormData.buddyFor?.spacing
                        : padding

                }
            }
            RowLayout {
                id: trailingItems
                visible: children.length > 0
                spacing: Kirigami.Units.smallSpacing
            }
        }
    }
}
