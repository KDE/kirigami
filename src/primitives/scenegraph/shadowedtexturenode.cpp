/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadowedtexturenode.h"

#include "shadowedbordertexturematerial.h"

template<typename T>
inline void preprocessTexture(QSGMaterial *material, QSGTextureProvider *provider)
{
    auto m = static_cast<T *>(material);
    // Since we handle texture coordinates differently in the shader, we
    // need to remove the texture from the atlas for now.
    if (provider->texture()->isAtlasTexture()) {
        // Blegh, I have no idea why "removedFromAtlas" doesn't just return
        // the texture when it's not an atlas.
        m->textureSource = provider->texture()->removedFromAtlas();
    } else {
        m->textureSource = provider->texture();
    }
    if (QSGDynamicTexture *dynamic_texture = qobject_cast<QSGDynamicTexture *>(m->textureSource)) {
        dynamic_texture->updateTexture();
    }
}

ShadowedTextureNode::ShadowedTextureNode()
    : ShadowedRectangleNode()
{
    setFlag(QSGNode::UsePreprocess);
}

ShadowedTextureNode::~ShadowedTextureNode()
{
    QObject::disconnect(m_textureChangeConnectionHandle);
}

void ShadowedTextureNode::setTextureSource(QSGTextureProvider *source)
{
    if (m_textureSource == source) {
        return;
    }

    if (m_textureSource) {
        m_textureSource->disconnect();
    }

    m_textureSource = source;
    m_textureChangeConnectionHandle = QObject::connect(m_textureSource.data(), &QSGTextureProvider::textureChanged, [this] {
        markDirty(QSGNode::DirtyMaterial);
    });
    markDirty(QSGNode::DirtyMaterial);
}

void ShadowedTextureNode::preprocess()
{
    if (m_textureSource && m_textureSource->texture() && material()) {
        if (materialVariant() == borderlessMaterialType()) {
            preprocessTexture<ShadowedTextureMaterial>(material(), m_textureSource);
        } else {
            preprocessTexture<ShadowedBorderTextureMaterial>(material(), m_textureSource);
        }
    }
}

QSGMaterial *ShadowedTextureNode::createMaterialVariant(QSGMaterialType *variant)
{
    if (variant == &ShadowedTextureMaterial::staticType) {
        return new ShadowedTextureMaterial{};
    } else if (variant == &ShadowedBorderTextureMaterial::staticType) {
        return new ShadowedBorderTextureMaterial{};
    }

    return nullptr;
}

QSGMaterialType *ShadowedTextureNode::borderlessMaterialType()
{
    return &ShadowedTextureMaterial::staticType;
}

QSGMaterialType *ShadowedTextureNode::borderMaterialType()
{
    return &ShadowedBorderTextureMaterial::staticType;
}
