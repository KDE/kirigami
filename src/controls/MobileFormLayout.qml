/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.kirigami 2.18 as Kirigami

/**
 * This is the base class for Form layouts conforming to the
 * Kirigami Human Interface Guidelines. The layout consists
 * of two columns: the left column contains only right-aligned
 * labels provided by a Kirigami.FormData attached property,
 * the right column contains left-aligned child types.
 *
 * Child types can be sectioned using an QtQuick.Item
 * or Kirigami.Separator with a Kirigami.FormData
 * attached property, see FormLayoutAttached::isSection for details.
 *
 * Example usage:
 * @code
 * import org.kde.kirigami 2.3 as Kirigami
 * Kirigami.FormLayout {
 *    TextField {
 *       Kirigami.FormData.label: "Label:"
 *    }
 *    Kirigami.Separator {
 *        Kirigami.FormData.label: "Section Title"
 *        Kirigami.FormData.isSection: true
 *    }
 *    TextField {
 *       Kirigami.FormData.label: "Label:"
 *    }
 *    TextField {
 *    }
 * }
 * @endcode
 * @see FormLayoutAttached
 * @since 2.3
 * @inherit QtQuick.Item
 */
Item {
    id: root

    /**
     * @brief This property tells whether the form layout is in wide mode.
     *
     * If true, the layout will be optimized for a wide screen, such as
     * a desktop machine (the labels will be on a left column,
     * the fields on a right column beside it), if false (such as on a phone)
     * everything is laid out in a single column.
     *
     * By default this property automatically adjusts the layout
     * if there is enough screen space.
     *
     * Set this to true for a convergent design,
     * set this to false for a mobile-only design.
     */
    property bool wideMode: width >= lay.wideImplicitWidth

    /**
     * If for some implementation reason multiple FormLayouts have to appear
     * on the same page, they can have each other in twinFormLayouts,
     * so they will vertically align with each other perfectly
     *
     * @since 5.53
     */
    property list<Item> twinFormLayouts  // should be list<FormLayout> but we can't have a recursive declaration

    onTwinFormLayoutsChanged: {
        for (let i in twinFormLayouts) {
            if (!(root in twinFormLayouts[i].children[0].reverseTwins)) {
                twinFormLayouts[i].children[0].reverseTwins.push(root)
                Qt.callLater(() => twinFormLayouts[i].children[0].reverseTwinsChanged());
            }
        }
    }

    Component.onCompleted: {
        relayoutTimer.triggered()
    }

    Component.onDestruction: {
        for (let i in twinFormLayouts) {
            const twin = twinFormLayouts[i];
            const child = twin.children[0];
            child.reverseTwins = child.reverseTwins.filter((value, index, arr) => value !== root)
        }
    }

    implicitWidth: lay.wideImplicitWidth
    implicitHeight: lay.implicitHeight
    Layout.preferredHeight: lay.implicitHeight
    Layout.fillWidth: true
    Accessible.role: Accessible.Form

    default property list<Item> __items

    Kirigami.CardsLayout {
        id: lay
        property int wideImplicitWidth
        columns: root.wideMode ? 2 : 1
        rowSpacing: Kirigami.Units.gridUnit
        width: root.wideMode ? undefined : root.width
        anchors {
            horizontalCenter: root.wideMode ? root.horizontalCenter : undefined
            left: root.wideMode ? undefined : root.left
        }

        property var reverseTwins: []
        property var knownItems: []
        property var buddies: []
        property int knownItemsImplicitWidth: {
            let hint = 0;
            for (let i in knownItems) {
                let actualWidth = knownItems[i].implicitWidth
                if (knownItems[i].Layout.preferredWidth > 0) {
                    actualWidth = knownItems[i].Layout.preferredWidth
                }
                actualWidth = Math.min(actualWidth, knownItems[i].Layout.maximumWidth)
                actualWidth = Math.max(actualWidth, knownItems[i].Layout.minimumWidth)

                hint = Math.max(hint, actualWidth);
            }
            return hint;
        }
        property int buddiesImplicitWidth: {
            let hint = 0;

            // HACK: we use var instead of let here, since it seems to trigger a very obscure bug
            // see: https://invent.kde.org/teams/plasma-mobile/issues/-/issues/88
            for (var i in buddies) {
                if (buddies[i].visible && !buddies[i].item.Kirigami.FormData.isSection) {
                    hint = Math.max(hint, buddies[i].implicitWidth);
                }
            }
            return hint;
        }
        readonly property var actualTwinFormLayouts: {
            // We need to copy that array by value
            const list = lay.reverseTwins.slice();
            for (let i in twinFormLayouts) {
                let parentLay = twinFormLayouts[i];
                if (!parentLay || !parentLay.hasOwnProperty("children")) {
                    continue;
                }
                list.push(parentLay);
                for (let j in parentLay.children[0].reverseTwins) {
                    let childLay = parentLay.children[0].reverseTwins[j];
                    if (childLay && !(childLay in list)) {
                        list.push(childLay);
                    }
                }
            }
            return list;
        }

        Timer {
            id: hintCompression
            interval: 0
            onTriggered: {
                if (root.wideMode) {
                    lay.wideImplicitWidth = lay.implicitWidth;
                }
            }
        }
        onImplicitWidthChanged: hintCompression.restart();
        //This invisible row is used to sync alignment between multiple layouts

        Item {
            Layout.preferredWidth: {
                let hint = lay.buddiesImplicitWidth;
                for (let i in lay.actualTwinFormLayouts) {
                    if (lay.actualTwinFormLayouts[i] && lay.actualTwinFormLayouts[i].hasOwnProperty("children")) {
                        hint = Math.max(hint, lay.actualTwinFormLayouts[i].children[0].buddiesImplicitWidth);
                    }
                }
                return hint;
            }
            Layout.preferredHeight:2
        }
        Item {
            Layout.preferredWidth: {
                let hint = Math.min(root.width, lay.knownItemsImplicitWidth);
                for (let i in lay.actualTwinFormLayouts) {
                    if (lay.actualTwinFormLayouts[i] && lay.actualTwinFormLayouts[i].hasOwnProperty("children")) {
                        hint = Math.max(hint, lay.actualTwinFormLayouts[i].children[0].knownItemsImplicitWidth);
                    }
                }
                return hint;
            }
            Layout.preferredHeight:2
        }
    }

    Item {
        id: temp

        /**
         * The following two functions are used in the label buddy items.
         *
         * They're in this mostly unused item to keep them private to the FormLayout
         * without creating another QObject.
         *
         * Normally, such complex things in bindings are kinda bad for performance
         * but this is a fairly static property. If for some reason an application
         * decides to obsessively change its alignment, V8's JIT hotspot optimisations
         * will kick in.
         */

        /**
         * @param {Item} item
         * @returns {Qt::Alignment}
         */
        function effectiveLayout(item) {
            const verticalAlignment =
                item.Kirigami.FormData.labelAlignment !== 0
                ? item.Kirigami.FormData.labelAlignment
                : Qt.AlignTop

            if (item.Kirigami.FormData.isSection) {
                return Qt.AlignHCenter
            }
            if (root.wideMode) {
                return Qt.AlignRight | verticalAlignment
            }
            return Qt.AlignLeft | Qt.AlignBottom
        }

        /**
         * @param {Item} item
         * @returns vertical alignment of the item passed as an argument.
         */
        function effectiveTextLayout(item) {
            if (root.wideMode) {
                return item.Kirigami.FormData.labelAlignment !== 0 ? item.Kirigami.FormData.labelAlignment : Text.AlignVCenter
            }
            return Text.AlignBottom
        }
    }

    Timer {
        id: relayoutTimer
        interval: 0
        onTriggered: {
            //let __items = children;
            // exclude the layout and temp
            let groupParent = null;
            for (let i in root.__items) {
                root.__items[i].parent = temp;
            }
            lay.knownItems = [];
            for (let i = 0; i < lay.children.length; ++i) {
                lay.children[i].destroy();
            }
            for (let i = 0; i < __items.length; ++i) {
                const item = __items[i];

                // skip items that are already there
                if (lay.knownItems.indexOf(item) !== -1 || item instanceof Repeater) {
                    continue;
                }
                lay.knownItems.push(item);


                // if section, label goes after the separator
                if (item.Kirigami.FormData.isSection || groupParent === null) {
                    groupParent = groupComponent.createObject(lay);
                   // itemContainer.parent = groupParent.layout;
                }

                const itemContainer = itemComponent.createObject(groupParent, {item: item})

                let buddy;
                if (item.Kirigami.FormData.checkable) {
                    buddy = checkableBuddyComponent.createObject(groupParent, {item: item})
                } else {
                    buddy = buddyComponent.createObject(groupParent, {item: item, index: i - 2})
                }
                itemContainer.buddy = buddy;

               // itemContainer.parent = groupParent.layout;
               // lay.buddies.push(buddy);
              //  const itemContainer = itemComponent.createObject(groupParent, {item: item})
                itemContainer.parent = groupParent.layout;
            }
            lay.knownItemsChanged();
            lay.buddiesChanged();
            hintCompression.triggered();
        }
    }

    onChildrenChanged: relayoutTimer.restart();

    Component {
        id: groupComponent
        Kirigami.AbstractCard {
            property alias layout: mainLayout
            Layout.fillWidth: true
            Layout.minimumWidth: 300
            Layout.minimumHeight: 100
            leftPadding: 0
            rightPadding: 0

            contentItem: ColumnLayout {
                id: mainLayout
                spacing: 0
            }
        }
    }
    Component {
        id: itemComponent
        Kirigami.AbstractListItem {
            id: container
            property var item
            property var buddy
            visible: item.visible || (item.Kirigami.FormData.label.length > 0 && (item instanceof Kirigami.Separator))

            contentItem: ColumnLayout {
                spacing: 0
                Control {
                    id: buddyParent
                    Layout.fillWidth: true
                    Layout.maximumHeight: contentItem && contentItem.visible ? implicitHeight : 0
                    visible: contentItem
                }
                Control {
                    id: itemParent
                    enabled: container.item.enabled
                    Layout.fillWidth: true
                    visible: container.item && !(container.item instanceof Kirigami.Separator)
                }
            }
            // NOTE: work around a  GridLayout quirk which doesn't lay out items with null size hints causing things to be laid out incorrectly in some cases
           /* implicitWidth: Math.max(item.implicitWidth, 1)
            implicitHeight: Math.max(item.implicitHeight, 1)
            Layout.preferredWidth: Math.max(1, item.Layout.preferredWidth > 0 ? item.Layout.preferredWidth : Math.ceil(item.implicitWidth))
            Layout.preferredHeight: Math.max(1, item.Layout.preferredHeight > 0 ? item.Layout.preferredHeight : Math.ceil(item.implicitHeight))

            Layout.minimumWidth: item.Layout.minimumWidth
            Layout.minimumHeight: item.Layout.minimumHeight

            Layout.maximumWidth: item.Layout.maximumWidth
            Layout.maximumHeight: item.Layout.maximumHeight

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: item instanceof TextInput || item.Layout.fillWidth || item.Kirigami.FormData.isSection
            Layout.columnSpan: item.Kirigami.FormData.isSection ? lay.columns : 1*/
            Layout.fillWidth: true
            onItemChanged: {
                if (item) {
                    itemParent.contentItem = item
                    item.parent = itemParent;
                } else {
                    container.destroy();
                }
            }
            onBuddyChanged: {
                if (buddy) {
                    buddyParent.contentItem = buddy
                    buddy.parent = buddyParent;
                }
            }
            //onXChanged: item.x = x + lay.x;
            //// Assume lay.y is always 0
            //onYChanged: item.y = y + lay.y;
            //onWidthChanged: item.width = width;
            //Component.onCompleted: item.x = x + lay.x;
            //Connections {
                //target: lay
                //function onXChanged() { item.x = x + lay.x }
            //}
        }
    }
    Component {
        id: placeHolderComponent
        Item {
            property var item
            enabled: item.enabled
            visible: item.visible
            width: Kirigami.Units.smallSpacing
            height: Kirigami.Units.smallSpacing
            Layout.topMargin: item.height > 0 ? Kirigami.Units.smallSpacing : 0
            onItemChanged: {
                if (!item) {
                    labelItem.destroy();
                }
            }
        }
    }
    Component {
        id: buddyComponent
        Kirigami.Heading {
            id: labelItem

            property Item item
            property int index
            enabled: item.enabled && item.Kirigami.FormData.enabled
            visible: /*item.visible && */(root.wideMode || text.length > 0)
            Kirigami.MnemonicData.enabled: item.Kirigami.FormData.buddyFor && item.Kirigami.FormData.buddyFor.activeFocusOnTab
            Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.FormLabel
            Kirigami.MnemonicData.label: item.Kirigami.FormData.label
            text: Kirigami.MnemonicData.richTextLabel
            type: item.Kirigami.FormData.isSection ? Kirigami.Heading.Type.Primary : Kirigami.Heading.Type.Normal

            level: item.Kirigami.FormData.isSection ? 3 : 5

           // Layout.columnSpan: item.Kirigami.FormData.isSection ? lay.columns : 1
         /*   Layout.preferredHeight: {
                if (item.Kirigami.FormData.label.length > 0) {
                    if (root.wideMode && !(item.Kirigami.FormData.buddyFor instanceof TextArea)) {
                        return Math.max(implicitHeight, item.Kirigami.FormData.buddyFor.height)
                    }
                    return implicitHeight
                }
                return Kirigami.Units.smallSpacing;
            }*/

           // Layout.alignment: temp.effectiveLayout(item)
           // verticalAlignment: temp.effectiveTextLayout(item)

            Layout.fillWidth: true
            wrapMode: Text.Wrap

         /*   Layout.topMargin: {
                if (root.wideMode && item.Kirigami.FormData.buddyFor.parent !== root) {
                    return item.Kirigami.FormData.buddyFor.y;
                }
                if (root.wideMode && (item.Kirigami.FormData.buddyFor instanceof TextArea)) {
                    return Kirigami.Units.smallSpacing;
                }
                if (index === 0 || root.wideMode) {
                    return 0;
                }
                return Kirigami.Units.largeSpacing * 2;
            }*/
            onItemChanged: {
                if (!item) {
                    labelItem.destroy();
                }
            }
            Shortcut {
                sequence: labelItem.Kirigami.MnemonicData.sequence
                onActivated: item.Kirigami.FormData.buddyFor.forceActiveFocus()
            }
        }
    }
    Component {
        id: checkableBuddyComponent
        CheckBox {
            id: labelItem
            property Item item
            visible: item.visible
            Kirigami.MnemonicData.enabled: item.Kirigami.FormData.buddyFor && item.Kirigami.FormData.buddyFor.activeFocusOnTab
            Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.FormLabel
            Kirigami.MnemonicData.label: item.Kirigami.FormData.label

            Layout.columnSpan: item.Kirigami.FormData.isSection ? lay.columns : 1
          /*  Layout.preferredHeight: {
                if (item.Kirigami.FormData.label.length > 0) {
                    if (root.wideMode && !(item.Kirigami.FormData.buddyFor instanceof TextArea)) {
                        return Math.max(implicitHeight, item.Kirigami.FormData.buddyFor.height)
                    }
                    return implicitHeight
                }
                return Kirigami.Units.smallSpacing;
            }

            Layout.alignment: temp.effectiveLayout(this)
            Layout.topMargin: item.Kirigami.FormData.buddyFor.height > implicitHeight * 2 ? Kirigami.Units.smallSpacing/2 : 0
*/
            activeFocusOnTab: indicator.visible && indicator.enabled
            // HACK: desktop style checkboxes have also the text in the background item
            // text: labelItem.Kirigami.MnemonicData.richTextLabel
            enabled: labelItem.item.Kirigami.FormData.enabled
            checked: labelItem.item.Kirigami.FormData.checked

            onItemChanged: {
                if (!item) {
                    labelItem.destroy();
                }
            }
            Shortcut {
                sequence: labelItem.Kirigami.MnemonicData.sequence
                onActivated: {
                    checked = !checked
                    item.Kirigami.FormData.buddyFor.forceActiveFocus()
                }
            }
            onCheckedChanged: {
                item.Kirigami.FormData.checked = checked
            }
            contentItem: Kirigami.Heading {
                id: labelItemHeading
                level: labelItem.item.Kirigami.FormData.isSection ? 3 : 5
                text: labelItem.Kirigami.MnemonicData.richTextLabel
                type: item.Kirigami.FormData.isSection ? Kirigami.Heading.Type.Primary : Kirigami.Heading.Type.Normal
                verticalAlignment: temp.effectiveTextLayout(labelItem.item)
                enabled: labelItem.item.Kirigami.FormData.enabled
                leftPadding: height  // parent.indicator.width
            }
            Rectangle {
                enabled: labelItem.indicator.enabled
                anchors.left: labelItemHeading.left
                anchors.right: labelItemHeading.right
                anchors.top: labelItemHeading.bottom
                anchors.leftMargin: labelItemHeading.leftPadding
                height: 1
                color: Kirigami.Theme.highlightColor
                visible: labelItem.activeFocus && labelItem.indicator.visible
            }
        }
    }
}
