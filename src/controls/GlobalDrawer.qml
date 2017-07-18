/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Templates 2.0 as T2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0

import "private"
import "templates/private"

/**
 * A drawer specialization intended for the global actions of the application
 * valid regardless of the application state (think about the menubar
 * of a desktop application).
 *
 * Example usage:
 * @code
 * import org.kde.kirigami 2.0 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *  [...]
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                iconName: "view-list-icons"
 *                Kirigami.Action {
 *                        text: "action 1"
 *                }
 *                Kirigami.Action {
 *                        text: "action 2"
 *                }
 *                Kirigami.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            Kirigami.Action {
 *                text: "Sync"
 *                iconName: "folder-sync"
 *            }
 *         ]
 *     }
 *  [...]
 * }
 * @endcode
 *
 */
OverlayDrawer {
    id: root
    edge: Qt.LeftEdge

    /**
     * title: string
     * A title to be displayed on top of the drawer
     */
    property alias title: heading.text

    /**
     * icon: var
     * An icon to be displayed alongside the title.
     * It can be a QIcon, a fdo-compatible icon name, or any url understood by Image
     */
    property alias titleIcon: headingIcon.source

    /**
     * bannerImageSource: string
     * An image to be used as background for the title and icon for
     * a decorative purpose.
     * It accepts any url format supported by Image
     */
    property alias bannerImageSource: bannerImage.source

    /**
     * actions: list<Action>
     * The list of actions can be nested having a tree structure.
     * A tree depth bigger than 2 is discouraged.
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.0 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [
     *            Kirigami.Action {
     *                text: "View"
     *                iconName: "view-list-icons"
     *                Kirigami.Action {
     *                        text: "action 1"
     *                }
     *                Kirigami.Action {
     *                        text: "action 2"
     *                }
     *                Kirigami.Action {
     *                        text: "action 3"
     *                }
     *            },
     *            Kirigami.Action {
     *                text: "Sync"
     *                iconName: "folder-sync"
     *            }
     *         ]
     *     }
     *  [...]
     * }
     * @endcode
     */
    property list<QtObject> actions


    /**
     * content: list<Item> default property
     * Any random Item can be instantiated inside the drawer and
     * will be displayed underneath the actions list.
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.0 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }
     *     }
     *  [...]
     * }
     * @endcode
     */
    default property alias content: mainContent.data

    /**
     * topContent: list<Item> default property
     * Items that will be instantiated inside the drawer and
     * will be displayed on top of the actions list.
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.0 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         topContent: [Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }]
     *     }
     *  [...]
     * }
     * @endcode
     */
    property alias topContent: topContent.data

    /**
     * resetMenuOnTriggered: bool
     *
     * On the actions menu, whenever a leaf action is triggered, the menu
     * will reset to its parent.
     */
    property bool resetMenuOnTriggered: true

    /**
     * currentSubMenu: Action
     *
     * Points to the action acting as a submenu
     */
    readonly property Action currentSubMenu: stackView.currentItem ? stackView.currentItem.current: null

    /**
     * Notifies that the banner has been clicked
     */
    signal bannerClicked()

    /**
     * Reverts the menu back to its initial state
     */
    function resetMenu() {
        stackView.pop(stackView.get(0, T2.StackView.DontLoad));
        if (root.modal) {
            root.drawerOpen = false;
        }
    }

    rightPadding: !Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Units.gridUnit : Units.smallSpacing

    contentItem: ScrollView {
        id: scrollView
        anchors.fill: parent
        implicitWidth: Math.min (Units.gridUnit * 20, root.parent.width * 0.8)
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        Flickable {
            id: mainFlickable
            contentWidth: width
            contentHeight: mainColumn.Layout.minimumHeight
            ColumnLayout {
                id: mainColumn
                width: mainFlickable.width
                spacing: 0
                height: Math.max(root.height, Layout.minimumHeight)

                Image {
                    id: bannerImage

                    Layout.fillWidth: true

                    Layout.preferredWidth: title.implicitWidth
                    Layout.preferredHeight: bannerImageSource != "" ? 10 * Units.gridUnit : Layout.minimumHeight
                    Layout.minimumHeight: title.height > 0 ? title.height + Units.smallSpacing * 2 : 0

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.bannerClicked()
                    }

                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }

                    EdgeShadow {
                        edge: Qt.BottomEdge
                        visible: bannerImageSource != ""
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.top
                        }
                    }
                    LinearGradient {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                        visible: bannerImageSource != "" && root.title != ""
                        height: title.height * 1.3
                        start: Qt.point(0, 0)
                        end: Qt.point(0, height)
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(0, 0, 0, 0.8)
                            }
                            GradientStop {
                                position: 1.0
                                color: "transparent"
                            }
                        }
                    }

                    RowLayout {
                        id: title
                        anchors {
                            left: parent.left
                            top: parent.top
                            margins: Units.smallSpacing * 2
                        }
                        Icon {
                            id: headingIcon
                            Layout.minimumWidth: Units.iconSizes.large
                            Layout.minimumHeight: width
                            visible: valid
                            enabled: false
                        }
                        Heading {
                            id: heading
                            Layout.fillWidth: true
                            Layout.rightMargin: heading.height
                            visible: text.length > 0
                            level: 1
                            color: bannerImageSource != "" ? "white" : Theme.textColor
                            elide: Text.ElideRight
                        }
                    }
                }

                ColumnLayout {
                    id: topContent
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: root.leftPadding
                    Layout.rightMargin: root.rightPadding
                    Layout.bottomMargin: Units.smallSpacing
                    Layout.topMargin: root.topPadding
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                    //as items are added only after this column creation
                    Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                    visible: children.length > 0 && childrenRect.height > 0
                }

                T2.StackView {
                    id: stackView
                    Layout.fillWidth: true
                    Layout.minimumHeight: currentItem ? currentItem.implicitHeight : 0
                    Layout.maximumHeight: Layout.minimumHeight
                    initialItem: menuComponent
                    //NOTE: it's important those are NumberAnimation and not XAnimators
                    // as while the animation is running the drawer may close, and
                    //the animator would stop when not drawing see BUG 381576
                    popEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * -stackView.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }

                    popExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * stackView.width; duration: 400; easing.type: Easing.OutCubic }
                    }

                    pushEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }

                    pushExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: 400; easing.type: Easing.OutCubic }
                    }

                    replaceEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }

                    replaceExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: 400; easing.type: Easing.OutCubic }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: root.actions.length>0
                    Layout.minimumHeight: Units.smallSpacing
                }

                ColumnLayout {
                    id: mainContent
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: root.leftPadding
                    Layout.rightMargin: root.rightPadding
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                    //as items are added only after this column creation
                    Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                    visible: children.length > 0
                }
                Item {
                    Layout.minimumWidth: Units.smallSpacing
                    Layout.minimumHeight: root.bottomPadding
                }

                Component {
                    id: menuComponent
                    ColumnLayout {
                        spacing: 0
                        property alias model: actionsRepeater.model
                        property Action current

                        property int level: 0
                        Layout.maximumHeight: Layout.minimumHeight


                        BasicListItem {
                            visible: level > 0
                            supportsMouseEvents: true
                            icon: "go-previous"
                            label: qsTr("Back")
                            separatorVisible: false
                            onClicked: stackView.pop()
                        }

                        Repeater {
                            id: actionsRepeater
                            model: actions
                            delegate: BasicListItem {
                                id: listItem
                                supportsMouseEvents: true
                                checked: modelData.checked
                                icon: modelData.iconName
                                label: modelData.text
                                separatorVisible: false
                                visible: model ? model.visible || model.visible===undefined : modelData.visible
                                enabled: model ? model.enabled : modelData.enabled
                                opacity: enabled ? 1.0 : 0.3
                                Icon {
                                    anchors {
                                        verticalCenter: contentItem.verticalCenter
                                        right: contentItem.right
                                        rightMargin: !Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Units.gridUnit : 0
                                    }
                                    height: Units.iconSizes.smallMedium
                                    selected: listItem.checked || listItem.pressed
                                    width: height
                                    source: "go-next"
                                    visible: modelData.children!==undefined && modelData.children.length > 0
                                }

                                onClicked: {
                                    modelData.trigger();

                                    if (modelData.children!==undefined && modelData.children.length > 0) {
                                        stackView.push(menuComponent, {model: modelData.children, level: level + 1, current: modelData });
                                    } else if (root.resetMenuOnTriggered) {
                                        root.resetMenu();
                                    }
                                    checked = Qt.binding(function() { return modelData.checked });
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

