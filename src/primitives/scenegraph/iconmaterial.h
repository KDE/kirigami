/*
 *  SPDX-FileCopyrightText: 2026 Volodymyr Zolotopupov <zvova7890@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include "shadermaterial.h"

class IconMaterial : public ShaderMaterial
{
public:
    using ShaderMaterial::ShaderMaterial;

protected:
    bool updateRenderStateUniforms(QSGMaterialShader::RenderState &state) override;
};
