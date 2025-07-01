pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KDialogs
import QtQuick.Controls as QQC2

T.Control {
    id: root

    /*!
     *      \qmlproperty Dialog DialogHeader::dialog
     *      This property points to the parent dialog, some of whose properties
     *      need to be available here.
     */
    required property T.Dialog dialog

    /*!
     \ brief This property holds the component* to the left of the footer buttons.
     */
    property Component footerLeadingComponent

    /*!
     \ brief his property holds the component *to the right of the footer buttons.
     */
    property Component footerTrailingComponent

    /*!
     \ brief This property sets whether th*e footer button style should be flat.
     */
    property bool flatFooterButtons: false

    /*!
     \ brief This property holds the custom actions displayed in the footer.      *

     Example usage:
     \code
     import QtQuick
     import org.kde.kirigami as Kirigami

     Kirigami.PromptDialog {
        id: dialog
        title: i18n("Confirm Playback")
        subtitle: i18n("Are you sure you want to play this song? It's really loud!")

        standardButtons: Kirigami.Dialog.Cancel
        customFooterActions: [
            Kirigami.Action {
                text: i18n("Play")
                icon.name: "media-playback-start"
                onTriggered: {
                    //...
                    dialog.close();
                }
            }
        ]
    }
    \endcode

    \sa Action
    */
    property list<T.Action> customFooterActions

    // DialogButtonBox should NOT contain invisible buttons, because in Qt 6
    // ListView preserves space even for invisible items.
    readonly property list<T.Action> __visibleCustomFooterActions: customFooterActions
    .filter(action => !(action instanceof Kirigami.Action) || action?.visible)

    // if there is nothing in the footer, still maintain a height so that we can create a rounded bottom buffer for the dialog
    property bool bufferMode: !root.footerLeadingComponent && !dialogButtonBox.visible
    implicitHeight: bufferMode ? Math.round(Kirigami.Units.smallSpacing / 2) : implicitContentHeight + topPadding + bottomPadding
    implicitWidth: footerLayout.implicitWidth + leftPadding + rightPadding

    padding: !bufferMode ? Kirigami.Units.largeSpacing : 0

    contentItem: RowLayout {
        id: footerLayout
        spacing: root.spacing
        // Don't let user interact with footer during transitions
        enabled: dialog.opened

        Loader {
            id: leadingLoader
            sourceComponent: root.footerLeadingComponent
        }

        // footer buttons
        QQC2.DialogButtonBox {
            // we don't explicitly set padding, to let the style choose the padding
            id: dialogButtonBox
            standardButtons: dialog.standardButtons
            visible: count > 0
            padding: 0

            Layout.fillWidth: true
            Layout.alignment: dialogButtonBox.alignment

            position: QQC2.DialogButtonBox.Footer

            // ensure themes don't add a background, since it can lead to visual inconsistencies
            // with the rest of the dialog
            background: null

            // we need to hook all of the buttonbox events to the dialog events
            onAccepted: dialog.accept()
            onRejected: dialog.reject()
            onApplied: dialog.applied()
            onDiscarded: dialog.discarded()
            onHelpRequested: dialog.helpRequested()
            onReset: dialog.reset()

            // add custom footer buttons
            Repeater {
                id: customFooterButtons
                model: root.__visibleCustomFooterActions
                // we have to use Button instead of ToolButton, because ToolButton has no visual distinction when disabled
                delegate: QQC2.Button {
                    required property T.Action modelData

                    flat: root.flatFooterButtons
                    action: modelData
                }
            }
        }

        Loader {
            id: trailingLoader
            sourceComponent: root.footerTrailingComponent
        }
    }

    background: Item {
        Kirigami.Separator {
            id: footerSeparator
            visible: if (root.dialog.contentItem instanceof T.Pane || root.dialog.contentItem instanceof Flickable) {
                return root.dialog.contentItem.height < root.dialog.contentItem.contentHeight;
            } else {
                return false;
            }
            width: parent.width
            anchors.top: parent.top
        }
    }
}
