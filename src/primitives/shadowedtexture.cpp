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
#include "scenegraph/softwarerectanglenode.h"

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

    if (isSoftwareRendering()) {
        auto rectangleNode = static_cast<SoftwareRectangleNode *>(node);
        if (!rectangleNode) {
            rectangleNode = new SoftwareRectangleNode{};
        }

        rectangleNode->setRect(boundingRect());
        rectangleNode->setWindow(window());
        rectangleNode->setColor(color());
        rectangleNode->setRadius(radius());
        rectangleNode->setBorderWidth(border()->width());
        rectangleNode->setBorderColor(border()->color());

        if (m_source) {
            rectangleNode->setTextureProvider(m_source->textureProvider());
        }

        return rectangleNode;
    }

    auto shaderNode = static_cast<ShaderNode *>(node);
    if (!shaderNode) {
        shaderNode = new ShaderNode{};
    }

    QString shader = u"shadowed"_s;
    if (border()->isEnabled()) {
        shader += u"_border"_s;
    }

    if (m_source) {
        shader += u"_texture"_s;
    } else {
        shader += u"_rectangle"_s;
    }

    if (isLowPowerRendering()) {
        shader += u"_lowpower"_s;
    }

    shaderNode->setShader(shader);
    shaderNode->setUniformBufferSize(sizeof(float) * 40);

    updateShaderNode(shaderNode);

    if (m_source) {
        shaderNode->setTexture(0, m_source->textureProvider());
    }

    shaderNode->update();

    return shaderNode;
}

#include "moc_shadowedtexture.cpp"
