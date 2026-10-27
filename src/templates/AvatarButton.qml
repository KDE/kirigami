// SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl\carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

/*!
   \qmltype AvatarButton
   \inqmlmodule org.kde.kirigamiaddons.components
   \brief An button that represents a user, either with initials, an icon, or a profile image.
 */
QQC2.AbstractButton {
    id: root

    /*!
       \qmlproperty string name
       \brief This property holds the given name of a user.
       \sa {Avatar::name} {Avatar.name}
     */
    property string name

    /*!
       \qmlproperty url source
       \brief This property holds avatar's icon source.
       \sa {Avatar::source} {Avatar.source}
     */
    property string source

    icon.name: "user"

    /*!
       \qmlproperty bool cache
       \brief This property sets whether the provided image should be cached.
       \sa {Image::cache} {Image.cache}
     */
    property bool cache: true

    /*!
       \qmlproperty bool asynchronous
       \brief Load the image asynchronously.
       \sa {Image::asynchronous} {Image.asynchronous}
     */
    property bool asynchronous: true

    /*!
       \qmlproperty int sourceSize
       \brief This property holds the source size of the user's profile picture.
     */
    property size sourceSize: Qt.binding(() => {Qt.size(width, height)})

    /*!
       \qmlproperty color color
       \brief This property holds the color to use for this avatar.
     */
    property color color: Primitives.NameUtils.colorsFromString(name)

    Platform.Theme.colorSet: Platform.Theme.Button
    Platform.Theme.inherit: false

    text: name

    padding: 1

    hoverEnabled: true // so the tooltip works

    QQC2.ToolTip.visible: text.length > 0 && (hovered || activeFocus)
    QQC2.ToolTip.text: text
    QQC2.ToolTip.delay: Platform.Units.toolTipDelay
}
