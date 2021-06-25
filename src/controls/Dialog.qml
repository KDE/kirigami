/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.12 as Kirigami

QtObject {
    id: root
    
    /**
     * contentItem: Item
     * The contents of the dialog.
     */
    default property Item contentItem
    
    property Item parent
    
    property real maximumHeight: dialog.parent.height - Kirigami.Units.largeSpacing * 2
    property real maximumWidth: dialog.parent.width - Kirigami.Units.largeSpacing * 2
    
    property alias height: dialog.height
    property alias width: dialog.width
    
    // this only takes effect on the content
    property real preferredHeight: -1
    property real preferredWidth: -1
    
    readonly property alias implicitWidth: column.implicitWidth
    readonly property alias implicitHeight: column.implicitHeight
    
    /**
     * title: string
     * The text to show in the dialog header.
     * 
     * The text is a single line, if it goes beyond the width of the 
     * 
     * Note: This is ignored if a custom header is set.
     */
    property string title: ""
    
    enum Actions {
        None = 0,
        Ok = 1,
        Cancel = 2,
        Close = 4,
        Done = 8,
        Save = 16,
        Apply = 32,
        Yes = 64,
        No = 128
    }
    
    /**
     * footerActions: 
     * 
     * Suggested pairings:
     */
    property int footerActions: Dialog.Actions.Close
    
    /**
     * customFooterActions: list<Action>
     * Define the list of buttons in the footer.
     * If footerActions is also 
     * 
     * @see Action
     */
    property list<Action> customFooterActions
    
    property alias headerText: heading
    
    /**
     * 
     */
    property Item header: Controls.Control {
        // needs to explicitly be set for each side to work
        topPadding: Kirigami.Units.largeSpacing
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        
        // top header bar (title and close button)
        contentItem: Kirigami.Heading {
            id: heading
            Layout.fillWidth: true
            level: 2
            text: root.title == "" ? " " : root.title // always have text to ensure header height
            elide: Text.ElideRight
            
            // use tooltip for long text that is elided
            Controls.ToolTip.visible: truncated && titleHoverHandler.hovered
            Controls.ToolTip.text: root.title
            HoverHandler { id: titleHoverHandler }
        }
    }
    
    /**
     * 
     */
    property Item footer: Controls.Control {
        // needs to explicitly be set for each side to work
        // don't have height if the footer has no buttons
        topPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        bottomPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        leftPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        rightPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        
        // footer buttons
        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Item { Layout.fillWidth: true }
            Repeater {
                model: {
                    // custom defined actions precede default actions
                    let actions = root.customFooterActions;
                    
                    // order matters here (in the left -> right arrangement of buttons)
                    if ((root.footerActions & Dialog.Actions.Ok) == Dialog.Actions.Ok) actions.push(okAction); 
                    if ((root.footerActions & Dialog.Actions.Cancel) == Dialog.Actions.Cancel) actions.push(cancelAction); 
                    if ((root.footerActions & Dialog.Actions.Close) == Dialog.Actions.Close) actions.push(closeAction);
                    if ((root.footerActions & Dialog.Actions.Done) == Dialog.Actions.Done) actions.push(doneAction);
                    if ((root.footerActions & Dialog.Actions.Save) == Dialog.Actions.Save) actions.push(saveAction);
                    if ((root.footerActions & Dialog.Actions.Apply) == Dialog.Actions.Apply) actions.push(applyAction);
                    if ((root.footerActions & Dialog.Actions.Yes) == Dialog.Actions.Yes) actions.push(yesAction);
                    if ((root.footerActions & Dialog.Actions.No) == Dialog.Actions.No) actions.push(noAction);
                    
                    return actions;
                }
                
                delegate: Controls.Button {
                    action: modelData
                }
            }
        }
    }
    
    /**
     * 
     */
    property alias background: dialog.background
    
    /**
     * 
     */
    property alias leftPadding: contentControl.leftPadding
    
    /**
     * 
     */
    property alias rightPadding: contentControl.rightPadding
    
    /**
     * 
     */
    property alias topPadding: contentControl.topPadding
    
    /**
     * 
     */
    property alias bottomPadding: contentControl.bottomPadding
    
    /**
     * 
     */
    property double padding: Kirigami.Units.smallSpacing
    
    /**
     * 
     */
    property alias popup: dialog
    
    property alias visible: dialog.visible
    
    /**
     * 
     */
    signal opened()
    
    /**
     * 
     */
    signal closed()
    
    /**
     * 
     */
    signal accepted()
    
    /**
     * 
     */
    signal rejected()

    /**
     * 
     */
    function open() {
        dialog.open();
    }
    
    /**
     * 
     */
    function close() {
        dialog.close();
    }
    
    // visible dialog component
    property var rootItem: Controls.Popup {
        id: dialog
        
        onOpened: root.opened();
        onClosed: root.closed();
        
        parent: {
            if (root.parent) {
                return root.parent;
            } else {
                return applicationWindow().overlay;
            }
        }
        
        modal: true
        clip: false
        padding: 0
        
        property int centerY: Math.round((parent.height - implicitHeight) / 2)
        x: Math.round((parent.width - implicitWidth) / 2)
        y: centerY + Kirigami.Units.gridUnit * 2 * (1 - opacity) // move animation
        
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Kirigami.Units.longDuration }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Kirigami.Units.longDuration }
        }
        
        Controls.Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.3 * dialog.opacity)
        }
        
        background: Item {
            RectangularGlow {
                anchors.fill: rect
                anchors.topMargin: 1
                cornerRadius: rect.radius * 2
                glowRadius: 2
                spread: 0.2
                color: Qt.rgba(0, 0, 0, 0.3)
            }
            
            Rectangle {
                id: rect
                anchors.fill: parent
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
            }
        }
        
        // actual dialog contents
        ColumnLayout {
            id: column
            spacing: 0
            
            // ensure rounded content top (if header is not shown)
            Rectangle {
                id: roundedHeaderBuffer
                z: -1 // below content
                visible: !headerControl.show
                Layout.fillWidth: true
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                
                implicitHeight: Kirigami.Units.smallSpacing * 2
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
            }
            
            // header
            Controls.Control {
                id: headerControl
                contentItem: root.header
                
                property bool show: contentItem && contentItem.implicitHeight != 0
                
                Layout.fillWidth: true
                Layout.maximumWidth: root.maximumWidth
                
                // needs to explicitly be set for each side to work
                // we let the contentItem do the padding themselves
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                
                background: Rectangle {
                    visible: headerControl.show
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.smallSpacing
                    
                    // cover bottom rounded corners
                    Rectangle {
                        color: Kirigami.Theme.backgroundColor
                        height: Kirigami.Units.smallSpacing
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }
                }
            }
            
            // header separator
            Kirigami.Separator {
                id: headerSeparator
                Layout.fillWidth: true
                visible: headerControl.show
            }
            
            // dialog content
            Controls.Control {
                id: contentControl
                contentItem: root.contentItem
                
                // ensure view colour scheme
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                
//                 Behavior on implicitHeight {
                    //NumberAnimation { duration: Kirigami.Units.shortDuration }
                //}
                
                // height of everything other than the content
                property real otherHeights: {
                    let h = headerControl.height + footerControl.height + headerSeparator.height + footerSeparator.height;
                    if (roundedHeaderBuffer.visible) h += roundedHeaderBuffer.height;
                    if (roundedFooterBuffer.visible) h += roundedFooterBuffer.height;
                    return h;
                }
                
                Layout.fillWidth: true
                Layout.maximumWidth: root.maximumWidth
                Layout.maximumHeight: root.maximumHeight - otherHeights // we enforce maximum height from the content
                
                // don't enforce preferred width if not set
                Layout.preferredWidth: root.preferredWidth >= 0 ? root.preferredWidth
                                                                : contentItem.implicitWidth + contentControl.leftPadding + contentControl.rightPadding
                // don't enforce preferred height if not set
                Layout.preferredHeight: root.preferredHeight >= 0 ? root.preferredHeight - otherHeights 
                                                                  : contentItem.implicitHeight + contentControl.topPadding + contentControl.bottomPadding
                
                // needs to explicitly be set for each to work, not sure why
                leftPadding: root.padding
                rightPadding: root.padding
                topPadding: root.padding
                bottomPadding: root.padding
                
                // different colour for dialog content background
                background: Rectangle {
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.View
                    color: Kirigami.Theme.backgroundColor
                }
            }

            // footer separator
            Kirigami.Separator {
                id: footerSeparator
                Layout.fillWidth: true
                visible: footerControl.show
            }
            
            // footer
            Controls.Control {
                id: footerControl
                contentItem: root.footer
                
                property bool show: contentItem && contentItem.implicitHeight != 0
                
                Layout.fillWidth: true
                Layout.maximumWidth: root.maximumWidth
                
                // needs to explicitly be set for each side to work
                // we let the contentItem do the padding themselves
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                
                background: Rectangle {
                    visible: footerControl.show
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.smallSpacing
                    
                    // cover top rounded corners
                    Rectangle {
                        color: Kirigami.Theme.backgroundColor
                        height: Kirigami.Units.smallSpacing
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                    }
                }
            }
            
            // ensure rounded content bottom (if footer is not shown)
            Rectangle {
                id: roundedFooterBuffer
                z: -1 // below content
                visible: !footerControl.show
                Layout.fillWidth: true
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                
                implicitHeight: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
            }
        }
        
        // default dialog actions provided
        Kirigami.Action {
            id: okAction
            text: i18n("OK")
            iconName: "dialog-ok"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: cancelAction
            text: i18n("Cancel")
            iconName: "dialog-cancel"
            onTriggered: { root.rejected(); root.close(); }
        }
        Kirigami.Action {
            id: closeAction
            text: i18n("Close")
            iconName: "dialog-close"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: doneAction
            text: i18n("Done")
            iconName: "dialog-ok"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: saveAction
            text: i18n("Save")
            iconName: "dialog-close"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: applyAction
            text: i18n("Apply")
            iconName: "dialog-ok-apply"
            onTriggered: { root.accepted(); root.close() }
        }
        Kirigami.Action {
            id: yesAction
            text: i18n("Yes")
            iconName: "dialog-ok"
            onTriggered: { root.accepted(); root.close() }
        }
        Kirigami.Action {
            id: noAction
            text: i18n("No")
            iconName: "dialog-cancel"
            onTriggered: { root.rejected(); root.close(); }
        }
    }
}

