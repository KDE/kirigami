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

QList<QPair<QString, QVariant>> ShaderMaterial::uniformData() const
{
    return m_uniformData;
}

bool ShaderMaterial::setUniform(QAnyStringView name, const QVariant &value)
{
    auto itr = std::find_if(m_uniformData.begin(), m_uniformData.end(), [&name](auto entry) {
        return entry.first == name;
    });
    if (itr != m_uniformData.end()) {
        if (itr->second != value) {
            itr->second = value;
            return true;
        }
    } else {
        m_uniformData.append(qMakePair(name.toString(), value));
        return true;
    }

    return false;
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
    return s_materialTypes.key(type, QString{});
}

QSGMaterialType *ShaderMaterial::typeForName(const QString &name)
{
    if (s_materialTypes.contains(name)) {
        return s_materialTypes.value(name);
    } else {
        auto type = new QSGMaterialType{};
        s_materialTypes.insert(name, type);
        return type;
    }
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

    auto uniformData = UniformDataStream(state);

    if (state.isMatrixDirty()) {
        uniformData << state.combinedMatrix();
        changed = true;
    } else {
        uniformData.skip<QMatrix4x4>();
    }

    if (state.isOpacityDirty()) {
        uniformData << state.opacity();
        changed = true;
    } else {
        uniformData.skip<float>();
    }

    if (!oldMaterial || newMaterial->compare(oldMaterial) != 0) {
        const auto material = static_cast<ShaderMaterial *>(newMaterial);

        const auto data = material->uniformData();
        for (auto [_, value] : data) {
            uniformData << value;
        }

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
        source->commitTextureOperations(state.rhi(), state.resourceUpdateBatch());
        *texture = source;
    } else {
        *texture = nullptr;
    }
}
