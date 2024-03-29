/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QSGTexture>

#include "shadowedborderrectanglematerial.h"

class ShadowedBorderTextureMaterial : public ShadowedBorderRectangleMaterial
{
public:
    ShadowedBorderTextureMaterial();

    QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;
    QSGMaterialType *type() const override;
    int compare(const QSGMaterial *other) const override;

    QSGTexture *textureSource = nullptr;

    static QSGMaterialType staticType;
};

class ShadowedBorderTextureShader : public ShadowedBorderRectangleShader
{
public:
    ShadowedBorderTextureShader(ShadowedRectangleMaterial::ShaderType shaderType);

    void
    updateSampledImage(QSGMaterialShader::RenderState &state, int binding, QSGTexture **texture, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;
};
