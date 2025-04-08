/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadernode.h"

#include <QSGTextureProvider>
#include <QVariant>

#include "shadermaterial.h"
#include "texturecache.h"

struct VertexLayout {
    using RectPropertyFunction = qreal (QRectF::*)() const;

    RectPropertyFunction x;
    RectPropertyFunction y;
};

static const std::array<VertexLayout, 4> Vertices = {
    VertexLayout{.x = &QRectF::left, .y = &QRectF::top},
    VertexLayout{.x = &QRectF::left, .y = &QRectF::bottom},
    VertexLayout{.x = &QRectF::right, .y = &QRectF::top},
    VertexLayout{.x = &QRectF::right, .y = &QRectF::bottom},
};

ShaderNode::ShaderNode()
    : m_rect(QRectF{0.0, 0.0, 1.0, 1.0})
    , m_uvs(16, QRectF{0.0, 0.0, 1.0, 1.0})
{
    setFlags(QSGNode::OwnsGeometry | QSGNode::OwnsMaterial | QSGNode::UsePreprocess);
}

ShaderNode::~ShaderNode() noexcept
{
    for (auto texture : std::as_const(m_textures)) {
        if (texture.provider) {
            texture.provider->disconnect(texture.providerConnection);
        }
    }
}

void ShaderNode::preprocess()
{
    for (const auto &info : std::as_const(m_textures)) {
        if (info.provider) {
            preprocessTexture(info);
        }
    }
}

QRectF ShaderNode::rect() const
{
    return m_rect;
}

void ShaderNode::setRect(const QRectF &newRect)
{
    if (newRect == m_rect) {
        return;
    }

    m_rect = newRect;
    m_geometryUpdateNeeded = true;
}

QRectF ShaderNode::uvs(TextureChannel channel) const
{
    Q_ASSERT(channel < m_textureChannels);
    return m_uvs[channel];
}

void ShaderNode::setUVs(TextureChannel channel, const QRectF &newUvs)
{
    Q_ASSERT(channel < m_textureChannels);

    if (newUvs == m_uvs[channel]) {
        return;
    }

    m_uvs[channel] = newUvs;
    m_geometryUpdateNeeded = true;
}

QSGMaterialType *ShaderNode::materialVariant() const
{
    return m_materialVariant;
}

void ShaderNode::setMaterialVariant(QSGMaterialType *variant)
{
    if (variant == m_materialVariant) {
        return;
    }

    m_materialVariant = variant;

    auto newMaterial = createMaterialVariant(m_materialVariant);
    if (newMaterial) {
        m_shaderMaterial = dynamic_cast<ShaderMaterial *>(newMaterial);
        setMaterial(newMaterial);
        markDirty(QSGNode::DirtyMaterial);
    }
}

void ShaderNode::setShader(const QString &shader)
{
    setMaterialVariant(ShaderMaterial::typeForName(shader));
}

void ShaderNode::setUniformBufferSize(qsizetype size)
{
    if (!m_shaderMaterial) {
        return;
    }

    m_shaderMaterial->setUniformBufferSize(size);
}

std::span<char> ShaderNode::uniformData()
{
    if (!m_shaderMaterial) {
        return std::span<char>{};
    }

    return m_shaderMaterial->uniformData();
}

void ShaderNode::setTextureChannels(unsigned char count)
{
    if (count == m_textureChannels) {
        return;
    }

    m_textureChannels = std::clamp(count, uint8_t(1), uint8_t(16));

    if (geometry()) {
        setGeometry(nullptr);
        delete[] m_attributeSet->attributes;
        delete m_attributeSet;
    }

    while (m_textures.size() > count) {
        m_textures.removeLast();
    }

    m_geometryUpdateNeeded = true;
}

