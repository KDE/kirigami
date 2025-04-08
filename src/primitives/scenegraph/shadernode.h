/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QSGGeometryNode>
#include <QSGMaterial>
#include <QSGMaterialShader>
#include <QSGTextureProvider>
#include <QVariant>

#include "uniformdatastream.h"

class ShaderMaterial;

/*!
 * A base class for scene graph nodes that want to use a shader to render something.
 */
class ShaderNode : public QSGGeometryNode
{
public:
    using TextureChannel = unsigned char;

    struct TextureInfo {
        TextureChannel channel = 0;
        QQuickWindow::CreateTextureOptions options;
        std::shared_ptr<QSGTexture> texture = nullptr;
        QPointer<QSGTextureProvider> provider = nullptr;
        QMetaObject::Connection providerConnection;
    };

    ShaderNode();
    ~ShaderNode() override;

    void preprocess() override;

    /*!
     * The rectangle describing the geometry of this node.
     */
    QRectF rect() const;
    void setRect(const QRectF &newRect);

    /*!
     * The UV coordinates of the geometry of this node.
     */
    QRectF uvs(TextureChannel channel) const;
    void setUVs(TextureChannel channel, const QRectF &newUvs);

    /*!
     * The variant of the material used for rendering.
     *
     * This will be passed to createMaterialVariant() to perform the actual
     * creation of the material.
     */
    QSGMaterialType *materialVariant() const;
    void setMaterialVariant(QSGMaterialType *variant);

    /*!
     * Set the name of the shader to use for rendering.
     *
     * By default this will create and use an instance of ShaderMaterial that
     * corresponds to the given shader.
     */
    void setShader(const QString &shader);

    /*!
     * Set the size of buffer used by the material for storing uniform values.
     *
     * The given size is in bytes. Note that you should account for all uniforms
     * in your shader's uniform buffer.
     */
    void setUniformBufferSize(qsizetype size);

    /*!
     * A writeable view of the material's uniform data buffer.
     *
     * This can be used in combination with UniformDataStream to write the
     * values of your uniforms.
     */
    std::span<char> uniformData();

    /*!
     * Set the number of texture channels.
     *
     * Each texture channel gets its own set of UV coordinates and texture. By
     * default, the UVs will be set to (0, 0, 1, 1) unless the texture is an
     * atlas texture, in which case coordinates matching the atlas will be used.
     * Use setTexture() to set the texture to use for a channel.
     */
    void setTextureChannels(unsigned char count);

    /*!
     * Set the texture for a channel to an image.
     *
     * This will create a texture from \p image using \p window and the options
     * specified by \p options, then assign it to texture channel \p channel.
     * Textures created from images are cached, if an image has the same cache
     * ID as a previous call to setTexture(), no new texture will be created.
     */
    void setTexture(TextureChannel channel, const QImage &image, QQuickWindow *window, QQuickWindow::CreateTextureOptions options = {});

    /*!
     * Set the texture for a channel to a texture provider.
     *
     * This will use \p provider to provide the texture for channel \p channel.
     * \p options will be used whenever a new texture is created from
     * \p provider.
     */
    void setTexture(TextureChannel channel, QSGTextureProvider *provider, QQuickWindow::CreateTextureOptions options = {});

    /*!
     * Update internal state based on newly-set parameters.
     *
     * This is done as an explicit step to ensure we don't modify expensive GPU
     * resources like geometry multiple times during a single update.
     */
    virtual void update();

    /*!
     * Helper function that returns a pre-multiplied version of a color.
     */
    static inline QColor toPremultiplied(const QColor &value)
    {
        return QColor::fromRgbF(value.redF() * value.alphaF(), //
                                value.greenF() * value.alphaF(),
                                value.blueF() * value.alphaF(),
                                value.alphaF());
    }

protected:
    /*!
     * Create a new instance of a certain material variant.
     *
     * This should return a new instance of the material that matches \p variant,
     * or nullptr if the specified variant cannot be handled by the current node.
     */
    virtual QSGMaterial *createMaterialVariant(QSGMaterialType *variant);

private:
    void preprocessTexture(const TextureInfo &texture);

    QRectF m_rect;
    QVarLengthArray<QRectF, 16> m_uvs;
    bool m_geometryUpdateNeeded = true;
    unsigned char m_textureChannels = 1;

    QSGMaterialType *m_materialVariant = nullptr;
    ShaderMaterial *m_shaderMaterial = nullptr;

    QList<TextureInfo> m_textures;

    QSGGeometry::AttributeSet *m_attributeSet = nullptr;
};
