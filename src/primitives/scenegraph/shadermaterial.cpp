/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadermaterial.h"

#include <QSGTexture>
#include <QVariant>

#include "uniformdatastream.h"

using namespace Qt::StringLiterals;

ShaderMaterial::ShaderMaterial(const QString &name)
    : m_name(name)
{
    m_type = typeForName(name);
    setFlag(QSGMaterial::Blending, true);
}

ShaderMaterial::ShaderMaterial(QSGMaterialType *type)
    : m_type(type)
{
    m_name = nameForType(type);
    setFlag(QSGMaterial::Blending, true);
}

QString ShaderMaterial::name() const
{
    return m_name;
}

QSGMaterialShader *ShaderMaterial::createShader(QSGRendererInterface::RenderMode) const
{
    return new ShaderMaterialShader{m_name};
}

QSGMaterialType *ShaderMaterial::type() const
{
    return m_type;
}

int ShaderMaterial::compare(const QSGMaterial *other) const
{
    auto material = static_cast<const ShaderMaterial *>(other);
    if (m_uniformData == material->m_uniformData && m_textures == material->m_textures) {
        return 0;
    }

    return QSGMaterial::compare(other);
}

void ShaderMaterial::setUniformBufferSize(qsizetype size)
{
    if (size == m_uniformData.size()) {
        return;
    }

    m_uniformData = QByteArray{size, '\0'};
}

std::span<char> ShaderMaterial::uniformData()
{
    return std::span(m_uniformData.data(), m_uniformData.size());
}

QSGTexture *ShaderMaterial::texture(int binding)
{
    return m_textures.value(binding, nullptr);
}

void ShaderMaterial::setTexture(int binding, QSGTexture *texture)
{
    m_textures[binding] = texture;
}

QString ShaderMaterial::nameForType(QSGMaterialType *type)
{
    for (auto &[key, value] : s_materialTypes) {
        if (value.get() == type) {
            return key;
        }
    }
    return QString();
}

QSGMaterialType *ShaderMaterial::typeForName(const QString &name)
{
    if (!s_materialTypes.contains(name)) {
        s_materialTypes[name] = std::make_unique<QSGMaterialType>();
    }
    return s_materialTypes[name].get();
}

ShaderMaterialShader::ShaderMaterialShader(const QString &shaderName)
{
    static const auto shaderRoot = QStringLiteral(":/qt/qml/org/kde/kirigami/primitives/shaders/");

    setShaderFileName(Stage::VertexStage, shaderRoot + shaderName + u".vert.qsb");
    setShaderFileName(Stage::FragmentStage, shaderRoot + shaderName + u".frag.qsb");
}

bool ShaderMaterialShader::updateUniformData(RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial)
{
    bool changed = false;

    auto data = state.uniformData()->data();
    auto remainingSize = std::size_t(state.uniformData()->size());

    if (state.isMatrixDirty()) {
        auto matrix = state.combinedMatrix();
        memcpy(data, matrix.data(), sizeof(float) * 16);
        changed = true;
    }
    data += sizeof(float) * 16;
    remainingSize -= sizeof(float) * 16;

    if (state.isOpacityDirty()) {
        auto opacity = state.opacity();
        memcpy(data, &opacity, sizeof(float));
        changed = true;
    }

    data += sizeof(float);
    remainingSize -= sizeof(float);

    if (!oldMaterial || newMaterial->compare(oldMaterial) != 0) {
        const auto uniformData = static_cast<ShaderMaterial *>(newMaterial)->uniformData();
        memcpy(data, uniformData.data() + sizeof(float) * 17, remainingSize);
        changed = true;
    }

    return changed;
}

void ShaderMaterialShader::updateSampledImage(QSGMaterialShader::RenderState &state,
                                              int binding,
                                              QSGTexture **texture,
                                              QSGMaterial *newMaterial,
                                              QSGMaterial *oldMaterial)
{
    Q_UNUSED(oldMaterial);

    auto material = static_cast<ShaderMaterial *>(newMaterial);
    auto source = material->texture(binding);
    if (source) {
        source->setFiltering(QSGTexture::Filtering::Linear);
        source->commitTextureOperations(state.rhi(), state.resourceUpdateBatch());
        *texture = source;
    } else {
        *texture = nullptr;
    }
}
