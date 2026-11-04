/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#version 440

layout(std140, binding = 0) uniform buf {
    highp mat4 model_view;
    mediump float opacity;

    mediump float mix_amount;
    mediump float highlight_amount;
    mediump float desaturate_amount;
    mediump vec4 mask_color;
    highp vec2 viewport_half;
    highp vec2 inv_viewport_double;
    highp mat4 projection;
    highp float dpr;
} uniforms;

layout(location = 0) in highp vec4 in_vertex;
layout(location = 1) in mediump vec2 in_uv0;
layout(location = 0) out mediump vec2 uv0;

#ifdef ENABLE_MIX
layout(location = 2) in mediump vec2 in_uv1;
layout(location = 1) out mediump vec2 uv1;
#endif

out gl_PerVertex { vec4 gl_Position; };

void main() {
    uv0 = in_uv0;
#ifdef ENABLE_MIX
    uv1 = in_uv1;
#endif
    // Snap in scene coordinates so resizing the viewport does not change the chosen pixel.
    highp vec4 position = uniforms.model_view * in_vertex;
    position.xy = (floor((position.xy / position.w) * uniforms.dpr + 0.5) / uniforms.dpr) * position.w;
    position = uniforms.projection * position;
    // Keep the final alignment for projections that do not map the DPR exactly to physical pixels.
    highp vec2 pixel = ((position.xy / position.w) * uniforms.viewport_half)
        + uniforms.viewport_half + 0.0001;
    position.xy = (round(pixel) * uniforms.inv_viewport_double - 1.0)
        * position.w;
    gl_Position = position;
}
