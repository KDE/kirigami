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
  \badcode
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
  \endcode

  \since Kirigami 5.69
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
      \qmlproperty qreal ShadowedImage::radius

      \brief This propery holds the corner radius of the image.
      \sa ShadowedRectangle::radius
     */
    property alias radius: shadowRectangle.radius

    /*!
      TODO qdoc
      \qmlproperty qreal ShadowedImage::shadow.size
      \qmlproperty qreal ShadowedImage::shadow.size
      \qmlproperty qreal ShadowedImage::shadow.size
      \qmlproperty qreal ShadowedImage::shadow.size

      \brief This property holds shadow's properties group.
      \sa ShadowedRectangle::shadow
     */
    property alias shadow: shadowRectangle.shadow

    /*!
     * TODO qdoc
      \brief This propery holds the border's properties of the image.
      \sa org::kde::kirigami::ShadowedRectangle::border
     */
    property alias border: shadowRectangle.border

    /*!
     * TODO qdoc
      \brief This propery holds the corner radius properties of the image.
      \sa org::kde::kirigami::ShadowedRectangle::corners
      @property ShadowedRectangle::CornersGroup corners
     */
    property alias corners: shadowRectangle.corners

    /*!
      \qmlproperty var ShadowedImage::source
      \brief This propery holds the source of the image.
      \sa QtQuick.Image::source
     */
    property alias source: image.source

    /*!
      \brief This property sets whether this image should be loaded asynchronously.

      Set this to false if you want the main thread to load the image, which
      blocks it until the image is loaded. Setting this to true loads the
      image in a separate thread which is useful when maintaining a responsive
      user interface is more desirable than having images immediately visible.

      \sa QtQuick.Image::asynchronous
      @property bool asynchronous
     */
    property alias asynchronous: image.asynchronous

    /*!
      \brief This property defines what happens when the source image has a different
      size than the item.
      \sa QtQuick.Image::fillMode
      @property int fillMode
     */
    property alias fillMode: image.fillMode

    /*!
      \brief This property holds whether the image uses mipmap filtering when scaled
      or transformed.
      \sa QtQuick.Image::mipmap
      @property bool mipmap
     */
    property alias mipmap: image.mipmap

    /*!
      \brief This property holds the scaled width and height of the full-frame image.
      \sa QtQuick.Image::sourceSize
     */
    property alias sourceSize: image.sourceSize

    /**
     * @brief This property holds the status of image loading.
     * @see QtQuick.Image::status
     * @since 6.5
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
    }
}
