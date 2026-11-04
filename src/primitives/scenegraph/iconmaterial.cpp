/*
 *  SPDX-FileCopyrightText: 2026 Volodymyr Zolotopupov <zvova7890@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "iconmaterial.h"

#include <QByteArray>

#include <array>
#include <cstring>

bool IconMaterial::updateRenderStateUniforms(QSGMaterialShader::RenderState &state)
{
    auto *uniformData = state.uniformData();
    auto *data = uniformData->data();
    const auto modelView = state.modelViewMatrix();
    const auto projection = state.projectionMatrix();
    memcpy(data, modelView.constData(), sizeof(float) * 16);
    memcpy(data + sizeof(float) * 28, projection.constData(), sizeof(float) * 16);

    const auto viewport = state.viewportRect();
    const float w = viewport.width();
    const float h = viewport.height();

    const std::array<float, 4> viewportData = {
        w * 0.5f,
        h * 0.5f,
        2.0f / w,
        2.0f / h,
    };

    memcpy(data + sizeof(float) * 24, viewportData.data(), sizeof(viewportData));

    const float dpr = state.devicePixelRatio();
    memcpy(data + sizeof(float) * 44, &dpr, sizeof(dpr));
    return true;
}
