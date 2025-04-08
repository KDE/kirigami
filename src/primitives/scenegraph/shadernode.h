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

class ShaderMaterial;

/*!
 * A base class for scene graph nodes that want to use a shader to render something.
 */
class ShaderNode : public QSGGeometryNode
{
public:
    using TextureChannel = unsigned char;

    ShaderNode();

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

    void setShader(const QString &shader);

    void setUniform(QAnyStringView name, const QVariant &value);

    void setTextureChannels(unsigned char count);
    void setTexture(TextureChannel channel, const QImage &image, QQuickWindow *window, QQuickWindow::CreateTextureOptions options = {});
    void setTexture(TextureChannel channel, QSGTextureProvider *provider, QQuickWindow::CreateTextureOptions options = {});

    inline void setUniformColorPremultiplied(QAnyStringView name, const QColor &value)
    {
        auto premultiplied = QColor::fromRgbF(value.redF() * value.alphaF(), //
                                              value.greenF() * value.alphaF(),
                                              value.blueF() * value.alphaF(),
                                              value.alphaF());
        setUniform(name, premultiplied);
    }

    /*!
     * Update internal state based on newly-set parameters.
     *
     * This is done as an explicit step to ensure we don't modify expensive GPU
     * resources like geometry multiple times during a single update.
     */
    virtual void update();

protected:
    /*!
     * Create a new instance of a certain material variant.
     *
     * This should return a new instance of the material that matches \p variant,
     * or nullptr if the specified variant cannot be handled by the current node.
     */
    virtual QSGMaterial *createMaterialVariant(QSGMaterialType *variant);

private:
    struct TextureInfo {
        TextureChannel channel = 0;
        QQuickWindow::CreateTextureOptions options;
        std::shared_ptr<QSGTexture> texture = nullptr;
        QPointer<QSGTextureProvider> provider = nullptr;
        QMetaObject::Connection providerConnection;
    };

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
