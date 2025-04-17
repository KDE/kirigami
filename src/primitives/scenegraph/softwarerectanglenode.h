/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QImage>
#include <QQuickWindow>
#include <QSGRenderNode>

#include "shadernode.h"

class ShaderMaterial;

/*!
 * A scene graph node that implements rendering a rectangle with a color and
 * texture for the software renderer.
 */
class SoftwareRectangleNode : public QSGRenderNode
{
public:
    SoftwareRectangleNode();

    void setWindow(QQuickWindow *window);

    QRectF rect() const override;
    void setRect(const QRectF &rect);
    void setColor(const QColor &color);
    void setImage(const QImage &image);
    void setTextureProvider(QSGTextureProvider *provider);
    void setRadius(qreal radius);
    void setBorderWidth(qreal width);
    void setBorderColor(const QColor &color);

    RenderingFlags flags() const override;
    void preprocess() override;
    void render(const RenderState *state) override;

private:
    QQuickWindow *m_window = nullptr;

    QSGImageNode *m_imageNode = nullptr;
    ShaderNode::TextureInfo m_textureInfo;

    QRectF m_rect;
    // QImage m_image;
    qreal m_radius = 0.0;
    qreal m_borderWidth = 0.0;
    QColor m_color = Qt::transparent;
    QColor m_borderColor = Qt::transparent;
};
