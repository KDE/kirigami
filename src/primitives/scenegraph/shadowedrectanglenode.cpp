/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadowedrectanglenode.h"
#include "shadowedborderrectanglematerial.h"

QColor premultiply(const QColor &color)
{
    return QColor::fromRgbF(color.redF() * color.alphaF(), //
                            color.greenF() * color.alphaF(),
                            color.blueF() * color.alphaF(),
                            color.alphaF());
}

ShadowedRectangleNode::ShadowedRectangleNode()
{
}

void ShadowedRectangleNode::setBorderEnabled(bool enabled)
{
    // We can achieve more performant shaders by splitting the two into separate
    // shaders. This requires separating the materials as well. So when
    // borderWidth is increased to something where the border should be visible,
    // switch to the with-border material. Otherwise use the no-border version.

    if (enabled) {
        setMaterialVariant(borderMaterialType());
    } else {
        setMaterialVariant(borderlessMaterialType());
    }
}

void ShadowedRectangleNode::setSize(float size)
{
    m_size = size;
    setMaterialProperty<ShadowedRectangleMaterial>(&ShadowedRectangleMaterial::size, toUniform(size) * 2.0f);
}

void ShadowedRectangleNode::setRadius(const QVector4D &radius)
{
    auto uniformRadius = toUniform(radius * 2.0f);
    uniformRadius = QVector4D{std::clamp(uniformRadius.x(), 0.0f, 1.0f),
                              std::clamp(uniformRadius.y(), 0.0f, 1.0f),
                              std::clamp(uniformRadius.z(), 0.0f, 1.0f),
                              std::clamp(uniformRadius.w(), 0.0f, 1.0f)};
    setMaterialProperty<ShadowedRectangleMaterial>(&ShadowedRectangleMaterial::radius, uniformRadius);
}

void ShadowedRectangleNode::setColor(const QColor &color)
{
    setMaterialProperty<ShadowedRectangleMaterial>(&ShadowedRectangleMaterial::color, toPremultiplied(color));
}

void ShadowedRectangleNode::setShadowColor(const QColor &color)
{
    setMaterialProperty<ShadowedRectangleMaterial>(&ShadowedRectangleMaterial::shadowColor, toPremultiplied(color));
}

void ShadowedRectangleNode::setOffset(const QVector2D &offset)
{
    m_offset = offset;
    setMaterialProperty<ShadowedRectangleMaterial>(&ShadowedRectangleMaterial::offset, toUniform(offset));
}

void ShadowedRectangleNode::setBorderWidth(float width)
{
    if (materialVariant() != borderMaterialType()) {
        return;
    }

    setMaterialProperty<ShadowedBorderRectangleMaterial>(&ShadowedBorderRectangleMaterial::borderWidth, toUniform(width));
}

void ShadowedRectangleNode::setBorderColor(const QColor &color)
{
    if (materialVariant() != borderMaterialType()) {
        return;
    }

    setMaterialProperty<ShadowedBorderRectangleMaterial>(&ShadowedBorderRectangleMaterial::borderColor, toPremultiplied(color));
}

void ShadowedRectangleNode::setShaderType(ShadowedRectangleMaterial::ShaderType type)
{
    m_shaderType = type;
}

void ShadowedRectangleNode::update()
{
    auto r = rect();

    auto aspect = QVector2D{1.0, 1.0};
    if (r.width() >= r.height()) {
        aspect.setX(r.width() / r.height());
    } else {
        aspect.setY(r.height() / r.width());
    }

    setMaterialProperty<ShadowedRectangleMaterial>(&ShadowedRectangleMaterial::aspect, aspect);

    if (m_shaderType == ShadowedRectangleMaterial::ShaderType::Standard) {
        r = r.adjusted(-m_size * aspect.x(), //
                       -m_size * aspect.y(),
                       m_size * aspect.x(),
                       m_size * aspect.y());

        auto offsetLength = m_offset.length();
        r = r.adjusted(-offsetLength * aspect.x(), //
                       -offsetLength * aspect.y(),
                       offsetLength * aspect.x(),
                       offsetLength * aspect.y());
    }

    QSGGeometry::updateTexturedRectGeometry(geometry(), r, uvs());
    markDirty(QSGNode::DirtyGeometry);
}

QSGMaterial *ShadowedRectangleNode::createMaterialVariant(QSGMaterialType *variant)
{
    if (variant == &ShadowedRectangleMaterial::staticType) {
        return new ShadowedRectangleMaterial{};
    } else if (variant == &ShadowedBorderRectangleMaterial::staticType) {
        return new ShadowedBorderRectangleMaterial{};
    }

    return nullptr;
}

QSGMaterialType *ShadowedRectangleNode::borderlessMaterialType()
{
    return &ShadowedRectangleMaterial::staticType;
}

QSGMaterialType *ShadowedRectangleNode::borderMaterialType()
{
    return &ShadowedBorderRectangleMaterial::staticType;
}