void ShaderNode::setTexture(TextureChannel channel, const QImage &image, QQuickWindow *window, QQuickWindow::CreateTextureOptions options)
{
    if (!m_shaderMaterial) {
        return;
    }

    auto texture = TextureCache::loadTexture(window, image, options);
    if (!texture) {
        return;
    }

    auto info = TextureInfo{
        .channel = channel,
        .options = options,
        .texture = texture,
        .provider = nullptr,
        .providerConnection = {},
    };

    auto itr = std::find_if(m_textures.begin(), m_textures.end(), [channel](auto info) {
        return info.channel == channel;
    });
    if (itr != m_textures.end()) {
        *itr = info;
    } else {
        m_textures.append(info);
    }

    setUVs(channel, texture->normalizedTextureSubRect());

    m_shaderMaterial->setTexture(channel + 1, texture.get());
    markDirty(QSGNode::DirtyMaterial);
}

void ShaderNode::setTexture(TextureChannel channel, QSGTextureProvider *provider, QQuickWindow::CreateTextureOptions options)
{
    if (!m_shaderMaterial) {
        return;
    }

    auto connection = QObject::connect(provider, &QSGTextureProvider::textureChanged, [this]() {
        markDirty(QSGNode::DirtyMaterial);
    });

    auto info = TextureInfo{
        .channel = channel,
        .options = options,
        .texture = nullptr,
        .provider = provider,
        .providerConnection = connection,
    };

    auto itr = std::find_if(m_textures.begin(), m_textures.end(), [channel](auto info) {
        return info.channel == channel;
    });
    if (itr != m_textures.end()) {
        if (itr->provider) {
            itr->provider->disconnect(itr->providerConnection);
        }
        *itr = info;
    } else {
        m_textures.append(info);
    }
}

void ShaderNode::update()
{
    if (m_geometryUpdateNeeded) {
        const auto attributeCount = 1 + m_textureChannels;

        if (!geometry()) {
            QSGGeometry::Attribute *attributes = new QSGGeometry::Attribute[attributeCount];
            attributes[0] = QSGGeometry::Attribute::createWithAttributeType(0, 2, QSGGeometry::FloatType, QSGGeometry::PositionAttribute);

            for (int i = 0; i < m_textureChannels; ++i) {
                attributes[i + 1] = QSGGeometry::Attribute::createWithAttributeType(i + 1, 2, QSGGeometry::FloatType, QSGGeometry::TexCoordAttribute);
            }

            m_attributeSet =
                new QSGGeometry::AttributeSet{.count = attributeCount, .stride = int(sizeof(float)) * 2 * attributeCount, .attributes = attributes};

            setGeometry(new QSGGeometry{*m_attributeSet, Vertices.size()});
        }

        auto vertices = static_cast<float *>(geometry()->vertexData());

        auto index = 0;
        for (auto layout : Vertices) {
            vertices[index++] = (m_rect.*layout.x)();
            vertices[index++] = (m_rect.*layout.y)();

            for (int channel = 0; channel < m_textureChannels; ++channel) {
                auto uv = uvs(channel);
                vertices[index++] = (uv.*layout.x)();
                vertices[index++] = (uv.*layout.y)();
            }
        }

        markDirty(QSGNode::DirtyGeometry);
        m_geometryUpdateNeeded = false;
    }
}

QSGMaterial *ShaderNode::createMaterialVariant(QSGMaterialType *variant)
{
    return new ShaderMaterial(variant);
}

void ShaderNode::preprocessTexture(const TextureInfo &info)
{
    auto provider = info.provider;
    if (!provider || !m_shaderMaterial) {
        return;
    }

    if (provider->texture()->isAtlasTexture() && !info.options.testFlag(QQuickWindow::TextureCanUseAtlas)) {
        m_shaderMaterial->setTexture(info.channel + 1, provider->texture()->removedFromAtlas());
    } else {
        m_shaderMaterial->setTexture(info.channel + 1, provider->texture());
    }
    if (QSGDynamicTexture *dynamic_texture = qobject_cast<QSGDynamicTexture *>(provider->texture())) {
        dynamic_texture->updateTexture();
    }
}
