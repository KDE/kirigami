import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FC

Item {
    id: root

    property string title: contentItem?.Kirigami.FormData.label
    property string subtitle
    property alias separatorVisible: separator.visible

    property alias contentItem: layout.contentItem
    property alias background: impl.background
    property alias footer: layout.footer

    implicitWidth: impl.implicitWidth
    implicitHeight: impl.implicitHeight

    Layout.fillWidth: true
    Layout.maximumWidth: implicitWidth

    signal clicked

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    QQC.Label {
        id: label
        anchors {
            top: parent.top
            right: parent.left
            topMargin: root.contentItem.Kirigami.FormData.buddyFor.height/2 - label.height/2 + impl.topPadding
        }
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
        TapHandler {
            onTapped: {
                const buddy = root.contentItem?.Kirigami.FormData.buddyFor;
                buddy.forceActiveFocus(Qt.ShortcutFocusReason);
            }
        }
    }

    T.Control {
        id: impl
        anchors.fill: parent
        implicitWidth: layout.implicitWidth + leftPadding + rightPadding
        implicitHeight: layout.implicitHeight + topPadding + bottomPadding
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: leftPadding
        topPadding: 0
        bottomPadding: 0

        contentItem: Kirigami.HeaderFooterLayout {
            id: layout
            width: contentItem?.Layout.preferredWidth > 0 ? Math.min(parent.width, contentItem.Layout.preferredWidth) : parent.width

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
    }

    // TODO: this should be a property in the template
    Kirigami.Separator {
        id: separator
        visible: false//root.Kirigami.FormData.isSection
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
        }
    }
}
