/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "softwarerectanglenode.h"

#include <QPainter>
#include <QSGImageNode>
#include <QSGRendererInterface>

#include "texturecache.h"

SoftwareRectangleNode::SoftwareRectangleNode()
{
    setFlag(QSGNode::UsePreprocess);
}

void SoftwareRectangleNode::setWindow(QQuickWindow *window)
{
    m_window = window;
}

QRectF SoftwareRectangleNode::rect() const
{
    return m_rect;
}

void SoftwareRectangleNode::setRect(const QRectF &rect)
{
    if (rect == m_rect) {
        return;
    }

    m_rect = rect;
    markDirty(QSGNode::DirtyGeometry);
}

void SoftwareRectangleNode::setColor(const QColor &color)
{
    if (color == m_color) {
        return;
    }

    m_color = color;
    markDirty(QSGNode::DirtyMaterial);
}

void SoftwareRectangleNode::setImage(const QImage &image)
{
    if (!m_window) {
        return;
    }

    m_textureInfo = ShaderNode::TextureInfo{
        .channel = 0,
        .options = {},
        .texture = TextureCache::loadTexture(m_window, image),
        .provider = nullptr,
        .providerConnection = {},
    };
}

void SoftwareRectangleNode::setTextureProvider(QSGTextureProvider *provider)
{
    if (!m_window) {
        return;
    }

    m_textureInfo = ShaderNode::TextureInfo{
        .channel = 0,
        .options = {},
        .texture = nullptr,
        .provider = provider,
        .providerConnection = {},
    };
}

void SoftwareRectangleNode::setRadius(qreal radius)
{
    if (qFuzzyCompare(radius, m_radius)) {
        return;
    }

    m_radius = radius;
    markDirty(QSGNode::DirtyMaterial);
}

void SoftwareRectangleNode::setBorderWidth(qreal width)
{
    if (qFuzzyCompare(width, m_borderWidth)) {
        return;
    }

    m_borderWidth = width;
    markDirty(QSGNode::DirtyMaterial);
}

void SoftwareRectangleNode::setBorderColor(const QColor &color)
{
    if (color == m_borderColor) {
        return;
    }

    m_borderColor = color;
    markDirty(QSGNode::DirtyMaterial);
}

QSGRenderNode::RenderingFlags SoftwareRectangleNode::flags() const
{
    return BoundedRectRendering;
}

void SoftwareRectangleNode::preprocess()
{
    QSGTexture *texture = nullptr;
    if (QSGTextureProvider *provider = m_textureInfo.provider) {
        texture = provider->texture();
        if (QSGDynamicTexture *dynamic_texture = qobject_cast<QSGDynamicTexture *>(provider->texture())) {
            dynamic_texture->updateTexture();
        }
    } else if (m_textureInfo.texture) {
        texture = m_textureInfo.texture.get();
    }

    if (texture) {
        if (!m_imageNode) {
            m_imageNode = m_window->createImageNode();
        }

        // The rect will be set in render().
        m_imageNode->setFiltering(QSGTexture::Filtering::Linear);
        m_imageNode->setTexture(texture);

        if (!m_imageNode->parent()) {
            appendChildNode(m_imageNode);
        }
    } else if (m_imageNode) {
        removeChildNode(m_imageNode);
        delete m_imageNode;
        m_imageNode = nullptr;
    }
}

void SoftwareRectangleNode::render(const RenderState *state)
{
    auto painter = static_cast<QPainter *>(m_window->rendererInterface()->getResource(m_window, QSGRendererInterface::PainterResource));
    Q_ASSERT(painter);

    const QRegion *clipRegion = state->clipRegion();
    if (clipRegion && !clipRegion->isEmpty()) {
        painter->setClipRegion(*clipRegion, Qt::ReplaceClip);
    }

    painter->setTransform(matrix()->toTransform());
    painter->setOpacity(inheritedOpacity());
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setPen(Qt::transparent);

    auto radius = std::min(m_radius, std::min(m_rect.width(), m_rect.height()) / 2);
    auto borderWidth = std::floor(m_borderWidth);

    if (borderWidth > 0.0) {
        painter->setBrush(m_borderColor);
        painter->drawRoundedRect(m_rect, radius, radius);
    }

    painter->setBrush(m_color);
    auto adjustedRect = m_rect.adjusted(borderWidth, borderWidth, -borderWidth, -borderWidth);
    painter->drawRoundedRect(adjustedRect, radius - borderWidth, radius - borderWidth);

    if (m_imageNode) {
        static constexpr auto cornerAngle = 0.70710678; // sin(0.25pi)
        auto cornerAdjustment = cornerAngle * (std::sqrt(std::pow(radius, 2.0) * 2.0) - radius + borderWidth);
        auto withoutCorners = m_rect.adjusted(cornerAdjustment, cornerAdjustment, -cornerAdjustment, -cornerAdjustment);
        m_imageNode->setRect(withoutCorners);
    }
}
