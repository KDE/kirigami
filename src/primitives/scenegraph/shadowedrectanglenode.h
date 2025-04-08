/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QColor>
// #include <QSGGeometryNode>
#include <QVector2D>
#include <QVector4D>

#include "shadernode.h"
#include "shadowedrectanglematerial.h"

struct QSGMaterialType;
class ShadowedBorderRectangleMaterial;

/**
 * Scene graph node for a shadowed rectangle.
 *
 * This node will set up the geometry and materials for a shadowed rectangle,
 * optionally with rounded corners.
 *
 * \note You must call updateGeometry() after setting properties of this node,
 * otherwise the node's state will not correctly reflect all the properties.
 *
 * \sa ShadowedRectangle
 */
class ShadowedRectangleNode : public ShaderNode
{
public:
    ShadowedRectangleNode();

    /**
     * Set whether to draw a border.
     *
     * Note that this will switch between a material with or without border.
     * This means this needs to be called before any other setters.
     */
    void setBorderEnabled(bool enabled);

    void setSize(float size);
    void setRadius(const QVector4D &radius);
    void setColor(const QColor &color);
    void setShadowColor(const QColor &color);
    void setOffset(const QVector2D &offset);
    void setBorderWidth(float width);
    void setBorderColor(const QColor &color);
    void setShaderType(ShadowedRectangleMaterial::ShaderType type);

    void update() override;

protected:
    QSGMaterial *createMaterialVariant(QSGMaterialType *variant) override;

    virtual QSGMaterialType *borderMaterialType();
    virtual QSGMaterialType *borderlessMaterialType();

    ShadowedRectangleMaterial::ShaderType m_shaderType = ShadowedRectangleMaterial::ShaderType::Standard;

private:
    float m_size = 0.0;
    QVector2D m_offset = QVector2D{0.0, 0.0};
};
