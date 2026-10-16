/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Window
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KC

/*!
   \qmltype Avatar
   \inqmlmodule org.kde.kirigamiaddons.components
   \brief An element that represents a user, either with initials, an icon, or a profile image.
 */
Item {
    id: root

    enum ImageMode {
        AlwaysShowImage,
        AdaptiveImageOrInitals,
        AlwaysShowInitials
    }

    enum InitialsMode {
        UseInitials,
        UseIcon
    }

//BEGIN properties
    /*!
       \brief This property holds the given name of a user.

       The user's name will be used for generating initials and to provide the
       accessible name for assistive technology.
     */
    property string name

    /*!
       \qmlproperty url source
       \brief This property holds the source of the user's profile picture; an image.
       \sa {Image::source} {Image.source}
     */
    property alias source: avatarImage.source

    /*!
       \qmlproperty var iconSource
       \brief This property holds avatar's icon source.

       This icon  is displayed when using an icon with Avatar.InitialsMode.UseIcon and
       Avatar.ImageNode.AlwaysShowInitials enabled.

       \sa {Icon::source} {Kirigami.Icon.source}
     */
    property alias iconSource: avatarIcon.source

    /*!
       \brief This property holds how the button should represent the user when no user-set image is available.

       Possible values are:
       \value Avatar.InitialsMode.UseInitials
              Show the user's initials.
       \value Avatar.InitialsMode.UseIcon
              Show a generic icon.

       \sa initialsMode
     */
    property int initialsMode: Avatar.InitialsMode.UseInitials

    /*!
       \brief This property holds how the avatar should be shown.

       This property holds whether the button should always show the image; show the image if one is
       available and show initials when it is not; or always show initials.

       Possible values are:
       \value Avatar.ImageMode.AlwaysShowImage
              Always try to show the image even if it hasn't loaded yet or is undefined.
       \value Avatar.ImageMode.AdaptiveImageOrInitals
              Show the image if it is valid or initials if it is not.
       \value Avatar.ImageMode.AlwaysShowInitials
              Always show initials.

       \sa imageMode
     */
    property int imageMode: Avatar.ImageMode.AdaptiveImageOrInitals

    /*!
       \qmlproperty bool cache
       \brief This property sets whether the provided image should be cached.
       \sa {Image::cache} {Image.cache}
     */
    property alias cache: avatarImage.cache

    /*!
       \qmlproperty bool asynchronous
       \brief Load the image asynchronously.
       \sa {Image::asynchronous} {Image.asynchronous}
       \since 1.7.0
     */
    property alias asynchronous: avatarImage.asynchronous

    /*!
       \qmlproperty int sourceSize
       \brief This property holds the source size of the user's profile picture.
       \sa {Image::sourceSize} {Image.sourceSize}
     */
    property alias sourceSize: avatarImage.sourceSize

    /*!
       \brief This property holds the color to use for this avatar.

       If not explicitly set, this defaults to generating a color from the name.
     */
    property color color: KC.NameUtils.colorsFromString(name)

    /*!
       \brief This property holds the color of the avatar's initials.

       If not explicitly set, this defaults to defaultInitialsColor.

       \sa defaultInitialsColor
     */
    property color initialsColor: defaultInitialsColor

    /*!
       \qmlproperty color defaultInitialsColor
       \brief This property holds the default color of the avatar's initials.

       It depends on the avatar's color.
     */
    readonly property alias defaultInitialsColor: root.__textColor

    /*!
       \qmlproperty Item clippedContent
       \brief This item holds the parent item on the clipped circle.

       Implementations may add custom graphics which will be clipped along with
       the rest of the avatar content.
     */
    readonly property alias clippedContent: clippedContent

    implicitWidth: Platform.Units.iconSizes.large
    implicitHeight: Platform.Units.iconSizes.large

    Accessible.role: Accessible.Graphic
    Accessible.name: name

    readonly property real __diameter: Math.min(root.width, root.height)

    readonly property color __textColor: Platform.ColorUtils.brightnessForColor(root.color) === Platform.ColorUtils.Light
                            ? "black"
                            : "white"

    readonly property bool __showImage: {
        switch (root.imageMode) {
        case Avatar.ImageMode.AlwaysShowImage:
            return true;
        case Avatar.ImageMode.AdaptiveImageOrInitals:
            return avatarImage.status === Image.Ready;
        case Avatar.ImageMode.AlwaysShowInitials:
        default:
            return false;
        }
    }

    readonly property bool __unsuitableForInitials: KC.NameUtils.isStringUnsuitableForInitials(root.name)

    Item {
        id: clippedContent

        anchors.centerIn: parent

        width: root.__diameter
        height: root.__diameter

        Rectangle {
            id: circleBorder

            visible: !root.__showImage
            anchors.fill: parent
            radius: root.__diameter

            border.width: 1.25
            border.color: root.color
            color: Platform.ColorUtils.tintWithAlpha(Platform.Theme.backgroundColor, border.color, 0.07)
        }

        Text {
            anchors.fill: parent

            visible: root.initialsMode === Avatar.InitialsMode.UseInitials &&
                    !root.__showImage &&
                    !root.__unsuitableForInitials

            text: KC.NameUtils.initialsFromString(root.name)
            textFormat: Text.PlainText
            color: root.color

            font {
                // this ensures we don't get a both point and pixel size are set warning
                pointSize: -1
                pixelSize: {
                     // Shrink padding as avatar gets tiny to improve readability.
                     const padding = Math.max(0, Math.min(Platform.Units.largeSpacing, root.height - Platform.Units.largeSpacing * 2));
                     return Math.round((root.height - padding) / 2);
                }
            }
            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Primitives.Icon {
            id: avatarIcon

            anchors.fill: parent
            anchors.margins: Platform.Units.largeSpacing

            visible: !root.__showImage
                && (root.initialsMode === Avatar.InitialsMode.UseIcon
                    || root.__unsuitableForInitials)

            color: root.__textColor
            source: "user"
        }

        Image {
            id: avatarImage

            anchors.fill: parent

            visible: root.__showImage

            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            mipmap: true
            sourceSize {
                width: root.__diameter * root.Screen.devicePixelRatio
                height: root.__diameter * root.Screen.devicePixelRatio
            }
            layer {
                enabled: GraphicsInfo.api !== GraphicsInfo.Software
                effect: Primitives.ShadowedTexture {
                    radius: root.__diameter
                }
            }
        }
    }
}
