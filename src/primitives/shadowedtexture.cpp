/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadowedtexture.h"

#include <QQuickWindow>
#include <QSGRectangleNode>
#include <QSGRendererInterface>

#include "scenegraph/shadernode.h"

using namespace Qt::StringLiterals;

ShadowedTexture::ShadowedTexture(QQuickItem *parentItem)
    : ShadowedRectangle(parentItem)
{
}

ShadowedTexture::~ShadowedTexture()
{
}

QQuickItem *ShadowedTexture::source() const
{
    return m_source;
}

void ShadowedTexture::setSource(QQuickItem *newSource)
{
    if (newSource == m_source) {
        return;
    }

    m_source = newSource;
    m_sourceChanged = true;
    if (m_source && !m_source->parentItem()) {
        m_source->setParentItem(this);
    }

    if (!isSoftwareRendering()) {
        update();
    }
    Q_EMIT sourceChanged();
}

QSGNode *ShadowedTexture::updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData *data)
{
    Q_UNUSED(data)

    if (boundingRect().isEmpty()) {
        delete node;
        return nullptr;
    }

    auto shaderNode = static_cast<ShaderNode *>(node);
    if (!shaderNode) {
        shaderNode = new ShaderNode{};
    }

    if (m_source) {
        if (border()->isEnabled()) {
            shaderNode->setShader(u"shadowed_border_texture"_s);
        } else {
            shaderNode->setShader(u"shadowed_texture"_s);
        }
    } else {
        if (border()->isEnabled()) {
            shaderNode->setShader(u"shadowed_border_rectangle"_s);
        } else {
            shaderNode->setShader(u"shadowed_rectangle"_s);
        }
    }

    auto rect = boundingRect();
    auto aspect = calculateAspect(rect);
    auto minDimension = std::min(rect.width(), rect.height());
    auto shadowSize = shadow()->size();
    auto offset = QVector2D{float(shadow()->xOffset()), float(shadow()->yOffset())};

    shaderNode->setRect(adjustRectForShadow(rect, shadowSize, offset, aspect));
    shaderNode->setUniform("aspect", aspect);
    shaderNode->setUniform("size", float(shadowSize / minDimension) * 2.0f);
    shaderNode->setUniform("radius", corners()->toVector4D(radius()) / minDimension);
    shaderNode->setUniform("offset", offset / minDimension);
    shaderNode->setUniformColorPremultiplied("color", color());
    shaderNode->setUniformColorPremultiplied("shadowColor", shadow()->color());
    shaderNode->setUniform("borderWidth", float(border()->width() / minDimension));
    shaderNode->setUniformColorPremultiplied("borderColor", border()->color());

    if (m_source) {
        shaderNode->setTexture(0, m_source->textureProvider());
    }

    shaderNode->update();

    return shaderNode;
}

#include "moc_shadowedtexture.cpp"
