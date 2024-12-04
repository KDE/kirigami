/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *  SPDX-FileCopyrightText: 2022 Carl Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

/*!
  \qmltype ShadowedImage
  \inqmlmodule org.kde.kirigami.primitives

  \brief An image with a shadow.

  This item will render a image, with a shadow below it. The rendering is done
  using distance fields, which provide greatly improved performance. The shadow is
  rendered outside of the item's bounds, so the item's width and height are the
  don't include the shadow.

  Example usage:
  \qml
  import org.kde.kirigami

  ShadowedImage {
      source: 'qrc:/myKoolGearPicture.png'

      radius: 20

      shadow.size: 20
      shadow.xOffset: 5
      shadow.yOffset: 5

      border.width: 2
      border.color: Kirigami.Theme.textColor

      corners.topLeftRadius: 4
      corners.topRightRadius: 5
      corners.bottomLeftRadius: 2
      corners.bottomRightRadius: 10
  }
  \endqml

  \since 5.69
 */
Item {
    id: root

//BEGIN properties
    /*!
      \qmlproperty color ShadowedImage::color
      \brief This property holds the color that will be underneath the image.

      This will be visible if the image has transparancy.

      \sa ShadowedRectangle::radius
     */
    property alias color: shadowRectangle.color

    /*!
      \qmlproperty real ShadowedImage::radius

      \brief This propery holds the corner radius of the image.
      \sa ShadowedRectangle::radius
     */
    property alias radius: shadowRectangle.radius

    /*!
      \qmlproperty real ShadowedImage::shadow.size
      \qmlproperty real ShadowedImage::shadow.xOffset
      \qmlproperty real ShadowedImage::shadow.yOffset
      \qmlproperty real ShadowedImage::shadow.color

      \brief This property holds shadow's properties group.
      \sa ShadowedRectangle::shadow
     */
    property alias shadow: shadowRectangle.shadow

    /*!
      \qmlproperty real ShadowedImage::border.width
      \qmlproperty real ShadowedImage::border.color
      \brief This propery holds the border's properties of the image.
      \sa ShadowedRectangle::border
     */
    property alias border: shadowRectangle.border

    /*!
      \qmlproperty real ShadowedImage::corners.topLeftRadius
      \qmlproperty real ShadowedImage::corners.topRightRadius
      \qmlproperty real ShadowedImage::corners.bottomLeftRadius
      \qmlproperty real ShadowedImage::corners.bottomRightRadius
      \brief This propery holds the corner radius properties of the image.
      \sa ShadowedRectangle::corners
     */
    property alias corners: shadowRectangle.corners

    /*!
      \qmlproperty var ShadowedImage::source
      \brief This propery holds the source of the image.
      \sa Image::source
     */
    property alias source: image.source

    /*!
      \qmlproperty bool asynchronous
      \brief This property sets whether this image should be loaded asynchronously.

      Set this to false if you want the main thread to load the image, which
      blocks it until the image is loaded. Setting this to true loads the
      image in a separate thread which is useful when maintaining a responsive
      user interface is more desirable than having images immediately visible.

      \sa Image::asynchronous
     */
    property alias asynchronous: image.asynchronous

    /*!
      \qmlproperty int fillMode
      \brief This property defines what happens when the source image has a different
      size than the item.
      \sa Image::fillMode
     */
    property alias fillMode: image.fillMode

    /*!
      \qmlproperty bool mipmap
      \brief This property holds whether the image uses mipmap filtering when scaled
      or transformed.
      \sa Image::mipmap
     */
    property alias mipmap: image.mipmap

    /*!
      \brief This property holds the scaled width and height of the full-frame image.
      \sa Image::sourceSize
     */
    property alias sourceSize: image.sourceSize

    /*!
       \brief This property holds the status of image loading.
       \sa Image::status
       \since 6.5
     */
    readonly property alias status: image.status
//END properties

    Image {
        id: image
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: textureSource
        sourceItem: image
        hideSource: !shadowRectangle.softwareRendering
    }

    Kirigami.ShadowedTexture {
        id: shadowRectangle
        anchors.fill: parent
        source: (image.status === Image.Ready && !softwareRendering) ? textureSource : null
        visible: !softwareRendering
    }
}
