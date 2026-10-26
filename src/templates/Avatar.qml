/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.platform as Platform

/*!
   \qmltype Avatar
   \inqmlmodule org.kde.kirigami
   \brief An element that represents a user, either with initials, an icon, or a profile image.
 */
T.Control {
    id: root

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
    property string source

    /*!
      \qmlproperty string Page::icon.name
      \qmlproperty string Page::icon.source
      \qmlproperty int Page::icon.width
      \qmlproperty int Page::icon.height
      \qmlproperty color Page::icon.color

      \brief This holds the icon that represents this page.
     */
    property Primitives.IconPropertiesGroup icon: Primitives.IconPropertiesGroup {
        name: "user"
    }

    /*!
       \qmlproperty bool cache
       \brief This property sets whether the provided image should be cached.
       \sa {Image::cache} {Image.cache}
     */
    property bool cache

    /*!
       \qmlproperty bool asynchronous
       \brief Load the image asynchronously.
       \sa {Image::asynchronous} {Image.asynchronous}
       \since 1.7.0
     */
    property bool asynchronous: true

    /*!
       \qmlproperty int sourceSize
       \brief This property holds the source size of the user's profile picture.
       \sa {Image::sourceSize} {Image.sourceSize}
     */
    property size sourceSize: {
        width: width
        height: height
    }

    /*!
       \brief This property holds the color to use for this avatar.

       If not explicitly set, this defaults to generating a color from the name.
     */
    property color color: Primitives.NameUtils.colorsFromString(name)

    implicitWidth: Platform.Units.iconSizes.large
    implicitHeight: Platform.Units.iconSizes.large

    Accessible.role: Accessible.Graphic
    Accessible.name: name
}
