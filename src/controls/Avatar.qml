/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.13
import org.kde.kirigami 2.14 as Kirigami
import QtQuick.Controls 2.13 as QQC2
import QtGraphicalEffects 1.0
import org.kde.kirigami.private 2.14

import "templates/private" as P

/**
 * An element that represents a user, either with initials, an icon, or a profile image.
 * @inherit QtQuick.Controls.Control
 */
QQC2.Control {
    id: avatarRoot

    enum ImageMode {
        AlwaysShowImage,
        AdaptiveImageOrInitals,
        AlwaysShowInitials
    }
    enum InitialsMode {
        UseInitials,
        UseIcon
    }

    /**
    * The given name of a user.
    *
    * The user's name will be used for generating initials and to provide the
    * accessible name for assistive technology.
    */
    property string name

    /**
    * The source of the user's profile picture; an image.
    */
    property alias source: avatarImage.source

    /**
    * How the button should represent the user when there is no image available.
    * * `UseInitials` - Use initials when the image is not available
    * * `UseIcon` - Use an icon of a user when the image is not available
    */
    property int initialsMode: Kirigami.Avatar.InitialsMode.UseInitials

    /**
    * Whether the button should always show the image; show the image if one is
    * available and show initials when it is not; or always show initials.
    * * `AlwaysShowImage` - Always show the image; even if is not value
    * * `AdaptiveImageOrInitals` - Show the image if it is valid; or show initials if it is not
    * * `AlwaysShowInitials` - Always show initials
    */
    property int imageMode: Kirigami.Avatar.ImageMode.AdaptiveImageOrInitals

     /**
     * Whether or not the image loaded from the provided source should be cached.
     *
     */
     property alias cache: avatarImage.cache

    /**
    * The source size of the user's profile picture.
    */
    property alias sourceSize: avatarImage.sourceSize

    /**
    * Whether or not the image loaded from the provided source should be smoothed.
    */
    property alias smooth: avatarImage.smooth

    /**
     *
     */

    /**
     * color: color
     *
     * The color to use for this avatar. If not explicitly set, this defaults to generating a colour from the name.
     */
    property var color: Kirigami.NameUtils.colorsFromString(name)
    // We use a var instead of a color here to allow setting the colour
    // as undefined, which will result in a generated colour being used.

    /**
     * actions.main: Kirigami.Action
     * actions.secondary: Kirigami.Action
     *
     * Actions associated with this avatar.
     *
     * Note that the secondary action should only be used for shortcuts of actions
     * elsewhere in your application's UI, and cannot be accessed on mobile platforms.
     */
    property AvatarGroup actions: AvatarGroup {}

    property P.BorderPropertiesGroup border: P.BorderPropertiesGroup {
        width: 0
        color: Qt.rgba(0,0,0,0.2)
    }

    padding: 0
    horizontalPadding: padding
    verticalPadding: padding
    leftPadding: horizontalPadding
    rightPadding: horizontalPadding
    topPadding: verticalPadding
    bottomPadding: verticalPadding

    implicitWidth: Kirigami.Units.iconSizes.large
    implicitHeight: Kirigami.Units.iconSizes.large

    activeFocusOnTab: !!actions.main

    Accessible.role: !!actions.main ? Accessible.Button : Accessible.Graphic
    Accessible.name: !!actions.main ? qsTr("%1 — %2").arg(name).arg(actions.main.text) : name
    Accessible.focusable: !!actions.main
    Accessible.onPressAction: {
        avatarRoot.actions.main.trigger()
    }
    Keys.onEnterPressed: if (!!avatarRoot.actions.main.trigger()) avatarRoot.actions.main.trigger()
    Keys.onSpacePressed: if (!!avatarRoot.actions.main.trigger()) avatarRoot.actions.main.trigger()

    background: Rectangle {
        radius: parent.width / 2

        color: __private.showImage ? Kirigami.Theme.backgroundColor : avatarRoot.color

        Rectangle {
            anchors.fill: parent
            anchors.margins: -border.width

            radius: width / 2

            color: "transparent"
            border.width: Kirigami.Units.smallSpacing
            border.color: Kirigami.Theme.focusColor
            visible: avatarRoot.focus
        }

        MouseArea {
            id: primaryMouse

            anchors.fill: parent
            hoverEnabled: true
            property bool mouseInCircle: {
                let x = avatarRoot.width / 2, y = avatarRoot.height / 2
                let xPrime = mouseX, yPrime = mouseY

                let distance = (x - xPrime) ** 2 + (y - yPrime) ** 2
                let radiusSquared = (Math.min(avatarRoot.width, avatarRoot.height) / 2) ** 2

                return distance < radiusSquared
            }

            onClicked: {
                if (!!avatarRoot.actions.secondary && mouseY > avatarRoot.height - __private.secondaryHeight) {
                    avatarRoot.actions.secondary.trigger()
                    return
                }
                if (!!avatarRoot.actions.main) {
                    avatarRoot.actions.main.trigger()
                }
            }

            enabled: !!avatarRoot.actions.main || !!avatarRoot.actions.secondary
            cursorShape: containsMouse && mouseInCircle && enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            states: [
                State {
                    name: "secondaryRevealed"
                    when: (!Kirigami.Settings.isMobile) && (!!avatarRoot.actions.secondary) && (primaryMouse.containsMouse && primaryMouse.mouseInCircle)
                    PropertyChanges {
                        target: secondaryRect
                        active: true
                    }
                }
            ]
        }
    }

    QtObject {
        id: __private
        property color textColor: Kirigami.ColorUtils.brightnessForColor(avatarRoot.color) == Kirigami.ColorUtils.Light
                                ? "black"
                                : "white"
        property bool shouldShowImage: (avatarRoot.imageMode == Kirigami.Avatar.ImageMode.AlwaysShowImage) || avatarRoot.source != ""
        property bool showImage: {
            return shouldShowImage &&
                   (avatarImage.status == Image.Ready && avatarRoot.imageMode == Kirigami.Avatar.ImageMode.AdaptiveImageOrInitals)
        }
        property int secondaryHeight: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing*2
    }

    contentItem: Item {
        id: contItem

        Component {
            id: avatarText

            Text {
                parent: contItem
                fontSizeMode: Text.Fit

                text: Kirigami.NameUtils.initialsFromString(name)
                color: __private.textColor

                anchors.fill: parent
                font {
                    // this ensures we don't get a both point and pixel size are set warning
                    pointSize: -1
                    pixelSize: (avatarRoot.height - Kirigami.Units.largeSpacing) / 2
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Component {
            id: avatarIcon

            Kirigami.Icon {
                parent: contItem
                source: "user"

                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing

                color: __private.textColor
            }
        }

        Loader {
            sourceComponent: {
                if ((avatarRoot.initialsMode == Kirigami.Avatar.InitialsMode.UseIcon && !__private.showImage) ||
                        (Kirigami.NameUtils.isStringUnsuitableForInitials(avatarRoot.name) && !__private.showImage)) {
                            return avatarIcon
                        }

                if (avatarRoot.initialsMode == Kirigami.Avatar.InitialsMode.UseInitials &&
                        !__private.showImage &&
                        !Kirigami.NameUtils.isStringUnsuitableForInitials(avatarRoot.name) &&
                        avatarRoot.width > Kirigami.Units.gridUnit) {
                            return avatarText
                        }

                return null
            }
        }

        Image {
            id: avatarImage
            visible: __private.showImage

            mipmap: true
            smooth: true
            sourceSize {
                width: avatarRoot.width
                height: avatarRoot.height
            }

            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
        }

        Rectangle {
            color: "transparent"

            radius: width / 2
            anchors.fill: parent

            border {
                width: avatarRoot.border.width
                color: avatarRoot.border.color
            }
        }

        Loader {
            id: secondaryRect
            active: false

            sourceComponent: Rectangle {
                parent: contentItem

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                height: __private.secondaryHeight

                color: Qt.rgba(0, 0, 0, 0.6)

                Kirigami.Icon {
                    Kirigami.Theme.textColor: "white"
                    source: (avatarRoot.actions.secondary || {iconName: ""}).iconName

                    width: Kirigami.Units.iconSizes.small
                    height: Kirigami.Units.iconSizes.small

                    x: Math.round((parent.width/2)-(this.width/2))
                    y: Math.round((parent.height/2)-(this.height/2))
                }
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                height: avatarRoot.height
                width: avatarRoot.width
                radius: height / 2
                color: "black"
                visible: false
            }
        }
    }
}
